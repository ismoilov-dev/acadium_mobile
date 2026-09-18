import '../../core/error/app_exception.dart';
import '../../core/storage/secure_storage_service.dart';
import '../datasources/auth_datasource.dart';
import '../models/auth_models.dart';

/// Auth biznes-oqimi: datasource + xavfsiz xotira.
///
/// UI qatlami datasource'ni to'g'ridan-to'g'ri ko'rmaydi — faqat shu repository
/// bilan ishlaydi. Shu sababli fake/real almashtirilganda UI o'zgarmaydi.
class AuthRepository {
  AuthRepository({
    required AuthDatasource datasource,
    required SecureStorageService storage,
  })  : _datasource = datasource,
        _storage = storage;

  final AuthDatasource _datasource;
  final SecureStorageService _storage;

  /// Qurilmaning barqaror ID'si (birinchi chaqiruvda yaratiladi).
  Future<String> deviceId() => _storage.getOrCreateDeviceId();

  /// Saqlangan sessiya bormi? Splash ekrani shu metodga tayanadi.
  Future<bool> hasSession() => _storage.hasSession();

  Future<String?> savedStudentId() => _storage.readStudentId();

  Future<String?> savedPhone() => _storage.readPhone();

  /// Telefon raqamni tekshirish (birinchi marta kirishmi yoki yo'qmi).
  Future<PhoneCheckResult> checkPhone(String phone) =>
      _datasource.checkPhone(phone);

  /// Birinchi marta kirish: PIN o'rnatish.
  Future<AuthSession> setupPin({
    required String phone,
    required String pin,
  }) async {
    final String device = await deviceId();
    final AuthSession session = await _datasource.registerPin(
      phone: phone,
      pin: pin,
      deviceId: device,
    );
    await _persist(session);
    return session;
  }

  /// Mavjud foydalanuvchi: PIN bilan kirish.
  Future<AuthSession> loginWithPin({
    required String phone,
    required String pin,
  }) async {
    final String device = await deviceId();
    final AuthSession session = await _datasource.loginWithPin(
      phone: phone,
      pin: pin,
      deviceId: device,
    );
    await _persist(session);
    return session;
  }

  /// Saqlangan sessiyani tiklash (ilova qayta ochilganda).
  Future<AuthSession?> restoreSession() async {
    final String? token = await _storage.readAccessToken();
    final String? studentId = await _storage.readStudentId();
    final String? phone = await _storage.readPhone();
    final String? device = await _storage.readDeviceId();

    if (token == null || studentId == null || device == null) return null;

    return AuthSession(
      accessToken: token,
      refreshToken: await _storage.readRefreshToken(),
      studentId: studentId,
      phone: phone ?? '',
      deviceId: device,
      // Real API'da muddat token ichidan olinadi; hozircha uzoq muddat.
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// Chiqish: server sessiyasi yopiladi va lokal ma'lumot tozalanadi.
  /// device_id saqlanib qoladi — bu qurilmaning barqaror identifikatori.
  Future<void> logout() async {
    try {
      await _datasource.logout();
    } on AppException {
      // Server xatosi chiqishga to'sqinlik qilmasligi kerak.
    } finally {
      await _storage.clearSession();
    }
  }

  Future<void> _persist(AuthSession session) async {
    await _storage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _storage.saveStudentId(session.studentId);
    await _storage.savePhone(session.phone);
  }
}
