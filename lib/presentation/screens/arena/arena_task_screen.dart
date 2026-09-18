import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/arena_task_model.dart';
import '../../providers/arena_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/arena_task_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/state_views.dart';

/// Arena topshirig'ini BAJARISH ekrani.
///
/// Uch xil topshiriqni qo'llab-quvvatlaydi:
///  * `quiz` — savollarga birma-bir javob berish, natija avtomatik hisoblanadi;
///  * `submission` — matn/fayl yuborish;
///  * `challenge` — bajarilgan chellenj uchun mukofotni olish.
///
/// Yakunlangach XP qo'shiladi va butun ilovadagi ko'rsatkichlar yangilanadi.
class ArenaTaskScreen extends ConsumerStatefulWidget {
  const ArenaTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<ArenaTaskScreen> createState() => _ArenaTaskScreenState();
}

class _ArenaTaskScreenState extends ConsumerState<ArenaTaskScreen> {
  /// Test boshlanganmi?
  bool _quizStarted = false;

  /// Joriy savol indeksi va tanlangan variant.
  int _index = 0;
  int? _selected;

  /// Savol id → tanlangan variant indeksi.
  final Map<String, int> _answers = <String, int>{};

  final TextEditingController _textController = TextEditingController();
  final List<String> _files = <String>[];

  @override
  void initState() {
    super.initState();
    // Oldingi topshiriqdan qolgan natijani tozalaymiz.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(arenaSubmitProvider.notifier).reset(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ harakatlar

  void _pickFile({required bool isImage}) {
    setState(() {
      _files.add(isImage
          ? 'IMG_${_files.length + 1}.jpg'
          : 'javob_${_files.length + 1}.pdf');
    });
  }

  Future<void> _nextQuestion(ArenaTaskModel task) async {
    final ArenaQuestion question = task.questions[_index];
    _answers[question.id] = _selected!;

    final bool isLast = _index == task.questions.length - 1;
    if (isLast) {
      await ref.read(arenaSubmitProvider.notifier).submitQuiz(
            taskId: task.id,
            answers: _answers,
          );
      return;
    }

    setState(() {
      _index++;
      _selected = _answers[task.questions[_index].id];
    });
  }

  void _previousQuestion(ArenaTaskModel task) {
    if (_index == 0) return;
    setState(() {
      _index--;
      _selected = _answers[task.questions[_index].id];
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ArenaTaskModel> task =
        ref.watch(arenaTaskProvider(widget.taskId));
    final ArenaSubmitState submit = ref.watch(arenaSubmitProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(task.valueOrNull?.type.label ?? 'Topshiriq'),
      ),
      body: SafeArea(
        top: false,
        child: task.when(
          loading: () => const ShimmerList(itemCount: 3, itemHeight: 120),
          error: (Object e, _) => ErrorView(
            error: e,
            onRetry: () => ref.invalidate(arenaTaskProvider(widget.taskId)),
          ),
          data: (ArenaTaskModel t) {
            // 1. Yakunlandi — natija ekrani.
            if (submit.result != null) {
              return _ResultView(result: submit.result!, task: t);
            }
            // 2. Ilgari bajarilgan topshiriq.
            if (t.isCompleted) return _CompletedView(task: t);
            // 3. Test jarayoni.
            if (_quizStarted && t.type == ArenaTaskType.quiz) {
              return _buildQuiz(t, submit);
            }
            // 4. Kirish (tavsif + boshlash/topshirish).
            return _buildIntro(t, submit);
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------ 1. Kirish

  Widget _buildIntro(ArenaTaskModel task, ArenaSubmitState submit) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        _TaskHeader(task: task),
        const SizedBox(height: AppSpacing.xl),
        Text('Topshiriq', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        AppCard(child: Text(task.description, style: AppTextStyles.body)),
        if (task.attachments.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          for (final String file in task.attachments)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(file, style: AppTextStyles.body)),
                    const Icon(Icons.download_rounded,
                        size: 18, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: AppSpacing.xl),
        ..._buildAction(task, submit),
      ],
    );
  }

  /// Topshiriq turiga qarab pastki qism.
  List<Widget> _buildAction(ArenaTaskModel task, ArenaSubmitState submit) {
    if (task.isExpired) {
      return <Widget>[
        AppCard(
          child: Row(
            children: <Widget>[
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.danger, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  "Muddati tugagan. Bu topshiriqni endi bajarib bo'lmaydi.",
                  style: AppTextStyles.bodyMuted,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    switch (task.type) {
      // ------------------------------------------------------------- test
      case ArenaTaskType.quiz:
        return <Widget>[
          AppCard(
            child: Row(
              children: <Widget>[
                const Icon(Icons.timer_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '${task.questions.length} ta savol. Har bir to\'g\'ri javob '
                    'uchun XP beriladi — jami ${task.xpReward} XP gacha.',
                    style: AppTextStyles.bodyMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Testni boshlash',
            icon: Icons.play_arrow_rounded,
            onPressed: () => setState(() {
              _quizStarted = true;
              _index = 0;
              _selected = null;
            }),
          ),
        ];

      // -------------------------------------------------------- topshiriq
      case ArenaTaskType.submission:
        return <Widget>[
          Text('Javobingiz', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _textController,
            maxLines: 7,
            minLines: 4,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              hintText: 'Javobingizni shu yerga yozing...',
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
                  .map((String f) => Chip(
                        label: Text(f, style: AppTextStyles.caption),
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        onDeleted: () => setState(() => _files.remove(f)),
                      ))
                  .toList(),
            ),
          ],
          if (submit.errorMessage != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              submit.errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Topshirish',
            icon: Icons.send_rounded,
            isLoading: submit.isSubmitting,
            onPressed: () => ref.read(arenaSubmitProvider.notifier).submitWork(
                  taskId: task.id,
                  text: _textController.text,
                  fileNames: _files,
                ),
          ),
        ];

      // --------------------------------------------------------- chellenj
      case ArenaTaskType.challenge:
        return <Widget>[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Bajarilishi', style: AppTextStyles.label),
                    Text(
                      '${task.progressCurrent} / ${task.progressTarget}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: task.progress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      task.canClaim ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (submit.errorMessage != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              submit.errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (task.canClaim)
            GradientButton(
              label: 'Mukofotni olish (+${task.xpReward} XP)',
              icon: Icons.card_giftcard_rounded,
              isLoading: submit.isSubmitting,
              onPressed: () =>
                  ref.read(arenaSubmitProvider.notifier).claim(task.id),
            )
          else
            AppCard(
              child: Row(
                children: <Widget>[
                  const Icon(Icons.hourglass_bottom_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Chellenj avtomatik hisoblanadi. Uni yakunlang va '
                      'mukofot shu yerda paydo bo\'ladi.',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ),
                ],
              ),
            ),
        ];
    }
  }

  // -------------------------------------------------------------- 2. Test

  Widget _buildQuiz(ArenaTaskModel task, ArenaSubmitState submit) {
    final ArenaQuestion question = task.questions[_index];
    final bool isLast = _index == task.questions.length - 1;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Savol ${_index + 1} / ${task.questions.length}',
                    style: AppTextStyles.label,
                  ),
                  Text(
                    '${task.xpReward} XP gacha',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.secondary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: (_index + 1) / task.questions.length,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: <Widget>[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(question.text, style: AppTextStyles.h3),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (int i = 0; i < question.options.length; i++) ...<Widget>[
                _OptionTile(
                  label: question.options[i],
                  index: i,
                  isSelected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (submit.errorMessage != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  submit.errorMessage!,
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            boxShadow: AppShadows.card,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: <Widget>[
                if (_index > 0) ...<Widget>[
                  SizedBox(
                    width: 56,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => _previousQuestion(task),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: GradientButton(
                    label: isLast ? 'Yakunlash' : 'Keyingi savol',
                    icon: isLast
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    enabled: _selected != null,
                    isLoading: submit.isSubmitting,
                    onPressed: () => _nextQuestion(task),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Topshiriq sarlavhasi: tur, o'qituvchi, muddat va XP.
class _TaskHeader extends StatelessWidget {
  const _TaskHeader({required this.task});

  final ArenaTaskModel task;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.2),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(ArenaTaskStyle.iconOf(task.type),
                          size: 14, color: AppColors.onPrimary),
                      const SizedBox(width: 4),
                      Text(task.type.label,
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.onPrimary)),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.bolt_rounded,
                    size: 18, color: AppColors.onPrimary),
                Text(
                  '+${task.xpReward} XP',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              task.title,
              style: AppTextStyles.h1.copyWith(color: AppColors.onPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Icon(Icons.person_outline_rounded,
                    size: 15,
                    color: AppColors.onPrimary.withValues(alpha: 0.85)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.subject.isEmpty
                        ? task.teacherName
                        : '${task.teacherName} · ${task.subject}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (task.deadline != null) ...<Widget>[
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Icon(Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.onPrimary.withValues(alpha: 0.85)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Muddat: ${Formatters.dayMonthTime(task.deadline!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Test varianti (tanlanadigan karta).
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  static const List<String> _letters = <String>['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected ? null : AppShadows.soft,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Text(
                _letters[index % _letters.length],
                style: AppTextStyles.label.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Yakuniy natija: olingan XP, to'g'ri javoblar va reytingdagi o'zgarish.
class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.task});

  final ArenaTaskResult result;
  final ArenaTaskModel task;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            width: 104,
            height: 104,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              shape: BoxShape.circle,
              boxShadow: AppShadows.glow,
            ),
            child: const Icon(Icons.check_rounded,
                size: 56, color: AppColors.onPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          result.message,
          style: AppTextStyles.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          task.title,
          style: AppTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.section),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: <Widget>[
              Text('Siz qo\'lga kiritdingiz', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Icon(Icons.bolt_rounded,
                        color: AppColors.secondary, size: 30),
                    Text(
                      '+${result.earnedXp}',
                      style: AppTextStyles.display
                          .copyWith(color: AppColors.secondary, fontSize: 40),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(' XP', style: AppTextStyles.h3),
                    ),
                  ],
                ),
              ),
              if (result.correctCount != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    '${result.correctCount} / ${result.totalQuestions} '
                    "to'g'ri javob",
                    style:
                        AppTextStyles.label.copyWith(color: AppColors.success),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Jami XP', style: AppTextStyles.label),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Formatters.number(result.totalXp),
                            style: AppTextStyles.h2
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Reyting', style: AppTextStyles.label),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (result.movedUp) ...<Widget>[
                                const Icon(Icons.trending_up_rounded,
                                    color: AppColors.success, size: 18),
                                const SizedBox(width: 2),
                              ],
                              Text(
                                "${result.newRank ?? '-'}-o'rin",
                                style: AppTextStyles.h2.copyWith(
                                  color: result.movedUp
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (result.movedUp) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${result.previousRank}-o\'rindan '
                  '${result.newRank}-o\'ringa ko\'tarildingiz! 🎉',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.success),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GradientButton(
          label: 'Arenaga qaytish',
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Ilgari bajarilgan topshiriq ko'rinishi.
class _CompletedView extends StatelessWidget {
  const _CompletedView({required this.task});

  final ArenaTaskModel task;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        _TaskHeader(task: task),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded,
                    color: AppColors.success, size: 32),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Bajarilgan', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '+${task.earnedXp ?? 0} XP qo\'shilgan',
                style: AppTextStyles.body.copyWith(color: AppColors.secondary),
              ),
              if (task.resultComment != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    task.resultComment!,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (task.completedAt != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  Formatters.dayMonthTime(task.completedAt!),
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Topshiriq matni', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        AppCard(child: Text(task.description, style: AppTextStyles.body)),
      ],
    );
  }
}
