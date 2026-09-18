import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lesson_model.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/state_views.dart';

/// Haftalik dars jadvali: yuqorida kunlar, pastda shu kundagi darslar.
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  /// 1 = Dushanba ... 7 = Yakshanba
  late int _selectedWeekday = DateTime.now().weekday;

  /// Joriy haftaning dushanbasi.
  DateTime get _weekStart {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map<int, List<LessonModel>>> schedule =
        ref.watch(weeklyScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dars jadvali'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(weeklyScheduleProvider),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            _WeekdaySelector(
              weekStart: _weekStart,
              selected: _selectedWeekday,
              counts: schedule.valueOrNull?.map(
                    (int day, List<LessonModel> l) =>
                        MapEntry<int, int>(day, l.length),
                  ) ??
                  <int, int>{},
              onSelect: (int day) => setState(() => _selectedWeekday = day),
            ),
            Expanded(
              child: schedule.when(
                loading: () => const ShimmerList(itemCount: 4, itemHeight: 104),
                error: (Object e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(weeklyScheduleProvider),
                ),
                data: (Map<int, List<LessonModel>> byDay) {
                  final List<LessonModel> lessons =
                      byDay[_selectedWeekday] ?? <LessonModel>[];

                  if (lessons.isEmpty) {
                    return EmptyView(
                      icon: Icons.free_breakfast_outlined,
                      title: 'Dars yo\'q',
                      message:
                          '${Formatters.weekdaysFull[_selectedWeekday - 1]} '
                          'kuni dars rejalashtirilmagan. Dam oling!',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async =>
                        ref.invalidate(weeklyScheduleProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: lessons.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, int i) => _LessonCard(lesson: lessons[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hafta kunlarini gorizontal tanlash paneli.
class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({
    required this.weekStart,
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  final DateTime weekStart;
  final int selected;
  final Map<int, int> counts;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final int todayWeekday = DateTime.now().weekday;

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, int i) {
          final int weekday = i + 1;
          final DateTime date = weekStart.add(Duration(days: i));
          final bool isSelected = weekday == selected;
          final bool isToday = weekday == todayWeekday;
          final int lessonCount = counts[weekday] ?? 0;

          return GestureDetector(
            onTap: () => onSelect(weekday),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: isSelected ? AppShadows.glow : AppShadows.soft,
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.primary, width: 1.2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Formatters.weekdaysShort[i],
                    style: AppTextStyles.label.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary.withValues(alpha: 0.9)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: AppTextStyles.h3.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lessonCount == 0
                          ? Colors.transparent
                          : isSelected
                              ? AppColors.onPrimary
                              : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Jadvaldagi bitta dars kartasi.
class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final bool isOnline = lesson.format == LessonFormat.online;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                Formatters.time(lesson.startsAt),
                style: AppTextStyles.h3.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.time(lesson.endsAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 3,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.forSubject(lesson.subject),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        lesson.subject,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lesson.isOngoing)
                      const StatusBadge(
                        label: 'Hozir',
                        color: AppColors.success,
                        background: AppColors.successLight,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.topic.isEmpty ? lesson.teacherName : lesson.topic,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Icon(
                      isOnline
                          ? Icons.videocam_outlined
                          : Icons.meeting_room_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.room} · ${lesson.format.label}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lesson.teacherName,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
