import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pin_input.dart';

/// Birinchi marta kirish: 4 xonali PIN o'rnatish va uni tasdiqlash.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

/// PIN o'rnatish bosqichlari.
enum _SetupStage { create, confirm }

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  _SetupStage _stage = _SetupStage.create;
  String _firstPin = '';
  String _secondPin = '';
  String? _error;

  String get _current =>
      _stage == _SetupStage.create ? _firstPin : _secondPin;

  void _onDigit(String digit) {
    if (_current.length >= AppConstants.pinLength) return;

    setState(() {
      _error = null;
      if (_stage == _SetupStage.create) {
        _firstPin += digit;
      } else {
        _secondPin += digit;
      }
    });

    if (_current.length == AppConstants.pinLength) {
      Future<void>.delayed(const Duration(milliseconds: 150), _onFilled);
    }
  }

  void _onBackspace() {
    if (_current.isEmpty) return;
    setState(() {
      _error = null;
      if (_stage == _SetupStage.create) {
        _firstPin = _firstPin.substring(0, _firstPin.length - 1);
      } else {
        _secondPin = _secondPin.substring(0, _secondPin.length - 1);
      }
    });
  }

  Future<void> _onFilled() async {
    if (!mounted) return;

    if (_stage == _SetupStage.create) {
      setState(() => _stage = _SetupStage.confirm);
      return;
    }

    if (_firstPin != _secondPin) {
      setState(() {
        _error = 'PIN kodlar mos kelmadi. Qaytadan kiriting.';
        _stage = _SetupStage.create;
        _firstPin = '';
        _secondPin = '';
      });
      return;
    }

    final bool ok =
        await ref.read(authControllerProvider.notifier).setupPin(_firstPin);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.shell, (Route<dynamic> r) => false);
    } else {
      setState(() {
        _stage = _SetupStage.create;
        _firstPin = '';
        _secondPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    final bool isConfirm = _stage == _SetupStage.confirm;
    final String? error = _error ?? auth.errorMessage;

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
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                isConfirm ? 'PIN kodni tasdiqlang' : 'PIN kod o\'rnating',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                isConfirm
                    ? 'Xuddi shu 4 ta raqamni qayta kiriting'
                    : 'Ilovaga tez kirish uchun 4 xonali kod o\'ylab toping',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              if (auth.phone != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Formatters.phone(auth.phone!),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.section),
              PinDots(length: _current.length, hasError: error != null),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 20,
                child: error == null
                    ? null
                    : Text(
                        error,
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
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
