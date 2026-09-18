import '../datasources/ai_assistant_datasource.dart';
import '../models/ai_message_model.dart';

/// AI yordamchi uchun repository.
///
/// UI qatlami datasource'ni ko'rmaydi — provider faqat shu repository bilan
/// ishlaydi. Fake/real almashtirilganda ekran va provider o'zgarmaydi.
class AiAssistantRepository {
  AiAssistantRepository({required AiAssistantDatasource datasource})
      : _datasource = datasource;

  final AiAssistantDatasource _datasource;

  /// Suhbat ochilganda ko'rsatiladigan birinchi AI xabari.
  Future<AIMessageModel> openingMessage({
    required String homeworkId,
    required String homeworkTitle,
  }) =>
      _datasource.openingMessage(
        homeworkId: homeworkId,
        homeworkTitle: homeworkTitle,
      );

  /// O'quvchi xabarini yuborib, AI javobini oladi.
  Future<AIMessageModel> sendMessage({
    required String studentId,
    required String homeworkId,
    required String message,
    required List<AIMessageModel> conversationHistory,
  }) =>
      _datasource.sendMessage(
        studentId: studentId,
        homeworkId: homeworkId,
        message: message,
        conversationHistory: conversationHistory,
      );
}
