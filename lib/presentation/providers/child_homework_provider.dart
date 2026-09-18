import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/homework_model.dart';
import '../../data/repositories/parent_repository.dart';
import 'selected_child_provider.dart';

/// Tanlangan farzandning uy vazifalari.
final FutureProvider<List<HomeworkModel>> childHomeworkProvider =
    FutureProvider<List<HomeworkModel>>((ref) async {
  final ParentRepository repo = ref.watch(parentRepositoryProvider);
  final String childId = requireSelectedChildId(ref);
  return repo.getChildHomework(childId);
});
