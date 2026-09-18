import '../models/auth_models.dart';

/// Autentifikatsiya uchun ABSTRAKT interfeys.
///
/// Fake va real implementatsiyalar shu shartnomani bajaradi. UI va repository
/// qatlami faqat shu interfeysni biladi — implementatsiya almashtirilganda
/// hech qanday boshqa kod o'zgarmaydi.
abstract class AuthDatasource {
  /// Telefon raqam bazada bor-yo'qligini tekshiradi.
  /// `isRegistered == false` bo'lsa — PIN o'rnatish oqimi boshlanadi.
  Future<PhoneCheckResult> checkPhone(String phone);

  /// Birinchi marta kirish: PIN o'rnatiladi va sessiya ochiladi.
  Future<AuthSession> registerPin({
    required String phone,
    required String pin,
    required String deviceId,
  });

  /// Mavjud foydalanuvchi: PIN bilan kirish.
  Future<AuthSession> loginWithPin({
    required String phone,
    required String pin,
    required String deviceId,
  });

  /// Serverdagi sessiyani yopish (real API'da refresh token bekor qilinadi).
  Future<void> logout();
}
