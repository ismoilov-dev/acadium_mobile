import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/homework_model.dart';
import 'app_card.dart';

/// Uy vazifasi statusiga mos rangli badge.
class HomeworkStatusBadge extends StatelessWidget {
  const HomeworkStatusBadge({super.key, required this.status});

  final HomeworkStatus status;

  /// Status → (matn rangi, fon rangi, ikonka).
  static (Color, Color, IconData) styleOf(HomeworkStatus status) {
    switch (status) {
      case HomeworkStatus.assigned:
        return (
          AppColors.warning,
          AppColors.warningLight,
          Icons.pending_actions_rounded
        );
      case HomeworkStatus.submitted:
        return (AppColors.info, AppColors.infoLight, Icons.upload_file_rounded);
      case HomeworkStatus.late:
        return (
          AppColors.danger,
          AppColors.dangerLight,
          Icons.running_with_errors_rounded
        );
      case HomeworkStatus.reviewed:
        return (
          AppColors.success,
          AppColors.successLight,
          Icons.check_circle_rounded
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color color, Color background, IconData icon) = styleOf(status);
    return StatusBadge(
      label: status.label,
      color: color,
      background: background,
      icon: icon,
    );
  }
}
