import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/xp_model.dart';
import '../../providers/arena_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/homework_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';
import '../grades/grades_screen.dart';
import '../shell/main_shell.dart';

/// Bosh sahifa: salomlashish, keyingi dars, XP, kutilayotgan vazifalar,
/// oxirgi baholar.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Pull-to-refresh: barcha bosh sahifa provider'larini qayta yuklaydi.
  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(studentProfileProvider);
    ref.invalidate(nextLessonProvider);
    ref.invalidate(homeworkListProvider);
    ref.invalidate(gradesProvider);
    ref.invalidate(totalXpProvider);
    ref.invalidate(attendanceProvider);
    ref.invalidate(leaderboardProvider);
    await Future<void>.delayed(AppConstants.fakeShortDelay);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<StudentModel> profile = ref.watch(studentProfileProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.section,
            ),
            children: <Widget>[
              _Header(profile: profile),
              const SizedBox(height: AppSpacing.xl),
              const _XpSection(),
              const SizedBox(height: AppSpacing.xl),
              const _NextLessonSection(),
              const SizedBox(height: AppSpacing.xl),
              const _QuickStats(),
              const SizedBox(height: AppSpacing.xl),
              const _RecentGrades(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Salomlashish + avatar + bildirishnoma tugmasi.
class _Header extends ConsumerWidget {
  const _Header({required this.profile});

  final AsyncValue<StudentModel> profile;

  /// Kun vaqtiga qarab salomlashish matni.
  String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Xayrli tong';
    if (hour < 18) return 'Xayrli kun';
    return 'Xayrli kech';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int unread = ref.watch(unreadNotificationsCountProvider);

    return Row(
      children: <Widget>[
        Expanded(
          child: profile.when(
            loading: () => const AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ShimmerBox(width: 100, height: 12),
                  SizedBox(height: AppSpacing.sm),
                  ShimmerBox(width: 180, height: 20),
                ],
              ),
            ),
            error: (Object e, _) => Text(
              'Salom!',
              style: AppTextStyles.h2,
            ),
            data: (StudentModel s) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_greeting, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  '${s.firstName} 👋',
                  style: AppTextStyles.h1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        _NotificationButton(unread: unread),
      ],
    );
  }
}

/// Bildirishnomalar tugmasi (o'qilmaganlar soni bilan).
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.button,
            boxShadow: AppShadows.soft,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.textPrimary,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: AppRadius.chip,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
              child: Text(
                '$unread',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// XP kartasi + reytingdagi o'rin.
class _XpSection extends ConsumerWidget {
  const _XpSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> xp = ref.watch(totalXpProvider);
    final AsyncValue<LeaderboardEntry?> rank = ref.watch(myRankProvider);

    final LeaderboardEntry? myRank = rank.valueOrNull;

    return xp.when(
      loading: () => const AppShimmer(
        child: ShimmerBox(height: 128, radius: AppRadius.lg),
      ),
      error: (Object e, _) => AppCard(
        child: ErrorView(
          error: e,
          compact: true,
          onRetry: () => ref.invalidate(totalXpProvider),
        ),
      ),
      data: (int value) => XpHeroCard(
        xp: Formatters.number(value),
        subtitle: 'Bilimingiz uchun to\'plangan ballar',
        rankLabel: myRank == null ? null : '${myRank.rank}-o\'rin',
        onTap: () => ref.read(shellTabProvider.notifier).state = 3,
      ),
    );
  }
}

/// Keyingi dars kartasi (countdown bilan).
class _NextLessonSection extends ConsumerWidget {
  const _NextLessonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LessonModel?> lesson = ref.watch(nextLessonProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: 'Keyingi dars',
          actionLabel: 'Jadval',
          onAction: () => ref.read(shellTabProvider.notifier).state = 1,
        ),
        lesson.when(
          loading: () => const AppShimmer(
              child: ShimmerBox(height: 120, radius: AppRadius.lg)),
          error: (Object e, _) => AppCard(
            child: ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(nextLessonProvider),
            ),
          ),
          data: (LessonModel? value) => value == null
              ? const AppCard(
                  child: EmptyView(
                    icon: Icons.event_available_rounded,
                    title: 'Darslar tugadi',
                    message: 'Bu hafta uchun rejalashtirilgan dars qolmadi.',
                  ),
                )
              : _NextLessonCard(lesson: value),
        ),
      ],
    );
  }
}

/// Har soniyada yangilanadigan countdown'li dars kartasi.
class _NextLessonCard extends StatefulWidget {
  const _NextLessonCard({required this.lesson});

  final LessonModel lesson;

  @override
  State<_NextLessonCard> createState() => _NextLessonCardState();
}

class _NextLessonCardState extends State<_NextLessonCard> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.lesson.startsAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = widget.lesson.startsAt.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LessonModel lesson = widget.lesson;
    final bool isOngoing = lesson.isOngoing;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SubjectAvatar(subject: lesson.subject),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      lesson.subject,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.teacherName,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: lesson.format.label,
                color: lesson.format == LessonFormat.online
                    ? AppColors.info
                    : AppColors.success,
                background: lesson.format == LessonFormat.online
                    ? AppColors.infoLight
                    : AppColors.successLight,
                icon: lesson.format == LessonFormat.online
                    ? Icons.videocam_rounded
                    : Icons.meeting_room_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: _LessonMeta(
                  icon: Icons.schedule_rounded,
                  label: Formatters.relativeDay(lesson.startsAt),
                  value: Formatters.timeRange(lesson.startsAt, lesson.endsAt),
                ),
              ),
              Expanded(
                child: _LessonMeta(
                  icon: Icons.place_outlined,
                  label: 'Joy',
                  value: lesson.room,
                ),
              ),
              Expanded(
                child: _LessonMeta(
                  icon: isOngoing
                      ? Icons.play_circle_fill_rounded
                      : Icons.hourglass_bottom_rounded,
                  label: isOngoing ? 'Holat' : 'Boshlanishiga',
                  value: isOngoing
                      ? 'Davom etmoqda'
                      : Formatters.countdown(_remaining),
                  highlight: true,
                ),
              ),
            ],
          ),
          if (lesson.topic.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'Mavzu: ${lesson.topic}',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.primaryDark),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dars kartasidagi kichik ma'lumot ustuni.
class _LessonMeta extends StatelessWidget {
  const _LessonMeta({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.label.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Kutilayotgan vazifalar va davomat foizi.
class _QuickStats extends ConsumerWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> pending = ref.watch(pendingHomeworkCountProvider);
    final AsyncValue<double> attendance = ref.watch(attendanceRateProvider);

    if (pending.isLoading || attendance.isLoading) {
      return const AppShimmer(
        child: Row(
          children: <Widget>[
            Expanded(child: ShimmerBox(height: 120, radius: AppRadius.lg)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: ShimmerBox(height: 120, radius: AppRadius.lg)),
          ],
        ),
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: StatCard(
            icon: Icons.assignment_late_outlined,
            value: '${pending.valueOrNull ?? 0}',
            label: 'Kutilayotgan uy vazifasi',
            color: AppColors.warning,
            onTap: () => ref.read(shellTabProvider.notifier).state = 2,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatCard(
            icon: Icons.how_to_reg_outlined,
            value: '${((attendance.valueOrNull ?? 0) * 100).round()}%',
            label: 'Davomat ko\'rsatkichi',
            color: AppColors.success,
            onTap: () => Navigator.of(context).push(gradesRoute()),
          ),
        ),
      ],
    );
  }
}

/// Oxirgi 3 ta baho.
class _RecentGrades extends ConsumerWidget {
  const _RecentGrades();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GradeModel>> grades = ref.watch(gradesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: 'Oxirgi baholar',
          actionLabel: 'Barchasi',
          onAction: () => Navigator.of(context).push(gradesRoute()),
        ),
        grades.when(
          loading: () => const AppShimmer(
            child: Column(
              children: <Widget>[
                ShimmerCard(height: 74),
                SizedBox(height: AppSpacing.md),
                ShimmerCard(height: 74),
              ],
            ),
          ),
          error: (Object e, _) => AppCard(
            child: ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(gradesProvider),
            ),
          ),
          data: (List<GradeModel> items) {
            if (items.isEmpty) {
              return const AppCard(
                child: EmptyView(
                  icon: Icons.grade_outlined,
                  title: 'Baholar yo\'q',
                  message: 'Birinchi bahoyingiz shu yerda ko\'rinadi.',
                ),
              );
            }
            final List<GradeModel> recent = items.take(3).toList();
            return Column(
              children: <Widget>[
                for (final GradeModel g in recent) ...<Widget>[
                  GradeTile(grade: g),
                  if (g != recent.last) const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
