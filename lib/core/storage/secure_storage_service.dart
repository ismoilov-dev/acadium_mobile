import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';

/// flutter_secure_storage ustidagi yupqa qatlam.
/// Token, device_id va sessiya ma'lumotlari faqat shu klass orqali saqlanadi.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage, Uuid? uuid})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions:
                  IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            ),
        _uuid = uuid ?? const Uuid();

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  // ---------------------------------------------------------------- token

  Future<String?> readAccessToken() =>
      _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(
          key: AppConstants.keyRefreshToken, value: refreshToken);
    }
  }

  // ------------------------------------------------------------ device id

  /// Ilova ichida generatsiya qilinadigan BARQAROR device_id.
  /// Android/iOS qurilma ID'siga bog'liq emas: birinchi chaqiruvda UUID
  /// yaratiladi va keyingi barcha safar o'sha qiymat qaytariladi.
  Future<String> getOrCreateDeviceId() async {
    final String? existing = await _storage.read(key: AppConstants.keyDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;

    final String deviceId = _uuid.v4();
    await _storage.write(key: AppConstants.keyDeviceId, value: deviceId);
    return deviceId;
  }

  Future<String?> readDeviceId() =>
      _storage.read(key: AppConstants.keyDeviceId);

  // --------------------------------------------------------------- sessiya

  Future<void> saveUserId(String userId) =>
      _storage.write(key: AppConstants.keyUserId, value: userId);

  Future<String?> readUserId() => _storage.read(key: AppConstants.keyUserId);

  /// Foydalanuvchi roli — ilova ochilganda qaysi oqim tiklanishini belgilaydi.
  Future<void> saveRole(String role) =>
      _storage.write(key: AppConstants.keyRole, value: role);

  Future<String?> readRole() => _storage.read(key: AppConstants.keyRole);

  Future<void> savePhone(String phone) =>
      _storage.write(key: AppConstants.keyPhone, value: phone);

  Future<String?> readPhone() => _storage.read(key: AppConstants.keyPhone);

  /// Foydalanuvchi tizimga kirganmi?
  Future<bool> hasSession() async {
    final String? token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout — device_id SAQLANIB QOLADI (qurilma o'zgarmagani uchun),
  /// faqat sessiya ma'lumotlari o'chiriladi.
  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyUserId);
    await _storage.delete(key: AppConstants.keyRole);
    await _storage.delete(key: AppConstants.keyPhone);
  }

  /// Hamma narsani o'chirish (device_id ham).
  Future<void> wipe() => _storage.deleteAll();
}
