import 'package:intl/intl.dart';

/// Sana, vaqt va matn formatlash yordamchilari (o'zbek tilida).
class Formatters {
  const Formatters._();

  static const List<String> _months = <String>[
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr',
  ];

  static const List<String> weekdaysShort = <String>[
    'Du',
    'Se',
    'Ch',
    'Pa',
    'Ju',
    'Sh',
    'Ya',
  ];

  static const List<String> weekdaysFull = <String>[
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
    'Yakshanba',
  ];

  /// 14:30
  static String time(DateTime dt) => DateFormat('HH:mm').format(dt);

  /// 14:30 - 16:00
  static String timeRange(DateTime from, DateTime to) =>
      '${time(from)} - ${time(to)}';

  /// 18.09.2026
  static String date(DateTime dt) => DateFormat('dd.MM.yyyy').format(dt);

  /// 18 sentabr
  static String dayMonth(DateTime dt) => '${dt.day} ${_months[dt.month - 1]}';

  /// 18 sentabr, 14:30
  static String dayMonthTime(DateTime dt) => '${dayMonth(dt)}, ${time(dt)}';

  /// Dushanba
  static String weekday(DateTime dt) => weekdaysFull[dt.weekday - 1];

  /// "Bugun" / "Ertaga" / "Kecha" / "18 sentabr"
  static String relativeDay(DateTime dt) {
    final DateTime now = DateTime.now();
    final int diff = _dateOnly(dt).difference(_dateOnly(now)).inDays;
    switch (diff) {
      case 0:
        return 'Bugun';
      case 1:
        return 'Ertaga';
      case -1:
        return 'Kecha';
      default:
        return dayMonth(dt);
    }
  }

  /// "2 soat oldin", "3 kun oldin" — bildirishnomalar uchun.
  static String timeAgo(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    return dayMonth(dt);
  }

  /// Muddatgacha qolgan vaqt: "2 kun 4 soat" yoki "muddati o'tgan".
  static String remaining(DateTime deadline) {
    final Duration diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return "Muddati o'tgan";
    if (diff.inDays > 0) {
      return '${diff.inDays} kun ${diff.inHours % 24} soat';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} soat ${diff.inMinutes % 60} daqiqa';
    }
    return '${diff.inMinutes} daqiqa';
  }

  /// Countdown: 01:23:45
  static String countdown(Duration d) {
    if (d.isNegative) return '00:00:00';
    final String h = d.inHours.toString().padLeft(2, '0');
    final String m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final String s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// +998 90 123 45 67
  static String phone(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    final String local =
        digits.startsWith('998') ? digits.substring(3) : digits;
    if (local.length != 9) return raw;
    return '+998 ${local.substring(0, 2)} ${local.substring(2, 5)} '
        '${local.substring(5, 7)} ${local.substring(7)}';
  }

  /// 1240 -> "1 240"
  static String number(int value) => value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (Match m) => '${m[1]} ',
      );

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
