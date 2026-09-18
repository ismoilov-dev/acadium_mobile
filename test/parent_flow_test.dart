import 'package:acadium_student/data/datasources/mock/mock_state.dart';
import 'package:acadium_student/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Testni telefon o'lchamida (390x844 logical) ishga tushiradi.
void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Fake datasource kechikishlarini o'tkazib yuborish uchun.
Future<void> _settle(WidgetTester tester, {int frames = 10}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  late Map<String, String> store;

  setUp(() {
    store = <String, String>{};
    _mockSecureStorage(store);
    MockState.instance.reset();
  });

  testWidgets(
      'Parent: telefon → PIN → Home → Farzandlar → farzand tanlash → '
      'Child Detail → Payments', (WidgetTester tester) async {
    _usePhoneScreen(tester);

    await tester.pumpWidget(const ProviderScope(child: AcadiumApp()));
    await _settle(tester);

    // 1. Login ekrani.
    expect(find.text('Xush kelibsiz!'), findsOneWidget);

    // 2. "33" operator kodi — ota-ona raqami, toq raqam bilan tugaydi
    //    (ya'ni mavjud foydalanuvchi → PIN kiritish).
    await tester.enterText(find.byType(TextField), '331234567');
    await tester.pump();
    await tester.tap(find.text('Davom etish'));
    await _settle(tester);
    expect(find.text('PIN kodni kiriting'), findsOneWidget);

    // 3. PIN: 1234 → Parent Home ochiladi (Student Home emas).
    for (final String d in <String>['1', '2', '3', '4']) {
      await tester.tap(find.widgetWithText(InkWell, d).first);
      await tester.pump();
    }
    await _settle(tester, frames: 14);

    // Rol saqlangan.
    expect(store['acadium_role'], 'parent');

    // Parent Home: salomlashish, farzand switcher va at-a-glance kartalar.
    expect(find.text('Sanjar'), findsOneWidget);
    expect(find.text('Amir Tursunov'), findsWidgets);
    expect(find.text('Bugungi dars'), findsOneWidget);
    expect(find.text('Kutilayotgan vazifa'), findsOneWidget);
    expect(find.text("O'rtacha baho"), findsOneWidget);
    expect(find.text("To'lov holati"), findsOneWidget);
    // Student oqimi ochilib qolmaganiga ishonch hosil qilamiz.
    expect(find.text('Jami XP'), findsNothing);

    // 4. Farzandlar tabi.
    await tester.tap(find.text('Farzandlar'));
    await _settle(tester, frames: 12);
    expect(find.text('Zilola Tursunova'), findsOneWidget);

    // 5. Ikkinchi farzandni tanlaymiz → Child Detail ochiladi.
    await tester.tap(find.text('Zilola Tursunova'));
    await _settle(tester, frames: 14);

    expect(find.text('Davomat'), findsOneWidget);
    expect(find.text('Vazifalar'), findsOneWidget);
    expect(find.text('Baholar'), findsOneWidget);
    expect(find.text('Jadval'), findsOneWidget);
    // Davomat tabi ochiq: Zilolaning fanlari ko'rinadi.
    expect(find.text('Matematika'), findsWidgets);

    // 6. Baholar tabiga o'tamiz.
    await tester.tap(find.text('Baholar'));
    await _settle(tester, frames: 12);
    expect(find.text('Kasrlar — nazorat ishi'), findsOneWidget);

    // 7. Orqaga → tanlangan farzand saqlanib qoladi (Riverpod holati).
    await tester.pageBack();
    await _settle(tester, frames: 12);

    // 8. To'lovlar tabi: Zilolaning kechikkan to'lovi ko'rinadi.
    await tester.tap(find.text("To'lovlar"));
    await _settle(tester, frames: 14);

    expect(find.text("To'lanishi kerak"), findsOneWidget);
    expect(find.text('Kechikkan'), findsWidgets);
    expect(find.text("O'tgan oy"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
