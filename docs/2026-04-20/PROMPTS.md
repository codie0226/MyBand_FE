# 2026-04-20 작업 기록

## 작업 요약
- 일정 추가 기능 전체 구현 (AddEventScreen, SetlistItem 모델, Provider 리팩토링)
- 메인 화면, 캘린더, 채팅 3개 진입점 연결
- 셋리스트 모델 구조화 (List\<String\> → List\<SetlistItem\>)

---

## 작업 배경 및 목적

기존 앱에는 일정을 조회하는 기능만 있었고, 일정 추가 기능이 없었다. 캘린더의 "새 일정 추가" 버튼과 채팅의 "일정 생성" 버튼에 TODO만 남아있는 상태였다. 밴드 운영에서 합주/공연 일정 등록은 핵심 기능이므로, 일정 생성 화면을 만들고 앱 전체에서 접근 가능하도록 3개 진입점을 연결하는 것이 목적이었다.

추가로, 셋리스트가 단순 문자열 리스트(`List<String>`)로 되어 있어 곡의 아티스트, 키(조성), 악보, 레퍼런스 등 구조화된 정보를 담을 수 없었다. 이번 작업에서 `SetlistItem` 모델로 확장하여 향후 악보 관리 및 레퍼런스 연동의 기반을 마련했다.

---

## 주요 의사결정 및 사고 과정

### 1. Provider 아키텍처 리팩토링
- **이전**: `bandsProvider`는 불변 `Provider<List<Band>>`, `selectedBandProvider`는 `NotifierProvider<SelectedBandNotifier, Band>`
- **문제**: 이벤트 추가 시 `bandsProvider`가 불변이라 데이터 갱신 불가. `selectedBandProvider`가 Band 객체 전체를 상태로 보유하여 `bandsProvider` 변경과 동기화 안 됨
- **해결**: `bandsProvider` → `NotifierProvider<BandsNotifier, List<Band>>`로 전환 + `addEvent()` 메서드 추가. `selectedBandProvider` → ID만 저장하는 `selectedBandIdProvider` + 파생 `Provider<Band>`로 분리. 이렇게 하면 bands 변경 시 `ref.watch` 체인으로 자동 갱신
- **대안**: 별도 `eventsProvider`를 만들어 이벤트만 관리하는 방안도 있었으나, 이벤트가 Band의 속성으로 이미 모델링되어 있어 `Band.copyWith(events: ...)` 방식이 더 자연스러웠음

### 2. 라우팅 — 루트 레벨 라우트
- **결정**: `/add_event`를 `StatefulShellRoute` 밖, `parentNavigatorKey: _rootNavigatorKey`로 배치
- **이유**: 일정 추가 화면은 메인/채팅/캘린더 3개 탭에서 모두 접근하므로, 특정 탭의 하위 라우트로 넣으면 다른 탭에서 접근 시 부자연스러움. 루트 레벨에 두면 하단 네비 위에 풀스크린으로 표시되어 3개 진입점 모두 동일한 경험 제공
- **날짜 전달**: 캘린더에서 진입 시 `?date=YYYY-MM-DD` 쿼리 파라미터로 사전 선택 날짜 전달

### 3. SetlistItem 모델 분리
- **결정**: `band_models.dart`에 `SetlistItem` 클래스 추가, `BandEvent.setlist` 타입을 `List<String>` → `List<SetlistItem>`으로 변경
- **이유**: 곡 정보를 구조화해야 아티스트/키/악보/레퍼런스를 개별 관리할 수 있음. 백엔드 없는 현재 상태에서도 Mock 데이터로 UI를 완성할 수 있고, 향후 API 연동 시 모델만 직렬화하면 됨
- **하위 호환**: 프로덕션 데이터 없으므로 Mock 데이터 전면 교체. 기존 setlist 표시 코드(`Text('${index}. ${value}')`)를 `SetlistItemCard` 위젯으로 교체

### 4. 폼 상태 관리
- **결정**: Riverpod 없이 로컬 `StatefulWidget` + `TextEditingController` 사용
- **이유**: 일정 추가 폼은 일회성 화면으로, 다른 위젯과 폼 상태를 공유할 필요가 없음. Riverpod Provider로 폼 상태를 올리면 불필요한 복잡도만 증가

### 5. 바텀시트에서 GoRouter 접근
- **문제**: `AttachmentMenu`가 `showModalBottomSheet`로 표시되므로, `Navigator.pop()` 후 context가 무효화되어 `GoRouter.of(context)` 실패 가능
- **해결**: pop 전에 `final router = GoRouter.of(context);`로 캡처 후 사용

---

## 구현 상세

### 변경/추가된 파일

| 파일 | 작업 내용 |
|------|-----------|
| `lib/features/my_band/models/band_models.dart` | `SetlistItem` 클래스 추가, `BandEvent.setlist` 타입 변경, `Band`/`BandEvent`에 `copyWith` 추가 |
| `lib/features/my_band/providers/band_provider.dart` | `BandsNotifier`로 전환, `addEvent()` 추가, `selectedBandIdProvider` + 파생 `selectedBandProvider` 리팩토링, Mock 데이터 SetlistItem 적용 |
| `lib/features/my_band/views/my_band_screen.dart` | 밴드 드롭다운에서 `selectedBandIdProvider.notifier.select()` 호출로 변경 |
| `lib/features/my_band/views/add_event_screen.dart` | **신규** — 일정 추가 폼 화면 (ConsumerStatefulWidget) |
| `lib/features/my_band/widgets/setlist_item_form.dart` | **신규** — 셋리스트 곡 입력 폼 위젯 + SetlistItemFormData 헬퍼 |
| `lib/features/my_band/widgets/setlist_item_card.dart` | **신규** — 셋리스트 곡 표시 위젯 (상세 화면용) |
| `lib/features/my_band/widgets/event_list_section.dart` | 제목 옆에 "+" IconButton 추가, go_router import |
| `lib/features/my_band/widgets/event_detail_dialog.dart` | setlist 렌더링을 SetlistItemCard로 교체 |
| `lib/core/router/app_router.dart` | `/add_event` GoRoute 추가 (rootNavigatorKey, date 쿼리 파라미터) |
| `lib/features/calendar/views/calendar_screen.dart` | "새 일정 추가" 버튼 연결, setlist 렌더링 SetlistItemCard로 교체 |
| `lib/features/chat/widgets/attachment_menu.dart` | "일정 생성" onTap에 GoRouter.push('/add_event') 연결 |

---

## 다음 작업을 위한 메모

### 이어서 작업해야 할 사항
1. **일정 수정/삭제** — 현재 추가만 가능, `BandsNotifier`에 `updateEvent()`, `deleteEvent()` 추가 필요
2. **프로필 화면** — 로그인한 Google 계정 정보 표시, 로그아웃 버튼
3. **채팅 이미지/PDF 첨부** — `image_picker`, `file_picker` 패키지 연동
4. **백엔드 API 연동** — `dio`로 실제 API 호출, 모델 직렬화(`freezed` + `json_serializable`)

### 주의사항
- Provider 구조 변경 후에는 반드시 `flutter clean` + 완전 재시작 필요 (핫 리로드 시 이전 타입 캐시로 `TypeError` 발생)
- `selectedBandProvider`가 이전에는 `NotifierProvider`였으나 현재는 `Provider`(파생)로 변경됨 — `.notifier` 접근 불가, 밴드 변경은 `selectedBandIdProvider.notifier.select(id)` 사용
- `SetlistItemFormData`의 `TextEditingController`들은 화면 dispose 시 반드시 정리해야 함
