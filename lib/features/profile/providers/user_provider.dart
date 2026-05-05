import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/auth_models.dart';
import '../data/user_repository.dart';

class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() {
    return ref.read(userRepositoryProvider).getProfile();
  }

  Future<void> saveProfile({String? name, String? instrument}) async {
    final repo = ref.read(userRepositoryProvider);
    final updated = await repo.updateProfile(
      name: name?.isNotEmpty == true ? name : null,
      instrument: instrument?.isNotEmpty == true ? instrument : null,
    );
    state = AsyncData(updated);
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
  () => UserProfileNotifier(),
);
