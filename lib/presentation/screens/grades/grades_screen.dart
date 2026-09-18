import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/grade_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/state_views.dart';

/// Baholar va umumiy progress ekrani.
class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(gradesProvider);
    ref.invalidate(gradesBySubjectProvider);
    ref.invalidate(progressProvider);
    ref.invalidate(attendanceProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GradeModel>> grades = ref.watch(gradesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Baholar va progress')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              const _ProgressSection(),
              const SizedBox(height: AppSpacing.xl),
              const _SubjectSection(),
              const SizedBox(height: AppSpacing.xl),
              Text('Barcha baholar', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              grades.when(
                loading: () => const AppShimmer(
                  child: Column(
                    children: <Widget>[
                      ShimmerCard(height: 78),
                      SizedBox(height: AppSpacing.md),
                      ShimmerCard(height: 78),
                      SizedBox(height: AppSpacing.md),
                      ShimmerCard(height: 78),
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
                data: (List<GradeModel> items) => items.isEmpty
                    ? const AppCard(
                        child: EmptyView(
                          icon: Icons.grade_outlined,
                          title: 'Baholar yo\'q',
                          message: 'Hali birorta baho qo\'yilmagan.',
                        ),
                      )
                    : Column(
                        children: <Widget>[
                          for (final GradeModel g in items) ...<Widget>[
                            GradeTile(grade: g),
                            const SizedBox(height: AppSpacing.md),
                          ],
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

/// Umumiy progress: davomat %, uy vazifasi %, testlar %.
class _ProgressSection extends ConsumerWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ProgressSummary> progress = ref.watch(progressProvider);

    return progress.when(
      loading: () => const AppShimmer(
        child: ShimmerBox(height: 210, radius: AppRadius.lg),
      ),
      error: (Object e, _) => AppCard(
        child: ErrorView(
          error: e,
          compact: true,
          onRetry: () => ref.invalidate(progressProvider),
        ),
      ),
      data: (ProgressSummary p) => AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Umumiy progress', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${(p.overall * 100).round()}%',
                        style: AppTextStyles.display,
                      ),
                      Text(
                        'Kursning o\'zlashtirish darajasi',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 74,
                  height: 74,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 74,
                        height: 74,
                        child: CircularProgressIndicator(
                          value: p.overall,
                          strokeWidth: 8,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            ProgressRow(
              label: 'Davomat',
              value: p.attendance,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.lg),
            ProgressRow(
              label: 'Uy vazifalari',
              value: p.homework,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.lg),
            ProgressRow(
              label: 'Testlar',
              value: p.tests,
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }
}

/// Fanlar bo'yicha o'rtacha ko'rsatkichlar.
class _SubjectSection extends ConsumerWidget {
  const _SubjectSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SubjectGrades>> subjects =
        ref.watch(gradesBySubjectProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Fanlar bo\'yicha', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        subjects.when(
          loading: () => const AppShimmer(
            child: Column(
              children: <Widget>[
                ShimmerCard(height: 84),
                SizedBox(height: AppSpacing.md),
                ShimmerCard(height: 84),
              ],
            ),
          ),
          error: (Object e, _) => AppCard(
            child: ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(gradesBySubjectProvider),
            ),
          ),
          data: (List<SubjectGrades> items) => items.isEmpty
              ? const AppCard(
                  child: EmptyView(
                    icon: Icons.menu_book_outlined,
                    title: 'Ma\'lumot yo\'q',
                    message: 'Fanlar bo\'yicha statistika hali shakllanmagan.',
                  ),
                )
              : Column(
                  children: <Widget>[
                    for (final SubjectGrades s in items) ...<Widget>[
                      _SubjectCard(subject: s),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

/// Bitta fan bo'yicha o'rtacha natija kartasi.
class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final SubjectGrades subject;

  @override
  Widget build(BuildContext context) {
    final double avg = subject.averagePercent;
    final Color color = AppColors.forSubject(subject.subject);

    return AppCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SubjectAvatar(subject: subject.subject, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      subject.subject,
                      style: AppTextStyles.h3.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${subject.grades.length} ta baho',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                '${avg.round()}%',
                style: AppTextStyles.h2.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: avg / 100,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ro'yxatdagi bitta baho (Home ekranida ham ishlatiladi).
class GradeTile extends StatelessWidget {
  const GradeTile({super.key, required this.grade});

  final GradeModel grade;

  /// Foizga qarab rang: yashil / sariq / qizil.
  Color get _scoreColor {
    if (grade.percent >= 85) return AppColors.success;
    if (grade.percent >= 65) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          SubjectAvatar(subject: grade.subject, size: 42),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  grade.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${grade.subject} · ${grade.type.label} · '
                  '${Formatters.dayMonth(grade.gradedAt)}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _scoreColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              '${grade.score}',
              style: AppTextStyles.h3.copyWith(
                color: _scoreColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
