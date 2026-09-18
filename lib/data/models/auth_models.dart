/// Telefon raqamni tekshirish natijasi.
/// Real API: `POST /auth/check-phone/` → {"registered": bool, ...}
class PhoneCheckResult {
  const PhoneCheckResult({
    required this.phone,
    required this.isRegistered,
    this.maskedName,
  });

  final String phone;

  /// false bo'lsa — PIN o'rnatish (birinchi marta kirish) kerak.
  final bool isRegistered;

  /// "A***v" ko'rinishidagi ism (ixtiyoriy, PIN ekranida ko'rsatish uchun).
  final String? maskedName;

  factory PhoneCheckResult.fromJson(Map<String, dynamic> json) => PhoneCheckResult(
        phone: json['phone'] as String,
        isRegistered: json['registered'] as bool,
        maskedName: json['masked_name'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'phone': phone,
        'registered': isRegistered,
        'masked_name': maskedName,
      };
}

/// Muvaffaqiyatli kirishdan keyingi sessiya.
/// Real API: `POST /auth/login/` → {"access": ..., "refresh": ..., "student_id": ...}
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.studentId,
    required this.phone,
    required this.deviceId,
    required this.expiresAt,
    this.refreshToken,
  });

  final String accessToken;
  final String studentId; // UUID
  final String phone;
  final String deviceId; // UUID (ilova ichida generatsiya qilingan)
  final DateTime expiresAt;
  final String? refreshToken;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['access'] as String,
        refreshToken: json['refresh'] as String?,
        studentId: json['student_id'] as String,
        phone: json['phone'] as String,
        deviceId: json['device_id'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access': accessToken,
        'refresh': refreshToken,
        'student_id': studentId,
        'phone': phone,
        'device_id': deviceId,
        'expires_at': expiresAt.toIso8601String(),
      };
}
