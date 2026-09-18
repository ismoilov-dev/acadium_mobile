/// Ilovadagi barcha kutilgan xatoliklar uchun asosiy klass.
/// UI faqat shu turdagi xatoliklarni foydalanuvchiga ko'rsatadi.
class AppException implements Exception {
  const AppException(this.message);

  /// Foydalanuvchiga ko'rsatiladigan matn.
  final String message;

  /// Xatolik turi (log va tahlil uchun).
  String get code => 'unknown';

  @override
  String toString() => 'AppException($code): $message';
}

/// Tarmoq bilan bog'liq xatolik (timeout, internet yo'q, 5xx).
class NetworkException extends AppException {
  const NetworkException([
    super.message = "Tarmoqda muammo. Internetni tekshiring.",
  ]);

  @override
  String get code => 'network';
}

/// Avtorizatsiya xatoligi (401 / noto'g'ri PIN / token eskirgan).
class AuthException extends AppException {
  const AuthException(super.message);

  @override
  String get code => 'auth';
}

/// Ma'lumot topilmadi (404).
class NotFoundException extends AppException {
  const NotFoundException([super.message = "Ma'lumot topilmadi."]);

  @override
  String get code => 'not_found';
}

/// Kiritilgan ma'lumot noto'g'ri (422).
class ValidationException extends AppException {
  const ValidationException(super.message);

  @override
  String get code => 'validation';
}
