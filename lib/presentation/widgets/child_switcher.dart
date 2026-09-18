import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/child_model.dart';
import '../providers/children_provider.dart';
import '../providers/selected_child_provider.dart';
import 'loading_shimmer.dart';

/// Farzand almashtirish komponenti.
///
/// Bosilganda pastdan ro'yxat (bottom sheet) ochiladi; tanlangan farzand
/// [selectedChildIdProvider] ga yoziladi va unga bog'liq barcha ekranlar
/// avtomatik yangilanadi. Home va Payments ekranlarida ishlatiladi.
class ChildSwitcher extends ConsumerWidget {
  const ChildSwitcher({super.key, this.dark = false});

  /// Gradient fon ustida ishlatilsa — oq matn.
  final bool dark;

  /// Farzandlar ro'yxatini pastdan ochadi.
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (_) => const _ChildSheet(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ChildModel>> children = ref.watch(childrenProvider);
    final ChildModel? selected = ref.watch(selectedChildProvider);

    if (children.isLoading) {
      return const AppShimmer(
        child: ShimmerBox(width: 200, height: 44, radius: AppRadius.pill),
      );
    }

    final int count = children.valueOrNull?.length ?? 0;
    final Color textColor = dark ? AppColors.onPrimary : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.chip,
        onTap: count <= 1 ? null : () => show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: dark
                ? AppColors.onPrimary.withValues(alpha: 0.16)
                : AppColors.surface,
            borderRadius: AppRadius.chip,
            boxShadow: dark ? null : AppShadows.soft,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Avatar(child: selected, dark: dark),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    selected?.fullName ?? 'Farzand tanlanmagan',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    selected?.groupName ?? '',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: dark
                          ? AppColors.onPrimary.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              if (count > 1)
                Icon(Icons.expand_more_rounded, size: 20, color: textColor),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Farzand avatari (bosh harflar bilan).
class _Avatar extends StatelessWidget {
  const _Avatar({required this.child, this.dark = false, this.size = 34});

  final ChildModel? child;
  final bool dark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark
            ? AppColors.onPrimary.withValues(alpha: 0.22)
            : AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Text(
        child?.initials ?? '?',
        style: AppTextStyles.label.copyWith(
          fontSize: size * 0.36,
          color: dark ? AppColors.onPrimary : AppColors.primary,
        ),
      ),
    );
  }
}

/// Pastdan ochiluvchi farzandlar ro'yxati.
class _ChildSheet extends ConsumerWidget {
  const _ChildSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ChildModel> children =
        ref.watch(childrenProvider).valueOrNull ?? <ChildModel>[];
    final String? selectedId = ref.watch(selectedChildProvider)?.id;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Farzandni tanlang', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            for (final ChildModel child in children)
              _ChildRow(
                child: child,
                isSelected: child.id == selectedId,
                onTap: () {
                  ref.read(selectedChildIdProvider.notifier).state = child.id;
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// Ro'yxatdagi bitta farzand qatori.
class _ChildRow extends StatelessWidget {
  const _ChildRow({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  final ChildModel child;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              children: <Widget>[
                _Avatar(child: child, size: 42),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        child.fullName,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(child.groupName, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
