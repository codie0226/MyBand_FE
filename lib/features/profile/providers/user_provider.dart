import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/auth_models.dart';
import '../../my_band/providers/band_provider.dart';
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

    // 나의 밴드 탭에도 변경사항이 반영되도록 밴드 상세 데이터 갱신
    ref.invalidate(selectedBandProvider);
  }

  Future<void> completeOnboarding({
    required String nickname,
    required String instrument,
    String? inviteCode,
    OnboardingBandInput? band,
  }) async {
    final repo = ref.read(userRepositoryProvider);
    final updated = await repo.completeOnboarding(
      nickname: nickname,
      instrument: instrument,
      inviteCode: inviteCode?.isNotEmpty == true ? inviteCode : null,
      band: band,
    );
    state = AsyncData(updated);
    ref.invalidate(bandsProvider);
    ref.invalidate(selectedBandProvider);
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
      () => UserProfileNotifier(),
    );
