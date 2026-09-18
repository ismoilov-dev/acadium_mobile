import '../models/ai_message_model.dart';

/// AI yordamchi uchun ABSTRAKT interfeys.
///
/// Yordamchi FAQAT uy vazifasi kontekstida ishlaydi — shuning uchun har bir
/// metodda [homeworkId] majburiy.
///
/// Kelajakda `RealAiAssistantDatasource` (Gemini API) shu interfeysni
/// implement qiladi va `service_locator.dart` ichidagi bitta qator
/// o'zgartiriladi — boshqa hech qanday faylga tegilmaydi.
abstract class AiAssistantDatasource {
  /// Suhbat ochilganda avtomatik ko'rsatiladigan birinchi AI xabari.
  ///
  /// Vazifa nomi xabar matniga kiradi, shuning uchun o'quvchi qaysi vazifa
  /// haqida gaplashayotganini darrov ko'radi.
  Future<AIMessageModel> openingMessage({
    required String homeworkId,
    required String homeworkTitle,
  });

  /// O'quvchi xabarini yuboradi va AI javobini qaytaradi.
  ///
  /// [conversationHistory] — shu suhbatdagi oldingi xabarlar (eski → yangi).
  /// Real implementatsiyada u model'ga kontekst sifatida uzatiladi.
  Future<AIMessageModel> sendMessage({
    required String studentId,
    required String homeworkId,
    required String message,
    required List<AIMessageModel> conversationHistory,
  });
}
