import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/attendance_model.dart';
import '../../../../data/models/child_model.dart';
import '../../../../data/models/grade_model.dart';
import '../../../../data/models/homework_model.dart';
import '../../../../data/models/lesson_model.dart';
import '../../../providers/child_attendance_provider.dart';
import '../../../providers/child_grades_provider.dart';
import '../../../providers/child_homework_provider.dart';
import '../../../providers/selected_child_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../widgets/state_views.dart';
import '../../grades/grades_screen.dart';
import '../../homework/homework_list_screen.dart';
import '../../schedule/schedule_screen.dart';

/// Tanlangan farzand bo'yicha to'liq ko'rinish.
/// Ichki TabBar: Davomat, Homework, Baholar, Jadval.
class ChildDetailScreen extends ConsumerWidget {
  const ChildDetailScreen({super.key, this.initialTab = 0});

  /// Qaysi tab ochiq bo'lishi (Home kartalaridan o'tishda ishlatiladi).
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChildModel? child = ref.watch(selectedChildProvider);

    return DefaultTabController(
      length: 4,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(title: Text(child?.fullName ?? 'Farzand')),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              if (child != null) _ChildHeader(child: child),
              const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: <Widget>[
                  Tab(text: 'Davomat'),
                  Tab(text: 'Vazifalar'),
                  Tab(text: 'Baholar'),
                  Tab(text: 'Jadval'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: <Widget>[
                    _AttendanceTab(),
                    _HomeworkTab(),
                    _GradesTab(),
                    _ScheduleTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Farzand haqida qisqa ma'lumot (tablar tepasida).
class _ChildHeader extends StatelessWidget {
  const _ChildHeader({required this.child});

  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Text(
                child.initials,
                style: AppTextStyles.label
                    .copyWith(color: AppColors.onPrimary, fontSize: 15),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    child.groupName,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${child.branchName} · ${child.level}-daraja',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                const Icon(Icons.bolt_rounded,
                    size: 16, color: AppColors.secondary),
                Text(
                  Formatters.number(child.totalXp),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- 1. Davomat

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AttendanceModel>> attendance =
        ref.watch(childAttendanceProvider);

    return attendance.when(
      loading: () => const ShimmerList(itemCount: 5, itemHeight: 76),
      error: (Object e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(childAttendanceProvider),
      ),
      data: (List<AttendanceModel> items) {
        if (items.isEmpty) {
          return const EmptyView(
            icon: Icons.how_to_reg_outlined,
            title: "Davomat ma'lumoti yo'q",
          );
        }

        final int attended =
            items.where((AttendanceModel a) => a.countsAsAttended).length;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(childAttendanceProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              AppCard(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Davomat ko\'rsatkichi',
                              style: AppTextStyles.label),
                          const SizedBox(height: 2),
                          Text(
                            '${(attended / items.length * 100).round()}%',
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$attended / ${items.length} dars',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final AttendanceModel a in items) ...<Widget>[
                _AttendanceTile(attendance: a),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Bitta davomat yozuvi.
class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.attendance});

  final AttendanceModel attendance;

  (Color, Color, IconData) get _style {
    switch (attendance.status) {
      case AttendanceStatus.present:
        return (
          AppColors.success,
          AppColors.successLight,
          Icons.check_circle_rounded
        );
      case AttendanceStatus.late:
        return (
          AppColors.warning,
          AppColors.warningLight,
          Icons.watch_later_rounded
        );
      case AttendanceStatus.absent:
        return (AppColors.danger, AppColors.dangerLight, Icons.cancel_rounded);
      case AttendanceStatus.excused:
        return (AppColors.info, AppColors.infoLight, Icons.info_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color color, Color background, IconData icon) = _style;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  attendance.subject,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attendance.note == null
                      ? Formatters.dayMonth(attendance.date)
                      : '${Formatters.dayMonth(attendance.date)} · '
                          '${attendance.note}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: attendance.status.label,
            color: color,
            background: background,
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- 2. Vazifalar

class _HomeworkTab extends ConsumerWidget {
  const _HomeworkTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<HomeworkModel>> homework =
        ref.watch(childHomeworkProvider);

    return homework.when(
      loading: () => const ShimmerList(itemCount: 4, itemHeight: 112),
      error: (Object e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(childHomeworkProvider),
      ),
      data: (List<HomeworkModel> items) => items.isEmpty
          ? const EmptyView(
              icon: Icons.task_alt_rounded,
              title: "Vazifa yo'q",
              message: 'Hozircha uy vazifasi berilmagan.',
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => ref.invalidate(childHomeworkProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                // readOnly: ota-ona vazifani topshira olmaydi, faqat ko'radi.
                itemBuilder: (_, int i) =>
                    HomeworkTile(homework: items[i], readOnly: true),
              ),
            ),
    );
  }
}

// --------------------------------------------------------------- 3. Baholar

class _GradesTab extends ConsumerWidget {
  const _GradesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GradeModel>> grades = ref.watch(childGradesProvider);

    return grades.when(
      loading: () => const ShimmerList(itemCount: 5, itemHeight: 78),
      error: (Object e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(childGradesProvider),
      ),
      data: (List<GradeModel> items) {
        if (items.isEmpty) {
          return const EmptyView(
            icon: Icons.grade_outlined,
            title: "Baholar yo'q",
          );
        }

        final double average = items.fold<double>(
              0,
              (double acc, GradeModel g) => acc + g.percent,
            ) /
            items.length;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(childGradesProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              AppCard(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("O'rtacha baho", style: AppTextStyles.label),
                          const SizedBox(height: 2),
                          Text(
                            '${average.round()}%',
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    Text('${items.length} ta baho',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final GradeModel g in items) ...<Widget>[
                GradeTile(grade: g),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- 4. Jadval

class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<int, List<LessonModel>>> schedule =
        ref.watch(childScheduleProvider);

    return schedule.when(
      loading: () => const ShimmerList(itemCount: 4, itemHeight: 104),
      error: (Object e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(childScheduleProvider),
      ),
      data: (Map<int, List<LessonModel>> byDay) {
        if (byDay.isEmpty) {
          return const EmptyView(
            icon: Icons.event_busy_outlined,
            title: "Jadval yo'q",
            message: 'Bu hafta uchun dars rejalashtirilmagan.',
          );
        }

        final List<int> days = byDay.keys.toList()..sort();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(childScheduleProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              for (final int day in days) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    Formatters.weekdaysFull[day - 1],
                    style: AppTextStyles.h3.copyWith(fontSize: 15),
                  ),
                ),
                for (final LessonModel lesson in byDay[day]!) ...<Widget>[
                  LessonCard(lesson: lesson),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }
}
