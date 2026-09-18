import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/parent_model.dart';
import '../../data/repositories/parent_repository.dart';
import 'auth_provider.dart';

/// Ota-ona profili.
final FutureProvider<ParentModel> parentProfileProvider =
    FutureProvider<ParentModel>((ref) async {
  final ParentRepository repo = ref.watch(parentRepositoryProvider);
  final String parentId = requireUserId(ref);
  return repo.getProfile(parentId);
});
