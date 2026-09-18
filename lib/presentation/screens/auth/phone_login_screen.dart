import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phone_input_formatter.dart';
import '../../../data/models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';

/// 1-qadam: telefon raqam kiritish.
///
/// Fake rejimda to'g'ri formatdagi har qanday raqam qabul qilinadi.
/// Raqam JUFT bilan tugasa — PIN o'rnatish, TOQ bilan tugasa — PIN kiritish.
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final bool valid = _digits.length == AppConstants.phoneDigits;
    if (valid != _isValid) setState(() => _isValid = valid);
  }

  String get _digits => _controller.text.replaceAll(RegExp(r'\D'), '');

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final String phone = '${AppConstants.phonePrefix}$_digits';
    final PhoneCheckResult? result =
        await ref.read(authControllerProvider.notifier).checkPhone(phone);

    if (!mounted || result == null) return;

    Navigator.of(context).pushNamed(
      result.isRegistered ? AppRoutes.pinLogin : AppRoutes.pinSetup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: AppSpacing.section),
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.glow,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.onPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Xush kelibsiz!', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Davom etish uchun telefon raqamingizni kiriting. '
                'Raqam markazda ro\'yxatdan o\'tgan bo\'lishi kerak.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.section),
              Text('Telefon raqam', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                autofocus: true,
                style: AppTextStyles.h3,
                inputFormatters: <TextInputFormatter>[PhoneInputFormatter()],
                decoration: InputDecoration(
                  hintText: '90 123 45 67',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.sm,
                    ),
                    child: Text(
                      AppConstants.phonePrefix,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                  errorText: auth.errorMessage,
                ),
                onSubmitted: (_) => _isValid ? _submit() : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              GradientButton(
                label: 'Davom etish',
                icon: Icons.arrow_forward_rounded,
                enabled: _isValid,
                isLoading: auth.isBusy,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FakeModeHint(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fake rejim qoidalarini eslatuvchi maslahat bloki.
/// Real API'ga ulangandan keyin bu vidjet olib tashlanadi.
class _FakeModeHint extends StatelessWidget {
  const _FakeModeHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.info),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Demo rejim: raqam JUFT bilan tugasa — PIN o\'rnatish, '
              'TOQ bilan tugasa — PIN kiritish oynasi ochiladi. '
              'Mavjud foydalanuvchi uchun PIN: 1234',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
