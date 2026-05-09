import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/band_member_repository.dart';
import '../data/band_repository.dart';
import '../data/event_repository.dart';
import '../models/band_models.dart';

// ---------------------------------------------------------------------------
// Bands — 목록 (members/events 미포함)
// ---------------------------------------------------------------------------

class BandsNotifier extends AsyncNotifier<List<Band>> {
  @override
  Future<List<Band>> build() {
    return ref.read(bandRepositoryProvider).getBands();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(bandRepositoryProvider).getBands(),
    );
  }
}

final bandsProvider =
    AsyncNotifierProvider<BandsNotifier, List<Band>>(
  () => BandsNotifier(),
);

// ---------------------------------------------------------------------------
// 선택된 밴드 ID
// ---------------------------------------------------------------------------

class SelectedBandIdNotifier extends Notifier<String> {
  @override
  String build() {
    // 밴드 목록이 로드되면 첫 번째 밴드 ID로 초기화.
    ref.listen<AsyncValue<List<Band>>>(bandsProvider, (_, next) {
      next.whenData((bands) {
        if (bands.isNotEmpty && state.isEmpty) {
          state = bands.first.id;
        }
      });
    });
    return '';
  }

  void select(String bandId) => state = bandId;
}

final selectedBandIdProvider =
    NotifierProvider<SelectedBandIdNotifier, String>(
  () => SelectedBandIdNotifier(),
);

// ---------------------------------------------------------------------------
// 선택된 밴드 상세 (members + events 조립)
// ---------------------------------------------------------------------------

/// 선택된 밴드의 members + events를 병렬 조회 후 조립한 완전한 Band 객체.
/// 밴드 ID가 바뀌거나 bandsProvider가 갱신될 때마다 재조회.
final selectedBandProvider = FutureProvider<Band>((ref) async {
  final bands = await ref.watch(bandsProvider.future);
  final selectedId = ref.watch(selectedBandIdProvider);

  if (bands.isEmpty) throw StateError('밴드 목록이 비어 있습니다.');

  final band = bands.firstWhere(
    (b) => b.id == selectedId,
    orElse: () => bands.first,
  );

  final memberRepo = ref.read(bandMemberRepositoryProvider);
  final eventRepo = ref.read(eventRepositoryProvider);

  final results = await Future.wait([
    memberRepo.getMembers(band.id),
    eventRepo.getEvents(band.id),
  ]);

  return band.copyWith(
    members: results[0] as List<Member>,
    events: results[1] as List<BandEvent>,
  );
});

