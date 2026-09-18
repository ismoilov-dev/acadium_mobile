/// Ilova bo'yicha umumiy konstantalar.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Acadium';
  static const String appTagline = "Bilim — sizning super kuchingiz";

  /// Real backend manzili (hozircha ishlatilmaydi, fake rejimda log uchun).
  static const String baseUrl = 'https://api.acadium.uz/api/v1';

  /// Fake tarmoq kechikishi — yuklanish holatlarini ko'rish uchun.
  static const Duration fakeShortDelay = Duration(milliseconds: 500);
  static const Duration fakeLongDelay = Duration(milliseconds: 900);

  /// Telefon raqam formati: +998 XX XXX XX XX
  static const String phonePrefix = '+998';
  static const int phoneDigits = 9; // prefiksdan keyingi raqamlar soni
  static const int pinLength = 4;

  /// Fake rejimda doim to'g'ri deb qabul qilinadigan PIN.
  static const String fakeValidPin = '1234';

  /// Fake rejimda ROL shu operator kodi bo'yicha aniqlanadi:
  /// `+998 33 ...` → ota-ona, boshqa kodlar → o'quvchi.
  /// Real API'da rol serverdan (`/auth/login/` javobidan) keladi.
  static const String fakeParentOperatorCode = '33';

  /// Secure storage kalitlari.
  static const String keyAccessToken = 'acadium_access_token';
  static const String keyRefreshToken = 'acadium_refresh_token';
  static const String keyDeviceId = 'acadium_device_id';
  static const String keyUserId = 'acadium_user_id';
  static const String keyRole = 'acadium_role';
  static const String keyPhone = 'acadium_phone';
}

/// Named route nomlari.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String phoneLogin = '/auth/phone';
  static const String pinSetup = '/auth/pin-setup';
  static const String pinLogin = '/auth/pin-login';
  static const String shell = '/shell';
  static const String parentShell = '/parent';
  static const String notifications = '/notifications';
  static const String parentNotifications = '/parent/notifications';
}
