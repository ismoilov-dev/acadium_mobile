/// To'lov holati.
enum PaymentStatus {
  paid('paid', "To'langan"),
  due('due', 'Muddati yaqin'),
  overdue('overdue', 'Kechikkan');

  const PaymentStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PaymentStatus fromApi(String value) => PaymentStatus.values.firstWhere(
        (PaymentStatus s) => s.apiValue == value,
        orElse: () => PaymentStatus.due,
      );
}

/// Bir farzandning bir davr (oy) uchun to'lovi.
/// Backend: `/parents/{id}/payments/`
class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.childId,
    required this.childName,
    required this.period,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
    this.lastPaymentAt,
  });

  final String id; // UUID
  final String childId; // UUID
  final String childName;

  /// Davr nomi, masalan "Sentabr 2026".
  final String period;

  /// So'mda.
  final int totalAmount;
  final int paidAmount;
  final DateTime dueDate;
  final PaymentStatus status;
  final DateTime? lastPaymentAt;

  int get remainingAmount =>
      (totalAmount - paidAmount) < 0 ? 0 : totalAmount - paidAmount;

  /// 0..1 oralig'idagi to'langan ulush.
  double get progress =>
      totalAmount == 0 ? 0 : (paidAmount / totalAmount).clamp(0.0, 1.0);

  bool get isFullyPaid => remainingAmount == 0;

  /// Muddatgacha qolgan kunlar (manfiy — kechikkan).
  int get daysLeft {
    final DateTime now = DateTime.now();
    return DateTime(dueDate.year, dueDate.month, dueDate.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String,
        childId: json['child_id'] as String,
        childName: json['child_name'] as String? ?? '',
        period: json['period'] as String,
        totalAmount: json['total_amount'] as int,
        paidAmount: json['paid_amount'] as int? ?? 0,
        dueDate: DateTime.parse(json['due_date'] as String),
        status: PaymentStatus.fromApi(json['status'] as String),
        lastPaymentAt: json['last_payment_at'] == null
            ? null
            : DateTime.parse(json['last_payment_at'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'child_id': childId,
        'child_name': childName,
        'period': period,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'due_date': dueDate.toIso8601String(),
        'status': status.apiValue,
        'last_payment_at': lastPaymentAt?.toIso8601String(),
      };
}
