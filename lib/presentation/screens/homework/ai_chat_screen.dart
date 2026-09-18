import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/ai_message_model.dart';
import '../../providers/ai_assistant_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/typing_indicator.dart';

/// AI yordamchi bilan suhbat — FAQAT bitta uy vazifasi kontekstida.
///
/// Bu ekran boshqa hech qayerdan ochilmaydi: unga yagona yo'l —
/// vazifa tafsiloti sahifasidagi "AI'dan yordam so'rash" tugmasi.
/// Shu sababli [homeworkId] va [homeworkTitle] majburiy.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({
    super.key,
    required this.homeworkId,
    required this.homeworkTitle,
  });

  final String homeworkId;
  final String homeworkTitle;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final AiChatTarget _target = AiChatTarget(
    homeworkId: widget.homeworkId,
    homeworkTitle: widget.homeworkTitle,
  );

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _controller.text;
    if (text.trim().isEmpty) return;

    _controller.clear();
    await ref.read(aiChatProvider(_target).notifier).sendMessage(text);
    if (mounted) _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final AiChatState state = ref.watch(aiChatProvider(_target));
    final List<AIMessageModel> messages = state.messages;

    // `reverse: true` — ro'yxat doim oxirgi xabarga "yopishib" turadi,
    // shuning uchun qo'lda scroll qilish kerak emas.
    final int extra = state.isTyping ? 1 : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Yordamchi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: _HomeworkChip(title: widget.homeworkTitle),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                itemCount: messages.length + extra,
                itemBuilder: (BuildContext context, int index) {
                  if (state.isTyping && index == 0) {
                    return const TypingIndicator();
                  }
                  final AIMessageModel message =
                      messages[messages.length - 1 - (index - extra)];
                  return ChatBubble(message: message);
                },
              ),
            ),
            if (state.errorMessage != null)
              _ErrorBanner(
                message: state.errorMessage!,
                onClose: () =>
                    ref.read(aiChatProvider(_target).notifier).clearError(),
              ),
            _ChatInputBar(
              controller: _controller,
              focusNode: _focusNode,
              isBusy: state.isTyping,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sarlavha ostidagi chip: suhbat qaysi vazifaga bog'langani.
/// Bu chip OLIB TASHLANMAYDI — kontekst har doim ko'rinib turishi kerak.
class _HomeworkChip extends StatelessWidget {
  const _HomeworkChip({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.chip,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('📎', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  "$title bo'yicha",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Xatolik haqida qisqa xabar (yopish tugmasi bilan).
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
          InkWell(
            onTap: onClose,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastdagi kiritish paneli: matn maydoni + gradient yuborish tugmasi.
class _ChatInputBar extends StatefulWidget {
  const _ChatInputBar({
    required this.controller,
    required this.focusNode,
    required this.isBusy,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isBusy;
  final VoidCallback onSend;

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final bool hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    final bool canSend = _hasText && !widget.isBusy;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'Savolingizni yozing...',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              onSubmitted: (_) {
                if (canSend) widget.onSend();
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _SendButton(enabled: canSend, onTap: widget.onSend),
        ],
      ),
    );
  }
}

/// Gradient fonli dumaloq yuborish tugmasi.
class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: enabled ? AppShadows.glow : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                Icons.send_rounded,
                size: 20,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
