import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/child_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../providers/child_payments_provider.dart';
import '../../../providers/children_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/child_switcher.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../widgets/state_views.dart';
import '../home/parent_home_screen.dart';

/// Barcha farzandlar bo'yicha to'lovlar.
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PaymentModel>> payments = ref.watch(paymentsProvider);
    final List<ChildModel> children =
        ref.watch(childrenProvider).valueOrNull ?? <ChildModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text("To'lovlar"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(paymentsProvider),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: payments.when(
          loading: () => const ShimmerList(itemCount: 3, itemHeight: 150),
          error: (Object e, _) => ErrorView(
            error: e,
            onRetry: () => ref.invalidate(paymentsProvider),
          ),
          data: (List<PaymentModel> items) {
            if (items.isEmpty) {
              return const EmptyView(
                icon: Icons.payments_outlined,
                title: "To'lov yo'q",
                message: "Hozircha to'lov ma'lumotlari mavjud emas.",
              );
            }

            // Farzandlar bo'yicha guruhlaymiz.
            final Map<String, List<PaymentModel>> byChild =
                <String, List<PaymentModel>>{};
            for (final PaymentModel p in items) {
              byChild.putIfAbsent(p.childId, () => <PaymentModel>[]).add(p);
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => ref.invalidate(paymentsProvider),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  const _TotalCard(),
                  const SizedBox(height: AppSpacing.xl),
                  if (children.length > 1) ...<Widget>[
                    const ChildSwitcher(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  for (final MapEntry<String, List<PaymentModel>> entry
                      in byChild.entries) ...<Widget>[
                    SectionHeader(title: entry.value.first.childName),
                    for (final PaymentModel payment in entry.value) ...<Widget>[
                      _PaymentTile(payment: payment),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Umumiy qarzdorlik kartasi.
class _TotalCard extends ConsumerWidget {
  const _TotalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int total = ref.watch(totalDueProvider).valueOrNull ?? 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.glow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    total == 0 ? 'Qarzdorlik' : "To'lanishi kerak",
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      total == 0 ? "To'liq to'langan" : Formatters.money(total),
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Barcha farzandlar bo\'yicha',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                total == 0
                    ? Icons.verified_rounded
                    : Icons.account_balance_wallet_rounded,
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bitta to'lov kartasi.
class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final PaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final (Color color, Color background) = paymentColors(payment.status);

    return AppCard(
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
                      payment.period,
                      style: AppTextStyles.h3.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Muddat: ${Formatters.date(payment.dueDate)}',
                      style: AppTextStyles.caption,
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
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: payment.progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _AmountColumn(
                  label: 'Umumiy',
                  value: Formatters.moneyShort(payment.totalAmount),
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: "To'langan",
                  value: Formatters.moneyShort(payment.paidAmount),
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: 'Qolgan',
                  value: payment.remainingAmount == 0
                      ? '—'
                      : Formatters.moneyShort(payment.remainingAmount),
                  color:
                      payment.remainingAmount == 0 ? AppColors.success : color,
                ),
              ),
            ],
          ),
          if (!payment.isFullyPaid) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Icon(
                  payment.daysLeft < 0
                      ? Icons.error_outline_rounded
                      : Icons.schedule_rounded,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    payment.daysLeft < 0
                        ? '${payment.daysLeft.abs()} kun kechikkan'
                        : '${payment.daysLeft} kun qoldi',
                    style: AppTextStyles.caption.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// To'lov kartasidagi summa ustuni.
class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 10.5)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
