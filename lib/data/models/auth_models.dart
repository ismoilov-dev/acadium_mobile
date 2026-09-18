/// Foydalanuvchi roli. Backend `/auth/login/` javobida qaytaradi va
/// ilova shu qiymatga qarab Student yoki Parent oqimini ochadi.
enum UserRole {
  student('student', "O'quvchi"),
  parent('parent', 'Ota-ona');

  const UserRole(this.apiValue, this.label);

  final String apiValue;
  final String label;

  bool get isParent => this == UserRole.parent;

  static UserRole fromApi(String value) => UserRole.values.firstWhere(
        (UserRole r) => r.apiValue == value,
        orElse: () => UserRole.student,
      );
}

/// Telefon raqamni tekshirish natijasi.
/// Real API: `POST /auth/check-phone/` → {"registered": bool, ...}
class PhoneCheckResult {
  const PhoneCheckResult({
    required this.phone,
    required this.isRegistered,
    required this.role,
    this.maskedName,
  });

  final String phone;

  /// Raqam kimga tegishli: o'quvchigami yoki ota-onagami.
  final UserRole role;

  /// false bo'lsa — PIN o'rnatish (birinchi marta kirish) kerak.
  final bool isRegistered;

  /// "A***v" ko'rinishidagi ism (ixtiyoriy, PIN ekranida ko'rsatish uchun).
  final String? maskedName;

  factory PhoneCheckResult.fromJson(Map<String, dynamic> json) =>
      PhoneCheckResult(
        phone: json['phone'] as String,
        isRegistered: json['registered'] as bool,
        role: UserRole.fromApi(json['role'] as String? ?? 'student'),
        maskedName: json['masked_name'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'phone': phone,
        'registered': isRegistered,
        'role': role.apiValue,
        'masked_name': maskedName,
      };
}

/// Muvaffaqiyatli kirishdan keyingi sessiya.
/// Real API: `POST /auth/login/` → {"access": ..., "user_id": ..., "role": ...}
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.role,
    required this.phone,
    required this.deviceId,
    required this.expiresAt,
    this.refreshToken,
  });

  final String accessToken;

  /// Tizimga kirgan foydalanuvchi ID'si: rolga qarab o'quvchi yoki ota-ona.
  final String userId; // UUID

  /// Ilovaning qaysi oqimi ochilishini belgilaydi.
  final UserRole role;
  final String phone;
  final String deviceId; // UUID (ilova ichida generatsiya qilingan)
  final DateTime expiresAt;
  final String? refreshToken;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['access'] as String,
        refreshToken: json['refresh'] as String?,
        userId: json['user_id'] as String,
        role: UserRole.fromApi(json['role'] as String? ?? 'student'),
        phone: json['phone'] as String,
        deviceId: json['device_id'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access': accessToken,
        'refresh': refreshToken,
        'user_id': userId,
        'role': role.apiValue,
        'phone': phone,
        'device_id': deviceId,
        'expires_at': expiresAt.toIso8601String(),
      };
}
