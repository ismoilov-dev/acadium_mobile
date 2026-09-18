/// Bildirishnoma turi.
enum NotificationType {
  homework('homework', 'Uy vazifasi'),
  grade('grade', 'Baho'),
  lesson('lesson', 'Dars'),
  xp('xp', 'XP'),
  system('system', 'Tizim');

  const NotificationType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static NotificationType fromApi(String value) =>
      NotificationType.values.firstWhere(
        (NotificationType t) => t.apiValue == value,
        orElse: () => NotificationType.system,
      );
}

/// Bitta bildirishnoma.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.targetId,
    this.childName,
  });

  final String id; // UUID
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  /// Bog'liq obyekt ID'si (masalan homework_id) — bosilganda ochish uchun.
  final String? targetId;

  /// Ota-ona ilovasida: bildirishnoma qaysi farzand haqida
  /// (Student oqimida har doim null).
  final String? childName;

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        targetId: targetId,
        childName: childName,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        type: NotificationType.fromApi(json['type'] as String),
        title: json['title'] as String,
        body: json['body'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        isRead: json['is_read'] as bool? ?? false,
        targetId: json['target_id'] as String?,
        childName: json['child_name'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type.apiValue,
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        'target_id': targetId,
        'child_name': childName,
      };
}
