/// O'quvchi profili. Backend'dagi `/students/{id}/` javobiga mos keladi.
class StudentModel {
  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.groupId,
    required this.groupName,
    required this.branchName,
    required this.totalXp,
    required this.level,
    required this.enrolledAt,
    this.avatarUrl,
  });

  final String id; // UUID
  final String firstName;
  final String lastName;
  final String phone;
  final String groupId; // UUID
  final String groupName;
  final String branchName;
  final int totalXp;
  final int level;
  final DateTime enrolledAt;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';

  /// Avatar uchun bosh harflar: "A. I."
  String get initials {
    final String a = firstName.isNotEmpty ? firstName[0] : '';
    final String b = lastName.isNotEmpty ? lastName[0] : '';
    return (a + b).toUpperCase();
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        phone: json['phone'] as String,
        groupId: json['group_id'] as String,
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
        'phone': phone,
        'group_id': groupId,
        'group_name': groupName,
        'branch_name': branchName,
        'total_xp': totalXp,
        'level': level,
        'enrolled_at': enrolledAt.toIso8601String(),
        'avatar_url': avatarUrl,
      };
}
