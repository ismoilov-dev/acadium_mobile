import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/homework_model.dart';
import '../../providers/homework_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/homework_status_badge.dart';
import 'ai_chat_screen.dart';

/// Uy vazifasi tafsilotlari va topshirish oqimi.
class HomeworkDetailScreen extends ConsumerWidget {
  const HomeworkDetailScreen({super.key, required this.homework});

  final HomeworkModel homework;

  /// Topshirish oynasini (bottom sheet) ochadi.
  Future<void> _openSubmitSheet(BuildContext context, WidgetRef ref) async {
    ref.read(homeworkSubmitProvider.notifier).reset();

    final bool? submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SubmitSheet(homework: homework),
    );

    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vazifa topshirildi ✅')),
      );
      Navigator.of(context).pop();
    }
  }

  /// AI yordamchini AYNAN shu vazifa konteksti bilan ochadi.
  /// Chat ekraniga yagona kirish nuqtasi — shu metod.
  void _openAiChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AiChatScreen(
          homeworkId: homework.id,
          homeworkTitle: homework.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(homework.subject)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Row(
              children: <Widget>[
                HomeworkStatusBadge(status: homework.status),
                const Spacer(),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    Text(
                      '+${homework.xpReward} XP',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(homework.title, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.person_outline_rounded,
                  size: 15,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(homework.teacherName, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Muddat kartasi
            AppCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _MetaColumn(
                      label: 'Berilgan',
                      value: Formatters.dayMonth(homework.assignedAt),
                      icon: Icons.event_available_outlined,
                    ),
                  ),
                  Container(width: 1, height: 36, color: AppColors.border),
                  Expanded(
                    child: _MetaColumn(
                      label: 'Muddat',
                      value: Formatters.dayMonthTime(homework.dueAt),
                      icon: Icons.event_busy_outlined,
                      color: homework.isOverdue ? AppColors.danger : null,
                    ),
                  ),
                  Container(width: 1, height: 36, color: AppColors.border),
                  Expanded(
                    child: _MetaColumn(
                      label: 'Qoldi',
                      value: Formatters.remaining(homework.dueAt),
                      icon: Icons.hourglass_bottom_rounded,
                      color: homework.isOverdue
                          ? AppColors.danger
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tavsif
            Text('Topshiriq', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Text(homework.description, style: AppTextStyles.body),
            ),

            // Biriktirilgan fayllar
            if (homework.attachments.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              Text('Biriktirilgan fayllar', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              for (final String file in homework.attachments)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.insert_drive_file_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(file, style: AppTextStyles.body),
                        ),
                        const Icon(
                          Icons.download_rounded,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],

            // Natija (tekshirilgan bo'lsa)
            if (homework.score != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              Text('Natija', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '${homework.score}',
                          style: AppTextStyles.display
                              .copyWith(color: AppColors.success),
                        ),
                        Text(
                          ' / ${homework.maxScore}',
                          style: AppTextStyles.h3
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    if (homework.teacherComment != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          homework.teacherComment!,
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (homework.submittedAt != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Topshirilgan: '
                    '${Formatters.dayMonthTime(homework.submittedAt!)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.section),
          ],
        ),
      ),
      // Pastki panel: asosiy "Topshirish" tugmasi va undan keyin ikkinchi
      // darajali AI tugmasi. AI yordam vazifa topshirilgandan keyin ham
      // kerak bo'lishi mumkin, shuning uchun u har doim ko'rinadi.
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.card,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (homework.canSubmit) ...<Widget>[
                GradientButton(
                  label: 'Topshirish',
                  icon: Icons.send_rounded,
                  onPressed: () => _openSubmitSheet(context, ref),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              SecondaryButton(
                label: "🤖 AI'dan yordam so'rash",
                onPressed: () => _openAiChat(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Muddat kartasidagi ustun.
class _MetaColumn extends StatelessWidget {
  const _MetaColumn({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Topshirish oynasi: matn + fayl tanlash simulyatsiyasi.
///
/// Fake rejimda fayl haqiqatda yuklanmaydi — faqat nomi ro'yxatga qo'shiladi.
/// Real API'ga o'tilganda shu joyda image_picker/file_picker chaqiriladi,
/// qolgan oqim o'zgarmaydi.
class _SubmitSheet extends ConsumerStatefulWidget {
  const _SubmitSheet({required this.homework});

  final HomeworkModel homework;

  @override
  ConsumerState<_SubmitSheet> createState() => _SubmitSheetState();
}

class _SubmitSheetState extends ConsumerState<_SubmitSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _files = <String>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickFile({required bool isImage}) {
    final int index = _files.length + 1;
    setState(() {
      _files.add(isImage ? 'IMG_000$index.jpg' : 'javob_$index.pdf');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isImage
              ? 'Demo: rasm tanlandi (haqiqiy yuklash real API bilan ishlaydi)'
              : 'Demo: fayl tanlandi',
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final bool ok = await ref.read(homeworkSubmitProvider.notifier).submit(
          homeworkId: widget.homework.id,
          text: _controller.text,
          fileNames: _files,
        );
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final HomeworkSubmitState state = ref.watch(homeworkSubmitProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Vazifani topshirish', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.homework.title, style: AppTextStyles.bodyMuted),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 3,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              hintText: 'Javobingizni yozing yoki izoh qoldiring...',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickFile(isImage: true),
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('Rasm'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickFile(isImage: false),
                  icon: const Icon(Icons.attach_file_rounded, size: 18),
                  label: const Text('Fayl'),
                ),
              ),
            ],
          ),
          if (_files.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _files
                  .map(
                    (String f) => Chip(
                      label: Text(f, style: AppTextStyles.caption),
                      onDeleted: () => setState(() => _files.remove(f)),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (state.errorMessage != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              state.errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Yuborish',
            icon: Icons.send_rounded,
            isLoading: state.isSubmitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
