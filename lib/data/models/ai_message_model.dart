/// AI suhbatidagi xabar muallifi.
enum AIMessageRole {
  user('user'),
  assistant('assistant');

  const AIMessageRole(this.apiValue);

  final String apiValue;

  static AIMessageRole fromApi(String value) => AIMessageRole.values.firstWhere(
        (AIMessageRole r) => r.apiValue == value,
        orElse: () => AIMessageRole.assistant,
      );

  bool get isUser => this == AIMessageRole.user;
}

/// AI yordamchi bilan suhbatdagi bitta xabar.
///
/// Backend: `POST /ai/homeworks/{id}/chat/` javobidagi element.
/// Gemini API'ga o'tilganda ham format o'zgarmaydi — `role` + `content`
/// Gemini'ning `contents` massiviga to'g'ridan-to'g'ri mos keladi.
class AIMessageModel {
  const AIMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  final String id; // UUID
  final AIMessageRole role;

  /// Xabar matni.
  final String content;

  final DateTime timestamp;

  bool get isUser => role.isUser;

  factory AIMessageModel.fromJson(Map<String, dynamic> json) => AIMessageModel(
        id: json['id'] as String,
        role: AIMessageRole.fromApi(json['role'] as String),
        content: json['content'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'role': role.apiValue,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}
