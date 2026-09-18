import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'chat_bubble.dart';

/// AI "yozayapti" indikatori: uchta nuqta navbatma-navbat ko'tarilib turadi.
///
/// Chat pufagi bilan bir xil ko'rinishda, shuning uchun javob kelganda
/// almashinuv silliq ko'rinadi.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: <Widget>[
          const AiAvatar(),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(AppRadius.sm),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.soft,
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < 3; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: 5),
                    _Dot(progress: _progressFor(i)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Har bir nuqta o'z navbatida (kechikish bilan) ko'tariladi.
  double _progressFor(int index) {
    final double shifted = (_controller.value - index * 0.18) % 1.0;
    // 0 → 1 → 0 egri chizig'i: nuqta ko'tarilib, yana tushadi.
    return shifted < 0.5 ? shifted * 2 : (1 - shifted) * 2;
  }
}

/// Bitta animatsiyalanadigan nuqta.
class _Dot extends StatelessWidget {
  const _Dot({required this.progress});

  /// 0 — pastda va xira, 1 — tepada va to'q.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -3 * progress),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.35 + 0.55 * progress),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
