import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/child_model.dart';
import '../../data/repositories/parent_repository.dart';
import 'auth_provider.dart';
import 'selected_child_provider.dart';

/// Ota-onaga bog'langan barcha farzandlar.
final FutureProvider<List<ChildModel>> childrenProvider =
    FutureProvider<List<ChildModel>>((ref) async {
  final ParentRepository repo = ref.watch(parentRepositoryProvider);
  final String parentId = requireUserId(ref);
  return repo.getChildren(parentId);
});

/// Tanlangan farzand bo'yicha "bir qarashda" ma'lumot (Home kartalari).
/// Farzand almashtirilsa avtomatik qayta so'raladi.
final FutureProvider<ChildSummary> selectedChildSummaryProvider =
    FutureProvider<ChildSummary>((ref) async {
  final ParentRepository repo = ref.watch(parentRepositoryProvider);
  final String childId = requireSelectedChildId(ref);
  return repo.getChildSummary(childId);
});
