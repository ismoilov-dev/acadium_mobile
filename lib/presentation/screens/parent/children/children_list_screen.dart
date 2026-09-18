import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/child_model.dart';
import '../../../providers/children_provider.dart';
import '../../../providers/selected_child_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../widgets/state_views.dart';
import 'child_detail_screen.dart';

/// Bog'langan farzandlar ro'yxati.
class ChildrenListScreen extends ConsumerWidget {
  const ChildrenListScreen({super.key});

  /// Farzandni tanlaydi va tafsilot ekranini ochadi.
  void _select(BuildContext context, WidgetRef ref, ChildModel child) {
    ref.read(selectedChildIdProvider.notifier).state = child.id;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChildDetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ChildModel>> children = ref.watch(childrenProvider);
    final String? selectedId = ref.watch(selectedChildProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Farzandlar')),
      body: SafeArea(
        top: false,
        child: children.when(
          loading: () => const ShimmerList(itemCount: 3, itemHeight: 120),
          error: (Object e, _) => ErrorView(
            error: e,
            onRetry: () => ref.invalidate(childrenProvider),
          ),
          data: (List<ChildModel> items) {
            if (items.isEmpty) {
              return const EmptyView(
                icon: Icons.family_restroom_rounded,
                title: "Farzand bog'lanmagan",
                message: 'Markaz administratoriga murojaat qiling.',
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => ref.invalidate(childrenProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, int i) => _ChildCard(
                  child: items[i],
                  isSelected: items[i].id == selectedId,
                  onTap: () => _select(context, ref, items[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Ro'yxatdagi farzand kartasi (mini statistika bilan).
class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  final ChildModel child;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : null,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  child.initials,
                  style: AppTextStyles.h3.copyWith(color: AppColors.onPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      child.fullName,
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child.groupName,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const StatusBadge(
                  label: 'Tanlangan',
                  color: AppColors.primary,
                  background: AppColors.primaryLight,
                )
              else
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStat(
                  icon: Icons.bolt_rounded,
                  label: 'XP',
                  value: Formatters.number(child.totalXp),
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.military_tech_outlined,
                  label: 'Daraja',
                  value: '${child.level}',
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.location_on_outlined,
                  label: 'Filial',
                  value: child.branchName.replaceAll(' filiali', ''),
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartadagi kichik ko'rsatkich.
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(label, style: AppTextStyles.label.copyWith(fontSize: 10.5)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
