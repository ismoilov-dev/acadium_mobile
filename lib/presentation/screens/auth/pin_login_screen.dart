import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pin_input.dart';

/// Mavjud foydalanuvchi uchun PIN kiritish ekrani.
/// Fake rejimda to'g'ri PIN — "1234".
class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _pin = '';

  void _onDigit(String digit) {
    if (_pin.length >= AppConstants.pinLength) return;
    setState(() => _pin += digit);
    ref.read(authControllerProvider.notifier).clearError();

    if (_pin.length == AppConstants.pinLength) {
      Future<void>.delayed(const Duration(milliseconds: 150), _login);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _login() async {
    if (!mounted) return;

    final bool ok =
        await ref.read(authControllerProvider.notifier).loginWithPin(_pin);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.shell, (Route<dynamic> r) => false);
    } else {
      setState(() => _pin = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: <Widget>[
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: AppColors.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('PIN kodni kiriting', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.sm),
              if (auth.phone != null)
                Text(
                  Formatters.phone(auth.phone!),
                  style: AppTextStyles.bodyMuted,
                ),
              const SizedBox(height: AppSpacing.section),
              PinDots(
                length: _pin.length,
                hasError: auth.errorMessage != null,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 20,
                child: auth.errorMessage == null
                    ? null
                    : Text(
                        auth.errorMessage!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.danger),
                        textAlign: TextAlign.center,
                      ),
              ),
              const Spacer(),
              if (auth.isBusy)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xl),
                  child: CircularProgressIndicator(),
                )
              else
                PinKeypad(
                  onDigit: _onDigit,
                  onBackspace: _onBackspace,
                  enabled: !auth.isBusy,
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Boshqa raqam bilan kirish'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
