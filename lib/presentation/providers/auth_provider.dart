import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/service_locator.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';

/// Sessiya holati.
enum AuthFlowStatus {
  /// Splash: saqlangan token tekshirilmoqda.
  checking,

  /// Token yo'q — login oqimi.
  unauthenticated,

  /// Token bor — ilova ichiga kiritish mumkin.
  authenticated,
}

/// Auth ekranlari uchun umumiy holat.
class AuthState {
  const AuthState({
    this.status = AuthFlowStatus.checking,
    this.session,
    this.phone,
    this.isBusy = false,
    this.errorMessage,
  });

  final AuthFlowStatus status;
  final AuthSession? session;

  /// Login oqimida kiritilgan telefon raqam (ekranlar orasida saqlanadi).
  final String? phone;

  /// So'rov ketayotganda tugmalarni bloklash uchun.
  final bool isBusy;

  /// Foydalanuvchiga ko'rsatiladigan xatolik.
  final String? errorMessage;

  AuthState copyWith({
    AuthFlowStatus? status,
    AuthSession? session,
    String? phone,
    bool? isBusy,
    String? errorMessage,
    bool clearError = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        session: session ?? this.session,
        phone: phone ?? this.phone,
        isBusy: isBusy ?? this.isBusy,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Auth oqimini boshqaruvchi controller.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  /// Ilova ochilganda: saqlangan sessiyani tiklash.
  Future<void> bootstrap() async {
    state = state.copyWith(status: AuthFlowStatus.checking, clearError: true);

    // device_id hali yaratilmagan bo'lsa — shu yerda yaratiladi.
    await _repository.deviceId();

    final AuthSession? session = await _repository.restoreSession();
    if (session == null || session.isExpired) {
      state = const AuthState(status: AuthFlowStatus.unauthenticated);
      return;
    }
    state = AuthState(
      status: AuthFlowStatus.authenticated,
      session: session,
      phone: session.phone,
    );
  }

  /// Telefon raqamni tekshirish. Natija null bo'lsa — xatolik yuz bergan.
  Future<PhoneCheckResult?> checkPhone(String phone) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final PhoneCheckResult result = await _repository.checkPhone(phone);
      state = state.copyWith(isBusy: false, phone: result.phone);
      return result;
    } on AppException catch (e) {
      state = state.copyWith(isBusy: false, errorMessage: e.message);
      return null;
    }
  }

  /// Birinchi marta kirish: PIN o'rnatish.
  Future<bool> setupPin(String pin) => _authenticate(
        () => _repository.setupPin(phone: state.phone ?? '', pin: pin),
      );

  /// Mavjud foydalanuvchi: PIN bilan kirish.
  Future<bool> loginWithPin(String pin) => _authenticate(
        () => _repository.loginWithPin(phone: state.phone ?? '', pin: pin),
      );

  /// Chiqish.
  Future<void> logout() async {
    state = state.copyWith(isBusy: true);
    await _repository.logout();
    state = const AuthState(status: AuthFlowStatus.unauthenticated);
  }

  /// Xatolik xabarini tozalash (masalan PIN qayta kiritilganda).
  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> _authenticate(Future<AuthSession> Function() action) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final AuthSession session = await action();
      state = AuthState(
        status: AuthFlowStatus.authenticated,
        session: session,
        phone: session.phone,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isBusy: false, errorMessage: e.message);
      return false;
    }
  }
}

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);

/// Joriy o'quvchi ID'si (sessiya bo'lmasa — null).
///
/// Ataylab null qaytaradi: logout paytida hali ekrandan ketmagan vidjetlar
/// sinxron xatolik tufayli qulab tushmasligi kerak.
final Provider<String?> currentStudentIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).session?.studentId;
});

/// Ma'lumot yuklaydigan async provider'lar uchun: ID bo'lmasa xatolik.
/// `async` blok ichida chaqiriladi, shuning uchun xatolik AsyncValue.error
/// ko'rinishida UI'ga yetib boradi va ErrorView ko'rsatiladi.
String requireStudentId(Ref ref) {
  final String? studentId = ref.watch(currentStudentIdProvider);
  if (studentId == null) {
    throw const AuthException('Sessiya topilmadi. Qaytadan kiring.');
  }
  return studentId;
}
