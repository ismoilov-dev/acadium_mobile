/// XP qayerdan kelgani.
enum XpSource {
  homework('homework', 'Uy vazifasi'),
  attendance('attendance', 'Davomat'),
  test('test', 'Test'),
  arena('arena', 'Arena'),
  bonus('bonus', 'Bonus');

  const XpSource(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static XpSource fromApi(String value) => XpSource.values.firstWhere(
        (XpSource s) => s.apiValue == value,
        orElse: () => XpSource.bonus,
      );
}

/// XP tarixidagi bitta yozuv.
class XpLogModel {
  const XpLogModel({
    required this.id,
    required this.amount,
    required this.reason,
    required this.source,
    required this.createdAt,
  });

  final String id; // UUID
  final int amount; // manfiy ham bo'lishi mumkin
  final String reason;
  final XpSource source;
  final DateTime createdAt;

  factory XpLogModel.fromJson(Map<String, dynamic> json) => XpLogModel(
        id: json['id'] as String,
        amount: json['amount'] as int,
        reason: json['reason'] as String,
        source: XpSource.fromApi(json['source'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'amount': amount,
        'reason': reason,
        'source': source.apiValue,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Reyting jadvalidagi bitta qator.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.studentId,
    required this.fullName,
    required this.totalXp,
    required this.rank,
    required this.isCurrentUser,
    this.avatarUrl,
  });

  final String studentId; // UUID
  final String fullName;
  final int totalXp;
  final int rank;
  final bool isCurrentUser;
  final String? avatarUrl;

  /// Ro'yxatda ko'rsatiladigan nom: o'zining qatorida "Siz" deb yoziladi.
  String get displayName => isCurrentUser ? 'Siz' : fullName;

  String get initials {
    final List<String> parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        studentId: json['student_id'] as String,
        fullName: json['full_name'] as String,
        totalXp: json['total_xp'] as int,
        rank: json['rank'] as int,
        isCurrentUser: json['is_current_user'] as bool? ?? false,
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'student_id': studentId,
        'full_name': fullName,
        'total_xp': totalXp,
        'rank': rank,
        'is_current_user': isCurrentUser,
        'avatar_url': avatarUrl,
      };
}
