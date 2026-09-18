import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/ai_message_model.dart';

/// AI suhbatidagi bitta xabar "pufagi".
///
/// O'quvchi xabari — o'ngda, gradient fon bilan;
/// AI javobi — chapda, och fon va AI ikonkasi bilan.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final AIMessageModel message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final double maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    final Widget bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isUser ? null : AppColors.surface,
        gradient: isUser ? AppColors.primaryGradient : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.sm),
          bottomRight: Radius.circular(isUser ? AppRadius.sm : AppRadius.lg),
        ),
        border: isUser ? null : Border.all(color: AppColors.border),
        boxShadow: isUser ? null : AppShadows.soft,
      ),
      child: Text(
        message.content,
        style: AppTextStyles.body.copyWith(
          color: isUser ? AppColors.onPrimary : AppColors.textPrimary,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isUser) ...<Widget>[
            const AiAvatar(),
            const SizedBox(width: AppSpacing.sm),
          ],
          Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              bubble,
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text(
                  Formatters.time(message.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// AI javoblari yonidagi kichik avatar.
class AiAvatar extends StatelessWidget {
  const AiAvatar({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size * 0.55,
        color: AppColors.primary,
      ),
    );
  }
}
