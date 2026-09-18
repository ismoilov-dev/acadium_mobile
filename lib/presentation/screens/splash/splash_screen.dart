import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/auth_models.dart';
import '../../providers/auth_provider.dart';

/// Splash: saqlangan token tekshiriladi va tegishli ekranga o'tkaziladi.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    // Logotip ko'rinib turishi uchun minimal kutish.
    final Future<void> minimumDelay =
        Future<void>.delayed(const Duration(milliseconds: 1200));

    await ref.read(authControllerProvider.notifier).bootstrap();
    await minimumDelay;

    if (!mounted) return;

    // Rolga qarab Student yoki Parent oqimiga o'tkazamiz.
    final AuthState auth = ref.read(authControllerProvider);
    final AuthSession? session = auth.session;

    Navigator.of(context).pushReplacementNamed(
      auth.status == AuthFlowStatus.authenticated && session != null
          ? shellRouteFor(session.role)
          : AppRoutes.phoneLogin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.heroGradient),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _Logo(),
              SizedBox(height: AppSpacing.section),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Acadium logotipi (matnli).
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.onPrimary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 44,
            color: AppColors.onPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          AppConstants.appName,
          style: AppTextStyles.display.copyWith(color: AppColors.onPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppConstants.appTagline,
          style: AppTextStyles.body
              .copyWith(color: AppColors.onPrimary.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}
