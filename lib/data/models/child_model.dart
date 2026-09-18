import 'attendance_model.dart';

/// Ota-onaga bog'langan farzand. Backend: `/parents/{id}/children/`
class ChildModel {
  const ChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.groupName,
    required this.branchName,
    required this.totalXp,
    required this.level,
    required this.enrolledAt,
    this.avatarUrl,
  });

  final String id; // UUID — o'quvchining ID'si
  final String firstName;
  final String lastName;
  final String groupName;
  final String branchName;
  final int totalXp;
  final int level;
  final DateTime enrolledAt;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';

  String get initials {
    final String a = firstName.isNotEmpty ? firstName[0] : '';
    final String b = lastName.isNotEmpty ? lastName[0] : '';
    return (a + b).toUpperCase();
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) => ChildModel(
        id: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        groupName: json['group_name'] as String,
        branchName: json['branch_name'] as String? ?? '',
        totalXp: json['total_xp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        enrolledAt: DateTime.parse(json['enrolled_at'] as String),
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'group_name': groupName,
        'branch_name': branchName,
        'total_xp': totalXp,
        'level': level,
        'enrolled_at': enrolledAt.toIso8601String(),
        'avatar_url': avatarUrl,
      };
}

/// Bugungi dars holati — Home ekranidagi rangli belgi uchun.
enum TodayLessonStatus {
  /// Dars bo'lgan va farzand kelgan.
  attended('attended', 'Darsga keldi'),

  /// Dars bo'lgan, lekin kelmagan.
  missed('missed', 'Darsga kelmadi'),

  /// Dars kechikib boshlangan/kelgan.
  late('late', 'Kechikib keldi'),

  /// Dars hali bo'lmagan (kutilmoqda).
  pending('pending', 'Dars hali boshlanmagan'),

  /// Bugun dars yo'q.
  noLesson('no_lesson', 'Bugun dars yo\'q');

  const TodayLessonStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TodayLessonStatus fromApi(String value) =>
      TodayLessonStatus.values.firstWhere(
        (TodayLessonStatus s) => s.apiValue == value,
        orElse: () => TodayLessonStatus.pending,
      );

  /// Davomat yozuvidan holat yasash (ichki qulaylik uchun).
  static TodayLessonStatus fromAttendance(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return TodayLessonStatus.attended;
      case AttendanceStatus.late:
        return TodayLessonStatus.late;
      case AttendanceStatus.absent:
      case AttendanceStatus.excused:
        return TodayLessonStatus.missed;
    }
  }
}

/// Farzand bo'yicha "bir qarashda" ma'lumot (Parent Home ekrani uchun).
/// Backend: `/children/{id}/summary/`
class ChildSummary {
  const ChildSummary({
    required this.childId,
    required this.todayStatus,
    required this.pendingHomework,
    required this.averageGrade,
    required this.attendanceRate,
    required this.paymentStatusLabel,
    required this.paymentDueInDays,
    this.nextLessonSubject,
    this.nextLessonAt,
    this.nextLessonRoom,
  });

  final String childId;
  final TodayLessonStatus todayStatus;

  /// Topshirilmagan uy vazifalari soni.
  final int pendingHomework;

  /// 0..100 oralig'idagi o'rtacha baho.
  final double averageGrade;

  /// 0..1 oralig'idagi davomat.
  final double attendanceRate;

  /// To'lov holati matni (kartada ko'rsatish uchun).
  final String paymentStatusLabel;

  /// To'lov muddatigacha necha kun qolgani (manfiy — kechikkan).
  final int paymentDueInDays;

  final String? nextLessonSubject;
  final DateTime? nextLessonAt;
  final String? nextLessonRoom;

  factory ChildSummary.fromJson(Map<String, dynamic> json) => ChildSummary(
        childId: json['child_id'] as String,
        todayStatus: TodayLessonStatus.fromApi(json['today_status'] as String),
        pendingHomework: json['pending_homework'] as int? ?? 0,
        averageGrade: (json['average_grade'] as num? ?? 0).toDouble(),
        attendanceRate: (json['attendance_rate'] as num? ?? 0).toDouble(),
        paymentStatusLabel: json['payment_status_label'] as String? ?? '',
        paymentDueInDays: json['payment_due_in_days'] as int? ?? 0,
        nextLessonSubject: json['next_lesson_subject'] as String?,
        nextLessonAt: json['next_lesson_at'] == null
            ? null
            : DateTime.parse(json['next_lesson_at'] as String),
        nextLessonRoom: json['next_lesson_room'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'child_id': childId,
        'today_status': todayStatus.apiValue,
        'pending_homework': pendingHomework,
        'average_grade': averageGrade,
        'attendance_rate': attendanceRate,
        'payment_status_label': paymentStatusLabel,
        'payment_due_in_days': paymentDueInDays,
        'next_lesson_subject': nextLessonSubject,
        'next_lesson_at': nextLessonAt?.toIso8601String(),
        'next_lesson_room': nextLessonRoom,
      };
}
