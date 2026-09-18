import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/app_exception.dart';
import '../../core/service_locator.dart';
import '../../data/models/ai_conversation_model.dart';
import '../../data/models/ai_message_model.dart';
import '../../data/repositories/ai_assistant_repository.dart';
import 'auth_provider.dart';

const Uuid _uuid = Uuid();

/// AI suhbati QAYSI vazifaga bog'langani.
///
/// Provider family'ning kaliti — shuning uchun `==` va `hashCode` aniqlangan:
/// bir xil vazifa uchun har doim bitta suhbat holati qaytariladi.
class AiChatTarget {
  const AiChatTarget({required this.homeworkId, required this.homeworkTitle});

  final String homeworkId;
  final String homeworkTitle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatTarget &&
          other.homeworkId == homeworkId &&
          other.homeworkTitle == homeworkTitle;

  @override
  int get hashCode => Object.hash(homeworkId, homeworkTitle);
}

/// Chat ekranining holati.
class AiChatState {
  const AiChatState({
    required this.conversation,
    this.isTyping = false,
    this.errorMessage,
  });

  /// Suhbatning o'zi (vazifaga bog'langan xabarlar bilan).
  final AIConversationModel conversation;

  /// AI hozir "yozayapti"mi (typing indikatori shu holatga qarab ko'rinadi).
  final bool isTyping;

  /// Foydalanuvchiga ko'rsatiladigan xatolik.
  final String? errorMessage;

  List<AIMessageModel> get messages => conversation.messages;

  AiChatState copyWith({
    AIConversationModel? conversation,
    bool? isTyping,
    String? errorMessage,
    bool clearError = false,
  }) =>
      AiChatState(
        conversation: conversation ?? this.conversation,
        isTyping: isTyping ?? this.isTyping,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Bitta vazifa bo'yicha AI suhbatini boshqaradi.
///
/// Ekran ochilishi bilan boshlang'ich AI xabari so'raladi, keyin har bir
/// yuborilgan xabarga javob qo'shiladi. Butun matn datasource'dan keladi —
/// Gemini'ga o'tilganda bu klass umuman o'zgarmaydi.
class AiChatController extends StateNotifier<AiChatState> {
  factory AiChatController({
    required Ref ref,
    required AiChatTarget target,
  }) =>
      AiChatController._(
        ref: ref,
        target: target,
        studentId: ref.read(currentUserIdProvider),
      );

  AiChatController._({
    required Ref ref,
    required AiChatTarget target,
    required String? studentId,
  })  : _ref = ref,
        _target = target,
        _studentId = studentId,
        super(
          AiChatState(
            conversation: AIConversationModel(
              id: _uuid.v4(),
              studentId: studentId ?? '',
              homeworkId: target.homeworkId,
              createdAt: DateTime.now(),
            ),
          ),
        ) {
    _start();
  }

  final Ref _ref;
  final AiChatTarget _target;
  final String? _studentId;

  AiAssistantRepository get _repo => _ref.read(aiAssistantRepositoryProvider);

  /// Suhbat ochilganda: boshlang'ich AI xabarini yuklaydi.
  Future<void> _start() async {
    if (_studentId == null) {
      state = state.copyWith(
        errorMessage: 'Sessiya topilmadi. Qaytadan kiring.',
      );
      return;
    }

    state = state.copyWith(isTyping: true, clearError: true);
    try {
      final AIMessageModel opening = await _repo.openingMessage(
        homeworkId: _target.homeworkId,
        homeworkTitle: _target.homeworkTitle,
      );
      if (!mounted) return;
      state = state.copyWith(
        conversation: state.conversation.withMessage(opening),
        isTyping: false,
      );
    } on AppException catch (e) {
      if (!mounted) return;
      state = state.copyWith(isTyping: false, errorMessage: e.message);
    }
  }

  /// O'quvchi xabarini yuboradi va AI javobini qo'shadi.
  Future<bool> sendMessage(String text) async {
    final String trimmed = text.trim();
    final String? studentId = _studentId;
    if (trimmed.isEmpty || state.isTyping || studentId == null) return false;

    // Foydalanuvchi xabari darrov ko'rinadi — javob kutilmaydi.
    final List<AIMessageModel> history = state.messages;
    final AIMessageModel outgoing = AIMessageModel(
      id: _uuid.v4(),
      role: AIMessageRole.user,
      content: trimmed,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      conversation: state.conversation.withMessage(outgoing),
      isTyping: true,
      clearError: true,
    );

    try {
      final AIMessageModel reply = await _repo.sendMessage(
        studentId: studentId,
        homeworkId: _target.homeworkId,
        message: trimmed,
        conversationHistory: history,
      );
      if (!mounted) return false;
      state = state.copyWith(
        conversation: state.conversation.withMessage(reply),
        isTyping: false,
      );
      return true;
    } on AppException catch (e) {
      if (!mounted) return false;
      // Yuborilgan xabar ro'yxatda qoladi — o'quvchi qayta urinib ko'radi.
      state = state.copyWith(isTyping: false, errorMessage: e.message);
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

/// Har bir vazifa uchun ALOHIDA suhbat holati.
///
/// Kalit — [AiChatTarget], ya'ni bitta vazifaning chatiga qayta kirilganda
/// oldingi yozishmalar saqlanib qoladi.
final StateNotifierProviderFamily<AiChatController, AiChatState, AiChatTarget>
    aiChatProvider =
    StateNotifierProvider.family<AiChatController, AiChatState, AiChatTarget>(
  (ref, AiChatTarget target) => AiChatController(ref: ref, target: target),
);
