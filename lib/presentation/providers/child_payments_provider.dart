import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/parent_repository.dart';
import 'auth_provider.dart';
import 'selected_child_provider.dart';

/// Barcha farzandlar bo'yicha to'lovlar.
final FutureProvider<List<PaymentModel>> paymentsProvider =
    FutureProvider<List<PaymentModel>>((ref) async {
  final ParentRepository repo = ref.watch(parentRepositoryProvider);
  final String parentId = requireUserId(ref);
  return repo.getPayments(parentId);
});

/// Faqat tanlangan farzandning to'lovlari.
final Provider<AsyncValue<List<PaymentModel>>> selectedChildPaymentsProvider =
    Provider<AsyncValue<List<PaymentModel>>>((ref) {
  final String? childId = ref.watch(selectedChildProvider)?.id;
  return ref.watch(paymentsProvider).whenData((List<PaymentModel> items) =>
      items.where((PaymentModel p) => p.childId == childId).toList());
});

/// Barcha farzandlar bo'yicha to'lanmagan umumiy summa.
final Provider<AsyncValue<int>> totalDueProvider =
    Provider<AsyncValue<int>>((ref) {
  return ref.watch(paymentsProvider).whenData((List<PaymentModel> items) =>
      items.fold<int>(0, (int acc, PaymentModel p) => acc + p.remainingAmount));
});
