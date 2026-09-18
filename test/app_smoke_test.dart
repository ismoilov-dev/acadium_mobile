import 'package:acadium_student/data/datasources/mock/mock_data.dart';
import 'package:acadium_student/data/datasources/mock/mock_state.dart';
import 'package:acadium_student/main.dart';
import 'package:acadium_student/presentation/screens/arena/arena_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// flutter_secure_storage plaginini xotiradagi Map bilan almashtiradi,
/// aks holda testda MissingPluginException chiqadi.
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

/// Testni telefon o'lchamida (390x844 logical) ishga tushiradi —
/// standart 800x600 test "oynasi" telefon ilovasi uchun real emas.
void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Fake datasource kechikishlarini o'tkazib yuborish uchun.
Future<void> _settle(WidgetTester tester, {int frames = 8}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  late Map<String, String> store;

  setUp(() {
    store = <String, String>{};
    _mockSecureStorage(store);
    // Fake "baza"ni boshlang'ich holatga qaytaramiz.
    MockState.instance.reset();
  });

  testWidgets('Splash → Phone login → PIN → Home oqimi ishlaydi',
      (WidgetTester tester) async {
    _usePhoneScreen(tester);
    await tester.pumpWidget(const ProviderScope(child: AcadiumApp()));

    // 1. Splash ko'rinadi, token yo'q → login ekraniga o'tadi.
    expect(find.text('Acadium'), findsOneWidget);
    await _settle(tester);
    expect(find.text('Xush kelibsiz!'), findsOneWidget);

    // 2. Toq raqam bilan tugaydigan telefon → mavjud foydalanuvchi.
    await tester.enterText(find.byType(TextField), '901234567');
    await tester.pump();
    await tester.tap(find.text('Davom etish'));
    await _settle(tester);
    expect(find.text('PIN kodni kiriting'), findsOneWidget);

    // 3. Noto'g'ri PIN rad etiladi.
    for (final String d in <String>['9', '9', '9', '9']) {
      await tester.tap(find.widgetWithText(InkWell, d).first);
      await tester.pump();
    }
    await _settle(tester);
    expect(find.textContaining("PIN kod noto'g'ri"), findsOneWidget);

    // 4. To'g'ri PIN (1234) → Home ekrani.
    for (final String d in <String>['1', '2', '3', '4']) {
      await tester.tap(find.widgetWithText(InkWell, d).first);
      await tester.pump();
    }
    await _settle(tester, frames: 12);

    expect(find.text('Jami XP'), findsOneWidget);
    expect(find.text('1 240'), findsOneWidget);
    expect(find.text('Keyingi dars'), findsOneWidget);

    // Token secure storage'ga saqlangan va device_id yaratilgan.
    expect(store['acadium_access_token'], isNotNull);
    expect(store['acadium_role'], 'student');
    expect(store['acadium_device_id'], isNotNull);

    // 5. Bottom navigation: Arena tabida reyting ko'rinadi.
    await tester.tap(find.text('Arena'));
    await _settle(tester, frames: 12);
    expect(find.text('Reyting jadvali'), findsOneWidget);
    expect(find.textContaining('Siz'), findsWidgets);

    // 6. Profil tabi va chiqish tugmasi.
    await tester.tap(find.text('Profil'));
    await _settle(tester, frames: 12);
    expect(find.text('Amir Tursunov'), findsOneWidget);
    expect(find.text('Chiqish'), findsOneWidget);

    // Timer'lar qolmasligi uchun daraxtni bo'shatamiz.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Saqlangan token bo\'lsa to\'g\'ridan-to\'g\'ri Home ochiladi',
      (WidgetTester tester) async {
    _usePhoneScreen(tester);
    store['acadium_access_token'] = 'fake.token.value';
    store['acadium_user_id'] = '9f8b1c2d-4e5a-4f6b-8c7d-1a2b3c4d5e6f';
    store['acadium_role'] = 'student';
    store['acadium_device_id'] = 'device-uuid';
    store['acadium_phone'] = '+998901234567';

    await tester.pumpWidget(const ProviderScope(child: AcadiumApp()));
    await _settle(tester, frames: 12);

    expect(find.text('Jami XP'), findsOneWidget);
    expect(find.text('Xush kelibsiz!'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Arena testini yechib XP olinadi', (WidgetTester tester) async {
    _usePhoneScreen(tester);
    const String quizId = 'a1000001-0000-4000-8000-000000000001';

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ArenaTaskScreen(taskId: quizId)),
      ),
    );
    await _settle(tester);

    expect(find.text('Grammar sprint: Present Perfect'), findsOneWidget);
    expect(find.text('Dilnoza Karimova · Ingliz tili'), findsOneWidget);

    // Testni boshlaymiz.
    await tester.tap(find.text('Testni boshlash'));
    await tester.pump();

    // Har bir savolga to'g'ri javob beramiz.
    final List<dynamic> questions = MockData.arenaTasks().firstWhere(
            (Map<String, dynamic> t) => t['id'] == quizId)['questions']
        as List<dynamic>;

    for (int i = 0; i < questions.length; i++) {
      final Map<String, dynamic> q = questions[i] as Map<String, dynamic>;
      final List<String> options =
          (q['options'] as List<dynamic>).cast<String>();
      final int correct = MockData.quizAnswerKey[q['id']]!;

      expect(find.text('Savol ${i + 1} / ${questions.length}'), findsOneWidget);
      await tester.tap(find.text(options[correct]));
      await tester.pump();
      await tester.tap(
        find.text(i == questions.length - 1 ? 'Yakunlash' : 'Keyingi savol'),
      );
      await tester.pump();
    }

    await _settle(tester, frames: 12);

    // Natija: 5/5 to'g'ri → to'liq 120 XP, jami 1360 XP.
    expect(find.text('+120'), findsOneWidget);
    expect(find.text("5 / 5 to'g'ri javob"), findsOneWidget);
    expect(find.text('1 360'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
