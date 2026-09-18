import 'package:uuid/uuid.dart';

import 'mock_data.dart';

/// Fake backend uchun XOTIRADAGI "baza".
///
/// [MockData] — o'zgarmas boshlang'ich ma'lumot, [MockState] esa sessiya
/// davomida o'zgarib turadigan holat: uy vazifasi topshirildi, arena
/// topshirig'i bajarildi, XP qo'shildi, reyting qayta hisoblandi.
///
/// Real API'ga o'tilganda bu fayl umuman kerak bo'lmaydi.
class MockState {
  MockState._() {
    reset();
  }

  /// Ilova davomida yagona nusxa (datasource qayta yaratilsa ham holat saqlanadi).
  static final MockState instance = MockState._();

  static const Uuid _uuid = Uuid();

  late List<Map<String, dynamic>> homework;
  late List<Map<String, dynamic>> notifications;

  /// Ota-ona ilovasidagi bildirishnomalar (o'qilgan holati o'zgarib turadi).
  late List<Map<String, dynamic>> parentNotifications;
  late List<Map<String, dynamic>> arenaTasks;
  late List<Map<String, dynamic>> leaderboard;
  late List<Map<String, dynamic>> xpLogs;
  late int totalXp;

  /// Boshlang'ich holatga qaytarish (testlar uchun ham ishlatiladi).
  void reset() {
    homework = MockData.homework();
    notifications = MockData.notifications();
    parentNotifications = MockData.parentNotifications();
    arenaTasks = MockData.arenaTasks();
    leaderboard = MockData.leaderboard();
    xpLogs = MockData.xpLogs();
    totalXp = MockData.totalXp;
  }

  /// Foydalanuvchining reytingdagi joriy o'rni.
  int get currentRank {
    for (final Map<String, dynamic> entry in leaderboard) {
      if (entry['is_current_user'] == true) return entry['rank'] as int;
    }
    return leaderboard.length;
  }

  /// XP qo'shadi: jami XP, XP tarixi va reyting birdaniga yangilanadi.
  /// Yangilangan jami XP qaytariladi.
  int awardXp({
    required int amount,
    required String reason,
    String source = 'arena',
  }) {
    totalXp += amount;

    xpLogs.insert(0, <String, dynamic>{
      'id': _uuid.v4(),
      'amount': amount,
      'reason': reason,
      'source': source,
      'created_at': DateTime.now().toIso8601String(),
    });

    _syncLeaderboard();
    return totalXp;
  }

  /// Yangi bildirishnoma qo'shadi (o'qilmagan holatda).
  void addNotification({
    required String type,
    required String title,
    required String body,
    String? targetId,
  }) {
    notifications.insert(0, <String, dynamic>{
      'id': _uuid.v4(),
      'type': type,
      'title': title,
      'body': body,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': false,
      'target_id': targetId,
    });
  }

  /// Foydalanuvchining XP'sini reytingga yozib, o'rinlarni qayta hisoblaydi.
  void _syncLeaderboard() {
    for (final Map<String, dynamic> entry in leaderboard) {
      if (entry['is_current_user'] == true) entry['total_xp'] = totalXp;
    }

    leaderboard.sort((Map<String, dynamic> a, Map<String, dynamic> b) =>
        (b['total_xp'] as int).compareTo(a['total_xp'] as int));

    for (int i = 0; i < leaderboard.length; i++) {
      leaderboard[i]['rank'] = i + 1;
    }
  }
}
