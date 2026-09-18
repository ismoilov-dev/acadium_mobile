import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

/// HTTP mijoz uchun umumiy interfeys.
///
/// Fake va real implementatsiyalar bir xil shartnomaga bo'ysunadi, shuning uchun
/// datasource'lar qaysi mijoz ishlayotganini bilmaydi.
abstract class ApiClient {
  String get baseUrl;

  /// Har bir so'rov uchun header'lar: token + device_id.
  Future<Map<String, String>> buildHeaders();

  /// So'rov yuborish. Real implementatsiyada decode qilingan JSON qaytadi.
  Future<dynamic> send({
    required String method,
    required String path,
    Map<String, dynamic>? query,
    Object? body,
  });
}

/// Fake rejim uchun mijoz.
///
/// Haqiqiy tarmoqqa chiqmaydi, lekin REAL mijoz qiladigan hamma narsani
/// bajaradi: token va device_id'ni secure storage'dan o'qiydi, header'larni
/// yig'adi, so'rovni log qiladi va tarmoq kechikishini simulyatsiya qiladi.
/// Shu sababli real API'ga o'tilganda auth oqimi allaqachon tayyor bo'ladi.
class FakeApiClient implements ApiClient {
  FakeApiClient(this._storage, {Duration? latency})
      : _latency = latency ?? AppConstants.fakeShortDelay;

  final SecureStorageService _storage;
  final Duration _latency;

  @override
  String get baseUrl => AppConstants.baseUrl;

  @override
  Future<Map<String, String>> buildHeaders() async {
    final String? token = await _storage.readAccessToken();
    final String deviceId = await _storage.getOrCreateDeviceId();

    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Device-Id': deviceId,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<dynamic> send({
    required String method,
    required String path,
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final Map<String, String> headers = await buildHeaders();

    debugPrint(
      '[FAKE API] $method $baseUrl$path'
      '${query == null ? '' : '?$query'} '
      'headers=$headers'
      '${body == null ? '' : ' body=$body'}',
    );

    await Future<void>.delayed(_latency);

    // Fake rejimda javob body'si datasource ichidagi mock JSON'dan olinadi,
    // shuning uchun bu yerda null qaytariladi. Real mijozda esa shu joyda
    // http response'ning decode qilingan JSON'i qaytariladi.
    return null;
  }
}
