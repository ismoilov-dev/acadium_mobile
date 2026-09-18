/// Arena topshirig'ining holati.
enum ArenaTaskStatus {
  available('available', 'Boshlash mumkin'),
  inProgress('in_progress', 'Jarayonda'),
  completed('completed', 'Bajarilgan');

  const ArenaTaskStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ArenaTaskStatus fromApi(String value) => ArenaTaskStatus.values.firstWhere(
        (ArenaTaskStatus s) => s.apiValue == value,
        orElse: () => ArenaTaskStatus.available,
      );
}

/// Arena (XP yig'ish) topshirig'i.
class ArenaTaskModel {
  const ArenaTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.status,
    required this.progressCurrent,
    required this.progressTarget,
    this.deadline,
  });

  final String id; // UUID
  final String title;
  final String description;
  final int xpReward;
  final ArenaTaskStatus status;
  final int progressCurrent;
  final int progressTarget;
  final DateTime? deadline;

  /// 0..1 oralig'idagi bajarilish darajasi.
  double get progress =>
      progressTarget == 0 ? 0 : (progressCurrent / progressTarget).clamp(0.0, 1.0);

  factory ArenaTaskModel.fromJson(Map<String, dynamic> json) => ArenaTaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        xpReward: json['xp_reward'] as int? ?? 0,
        status: ArenaTaskStatus.fromApi(json['status'] as String),
        progressCurrent: json['progress_current'] as int? ?? 0,
        progressTarget: json['progress_target'] as int? ?? 1,
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'xp_reward': xpReward,
        'status': status.apiValue,
        'progress_current': progressCurrent,
        'progress_target': progressTarget,
        'deadline': deadline?.toIso8601String(),
      };
}
