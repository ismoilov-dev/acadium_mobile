import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/ai_message_model.dart';
import 'ai_assistant_datasource.dart';

/// [AiAssistantDatasource]ning FAKE implementatsiyasi.
///
/// Haqiqiy model chaqirilmaydi, lekin oqim to'liq simulyatsiya qilinadi:
///  * so'rov [ApiClient] orqali "yuboriladi" (token va device_id header'lari
///    yig'iladi va log qilinadi);
///  * AI "o'ylayotgan" vaqt Future.delayed bilan taqlid qilinadi
///    (800ms - 1.5s), shu paytda UI'da typing indikator ko'rinadi;
///  * javob real backend qaytaradigan JSON formatida qaytariladi.
///
/// TUTOR XULQI (real promptda ham shu qoidalar saqlanadi):
///  * AI hech qachon tayyor javob bermaydi;
///  * o'quvchidan savol so'raydi yoki keyingi qadamni ko'rsatadi;
///  * ohang iliq va rag'batlantiruvchi, javob qisqa (2-3 gap).
class FakeAiAssistantDatasource implements AiAssistantDatasource {
  FakeAiAssistantDatasource(this._api);

  final ApiClient _api;
  final Random _random = Random();

  static const Uuid _uuid = Uuid();

  /// AI "o'ylash" vaqti — typing indikatori ko'rinib turishi uchun.
  static const Duration _minThinking = Duration(milliseconds: 800);
  static const Duration _maxThinking = Duration(milliseconds: 1500);

  /// Tayyor javob so'ralganini bildiruvchi iboralar.
  ///
  /// Ataylab IBORA bo'yicha tekshiriladi, faqat "javob" so'zi bo'yicha emas:
  /// "Javobim to'g'rimi?" — bu haqiqiy savol, uni rad etish noto'g'ri bo'lardi.
  static const List<String> _answerRequestPhrases = <String>[
    'javobini ayt',
    'javobni ayt',
    'javob ayt',
    'javobini ber',
    'javobni ber',
    'javob ber',
    'javobini yoz',
    'javobni yoz',
    'javobi nima',
    'javobini top',
    'tayyor javob',
    "to'g'ridan-to'g'ri ayt",
    "to'g'ridan to'g'ri ayt",
    'yechimini yoz',
    'yechimni yoz',
    'yechib ber',
    'ishlab ber',
    'yozib ber',
    'qilib ber',
    'hal qilib ber',
  ];

  /// Tayyor javob so'ralganda beriladigan rad javobi.
  static const String _refusalReply =
      "Men senga to'g'ridan-to'g'ri javob berolmayman, lekin birga "
      'qadam-baqadam ko\'rib chiqamiz. Birinchi qadam nima deb o\'ylaysan?';

  /// Tutor uslubidagi javoblar — tasodifiy tanlanadi.
  static const List<String> _tutorReplies = <String>[
    "Yaxshi savol! Avval shu masalani qanday tushunganingni ayt-chi?",
    "Bu joyni qaysi qadamgacha tushundik? O'shandan davom qilaylik.",
    "Deyarli to'g'ri yo'ldasan, davom et. Keyingi qadamda nima qilasan?",
    "Qaysi qismi eng qiyin tuyulyapti? O'shanga birga qaraymiz.",
    "Qoida esingdami? Uni shu misolga qanday qo'llash mumkin deb o'ylaysan?",
  ];

  @override
  Future<AIMessageModel> openingMessage({
    required String homeworkId,
    required String homeworkTitle,
  }) async {
    await _api.send(
      method: 'POST',
      path: '/ai/homeworks/$homeworkId/chat/start/',
    );

    return _assistantMessage(
      "Salom! '$homeworkTitle' bo'yicha yordam kerakmi? "
      'Qaysi qismida qiynalayapsan?',
    );
  }

  @override
  Future<AIMessageModel> sendMessage({
    required String studentId,
    required String homeworkId,
    required String message,
    required List<AIMessageModel> conversationHistory,
  }) async {
    if (message.trim().isEmpty) {
      throw const ValidationException('Xabar bo\'sh bo\'lishi mumkin emas.');
    }

    await _api.send(
      method: 'POST',
      path: '/ai/homeworks/$homeworkId/chat/',
      body: <String, dynamic>{
        'student_id': studentId,
        'message': message,
        // Real API'ga kontekst sifatida butun suhbat uzatiladi.
        'history': conversationHistory
            .map((AIMessageModel m) => m.toJson())
            .toList(growable: false),
      },
    );

    // "O'ylash" vaqti — UI'da typing indikatori shu paytda ko'rinadi.
    await Future<void>.delayed(_thinkingDelay());

    return _assistantMessage(
      _isAnswerRequest(message) ? _refusalReply : _randomTutorReply(),
    );
  }

  // ------------------------------------------------------------- yordamchilar

  /// Turli apostroflarni (ʻ ' ` ´) bitta shaklga keltirib, kichik harfga o'tadi.
  String _normalize(String text) => text
      .toLowerCase()
      .replaceAll('ʻ', "'")
      .replaceAll('‘', "'")
      .replaceAll('’', "'")
      .replaceAll('`', "'")
      .replaceAll('´', "'");

  /// Foydalanuvchi tayyor javob so'rayaptimi?
  bool _isAnswerRequest(String message) {
    final String normalized = _normalize(message);
    for (final String phrase in _answerRequestPhrases) {
      if (normalized.contains(phrase)) return true;
    }
    return false;
  }

  String _randomTutorReply() =>
      _tutorReplies[_random.nextInt(_tutorReplies.length)];

  Duration _thinkingDelay() {
    final int span =
        _maxThinking.inMilliseconds - _minThinking.inMilliseconds;
    return Duration(
      milliseconds: _minThinking.inMilliseconds + _random.nextInt(span + 1),
    );
  }

  /// Server qaytaradigan JSON'ga mos AI xabari yasaydi.
  AIMessageModel _assistantMessage(String content) =>
      AIMessageModel.fromJson(<String, dynamic>{
        'id': _uuid.v4(),
        'role': AIMessageRole.assistant.apiValue,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      });
}
