import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/student_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/state_views.dart';
import '../shell/main_shell.dart';

/// Profil: shaxsiy ma'lumotlar, statistika va chiqish.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Chiqishni tasdiqlash va sessiyani tozalash.
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Chiqish', style: AppTextStyles.h3),
        content: Text(
          'Hisobdan chiqmoqchimisiz? Keyingi safar PIN kod so\'raladi.',
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
    ref.read(shellTabProvider.notifier).state = 0;

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.phoneLogin,
      (Route<dynamic> r) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<StudentModel> profile = ref.watch(studentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        top: false,
        child: profile.when(
          loading: () => const ShimmerList(itemCount: 4, itemHeight: 110),
          error: (Object e, _) => ErrorView(
            error: e,
            onRetry: () => ref.invalidate(studentProfileProvider),
          ),
          data: (StudentModel s) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              _ProfileHeader(student: s),
              const SizedBox(height: AppSpacing.xl),
              const _ProfileStats(),
              const SizedBox(height: AppSpacing.xl),
              Text('Ma\'lumotlar', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: <Widget>[
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Telefon',
                      value: Formatters.phone(s.phone),
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.groups_outlined,
                      label: 'Guruh',
                      value: s.groupName,
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Filial',
                      value: s.branchName,
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Boshlagan sana',
                      value: Formatters.date(s.enrolledAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Qurilma', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              const _DeviceCard(),
              const SizedBox(height: AppSpacing.xl),
              SecondaryButton(
                label: 'Chiqish',
                icon: Icons.logout_rounded,
                onPressed: () => _logout(context, ref),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  '${AppConstants.appName} · v1.0.0'
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

/// Avatar, ism va daraja.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.student});

  final StudentModel student;

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
                student.initials,
                style: AppTextStyles.h1.copyWith(color: AppColors.onPrimary),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    student.fullName,
                    style:
                        AppTextStyles.h2.copyWith(color: AppColors.onPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.groupName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      '${student.level}-daraja · '
                      '${Formatters.number(student.totalXp)} XP',
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

/// Davomat va baholar statistikasi.
class _ProfileStats extends ConsumerWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<double> attendance = ref.watch(attendanceRateProvider);
    final AsyncValue<int> xp = ref.watch(totalXpProvider);

    return Row(
      children: <Widget>[
        Expanded(
          child: AppCard(
            child: Column(
              children: <Widget>[
                Text(
                  '${((attendance.valueOrNull ?? 0) * 100).round()}%',
                  style: AppTextStyles.h1.copyWith(color: AppColors.success),
                ),
                Text('Davomat', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppCard(
            child: Column(
              children: <Widget>[
                Text(
                  Formatters.number(xp.valueOrNull ?? 0),
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                ),
                Text('Jami XP', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ma'lumot qatori (ikonka + label + qiymat).
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
          Text(label, style: AppTextStyles.bodyMuted),
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

/// Qurilma ID'si — ilova ichida generatsiya qilingan barqaror UUID.
class _DeviceCard extends ConsumerWidget {
  const _DeviceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: ref.watch(secureStorageProvider).readDeviceId(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        return AppCard(
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.smartphone_rounded,
                size: 18,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Device ID', style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(
                      snapshot.data ?? 'Yuklanmoqda...',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
