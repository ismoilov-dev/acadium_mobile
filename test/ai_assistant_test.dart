import 'package:acadium_student/core/error/app_exception.dart';
import 'package:acadium_student/core/network/api_client.dart';
import 'package:acadium_student/core/theme/app_theme.dart';
import 'package:acadium_student/data/datasources/fake_ai_assistant_datasource.dart';
import 'package:acadium_student/data/datasources/mock/mock_data.dart';
import 'package:acadium_student/data/datasources/mock/mock_state.dart';
import 'package:acadium_student/data/models/ai_message_model.dart';
import 'package:acadium_student/data/models/homework_model.dart';
import 'package:acadium_student/presentation/providers/auth_provider.dart';
import 'package:acadium_student/presentation/screens/homework/ai_chat_screen.dart';
import 'package:acadium_student/presentation/screens/homework/homework_detail_screen.dart';
import 'package:acadium_student/presentation/widgets/chat_bubble.dart';
import 'package:acadium_student/presentation/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testlar uchun soxta ApiClient — secure storage'ga tegmaydi va kechikmaydi.
class _NoopApiClient implements ApiClient {
  @override
  String get baseUrl => 'https://test.local';

  @override
  Future<Map<String, String>> buildHeaders() async => <String, String>{};

  @override
  Future<dynamic> send({
    required String method,
    required String path,
    Map<String, dynamic>? query,
    Object? body,
  }) async =>
      null;
}

/// flutter_secure_storage plaginini xotiradagi Map bilan almashtiradi.
void _mockSecureStorage(Map<String, String> store) {
  const MethodChannel channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
    final Map<Object?, Object?> args =
        (call.arguments as Map<Object?, Object?>?) ?? <Object?, Object?>{};
    final String? key = args['key'] as String?;

    switch (call.method) {
      case 'read':
        return store[key];
      case 'readAll':
        return store;
      case 'write':
        store[key!] = args['value'] as String;
        return null;
      case 'delete':
        store.remove(key);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'containsKey':
        return store.containsKey(key);
      default:
        return null;
    }
  });
}

void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Fake kechikishlarni (API + AI "o'ylash" vaqti) o'tkazib yuborish.
Future<void> _settle(WidgetTester tester, {int frames = 12}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  final _NoopApiClient api = _NoopApiClient();

  group('FakeAiAssistantDatasource — tutor xulqi', () {
    final FakeAiAssistantDatasource ds = FakeAiAssistantDatasource(api);

    test('boshlang\'ich xabarda vazifa nomi bo\'ladi', () async {
      final AIMessageModel opening = await ds.openingMessage(
        homeworkId: 'hw-1',
        homeworkTitle: 'Unit 7: Writing Task 2 essay',
      );

      expect(opening.role, AIMessageRole.assistant);
      expect(opening.content, contains('Unit 7: Writing Task 2 essay'));
      expect(opening.content, contains('Qaysi qismida qiynalayapsan?'));
    });

    test('tayyor javob so\'ralsa — AI rad etadi va qadam so\'raydi', () async {
      for (final String ask in <String>[
        'Iltimos javobini ayt',
        "To'g'ridan-to'g'ri ayt javobini",
        'yechimini yoz',
        'shuni qilib ber',
      ]) {
        final AIMessageModel reply = await ds.sendMessage(
          studentId: MockData.studentId,
          homeworkId: 'hw-1',
          message: ask,
          conversationHistory: const <AIMessageModel>[],
        );

        expect(
          reply.content,
          contains("to'g'ridan-to'g'ri javob berolmayman"),
          reason: '"$ask" uchun rad javobi kutilgan edi',
        );
        expect(reply.content, contains('Birinchi qadam nima deb'));
      }
    });

    test('haqiqiy savol rad etilmaydi (masalan "javobim to\'g\'rimi?")',
        () async {
      final AIMessageModel reply = await ds.sendMessage(
        studentId: MockData.studentId,
        homeworkId: 'hw-1',
        message: "Javobim to'g'rimi?",
        conversationHistory: const <AIMessageModel>[],
      );

      expect(reply.content, isNot(contains('javob berolmayman')));
    });

    test('har qanday javob qisqa bo\'ladi va savol bilan yo\'naltiradi',
        () async {
      final List<AIMessageModel> replies = await Future.wait<AIMessageModel>(
        List<Future<AIMessageModel>>.generate(
          6,
          (_) => ds.sendMessage(
            studentId: MockData.studentId,
            homeworkId: 'hw-1',
            message: 'Bu yerda nimadan boshlasam bo\'ladi?',
            conversationHistory: const <AIMessageModel>[],
          ),
        ),
      );

      for (final AIMessageModel reply in replies) {
        expect(reply.role, AIMessageRole.assistant);
        expect(reply.content, contains('?'));
        expect(reply.content.length, lessThan(160));
      }
    });

    test('bo\'sh xabar qabul qilinmaydi', () {
      expect(
        () => ds.sendMessage(
          studentId: MockData.studentId,
          homeworkId: 'hw-1',
          message: '   ',
          conversationHistory: const <AIMessageModel>[],
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('AI Yordamchi — Vazifa tafsilotidan chatgacha', () {
    late Map<String, String> store;

    setUp(() {
      store = <String, String>{};
      _mockSecureStorage(store);
      MockState.instance.reset();
    });

    testWidgets(
        'Vazifa detali → AI tugmasi → boshlang\'ich xabar → savol → javob',
        (WidgetTester tester) async {
      _usePhoneScreen(tester);

      final HomeworkModel homework =
          HomeworkModel.fromJson(MockData.homework().first);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            currentUserIdProvider.overrideWithValue(MockData.studentId),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: HomeworkDetailScreen(homework: homework),
          ),
        ),
      );
      await tester.pump();

      // 1. Vazifa sahifasida AI tugmasi bor (Topshirish tugmasi bilan birga).
      expect(find.text('Topshirish'), findsOneWidget);
      expect(find.text("🤖 AI'dan yordam so'rash"), findsOneWidget);

      // 2. Tugma bosilganda chat ochiladi va kontekst chipi ko'rinadi.
      await tester.tap(find.text("🤖 AI'dan yordam so'rash"));
      await tester.pump();
      await _settle(tester);

      expect(find.text('AI Yordamchi'), findsOneWidget);
      expect(find.text("${homework.title} bo'yicha"), findsOneWidget);

      // 3. Boshlang'ich AI xabari avtomatik ko'rinadi.
      expect(
        find.textContaining("'${homework.title}' bo'yicha yordam kerakmi?"),
        findsOneWidget,
      );
      expect(find.byType(ChatBubble), findsOneWidget);

      // 4. Savol yuboriladi: xabar darrov chiqadi, AI "yozayapti" holatiga o'tadi.
      const String question = 'Essayni qanday boshlasam bo\'ladi?';
      await tester.enterText(find.byType(TextField), question);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(find.text(question), findsOneWidget);
      expect(find.byType(TypingIndicator), findsOneWidget);

      // 5. Fake javob keladi: typing yo'qoladi, uchinchi pufak qo'shiladi.
      await _settle(tester);

      expect(find.byType(TypingIndicator), findsNothing);
      expect(find.byType(ChatBubble), findsNWidgets(3));

      // Javob AI tomonidan berilgan va savol bilan yo'naltiradi.
      final ChatBubble last = tester.widgetList<ChatBubble>(
        find.byType(ChatBubble),
      ).first;
      expect(last.message.role, AIMessageRole.assistant);
      expect(last.message.content, contains('?'));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Chatda tayyor javob so\'ralsa — AI rad etadi',
        (WidgetTester tester) async {
      _usePhoneScreen(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            currentUserIdProvider.overrideWithValue(MockData.studentId),
          ],
          child: const MaterialApp(
            home: AiChatScreen(
              homeworkId: 'cc000001-0000-4000-8000-000000000001',
              homeworkTitle: 'Unit 7: Writing Task 2 essay',
            ),
          ),
        ),
      );
      await _settle(tester);

      await tester.enterText(
        find.byType(TextField),
        'Iltimos javobini ayt, vaqtim yo\'q',
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await _settle(tester);

      expect(
        find.textContaining("to'g'ridan-to'g'ri javob berolmayman"),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
