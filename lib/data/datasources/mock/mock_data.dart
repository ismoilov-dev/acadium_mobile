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

  /// Ota-ona va uning ikkinchi farzandi (birinchisi — yuqoridagi [studentId]).
  static const String parentId = '7c6d5e4f-3a2b-4c1d-9e8f-0a1b2c3d4e5f';
  static const String secondChildId = '2e3f4a5b-6c7d-4e8f-9a0b-1c2d3e4f5a6b';
  static const String secondChildGroupId =
      '5a6b7c8d-9e0f-4a1b-8c2d-3e4f5a6b7c8d';

  // ------------------------------------------------------------- Yordamchilar

  /// Bugungi kunning 00:00 vaqti.
  static DateTime get _today {
    final DateTime n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Joriy haftaning dushanbasi (00:00).
  static DateTime get _weekStart =>
      _today.subtract(Duration(days: _today.weekday - 1));

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
      'present',
      'present',
      'late',
      'present',
      'present',
      'present',
      'present',
      'present',
      'excused',
      'present',
      'present',
      'late',
      'present',
      'present',
      'present',
      'present',
      'present',
      'present',
      'present',
      'present',
    ];

    return List<Map<String, dynamic>>.generate(statuses.length, (int i) {
      final DateTime date = _today.subtract(Duration(days: (i + 1) * 2));
      return <String, dynamic>{
        'id':
            'bb0000${i.toString().padLeft(2, '0')}-0000-4000-8000-000000000001',
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
          'description': 'Darslikning 84-betidagi 1-12 masalalarni yeching. '
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
          'submitted_at':
              _iso(_today.subtract(const Duration(days: 1, hours: 3))),
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
          'description': 'Oylik byudjet jadvalini yarating: SUM, AVERAGE va IF '
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
          'created_at':
              _iso(_today.subtract(const Duration(days: 1, hours: 4))),
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

  /// O'qituvchilar yuklagan arena topshiriqlari.
  /// `quiz` turidagilarda savollar bor, to'g'ri javoblar esa [quizAnswerKey]
  /// ichida — xuddi real backend'dagidek, mijozga yuborilmaydi.
  static List<Map<String, dynamic>> arenaTasks() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000001',
          'type': 'quiz',
          'title': 'Grammar sprint: Present Perfect',
          'description': '5 ta savol, har biri uchun bitta to\'g\'ri javob. '
              'To\'g\'ri javoblar soniga qarab XP beriladi.',
          'teacher_name': 'Dilnoza Karimova',
          'subject': 'Ingliz tili',
          'xp_reward': 120,
          'status': 'available',
          'progress_current': 0,
          'progress_target': 5,
          'created_at': _iso(DateTime.now().subtract(const Duration(hours: 5))),
          'deadline': _iso(_today.add(const Duration(days: 3, hours: 20))),
          'attachments': <String>[],
          'questions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'q1-0001',
              'text': 'She ___ in London since 2019.',
              'options': <String>['lives', 'has lived', 'lived', 'is living'],
            },
            <String, dynamic>{
              'id': 'q1-0002',
              'text': 'I ___ that film three times.',
              'options': <String>['have seen', 'saw', 'see', 'had seen'],
            },
            <String, dynamic>{
              'id': 'q1-0003',
              'text': 'Qaysi gap to\'g\'ri yozilgan?',
              'options': <String>[
                'He has went home',
                'He have gone home',
                'He has gone home',
                'He has go home',
              ],
            },
            <String, dynamic>{
              'id': 'q1-0004',
              'text': '___ you ever been to Dubai?',
              'options': <String>['Did', 'Has', 'Are', 'Have'],
            },
            <String, dynamic>{
              'id': 'q1-0005',
              'text': "We haven't finished ___.",
              'options': <String>['already', 'ago', 'yet', 'since'],
            },
          ],
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000002',
          'type': 'quiz',
          'title': 'Blitz: kvadrat tenglamalar',
          'description': '4 ta savol. Kalkulyatorsiz yechishga harakat qiling!',
          'teacher_name': 'Bekzod Rahimov',
          'subject': 'Matematika',
          'xp_reward': 100,
          'status': 'available',
          'progress_current': 0,
          'progress_target': 4,
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 1))),
          'deadline': _iso(_today.add(const Duration(days: 5, hours: 20))),
          'attachments': <String>[],
          'questions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'q2-0001',
              'text': 'x² − 5x + 6 = 0 tenglamaning ildizlari:',
              'options': <String>['2 va 3', '1 va 6', '−2 va −3', '0 va 5'],
            },
            <String, dynamic>{
              'id': 'q2-0002',
              'text': 'Diskriminant formulasi:',
              'options': <String>[
                'b² + 4ac',
                'b² − 4ac',
                '−b / 2a',
                'a² − 4bc'
              ],
            },
            <String, dynamic>{
              'id': 'q2-0003',
              'text': "D < 0 bo'lsa, tenglama nechta haqiqiy ildizga ega?",
              'options': <String>['2 ta', '1 ta', 'Ildizi yo\'q', 'Cheksiz'],
            },
            <String, dynamic>{
              'id': 'q2-0004',
              'text': 'x² − 9 = 0 tenglamaning yechimi:',
              'options': <String>['x = 3', 'x = ±3', 'x = 9', 'x = ±9'],
            },
          ],
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000003',
          'type': 'submission',
          'title': 'Essay challenge: My future career',
          'description':
              '150-200 so\'zdan iborat qisqa essay yozing. Kamida 3 ta yangi '
                  'so\'z va bitta Present Perfect gap ishlatilsin.',
          'teacher_name': 'Dilnoza Karimova',
          'subject': 'Ingliz tili',
          'xp_reward': 150,
          'status': 'available',
          'progress_current': 0,
          'progress_target': 1,
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 2))),
          'deadline': _iso(_today.add(const Duration(days: 4, hours: 20))),
          'attachments': <String>['essay_namuna.pdf'],
          'questions': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000004',
          'type': 'submission',
          'title': 'Video: 1 daqiqalik self-introduction',
          'description':
              'O\'zingiz haqingizda 1 daqiqalik video yozib yuklang. '
                  'Ism, yosh, qiziqish va maqsadingiz haqida gapiring.',
          'teacher_name': 'Madina Yusupova',
          'subject': 'IELTS Speaking',
          'xp_reward': 90,
          'status': 'available',
          'progress_current': 0,
          'progress_target': 1,
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 3))),
          'deadline': null,
          'attachments': <String>[],
          'questions': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000005',
          'type': 'challenge',
          'title': 'Haftalik marafon',
          'description': "Bu hafta 5 ta uy vazifasini o'z vaqtida topshiring.",
          'teacher_name': 'Acadium',
          'subject': '',
          'xp_reward': 150,
          'status': 'in_progress',
          'progress_current': 3,
          'progress_target': 5,
          'created_at': _iso(_weekStart),
          'deadline': _iso(_weekStart.add(const Duration(days: 6, hours: 23))),
          'attachments': <String>[],
          'questions': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000006',
          'type': 'challenge',
          'title': 'Mukammal davomat',
          'description': '10 ta darsga kechikmasdan keling.',
          'teacher_name': 'Acadium',
          'subject': '',
          'xp_reward': 120,
          'status': 'in_progress',
          'progress_current': 8,
          'progress_target': 10,
          'created_at': _iso(_today.subtract(const Duration(days: 20))),
          'deadline': null,
          'attachments': <String>[],
          'questions': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000007',
          'type': 'challenge',
          'title': 'Birinchi qadam',
          'description':
              "Profilingizni to'ldiring va ilovaga birinchi marta kiring. "
                  'Mukofot tayyor — uni olib qo\'ying!',
          'teacher_name': 'Acadium',
          'subject': '',
          'xp_reward': 50,
          'status': 'available',
          'progress_current': 1,
          'progress_target': 1,
          'created_at': _iso(_today.subtract(const Duration(days: 30))),
          'deadline': null,
          'attachments': <String>[],
          'questions': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'id': 'a1000001-0000-4000-8000-000000000008',
          'type': 'quiz',
          'title': 'Vocabulary check: Unit 6',
          'description': 'Unit 6 dagi so\'zlar bo\'yicha tezkor test.',
          'teacher_name': 'Dilnoza Karimova',
          'subject': 'Ingliz tili',
          'xp_reward': 80,
          'status': 'completed',
          'progress_current': 5,
          'progress_target': 5,
          'created_at': _iso(_today.subtract(const Duration(days: 7))),
          'deadline': null,
          'attachments': <String>[],
          'questions': <Map<String, dynamic>>[],
          'earned_xp': 64,
          'result_comment': '5 ta savoldan 4 tasiga to\'g\'ri javob berdingiz.',
          'completed_at': _iso(_today.subtract(const Duration(days: 6))),
        },
      ];

  /// Testlarning to'g'ri javoblari (savol id → to'g'ri variant indeksi).
  ///
  /// Real backend'da bu ma'lumot serverda qoladi va mijozga hech qachon
  /// yuborilmaydi. Shu sababli u model'da emas, "server tomoni"da turibdi.
  static const Map<String, int> quizAnswerKey = <String, int>{
    'q1-0001': 1,
    'q1-0002': 0,
    'q1-0003': 2,
    'q1-0004': 3,
    'q1-0005': 2,
    'q2-0001': 0,
    'q2-0002': 1,
    'q2-0003': 2,
    'q2-0004': 1,
  };

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
          'created_at':
              _iso(DateTime.now().subtract(const Duration(hours: 20))),
          'is_read': false,
          'target_id': null,
        },
        <String, dynamic>{
          'id': 'b1000001-0000-4000-8000-000000000004',
          'type': 'xp',
          'title': '+45 XP',
          'body': 'Uy vazifasi uchun XP qo\'shildi. Reytingda 2-o\'rindasiz!',
          'created_at':
              _iso(DateTime.now().subtract(const Duration(days: 1, hours: 4))),
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

  // ======================================================================
  //                         OTA-ONA (PARENT) OQIMI
  // ======================================================================

  /// Ota-ona profili.
  static Map<String, dynamic> parent() => <String, dynamic>{
        'id': parentId,
        'first_name': 'Sanjar',
        'last_name': 'Tursunov',
        'phone': '+998331234567',
        'children_count': 2,
        'created_at': _iso(_today.subtract(const Duration(days: 96))),
        'avatar_url': null,
      };

  /// Ota-onaga bog'langan farzandlar.
  /// Birinchisi — Student ilovasidagi o'sha o'quvchi (bir xil ID).
  static List<Map<String, dynamic>> children() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': studentId,
          'first_name': 'Amir',
          'last_name': 'Tursunov',
          'group_name': 'IELTS Intensive — B2',
          'branch_name': 'Chilonzor filiali',
          'total_xp': totalXp,
          'level': 7,
          'enrolled_at': _iso(_today.subtract(const Duration(days: 96))),
          'avatar_url': null,
        },
        <String, dynamic>{
          'id': secondChildId,
          'first_name': 'Zilola',
          'last_name': 'Tursunova',
          'group_name': 'Matematika — 5-sinf',
          'branch_name': 'Chilonzor filiali',
          'total_xp': 860,
          'level': 5,
          'enrolled_at': _iso(_today.subtract(const Duration(days: 54))),
          'avatar_url': null,
        },
      ];

  static bool _isFirstChild(String childId) => childId == studentId;

  /// Farzandning dars jadvali.
  static List<Map<String, dynamic>> childSchedule(String childId) =>
      _isFirstChild(childId) ? lessons() : _secondChildLessons();

  /// Farzandning davomat tarixi.
  static List<Map<String, dynamic>> childAttendance(String childId) =>
      _isFirstChild(childId) ? attendance() : _secondChildAttendance();

  /// Farzandning uy vazifalari.
  static List<Map<String, dynamic>> childHomework(String childId) =>
      _isFirstChild(childId) ? homework() : _secondChildHomework();

  /// Farzandning baholari.
  static List<Map<String, dynamic>> childGrades(String childId) =>
      _isFirstChild(childId) ? grades() : _secondChildGrades();

  // ------------------------------------------------- ikkinchi farzand (Zilola)

  static List<Map<String, dynamic>> _secondChildLessons() {
    const List<List<Object>> plan = <List<Object>>[
      <Object>[1, 'Matematika', "Kasrlar bilan amallar", '102-xona'],
      <Object>[2, 'Ona tili', "Matn ustida ishlash", '103-xona'],
      <Object>[4, 'Matematika', "Geometrik shakllar", '102-xona'],
      <Object>[5, 'Ingliz tili', 'Family and friends', '204-xona'],
    ];

    return List<Map<String, dynamic>>.generate(plan.length, (int i) {
      final List<Object> row = plan[i];
      final DateTime start = _at(row[0] as int, 9, 0);
      return <String, dynamic>{
        'id': 'ac00000$i-0000-4000-8000-000000000001',
        'subject': row[1] as String,
        'teacher_name': 'Gulnora Saidova',
        'room': row[3] as String,
        'format': 'offline',
        'starts_at': _iso(start),
        'ends_at': _iso(start.add(const Duration(minutes: 80))),
        'topic': row[2] as String,
      };
    });
  }

  static List<Map<String, dynamic>> _secondChildAttendance() {
    const List<String> subjects = <String>[
      'Matematika',
      'Ona tili',
      'Ingliz tili',
    ];
    const List<String> statuses = <String>[
      'present',
      'present',
      'late',
      'present',
      'present',
      'absent',
      'present',
      'present',
      'present',
      'present',
    ];

    return List<Map<String, dynamic>>.generate(statuses.length, (int i) {
      final DateTime date = _today.subtract(Duration(days: (i + 1) * 2));
      return <String, dynamic>{
        'id':
            'ad0000${i.toString().padLeft(2, '0')}-0000-4000-8000-000000000001',
        'lesson_id': 'ac00000${i % 4}-0000-4000-8000-000000000001',
        'subject': subjects[i % subjects.length],
        'date': _iso(date.add(const Duration(hours: 9))),
        'status': statuses[i],
        'note': statuses[i] == 'absent' ? 'Sabab ko\'rsatilmagan' : null,
      };
    });
  }

  static List<Map<String, dynamic>> _secondChildHomework() =>
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'ae000001-0000-4000-8000-000000000001',
          'subject': 'Matematika',
          'title': 'Kasrlarni qo\'shish — 10 ta misol',
          'description': 'Daftarda 10 ta misolni yechib keling.',
          'teacher_name': 'Gulnora Saidova',
          'assigned_at': _iso(_today.subtract(const Duration(days: 1))),
          'due_at': _iso(_today.add(const Duration(days: 1, hours: 20))),
          'status': 'assigned',
          'max_score': 100,
          'xp_reward': 40,
          'score': null,
          'submitted_at': null,
          'teacher_comment': null,
          'attachments': <String>[],
        },
        <String, dynamic>{
          'id': 'ae000001-0000-4000-8000-000000000002',
          'subject': 'Ona tili',
          'title': 'Insho: Mening oilam',
          'description': 'Kamida 10 ta gapdan iborat insho yozing.',
          'teacher_name': 'Gulnora Saidova',
          'assigned_at': _iso(_today.subtract(const Duration(days: 6))),
          'due_at': _iso(_today.subtract(const Duration(days: 3))),
          'status': 'reviewed',
          'max_score': 100,
          'xp_reward': 45,
          'score': 95,
          'submitted_at': _iso(_today.subtract(const Duration(days: 4))),
          'teacher_comment': 'Juda chiroyli yozilgan!',
          'attachments': <String>[],
        },
      ];

  static List<Map<String, dynamic>> _secondChildGrades() =>
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'af000001-0000-4000-8000-000000000001',
          'subject': 'Matematika',
          'title': 'Kasrlar — nazorat ishi',
          'type': 'test',
          'score': 92,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 2))),
          'teacher_name': 'Gulnora Saidova',
          'comment': null,
        },
        <String, dynamic>{
          'id': 'af000001-0000-4000-8000-000000000002',
          'subject': 'Ona tili',
          'title': 'Insho: Mening oilam',
          'type': 'homework',
          'score': 95,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 3))),
          'teacher_name': 'Gulnora Saidova',
          'comment': 'Juda chiroyli yozilgan!',
        },
        <String, dynamic>{
          'id': 'af000001-0000-4000-8000-000000000003',
          'subject': 'Ingliz tili',
          'title': 'Unit 3 — Vocabulary',
          'type': 'test',
          'score': 84,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 9))),
          'teacher_name': 'Dilnoza Karimova',
          'comment': null,
        },
        <String, dynamic>{
          'id': 'af000001-0000-4000-8000-000000000004',
          'subject': 'Matematika',
          'title': "Og'zaki hisob",
          'type': 'oral',
          'score': 88,
          'max_score': 100,
          'graded_at': _iso(_today.subtract(const Duration(days: 14))),
          'teacher_name': 'Gulnora Saidova',
          'comment': null,
        },
      ];

  // ------------------------------------------------------------- To'lovlar

  /// Farzandlar bo'yicha to'lovlar (har biri uchun joriy davr).
  static List<Map<String, dynamic>> payments() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'b0000001-0000-4000-8000-000000000001',
          'child_id': studentId,
          'child_name': 'Amir Tursunov',
          'period': 'Joriy oy',
          'total_amount': 1200000,
          'paid_amount': 1200000,
          'due_date': _iso(_today.add(const Duration(days: 12))),
          'status': 'paid',
          'last_payment_at': _iso(_today.subtract(const Duration(days: 8))),
        },
        <String, dynamic>{
          'id': 'b0000001-0000-4000-8000-000000000002',
          'child_id': secondChildId,
          'child_name': 'Zilola Tursunova',
          'period': 'Joriy oy',
          'total_amount': 900000,
          'paid_amount': 400000,
          'due_date': _iso(_today.add(const Duration(days: 4))),
          'status': 'due',
          'last_payment_at': _iso(_today.subtract(const Duration(days: 20))),
        },
        <String, dynamic>{
          'id': 'b0000001-0000-4000-8000-000000000003',
          'child_id': secondChildId,
          'child_name': 'Zilola Tursunova',
          'period': "O'tgan oy",
          'total_amount': 900000,
          'paid_amount': 500000,
          'due_date': _iso(_today.subtract(const Duration(days: 9))),
          'status': 'overdue',
          'last_payment_at': _iso(_today.subtract(const Duration(days: 33))),
        },
      ];

  // -------------------------------------------------- Ota-ona bildirishnomalari

  static List<Map<String, dynamic>> parentNotifications() =>
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'b2000001-0000-4000-8000-000000000001',
          'type': 'lesson',
          'title': 'Farzandingiz darsga keldi',
          'body': 'Amir bugungi Ingliz tili darsiga o\'z vaqtida keldi.',
          'created_at': _iso(DateTime.now().subtract(const Duration(hours: 2))),
          'is_read': false,
          'target_id': null,
          'child_name': 'Amir Tursunov',
        },
        <String, dynamic>{
          'id': 'b2000001-0000-4000-8000-000000000002',
          'type': 'system',
          'title': "To'lov muddati yaqinlashmoqda",
          'body': "Zilola uchun 500 000 so'm to'lov 4 kundan keyin.",
          'created_at': _iso(DateTime.now().subtract(const Duration(hours: 6))),
          'is_read': false,
          'target_id': null,
          'child_name': 'Zilola Tursunova',
        },
        <String, dynamic>{
          'id': 'b2000001-0000-4000-8000-000000000003',
          'type': 'grade',
          'title': "Yangi baho qo'yildi",
          'body': 'Zilola — Matematika nazorat ishi: 92/100.',
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 2))),
          'is_read': false,
          'target_id': null,
          'child_name': 'Zilola Tursunova',
        },
        <String, dynamic>{
          'id': 'b2000001-0000-4000-8000-000000000004',
          'type': 'homework',
          'title': 'Uy vazifasi topshirilmagan',
          'body': 'Amir uchun 3 ta vazifa muddati yaqinlashmoqda.',
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 3))),
          'is_read': true,
          'target_id': null,
          'child_name': 'Amir Tursunov',
        },
        <String, dynamic>{
          'id': 'b2000001-0000-4000-8000-000000000005',
          'type': 'system',
          'title': 'Ota-onalar yig\'ilishi',
          'body':
              'Shanba kuni soat 15:00 da filialda yig\'ilish bo\'lib o\'tadi.',
          'created_at': _iso(DateTime.now().subtract(const Duration(days: 5))),
          'is_read': true,
          'target_id': null,
          'child_name': null,
        },
      ];
}
