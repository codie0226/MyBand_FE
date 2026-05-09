# Task Plan — 백엔드 API 연동

## 목표
`docs/api/API_LIST.md` 기준으로 Flutter 앱과 `myband-be` (Express + Tsoa) REST API를 연동한다. 현재 Mock 데이터 기반의 Provider를 실제 API 호출로 단계적으로 교체한다.

---

## 핵심 의사결정

| 항목 | 결정 | 이유 |
|------|------|------|
| JSON 직렬화 | **수동 작성** (`fromJson`/`toJson`) | 모델 단순, `json_serializable` 도입 시 build_runner 부담 |
| 토큰 저장소 | **`flutter_secure_storage`** | JWT 보안 저장 필수 |
| 도메인 모델 vs DTO | **단일 모델로 통합** (BE 응답 구조 그대로 사용) | 변환 레이어 최소화 |
| Mock 데이터 처리 | **개발 환경 토글로 유지** (`AppConfig.useMock`) | BE 미실행 시에도 작업 가능 |
| HTTP 클라이언트 | 기존 `dio ^5.9.2` 활용 | 이미 추가됨 |
| 에러 처리 | 통합 `ApiException` 클래스 + Repository에서 변환 | UI 레이어 단순화 |

---

## 모델 변경 사항

### `Member` (`band_models.dart`)
- 🆕 `email: String` 추가
- 🆕 `role: BandMemberRole` (`owner` / `member`) 추가
- ⚠️ `instrument`, `profileImageUrl` → nullable (`String?`)

### `BandEvent` (`band_models.dart`)
- ⚠️ `description: String?` (nullable로 변경)

### `Band` (`band_models.dart`)
- 그대로 유지 (members/events는 Repository에서 조립)
- `BandSummary`(목록용, members/events 없음) 별도 추가는 보류 — 일단 events/members 빈 배열로 시작

### 신규 모델
- `AuthUser` — 로그인 응답용
- `BandMemberRole` enum (`owner` / `member`)
- `MessageDto` (id, senderId, senderName, senderProfileImageUrl, text, createdAt)

---

## Phase 3: 인프라 구축 ✅ 완료
## Phase 4: 모델 변경 ✅ 완료
## Phase 5 (Auth): AuthRepository + AuthNotifier ✅ 완료 (accessToken 폴백 포함)

---

## Phase 5 (나머지): Repository 구현 ⬅ 현재 세션
- [ ] `lib/features/my_band/data/band_repository.dart` — GET /bands, GET /bands/:id
- [ ] `lib/features/my_band/data/band_member_repository.dart` — GET /bands/:id/members
- [ ] `lib/features/my_band/data/event_repository.dart` — CRUD /bands/:id/events

## Phase 6: Provider + 화면 연동
- [ ] `band_provider.dart` 교체
  - `BandsNotifier` → `AsyncNotifier<List<Band>>` (GET /bands 호출)
  - `selectedBandProvider` → `FutureProvider<Band>` (members + events 조립)
- [ ] `my_band_screen.dart` — `AsyncValue.when` 처리
- [ ] `calendar_screen.dart` — `AsyncValue.when` 처리
- [ ] `chat_screen.dart` — band id 접근으로 최소 변경
- [ ] `add_event_screen.dart` — `EventRepository.createEvent()` 호출로 교체

## Phase 7: 검증
- [ ] `flutter analyze` 통과
- [ ] 밴드 목록 → 일정 추가 E2E 확인
- [ ] 401 자동 로그아웃 확인

---

## 아키텍처 결정 (이번 세션)

**Provider 구조:**
```
bandsProvider: AsyncNotifier<List<Band>>          // API: GET /bands
selectedBandIdProvider: Notifier<String>           // 선택된 밴드 ID
selectedBandProvider: FutureProvider<Band>         // members + events 조립
  ├── GET /bands/:id/members
  └── GET /bands/:id/events
```

**화면 패턴:**
```dart
ref.watch(selectedBandProvider).when(
  loading: () => ...,
  error: (e, _) => ...,
  data: (band) => ...,  // Band with members + events
)
```

---

## 차단/이슈
- 에러 응답 스키마 명세 누락 — 실제 호출 시 확인하며 보완
- Attachments multipart 명세 누락 — 후순위
- WebSocket 미지원 → Messages는 폴링으로 임시 구현 (이번 세션 범위 외)
