import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/band_models.dart';

final mockBands = [
  Band(
    id: 'b1',
    name: '인디스타즈',
    description: '우리는 홍대를 무대로 활동하는 감성 모던락 밴드입니다. 매주 토요일 합주를 진행하며 정기 공연을 기획하고 있습니다.',
    members: [
      const Member(id: 'm1', name: '김보컬', instrument: 'Vocal/Guitar', profileImageUrl: 'https://i.pravatar.cc/150?u=m1'),
      const Member(id: 'm2', name: '이베이스', instrument: 'Bass', profileImageUrl: 'https://i.pravatar.cc/150?u=m2'),
      const Member(id: 'm3', name: '박드럼', instrument: 'Drum', profileImageUrl: 'https://i.pravatar.cc/150?u=m3'),
      const Member(id: 'm4', name: '최건반', instrument: 'Keyboard', profileImageUrl: 'https://i.pravatar.cc/150?u=m4'),
    ],
    events: [
      BandEvent(
        id: 'e1',
        title: '정기 합주',
        date: DateTime.now().add(const Duration(days: 2)),
        type: EventType.practice,
        description: '다음 주 공연을 위한 최종 리허설 및 사운드 체킹',
        setlist: ['별빛이 내린다 - 안녕바다', '스토커 - 10cm', '자작곡: 새벽별'],
      ),
      BandEvent(
        id: 'e2',
        title: '클럽 빵 금요 기획공연',
        date: DateTime.now().add(const Duration(days: 5)),
        type: EventType.performance,
        description: '저녁 8시 라인업 두번째 순서. 장비 세팅 7시 30분까지 완료 요망.',
        setlist: ['별빛이 내린다 - 안녕바다', '스토커 - 10cm', '자작곡: 새벽별', '앵콜곡 준비'],
      ),
      BandEvent(
        id: 'e3',
        title: '팀 회식',
        date: DateTime.now().add(const Duration(days: 6)),
        type: EventType.other,
        description: '공연 완료 후 홍대 삼겹살집에서 회식',
      ),
    ],
  ),
  const Band(
    id: 'b2',
    name: 'Blue Note Project',
    description: '재즈 스탠다드를 연주하는 프로젝트 밴드',
    members: [
      Member(id: 'm1', name: '김보컬', instrument: 'Vocal', profileImageUrl: 'https://i.pravatar.cc/150?u=m1'),
      Member(id: 'm5', name: '정섹소폰', instrument: 'Saxophone', profileImageUrl: 'https://i.pravatar.cc/150?u=m5'),
    ],
    events: [],
  ),
];

final bandsProvider = Provider<List<Band>>((ref) {
  return mockBands;
});

class SelectedBandNotifier extends Notifier<Band> {
  @override
  Band build() => mockBands.first;

  void updateBand(Band newBand) {
    state = newBand;
  }
}

final selectedBandProvider = NotifierProvider<SelectedBandNotifier, Band>(() {
  return SelectedBandNotifier();
});
