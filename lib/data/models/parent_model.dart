/// Ota-ona profili. Backend: `/parents/{id}/`
class ParentModel {
  const ParentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.childrenCount,
    required this.createdAt,
    this.avatarUrl,
  });

  final String id; // UUID
  final String firstName;
  final String lastName;
  final String phone;

  /// Bog'langan farzandlar soni.
  final int childrenCount;
  final DateTime createdAt;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';

  String get initials {
    final String a = firstName.isNotEmpty ? firstName[0] : '';
    final String b = lastName.isNotEmpty ? lastName[0] : '';
    return (a + b).toUpperCase();
  }

  factory ParentModel.fromJson(Map<String, dynamic> json) => ParentModel(
        id: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        phone: json['phone'] as String,
        childrenCount: json['children_count'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'children_count': childrenCount,
        'created_at': createdAt.toIso8601String(),
        'avatar_url': avatarUrl,
      };
}
