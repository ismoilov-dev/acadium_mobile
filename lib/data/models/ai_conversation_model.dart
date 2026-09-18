import 'ai_message_model.dart';

/// Bitta uy vazifasi bo'yicha AI suhbati.
///
/// [homeworkId] MAJBURIY va nullable EMAS: AI yordamchi faqat vazifa
/// kontekstida ishlaydi, kontekstsiz suhbat umuman mavjud bo'lmaydi.
class AIConversationModel {
  const AIConversationModel({
    required this.id,
    required this.studentId,
    required this.homeworkId,
    required this.createdAt,
    this.messages = const <AIMessageModel>[],
  });

  final String id; // UUID
  final String studentId; // UUID

  /// Suhbat qaysi vazifaga bog'langan (har doim mavjud).
  final String homeworkId; // UUID

  final List<AIMessageModel> messages;
  final DateTime createdAt;

  bool get isEmpty => messages.isEmpty;

  /// Oxirgi xabar (bo'lmasa — null).
  AIMessageModel? get lastMessage =>
      messages.isEmpty ? null : messages.last;

  /// Yangi xabar qo'shilgan NUSXA qaytaradi (holat o'zgarmas bo'lib qoladi).
  AIConversationModel withMessage(AIMessageModel message) => copyWith(
        messages: <AIMessageModel>[...messages, message],
      );

  AIConversationModel copyWith({List<AIMessageModel>? messages}) =>
      AIConversationModel(
        id: id,
        studentId: studentId,
        homeworkId: homeworkId,
        createdAt: createdAt,
        messages: messages ?? this.messages,
      );

  factory AIConversationModel.fromJson(Map<String, dynamic> json) =>
      AIConversationModel(
        id: json['id'] as String,
        studentId: json['student_id'] as String,
        homeworkId: json['homework_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        messages: (json['messages'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) =>
                AIMessageModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'student_id': studentId,
        'homework_id': homeworkId,
        'created_at': createdAt.toIso8601String(),
        'messages': messages
            .map((AIMessageModel m) => m.toJson())
            .toList(growable: false),
      };
}
