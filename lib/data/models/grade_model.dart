/// Baho turi.
enum GradeType {
  test('test', 'Test'),
  homework('homework', 'Uy vazifasi'),
  oral('oral', "Og'zaki"),
  exam('exam', 'Imtihon');

  const GradeType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static GradeType fromApi(String value) => GradeType.values.firstWhere(
        (GradeType t) => t.apiValue == value,
        orElse: () => GradeType.test,
      );
}

/// Bitta baho yozuvi.
class GradeModel {
  const GradeModel({
    required this.id,
    required this.subject,
    required this.title,
    required this.type,
    required this.score,
    required this.maxScore,
    required this.gradedAt,
    required this.teacherName,
    this.comment,
  });

  final String id; // UUID
  final String subject;
  final String title;
  final GradeType type;
  final int score;
  final int maxScore;
  final DateTime gradedAt;
  final String teacherName;
  final String? comment;

  /// 0..100 oralig'idagi foiz.
  double get percent => maxScore == 0 ? 0 : (score / maxScore) * 100;

  factory GradeModel.fromJson(Map<String, dynamic> json) => GradeModel(
        id: json['id'] as String,
        subject: json['subject'] as String,
        title: json['title'] as String,
        type: GradeType.fromApi(json['type'] as String),
        score: json['score'] as int,
        maxScore: json['max_score'] as int? ?? 100,
        gradedAt: DateTime.parse(json['graded_at'] as String),
        teacherName: json['teacher_name'] as String? ?? '',
        comment: json['comment'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'subject': subject,
        'title': title,
        'type': type.apiValue,
        'score': score,
        'max_score': maxScore,
        'graded_at': gradedAt.toIso8601String(),
        'teacher_name': teacherName,
        'comment': comment,
      };
}

/// Umumiy progress ko'rsatkichlari (0..1 oralig'ida).
/// Landing page'dagi "Progress" bloki bilan bir xil konsepsiya.
class ProgressSummary {
  const ProgressSummary({
    required this.attendance,
    required this.homework,
    required this.tests,
  });

  final double attendance;
  final double homework;
  final double tests;

  /// Uchta ko'rsatkichning o'rtachasi.
  double get overall => (attendance + homework + tests) / 3;

  static const ProgressSummary empty =
      ProgressSummary(attendance: 0, homework: 0, tests: 0);
}

/// Bir fan bo'yicha jamlangan baholar.
class SubjectGrades {
  const SubjectGrades({
    required this.subject,
    required this.grades,
  });

  final String subject;
  final List<GradeModel> grades;

  /// Fan bo'yicha o'rtacha foiz.
  double get averagePercent {
    if (grades.isEmpty) return 0;
    final double sum = grades.fold<double>(
      0,
      (double acc, GradeModel g) => acc + g.percent,
    );
    return sum / grades.length;
  }
}
