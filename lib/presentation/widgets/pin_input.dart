import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Kiritilgan PIN uzunligini nuqtalar bilan ko'rsatadi.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    this.hasError = false,
    this.total = AppConstants.pinLength,
  });

  final int length;
  final bool hasError;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(total, (int i) {
        final bool filled = i < length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          width: filled ? 18 : 16,
          height: filled ? 18 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? AppColors.danger
                : filled
                    ? AppColors.primary
                    : AppColors.border,
          ),
        );
      }),
    );
  }
}

/// Raqamli klaviatura (0-9, o'chirish).
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const List<String> keys = <String>[
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'back',
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.7,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.lg,
      children: keys.map((String key) {
        if (key.isEmpty) return const SizedBox.shrink();

        final bool isBackspace = key == 'back';
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: !enabled
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    isBackspace ? onBackspace() : onDigit(key);
                  },
            child: Center(
              child: isBackspace
                  ? const Icon(
                      Icons.backspace_outlined,
                      color: AppColors.textSecondary,
                    )
                  : Text(
                      key,
                      style: AppTextStyles.h1.copyWith(fontSize: 26),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
