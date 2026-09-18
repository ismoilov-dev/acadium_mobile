import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/child_model.dart';
import '../../../../data/models/parent_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/children_provider.dart';
import '../../../providers/parent_provider.dart';
import '../../../providers/selected_child_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../widgets/state_views.dart';
import '../shell/parent_main_shell.dart';

/// Ota-ona profili: shaxsiy ma'lumotlar, farzandlar va chiqish.
class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  /// Chiqish — Student oqimidagi bilan bir xil logika.
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Chiqish', style: AppTextStyles.h3),
        content: Text(
          "Hisobdan chiqmoqchimisiz? Keyingi safar PIN kod so'raladi.",
          style: AppTextStyles.bodyMuted,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(authControllerProvider.notifier).logout();
    ref.read(parentTabProvider.notifier).state = 0;
    ref.read(selectedChildIdProvider.notifier).state = null;

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.phoneLogin,
      (Route<dynamic> r) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ParentModel> profile = ref.watch(parentProfileProvider);
    final List<ChildModel> children =
        ref.watch(childrenProvider).valueOrNull ?? <ChildModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        top: false,
        child: profile.when(
          loading: () => const ShimmerList(itemCount: 3, itemHeight: 120),
          error: (Object e, _) => ErrorView(
            error: e,
            onRetry: () => ref.invalidate(parentProfileProvider),
          ),
          data: (ParentModel p) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              _Header(parent: p),
              const SizedBox(height: AppSpacing.xl),
              Text("Ma'lumotlar", style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: <Widget>[
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Telefon',
                      value: Formatters.phone(p.phone),
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.family_restroom_rounded,
                      label: 'Farzandlar',
                      value: '${p.childrenCount} ta',
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: "Ro'yxatdan o'tgan",
                      value: Formatters.date(p.createdAt),
                    ),
                  ],
                ),
              ),
              if (children.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xl),
                Text('Bog\'langan farzandlar', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < children.length; i++) ...<Widget>[
                        _InfoRow(
                          icon: Icons.school_outlined,
                          label: children[i].fullName,
                          value: children[i].groupName,
                        ),
                        if (i != children.length - 1) const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SecondaryButton(
                label: 'Chiqish',
                icon: Icons.logout_rounded,
                onPressed: () => _logout(context, ref),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  '${AppConstants.appName} · Ota-ona · v1.0.0'
                  '${kUseFakeData ? ' · demo rejim' : ''}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient profil sarlavhasi.
class _Header extends StatelessWidget {
  const _Header({required this.parent});

  final ParentModel parent;

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.onPrimary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Text(
                parent.initials,
                style: AppTextStyles.h1.copyWith(color: AppColors.onPrimary),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    parent.fullName,
                    style:
                        AppTextStyles.h2.copyWith(color: AppColors.onPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ota-ona',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.18),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      '${parent.childrenCount} ta farzand',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ma'lumot qatori.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodyMuted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
