import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/grade_model.dart';
import '../../data/repositories/parent_repository.dart';
import 'selected_child_provider.dart';

/// Tanlangan farzandning baholari.
final FutureProvider<List<GradeModel>> childGradesProvider =
    FutureProvider<List<GradeModel>>((ref) async {
  final ParentRepository repo = ref.watch(parentRepositoryProvider);
  final String childId = requireSelectedChildId(ref);
  return repo.getChildGrades(childId);
});
