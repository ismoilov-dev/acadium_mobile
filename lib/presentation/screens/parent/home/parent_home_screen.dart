import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/child_model.dart';
import '../../../../data/models/parent_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../providers/child_payments_provider.dart';
import '../../../providers/children_provider.dart';
import '../../../providers/parent_notification_provider.dart';
import '../../../providers/parent_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/child_switcher.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/state_views.dart';
import '../children/child_detail_screen.dart';
import '../shell/parent_main_shell.dart';

/// Ota-ona bosh sahifasi: tanlangan farzand bo'yicha "bir qarashda" ma'lumot.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(childrenProvider);
    ref.invalidate(selectedChildSummaryProvider);
    ref.invalidate(paymentsProvider);
    ref.invalidate(parentProfileProvider);
    await Future<void>.delayed(AppConstants.fakeShortDelay);
  }

  /// Farzand tafsilotlarini kerakli tabda ochadi.
  void _openDetail(BuildContext context, int tab) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChildDetailScreen(initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ChildModel>> children = ref.watch(childrenProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const _Header(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: children.when(
                loading: () => const AppShimmer(
                  child: Column(
                    children: <Widget>[
                      ShimmerCard(height: 120),
                      SizedBox(height: AppSpacing.md),
                      ShimmerCard(height: 120),
                    ],
                  ),
                ),
                error: (Object e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(childrenProvider),
                ),
                data: (List<ChildModel> items) => items.isEmpty
                    ? const EmptyView(
                        icon: Icons.family_restroom_rounded,
                        title: "Farzand bog'lanmagan",
                        message: 'Markaz administratoriga murojaat qiling.',
                      )
                    : _Summary(onOpenDetail: _openDetail),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient sarlavha: salomlashish, bildirishnoma va farzand switcher.
class _Header extends ConsumerWidget {
  const _Header();

  String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Xayrli tong';
    if (hour < 18) return 'Xayrli kun';
    return 'Xayrli kech';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ParentModel> parent = ref.watch(parentProfileProvider);
    final int unread = ref.watch(parentUnreadCountProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _greeting,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          parent.valueOrNull?.firstName ?? 'Ota-ona',
                          style: AppTextStyles.h1
                              .copyWith(color: AppColors.onPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.onPrimary.withValues(alpha: 0.18),
                          borderRadius: AppRadius.button,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none_rounded),
                          color: AppColors.onPrimary,
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.parentNotifications),
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const ChildSwitcher(dark: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Bir qarashda" kartalar.
class _Summary extends ConsumerWidget {
  const _Summary({required this.onOpenDetail});

  final void Function(BuildContext context, int tab) onOpenDetail;

  /// Bugungi dars holatiga mos rang.
  Color _statusColor(TodayLessonStatus status) {
    switch (status) {
      case TodayLessonStatus.attended:
        return AppColors.success;
      case TodayLessonStatus.late:
        return AppColors.warning;
      case TodayLessonStatus.missed:
        return AppColors.danger;
      case TodayLessonStatus.pending:
        return AppColors.info;
      case TodayLessonStatus.noLesson:
        return AppColors.textTertiary;
    }
  }

  IconData _statusIcon(TodayLessonStatus status) {
    switch (status) {
      case TodayLessonStatus.attended:
        return Icons.check_circle_rounded;
      case TodayLessonStatus.late:
        return Icons.watch_later_rounded;
      case TodayLessonStatus.missed:
        return Icons.cancel_rounded;
      case TodayLessonStatus.pending:
        return Icons.schedule_rounded;
      case TodayLessonStatus.noLesson:
        return Icons.event_busy_rounded;
    }
  }

  /// Karta uchun qisqa matn.
  String _statusValue(TodayLessonStatus status) {
    switch (status) {
      case TodayLessonStatus.attended:
        return 'Keldi';
      case TodayLessonStatus.late:
        return 'Kechikdi';
      case TodayLessonStatus.missed:
        return 'Kelmadi';
      case TodayLessonStatus.pending:
        return 'Kutilmoqda';
      case TodayLessonStatus.noLesson:
        return "Dars yo'q";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ChildSummary> summary =
        ref.watch(selectedChildSummaryProvider);

    return summary.when(
      loading: () => const AppShimmer(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: ShimmerBox(height: 124, radius: AppRadius.lg)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: ShimmerBox(height: 124, radius: AppRadius.lg)),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(child: ShimmerBox(height: 124, radius: AppRadius.lg)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: ShimmerBox(height: 124, radius: AppRadius.lg)),
              ],
            ),
          ],
        ),
      ),
      error: (Object e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(selectedChildSummaryProvider),
      ),
      data: (ChildSummary s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: StatCard(
                  icon: _statusIcon(s.todayStatus),
                  value: _statusValue(s.todayStatus),
                  label: 'Bugungi dars',
                  color: _statusColor(s.todayStatus),
                  onTap: () => onOpenDetail(context, 0),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.assignment_late_outlined,
                  value: '${s.pendingHomework}',
                  label: 'Kutilayotgan vazifa',
                  color: AppColors.warning,
                  onTap: () => onOpenDetail(context, 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: StatCard(
                  icon: Icons.school_outlined,
                  value: '${s.averageGrade.round()}%',
                  label: "O'rtacha baho",
                  color: AppColors.primary,
                  onTap: () => onOpenDetail(context, 2),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.event_available_outlined,
                  value: s.nextLessonAt == null
                      ? '—'
                      : Formatters.time(s.nextLessonAt!),
                  label: s.nextLessonAt == null
                      ? 'Keyingi dars yo\'q'
                      : '${Formatters.relativeDay(s.nextLessonAt!)} · '
                          '${s.nextLessonSubject}',
                  color: AppColors.info,
                  onTap: () => onOpenDetail(context, 3),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _PaymentCard(),
        ],
      ),
    );
  }
}

/// Tanlangan farzandning to'lov holati.
class _PaymentCard extends ConsumerWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PaymentModel>> payments =
        ref.watch(selectedChildPaymentsProvider);

    return payments.when(
      loading: () => const AppShimmer(
        child: ShimmerBox(height: 108, radius: AppRadius.lg),
      ),
      error: (Object e, _) => AppCard(
        child: ErrorView(
          error: e,
          compact: true,
          onRetry: () => ref.invalidate(paymentsProvider),
        ),
      ),
      data: (List<PaymentModel> items) {
        if (items.isEmpty) {
          return const AppCard(
            child: EmptyView(
              icon: Icons.payments_outlined,
              title: "To'lov ma'lumoti yo'q",
            ),
          );
        }

        // Eng muhimi: kechikkan, bo'lmasa muddati yaqin bo'lgani.
        final PaymentModel payment = items.reduce(
            (PaymentModel a, PaymentModel b) =>
                a.status.index >= b.status.index ? a : b);
        final (Color color, Color background) = paymentColors(payment.status);

        return AppCard(
          onTap: () => ref.read(parentTabProvider.notifier).state = 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.payments_rounded, color: color, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("To'lov holati", style: AppTextStyles.label),
                        const SizedBox(height: 2),
                        Text(
                          payment.isFullyPaid
                              ? "To'liq to'langan"
                              : Formatters.money(payment.remainingAmount),
                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: payment.status.label,
                    color: color,
                    background: background,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                payment.isFullyPaid
                    ? 'Keyingi to\'lov: ${Formatters.dayMonth(payment.dueDate)}'
                    : payment.daysLeft < 0
                        ? '${payment.daysLeft.abs()} kun kechikkan'
                        : 'Muddat: ${payment.daysLeft} kun qoldi '
                            '(${Formatters.dayMonth(payment.dueDate)})',
                style: AppTextStyles.caption.copyWith(color: color),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// To'lov holatiga mos ranglar (Payments ekranida ham ishlatiladi).
(Color, Color) paymentColors(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return (AppColors.success, AppColors.successLight);
    case PaymentStatus.due:
      return (AppColors.warning, AppColors.warningLight);
    case PaymentStatus.overdue:
      return (AppColors.danger, AppColors.dangerLight);
  }
}
