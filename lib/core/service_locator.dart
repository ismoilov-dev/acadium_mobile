import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/auth_datasource.dart';
import '../data/datasources/fake_auth_datasource.dart';
import '../data/datasources/fake_parent_datasource.dart';
import '../data/datasources/fake_student_datasource.dart';
import '../data/datasources/parent_datasource.dart';
import '../data/datasources/student_datasource.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/parent_repository.dart';
import '../data/repositories/student_repository.dart';
import 'network/api_client.dart';
import 'storage/secure_storage_service.dart';

/// ============================================================================
///                        YAGONA ALMASHTIRISH NUQTASI
/// ============================================================================
///
/// Butun ilovada qaysi datasource ishlashi SHU FAYLDA hal qilinadi.
///
/// Real backend tayyor bo'lganda:
///   1. `data/datasources/real_auth_datasource.dart`,
///      `real_student_datasource.dart` va `real_parent_datasource.dart`
///      fayllarini yozing (mos interfeyslarni implement qilib);
///   2. `core/network/real_api_client.dart` — http bilan ishlaydigan
///      [ApiClient] implementatsiyasini qo'shing;
///   3. quyidagi `kUseFakeData` ni `false` qiling (yoki `--dart-define` orqali
///      bering) va pastdagi izohlangan qatorlarni oching.
///
/// Boshqa HECH QANDAY faylga tegish shart emas: model'lar, repository'lar,
/// provider'lar va ekranlar o'zgarishsiz qoladi.
/// ============================================================================

/// Fake rejim yoqilganmi?
/// Terminaldan boshqarish: `flutter run --dart-define=USE_FAKE=false`
const bool kUseFakeData = bool.fromEnvironment('USE_FAKE', defaultValue: true);

// ----------------------------------------------------------------- Infratuzilma

/// Xavfsiz xotira (token, device_id).
final Provider<SecureStorageService> secureStorageProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());

/// HTTP mijoz. Fake rejimda so'rovlar log qilinadi, real rejimda yuboriladi.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final SecureStorageService storage = ref.watch(secureStorageProvider);
  if (kUseFakeData) {
    return FakeApiClient(storage);
  }
  // return RealApiClient(storage);
  throw UnimplementedError(
    'RealApiClient hali yozilmagan. kUseFakeData = true qiling.',
  );
});

// -------------------------------------------------------------- Datasource'lar

/// <<< ALMASHTIRISH NUQTASI 1 >>>
final Provider<AuthDatasource> authDatasourceProvider =
    Provider<AuthDatasource>((ref) {
  final ApiClient api = ref.watch(apiClientProvider);
  if (kUseFakeData) {
    return FakeAuthDatasource(api);
  }
  // return RealAuthDatasource(api);
  throw UnimplementedError('RealAuthDatasource hali yozilmagan.');
});

/// <<< ALMASHTIRISH NUQTASI 2 >>>
final Provider<StudentDatasource> studentDatasourceProvider =
    Provider<StudentDatasource>((ref) {
  final ApiClient api = ref.watch(apiClientProvider);
  if (kUseFakeData) {
    return FakeStudentDatasource(api);
  }
  // return RealStudentDatasource(api);
  throw UnimplementedError('RealStudentDatasource hali yozilmagan.');
});

/// <<< ALMASHTIRISH NUQTASI 3 (ota-ona oqimi) >>>
final Provider<ParentDatasource> parentDatasourceProvider =
    Provider<ParentDatasource>((ref) {
  final ApiClient api = ref.watch(apiClientProvider);
  if (kUseFakeData) {
    return FakeParentDatasource(api);
  }
  // return RealParentDatasource(api);
  throw UnimplementedError('RealParentDatasource hali yozilmagan.');
});

// -------------------------------------------------------------- Repository'lar

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(
          datasource: ref.watch(authDatasourceProvider),
          storage: ref.watch(secureStorageProvider),
        ));

final Provider<StudentRepository> studentRepositoryProvider =
    Provider<StudentRepository>((ref) => StudentRepository(
          datasource: ref.watch(studentDatasourceProvider),
        ));

final Provider<ParentRepository> parentRepositoryProvider =
    Provider<ParentRepository>((ref) => ParentRepository(
          datasource: ref.watch(parentDatasourceProvider),
        ));
