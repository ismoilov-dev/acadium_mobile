import 'dart:math';

import '../../core/constants/app_constants.dart';
import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/auth_models.dart';
import 'auth_datasource.dart';
import 'mock/mock_data.dart';

/// [AuthDatasource]ning FAKE implementatsiyasi.
///
/// Haqiqiy server yo'q, lekin oqim to'liq simulyatsiya qilinadi:
///  * so'rovlar [ApiClient] orqali "yuboriladi" (token va device_id header'lari
///    yig'iladi va log qilinadi);
///  * tarmoq kechikishi Future.delayed bilan taqlid qilinadi;
///  * javoblar real backend qaytaradigan JSON formatida qaytariladi.
///
/// FAKE QOIDALARI (test qilish uchun):
///  * to'g'ri formatdagi har qanday +998 raqam "bazada bor" deb qabul qilinadi;
///  * raqamning oxirgi raqami JUFT bo'lsa — birinchi marta kirish (PIN o'rnatish);
///  * TOQ bo'lsa — mavjud foydalanuvchi (PIN kiritish);
///  * mavjud foydalanuvchi uchun to'g'ri PIN — "1234".
class FakeAuthDatasource implements AuthDatasource {
  FakeAuthDatasource(this._api);

  final ApiClient _api;
  final Random _random = Random();

  @override
  Future<PhoneCheckResult> checkPhone(String phone) async {
    final String digits = _normalize(phone);
    _validatePhone(digits);

    await _api.send(
      method: 'POST',
      path: '/auth/check-phone/',
      body: <String, dynamic>{'phone': digits},
    );

    // Oxirgi raqam juft bo'lsa — yangi foydalanuvchi (PIN o'rnatadi).
    final int lastDigit = int.parse(digits.lastChar);
    final bool isRegistered = lastDigit.isOdd;

    return PhoneCheckResult.fromJson(<String, dynamic>{
      'phone': digits,
      'registered': isRegistered,
      'masked_name': isRegistered ? 'A***v' : null,
    });
  }

  @override
  Future<AuthSession> registerPin({
    required String phone,
    required String pin,
    required String deviceId,
  }) async {
    final String digits = _normalize(phone);
    _validatePhone(digits);
    _validatePin(pin);

    await _api.send(
      method: 'POST',
      path: '/auth/set-pin/',
      body: <String, dynamic>{
        'phone': digits,
        'pin': pin,
        'device_id': deviceId,
      },
    );

    return _buildSession(phone: digits, deviceId: deviceId);
  }

  @override
  Future<AuthSession> loginWithPin({
    required String phone,
    required String pin,
    required String deviceId,
  }) async {
    final String digits = _normalize(phone);
    _validatePhone(digits);
    _validatePin(pin);

    await _api.send(
      method: 'POST',
      path: '/auth/login/',
      body: <String, dynamic>{
        'phone': digits,
        'pin': pin,
        'device_id': deviceId,
      },
    );

    if (pin != AppConstants.fakeValidPin) {
      throw const AuthException("PIN kod noto'g'ri. Qaytadan urinib ko'ring.");
    }

    return _buildSession(phone: digits, deviceId: deviceId);
  }

  @override
  Future<void> logout() async {
    await _api.send(method: 'POST', path: '/auth/logout/');
  }

  // ------------------------------------------------------------- yordamchilar

  /// Server qaytaradigan JSON'ga mos sessiya yasaydi.
  AuthSession _buildSession({required String phone, required String deviceId}) {
    return AuthSession.fromJson(<String, dynamic>{
      'access': _fakeToken(),
      'refresh': _fakeToken(),
      'student_id': MockData.studentId,
      'phone': phone,
      'device_id': deviceId,
      'expires_at':
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    });
  }

  /// JWT'ga o'xshash tasodifiy string.
  String _fakeToken() {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String segment(int length) => List<String>.generate(
          length,
          (_) => chars[_random.nextInt(chars.length)],
        ).join();
    return 'fake.${segment(24)}.${segment(32)}';
  }

  /// "+998 90 123 45 67" → "+998901234567"
  String _normalize(String phone) {
    final String digits = phone.replaceAll(RegExp(r'\D'), '');
    final String local = digits.startsWith('998') ? digits.substring(3) : digits;
    return '${AppConstants.phonePrefix}$local';
  }

  void _validatePhone(String normalized) {
    final RegExp pattern = RegExp(r'^\+998\d{9}$');
    if (!pattern.hasMatch(normalized)) {
      throw const ValidationException(
        "Telefon raqam noto'g'ri. Format: +998 90 123 45 67",
      );
    }
  }

  void _validatePin(String pin) {
    if (pin.length != AppConstants.pinLength ||
        !RegExp(r'^\d+$').hasMatch(pin)) {
      throw const ValidationException('PIN 4 ta raqamdan iborat bo\'lishi kerak.');
    }
  }
}

/// Kichik yordamchi: string'ning oxirgi belgisi.
extension on String {
  String get lastChar => isEmpty ? '0' : substring(length - 1);
}
