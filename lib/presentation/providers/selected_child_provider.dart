import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/child_model.dart';
import 'children_provider.dart';

/// HOZIR TANLANGAN farzand ID'si.
///
/// Butun Parent ilovasi shu holatga tayanadi: qiymat o'zgarganda unga bog'liq
/// barcha provider'lar (davomat, vazifa, baho, jadval, summary) Riverpod
/// reaktivligi tufayli avtomatik qayta so'raladi.
///
/// `null` — hali tanlanmagan: bu holda birinchi farzand tanlangan hisoblanadi.
final StateProvider<String?> selectedChildIdProvider =
    StateProvider<String?>((ref) => null);

/// Tanlangan farzand modeli (ro'yxat yuklanmagan bo'lsa — null).
final Provider<ChildModel?> selectedChildProvider =
    Provider<ChildModel?>((ref) {
  final List<ChildModel>? children = ref.watch(childrenProvider).valueOrNull;
  if (children == null || children.isEmpty) return null;

  final String? selectedId = ref.watch(selectedChildIdProvider);
  if (selectedId == null) return children.first;

  for (final ChildModel child in children) {
    if (child.id == selectedId) return child;
  }
  // Tanlangan farzand ro'yxatdan yo'qolgan bo'lsa — birinchisiga qaytamiz.
  return children.first;
});

/// Farzandga bog'liq async provider'lar uchun: tanlov bo'lmasa xatolik.
/// `async` blok ichida chaqiriladi, shuning uchun UI'da ErrorView ko'rinadi.
String requireSelectedChildId(Ref ref) {
  final ChildModel? child = ref.watch(selectedChildProvider);
  if (child == null) {
    throw const AppException('Farzand tanlanmagan.');
  }
  return child.id;
}
