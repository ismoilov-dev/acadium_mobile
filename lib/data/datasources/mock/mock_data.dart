/// Fake (mock) ma'lumotlar manbasi.
///
/// Bu yerdagi barcha JSON'lar REAL backend (Django REST / Supabase) qaytaradigan
/// formatga imkon qadar yaqin: `id` — UUID string, sanalar — ISO 8601,
/// enum'lar — snake_case string, kalitlar — snake_case.
///
/// Sanalar joriy vaqtga nisbatan generatsiya qilinadi, shuning uchun ilova
/// qachon ochilmasin jadval va muddatlar "tirik" ko'rinadi.
class MockData {
  const MockData._();

  // ------------------------------------------------------------------ ID'lar
  static const String studentId = '9f8b1c2d-4e5a-4f6b-8c7d-1a2b3c4d5e6f';
  static const String groupId = '1b2c3d4e-5f60-4a71-8b92-0c1d2e3f4a5b';

  // ------------------------------------------------------------- Yordamchilar

  /// Bugungi kunning 00:00 vaqti.
  static DateTime get _today {
    final DateTime n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Joriy haftaning dushanbasi (00:00).
  static DateTime get _weekStart => _today.subtract(Duration(days: _today.weekday - 1));

  /// Joriy haftaning [weekday] kunidagi [hour]:[minute] vaqti.
  /// weekday: 1 = Dushanba ... 7 = Yakshanba
  static DateTime _at(int weekday, int hour, int minute) =>
      _weekStart.add(Duration(days: weekday - 1)).add(
            Duration(hours: hour, minutes: minute),
          );

  static String _iso(DateTime dt) => dt.toIso8601String();

  // --------------------------------------------------------------- 1. Profil

  static Map<String, dynamic> student() => <String, dynamic>{
        'id': studentId,
        'first_name': 'Amir',
        'last_name': 'Tursunov',
        'phone': '+998901234567',
        'group_id': groupId,
        'group_name': 'IELTS Intensive — B2',
        'branch_name': 'Chilonzor filiali',
        'total_xp': 1240,
        'level': 7,
        'enrolled_at': _iso(_today.subtract(const Duration(days: 96))),
        'avatar_url': null,
      };

  // -------------------------------------------------------------- 2. Jadval

  /// Haftalik dars jadvali (joriy hafta uchun).
  static List<Map<String, dynamic>> lessons() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'aa000001-0000-4000-8000-000000000001',
          'subject': 'Ingliz tili',
          'teacher_name': 'Dilnoza Karimova',
          'room': '204-xona',
          'format': 'offline',
          'starts_at': _iso(_at(1, 14, 0)),
          'ends_at': _iso(_at(1, 15, 30)),
          'topic': 'Present Perfect vs Past Simple',
        },
        <String, dynamic>{
          'id': 'aa000001-0000-4000-8000-000000000002',
          'subject': 'Matematika',
          'teacher_name': 'Bekzod Rahimov',
          'room': '301-xona',
          'format': 'offline',
          'starts_at': _iso(_at(1, 16, 0)),
          'ends_at': _iso(_at(1, 17, 30)),
          'topic': 'Kvadrat tenglamalar',
        },
        <String, dynamic>{
          'id': 'aa000001-0000-4000-8000-000000000003',
          'subject': 'IELTS Speaking',
          'teacher_name': 'Madina Yusupova',
          'room': 'Zoom',
          'format': 'online',
          'starts_at': _iso(_at(2, 18, 0)),
          'ends_at': _iso(_at(2, 19, 0)),
          'topic': 'Part 2: Cue card practice',
        },
        <String, dynamic>{
          'id': 'aa000001-0000-4000-8000-000000000004',
          'subject': 'Ingliz tili',
          'teacher_name': 'Dilnoza Karimova',
          'room': '204-xona',
          'format': 'offline',
          'starts_at': _iso(_at(3, 14, 0)),
          'ends_at': _iso(_at(3, 15, 30)),
          'topic': 'Reading: True / False / Not Given',
        },
        <String, dynamic>{
          'id': 'aa000001-0000-4000-8000-000000000005',
          'subject': 'Kompyuter savodxonligi',
          'teacher_name': 'Sardor Nazarov',
          'room': '105-xona',
          'format': 'offline',
          'starts_at': _iso(_at(3, 16, 0)),
          'ends_at': _iso(_at(3, 17, 0)),
          'topic': 'Excel: formulalar bilan ishlash',
        },
        <String, dynamic>{
          'id': 'aa000001-0000-4000-8000-000000000006',
          'subject': 'Matematika',
          'teacher_name': 'Bekzod Rahimov',
          'room': '301-xona',
          'format': 'offline',
          'starts_at': _iso(_at(4, 14, 0)),
          'ends_at': _iso(_at(4, 15, 30)),
          'topic': 'Funksiya grafiklari',
        },
        <String, dynamic>{
          'id': 'aa000001-0000-4000-8000-000000000007',
          'subject': 'IELTS Speaking',
          'teacher_name': 'Madina Yusupova',
          'room': 'Zoom',
          'format': 'online',
          'starts_at': _iso(_at(5, 18, 0)),
          'ends_at': _iso(_at(5, 19, 0)),
          'topic': 'Part 3: Abstract questions',
        },
        <String, dynamic>{
          'id': 'aa000001-0000-4000-8000-000000000008',
          'subject': 'Ingliz tili',
          'teacher_name': 'Dilnoza Karimova',
          'room': '204-xona',
          'format': 'offline',
          'starts_at': _iso(_at(6, 10, 0)),
          'ends_at': _iso(_at(6, 12, 0)),
          'topic': 'Mock test: Listening + Reading',
        },
      ];

  // ------------------------------------------------------------- 3. Davomat

  static List<Map<String, dynamic>> attendance() {
    const List<String> subjects = <String>[
      'Ingliz tili',
      'Matematika',
      'IELTS Speaking',
      'Kompyuter savodxonligi',
    ];
    // Oxirgi 20 ta dars: 17 ta keldi, 2 ta kechikdi, 1 ta sababli.
    const List<String> statuses = <String>[
      'present', 'present', 'late', 'present', 'present',
      'present', 'present', 'present', 'excused', 'present',
      'present', 'late', 'present', 'present', 'present',
      'present', 'present', 'present', 'present', 'present',
    ];

    return List<Map<String, dynamic>>.generate(statuses.length, (int i) {
      final DateTime date = _today.subtract(Duration(days: (i + 1) * 2));
      return <String, dynamic>{
        'id': 'bb0000${i.toString().padLeft(2, '0')}-0000-4000-8000-000000000001',
        'lesson_id': 'aa000001-0000-4000-8000-00000000000${(i % 8) + 1}',
        'subject': subjects[i % subjects.length],
        'date': _iso(date.add(const Duration(hours: 14))),
        'status': statuses[i],
        'note': statuses[i] == 'excused' ? 'Shifokor ma\'lumotnomasi' : null,
      };
    });
  }

  // -------------------------------------------------------- 4. Uy vazifalari

  static List<Map<String, dynamic>> homework() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'cc000001-0000-4000-8000-000000000001',
          'subject': 'Ingliz tili',
          'title': 'Unit 7: Writing Task 2 essay',
          'description':
              'Mavzu: "Some people think that technology makes life more '
                  'complicated". Kamida 250 so\'zdan iborat essay yozing. '
                  'Kirish, 2 ta asosiy paragraf va xulosa bo\'lishi shart.',
          'teacher_name': 'Dilnoza Karimova',
          'assigned_at': _iso(_today.subtract(const Duration(days: 1))),
          'due_at': _iso(_today.add(const Duration(days: 2, hours: 20))),
          'status': 'assigned',
          'max_score': 100,
          'xp_reward': 60,
          'score': null,
          'submitted_at': null,
          'teacher_comment': null,
          'attachments': <String>['essay_template.pdf'],
        },
        <String, dynamic>{
          'id': 'cc000001-0000-4000-8000-000000000002',
          'subject': 'Matematika',
          'title': 'Kvadrat tenglamalar — 12 ta masala',
          'description':
              'Darslikning 84-betidagi 1-12 masalalarni yeching. '
                  'Har bir masalaning yechimi bosqichma-bosqich yozilsin.',
          'teacher_name': 'Bekzod Rahimov',
          'assigned_at': _iso(_today.subtract(const Duration(days: 2))),
          'due_at': _iso(_today.add(const Duration(hours: 21))),
          'status': 'assigned',
          'max_score': 100,
          'xp_reward': 50,
          'score': null,
          'submitted_at': null,
          'teacher_comment': null,
          'attachments': <String>[],
        },
        <String, dynamic>{
          'id': 'cc000001-0000-4000-8000-000000000003',
          'subject': 'IELTS Speaking',
          'title': 'Cue card: Describe a place you visited',
          'description':
              '2 daqiqalik nutqingizni ovozli yozib, audio faylni yuklang.',
          'teacher_name': 'Madina Yusupova',
          'assigned_at': _iso(_today.subtract(const Duration(days: 4))),
          'due_at': _iso(_today.subtract(const Duration(days: 1))),
          'status': 'submitted',
          'max_score': 100,
          'xp_reward': 40,
          'score': null,
          'submitted_at': _iso(_today.subtract(const Duration(days: 1, hours: 3))),
          'teacher_comment': null,
          'attachments': <String>[],
        },
        <String, dynamic>{
          'id': 'cc000001-0000-4000-8000-000000000004',
          'subject': 'Ingliz tili',
          'title': 'Unit 6: Vocabulary quiz',
          'description': '40 ta yangi so\'zni yodlab, onlayn testni yeching.',
          'teacher_name': 'Dilnoza Karimova',
          'assigned_at': _iso(_today.subtract(const Duration(days: 8))),
          'due_at': _iso(_today.subtract(const Duration(days: 5))),
          'status': 'reviewed',
          'max_score': 100,
          'xp_reward': 45,
          'score': 92,
          'submitted_at': _iso(_today.subtract(const Duration(days: 6))),
          'teacher_comment': 'Juda yaxshi! Faqat 3 ta so\'zda xato bor.',
          'attachments': <String>[],
        },
        <String, dynamic>{
          'id': 'cc000001-0000-4000-8000-000000000005',
          'subject': 'Kompyuter savodxonligi',
          'title': 'Excel: byudjet jadvali',
          'description':
              'Oylik byudjet jadvalini yarating: SUM, AVERAGE va IF '
                  'formulalaridan foydalaning.',
          'teacher_name': 'Sardor Nazarov',
          'assigned_at': _iso(_today.subtract(const Duration(days: 11))),
          'due_at': _iso(_today.subtract(const Duration(days: 9))),
          'status': 'late',
          'max_score': 100,
          'xp_reward': 30,
          'score': null,
          'submitted_at': null,
          'teacher_comment': null,
          'attachments': <String>[],
        },
        <String, dynamic>{
          'id': 'cc000001-0000-4000-8000-000000000006',
          'subject': 'Matematika',
          'title': 'Funksiya grafiklari — mustaqil ish',
          'description': '5 ta funksiyaning grafigini daftarda chizing.',
          'teacher_name': 'Bekzod Rahimov',
          'assigned_at': _iso(_today.subtract(const Duration(days: 14))),
          'due_at': _iso(_today.subtract(const Duration(days: 11))),
          'status': 'reviewed',
          'max_score': 100,
          'xp_reward': 50,
          'score': 78,
          'submitted_at': _iso(_today.subtract(const Duration(days: 12))),
          'teacher_comment': 'Grafiklar to\'g\'ri, lekin masshtab noaniq.',
          'attachments': <String>[],
        },
      ];

  // --------------------------------------------------------------- 5. Baholar

  static List<Map<String, dynamic>> grades() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'dd000001-0000-4000-8000-000000000001',
          'subject': 'Ingliz tili',
          'title': 'Unit 7 — Progress test',
          'type': 'test',
          'score': 88,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 1, hours: 5))),
          'teacher_name': 'Dilnoza Karimova',
          'comment': 'Listening qismi a\'lo darajada.',
        },
        <String, dynamic>{
          'id': 'dd000001-0000-4000-8000-000000000002',
          'subject': 'Matematika',
          'title': 'Kvadrat tenglamalar — nazorat',
          'type': 'test',
          'score': 74,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 3, hours: 2))),
          'teacher_name': 'Bekzod Rahimov',
          'comment': 'Diskriminantda hisoblash xatolari bor.',
        },
        <String, dynamic>{
          'id': 'dd000001-0000-4000-8000-000000000003',
          'subject': 'Ingliz tili',
          'title': 'Unit 6: Vocabulary quiz',
          'type': 'homework',
          'score': 92,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 5))),
          'teacher_name': 'Dilnoza Karimova',
          'comment': null,
        },
        <String, dynamic>{
          'id': 'dd000001-0000-4000-8000-000000000004',
          'subject': 'IELTS Speaking',
          'title': 'Speaking mock — Part 1',
          'type': 'oral',
          'score': 81,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 7))),
          'teacher_name': 'Madina Yusupova',
          'comment': 'Fluency yaxshi, grammatikaga e\'tibor bering.',
        },
        <String, dynamic>{
          'id': 'dd000001-0000-4000-8000-000000000005',
          'subject': 'Matematika',
          'title': 'Funksiya grafiklari',
          'type': 'homework',
          'score': 78,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 11))),
          'teacher_name': 'Bekzod Rahimov',
          'comment': null,
        },
        <String, dynamic>{
          'id': 'dd000001-0000-4000-8000-000000000006',
          'subject': 'Kompyuter savodxonligi',
          'title': 'Word: hujjat formatlash',
          'type': 'test',
          'score': 95,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 15))),
          'teacher_name': 'Sardor Nazarov',
          'comment': 'Barcha topshiriqlar bajarilgan.',
        },
        <String, dynamic>{
          'id': 'dd000001-0000-4000-8000-000000000007',
          'subject': 'Ingliz tili',
          'title': 'Mid-term imtihon',
          'type': 'exam',
          'score': 84,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 21))),
          'teacher_name': 'Dilnoza Karimova',
          'comment': null,
        },
      ];

  // -------------------------------------------------------------- 6. XP / Arena

  static const int totalXp = 1240;

  static List<Map<String, dynamic>> xpLogs() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'ee000001-0000-4000-8000-000000000001',
          'amount': 45,
          'reason': 'Unit 6: Vocabulary quiz topshirildi',
          'source': 'homework',
          'created_at': _iso(_today.subtract(const Duration(days: 1, hours: 4))),
        },
        <String, dynamic>{
          'id': 'ee000001-0000-4000-8000-000000000002',
          'amount': 20,
          'reason': 'Darsga o\'z vaqtida kelish (5 kun ketma-ket)',
          'source': 'attendance',
          'created_at': _iso(_today.subtract(const Duration(days: 2))),
        },
        <String, dynamic>{
          'id': 'ee000001-0000-4000-8000-000000000003',
          'amount': 60,
          'reason': 'Progress test — 88 ball',
          'source': 'test',
          'created_at': _iso(_today.subtract(const Duration(days: 3))),
        },
        <String, dynamic>{
          'id': 'ee000001-0000-4000-8000-000000000004',
          'amount': 100,
          'reason': 'Haftalik arena topshirig\'i bajarildi',
          'source': 'arena',
          'created_at': _iso(_today.subtract(const Duration(days: 6))),
        },
        <String, dynamic>{
          'id': 'ee000001-0000-4000-8000-000000000005',
          'amount': -15,
          'reason': 'Uy vazifasi kechiktirildi',
          'source': 'homework',
          'created_at': _iso(_today.subtract(const Duration(days: 9))),
        },
      ];

  /// Guruh reytingi — landing page'dagi format: 1-o'rin Madina 1480, 2-o'rin Siz 1240.
  static List<Map<String, dynamic>> leaderboard() => <Map<String, dynamic>>[
        <String, dynamic>{
          'student_id': 'ff000001-0000-4000-8000-000000000001',
          'full_name': 'Madina Yo\'ldosheva',
          'total_xp': 1480,
          'rank': 1,
          'is_current_user': false,
          'avatar_url': null,
        },
        <String, dynamic>{
          'student_id': studentId,
          'full_name': 'Amir Tursunov',
          'total_xp': totalXp,
          'rank': 2,
          'is_current_user': true,
          'avatar_url': null,
        },
        <String, dynamic>{
          'student_id': 'ff000001-0000-4000-8000-000000000003',
          'full_name': 'Jasur Ergashev',
          'total_xp': 1185,
          'rank': 3,
          'is_current_user': false,
          'avatar_url': null,
        },
        <String, dynamic>{
          'student_id': 'ff000001-0000-4000-8000-000000000004',
          'full_name': 'Sevinch Qodirova',
          'total_xp': 1020,
          'rank': 4,
          'is_current_user': false,
          'avatar_url': null,
        },
        <String, dynamic>{
          'student_id': 'ff000001-0000-4000-8000-000000000005',
          'full_name': 'Otabek Sodiqov',
          'total_xp': 940,
          'rank': 5,
          'is_current_user': false,
          'avatar_url': null,
        },
        <String, dynamic>{
          'student_id': 'ff000001-0000-4000-8000-000000000006',
          'full_name': 'Nilufar Hasanova',
          'total_xp': 865,
          'rank': 6,
          'is_current_user': false,
          'avatar_url': null,
        },
        <String, dynamic>{
          'student_id': 'ff000001-0000-4000-8000-000000000007',
          'full_name': 'Doniyor Islomov',
          'total_xp': 720,
          'rank': 7,
          'is_current_user': false,
          'avatar_url': null,
        },
      ];

  static List<Map<String, dynamic>> arenaTasks() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000001',
          'title': 'Haftalik marafon',
          'description': 'Bu hafta 5 ta uy vazifasini o\'z vaqtida topshiring.',
          'xp_reward': 150,
          'status': 'in_progress',
          'progress_current': 3,
          'progress_target': 5,
          'deadline': _iso(_weekStart.add(const Duration(days: 6, hours: 23))),
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000002',
          'title': 'Mukammal davomat',
          'description': '10 ta darsga kechikmasdan keling.',
          'xp_reward': 120,
          'status': 'in_progress',
          'progress_current': 8,
          'progress_target': 10,
          'deadline': null,
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000003',
          'title': 'Test ustasi',
          'description': 'Ketma-ket 3 ta testda 85+ ball oling.',
          'xp_reward': 200,
          'status': 'available',
          'progress_current': 0,
          'progress_target': 3,
          'deadline': null,
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000004',
          'title': 'Birinchi qadam',
          'description': 'Profilingizni to\'ldiring.',
          'xp_reward': 50,
          'status': 'completed',
          'progress_current': 1,
          'progress_target': 1,
          'deadline': null,
        },
      ];

  // ------------------------------------------------------- 7. Bildirishnomalar

  static List<Map<String, dynamic>> notifications() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'b1000001-0000-4000-8000-000000000001',
          'type': 'homework',
          'title': 'Yangi uy vazifasi',
          'body': 'Ingliz tili: "Unit 7: Writing Task 2 essay" — muddat 2 kun.',
          'created_at': _iso(DateTime.now().subtract(const Duration(hours: 3))),
          'is_read': false,
          'target_id': 'cc000001-0000-4000-8000-000000000001',
        },
        <String, dynamic>{
          'id': 'b1000001-0000-4000-8000-000000000002',
          'type': 'grade',
          'title': 'Baho qo\'yildi',
          'body': 'Ingliz tili — Progress test: 88/100 ball.',
          'created_at': _iso(DateTime.now().subtract(const Duration(hours: 9))),
          'is_read': false,
          'target_id': 'dd000001-0000-4000-8000-000000000001',
        },
        <String, dynamic>{
          'id': 'b1000001-0000-4000-8000-000000000003',
          'type': 'lesson',
          'title': 'Dars eslatmasi',
          'body': 'Ertaga soat 14:00 da Matematika darsi bo\'ladi (301-xona).',
          'created_at': _iso(DateTime.now().subtract(const Duration(hours: 20))),
          'is_read': false,
          'target_id': null,
        },
        <String, dynamic>{
          'id': 'b1000001-0000-4000-8000-000000000004',
          'type': 'xp',
          'title': '+45 XP',
          'body': 'Uy vazifasi uchun XP qo\'shildi. Reytingda 2-o\'rindasiz!',
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 1, hours: 4))),
          'is_read': true,
          'target_id': null,
        },
        <String, dynamic>{
          'id': 'b1000001-0000-4000-8000-000000000005',
          'type': 'system',
          'title': 'To\'lov eslatmasi',
          'body': 'Keyingi oy uchun to\'lov muddati 25-sanada tugaydi.',
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 2))),
          'is_read': true,
          'target_id': null,
        },
        <String, dynamic>{
          'id': 'b1000001-0000-4000-8000-000000000006',
          'type': 'homework',
          'title': 'Vazifa tekshirildi',
          'body': 'Unit 6: Vocabulary quiz — 92/100. Izoh qoldirildi.',
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 5))),
          'is_read': true,
          'target_id': 'cc000001-0000-4000-8000-000000000004',
        },
      ];
}
