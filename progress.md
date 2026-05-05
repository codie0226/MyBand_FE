# Progress Log

## 2026-04-20

### 작업 시작
- planning-with-files 워크플로우 진입
- 작업 목표: localhost:3000/docs Swagger 문서 기반으로 `docs/api/API_LIST.md` 업데이트 후 API 연동 시작
- 세 가지 계획 파일 생성: `task_plan.md`, `findings.md`, `progress.md`

### 작업 완료 — Swagger 분석
- 서버 확인: Express + Tsoa + Prisma/SQLite (`myband-be v0.1.0`)
- Swagger 위치: `/docs/` (UI), 스펙은 `/docs/swagger-ui-init.js` 안에 인라인 임베드 (1396줄)
- 표준 JSON 엔드포인트(`/docs-json`, `/openapi.json` 등)는 모두 404
- 임시로 `.swagger-spec.js`에 저장 후 분석 → 작업 완료 시 정리

### 작업 완료 — findings.md 작성
- 7개 도메인별 차이점 정리 (Auth/User/Band/Members/Events/Messages/Attachments)
- 주요 발견: WebSocket 미지원, BandMember에 `role`/`email` 추가, BandResponse가 members/events 미포함
- FE 모델 변경 필요 항목 정리

### 작업 완료 — API_LIST.md 업데이트
- 실제 Swagger 스펙 기반으로 전체 재작성
- 각 엔드포인트의 인증 여부, 응답 코드(200/201/204), 요청/응답 스키마 명시
- "스키마 요약" 및 "FE 연동 시 주의점" 섹션 추가
- 마지막 업데이트 일자 표시

### 다음 단계 (Phase 3 — API 연동 인프라 구축)
- `core/network/` 디렉토리 생성, `dio` 기반 `ApiClient` 구현
- 인증 인터셉터 (JWT 자동 첨부), 토큰 저장소 (`flutter_secure_storage`)
- DTO 클래스 작성 (Swagger 스키마 기반, `fromJson`/`toJson`)
- Repository 패턴 도입 — 도메인별 (Auth/Band/Member/Event/Message/Attachment)

### 차단/이슈
- Swagger에 에러 응답 스키마 미정의 → 실제 호출하며 확인 후 보완 예정
- Attachments의 multipart 명세 누락 → 서버 코드 확인 또는 BE 담당자 문의 필요
- WebSocket 미지원으로 채팅 실시간성은 폴링으로 임시 구현 결정

---

### 2026-05-04 — Phase 3 시작
- task_plan.md 구체화: 핵심 의사결정 5개 정리
  - 수동 JSON 직렬화 / `flutter_secure_storage` / 단일 모델(DTO 분리 X) / `useMock` 토글 / `ApiException` 통합 처리
- 이번 세션 범위 결정: Phase 3 인프라 + Auth 연동까지
- 다음 도메인(Band/Member/Event/Message/User)은 다음 세션에 단계적으로 진행
- 모델 변경 사항 사전 정리: Member에 email/role 추가 + nullable 필드, BandEvent.description nullable

### 2026-05-04 — Phase 3, 4, Auth 완료
- `flutter_secure_storage ^9.2.2` 추가
- 인프라 구축 완료:
  - `lib/core/config/app_config.dart` (Base URL, useMock, 타임아웃)
  - `lib/core/network/api_exception.dart` (`ApiException`, `UnauthorizedException`, `NetworkException`)
  - `lib/core/network/token_storage.dart` (JWT 안전 저장소)
  - `lib/core/network/api_client.dart` (Dio + 인증 인터셉터 + 에러 변환)
  - `lib/core/network/api_providers.dart` (Riverpod 노출)
- 모델 변경 완료:
  - `BandMemberRole` enum 추가
  - `Member`에 `email` 필수, `role` 추가, `instrument`/`profileImageUrl` nullable
  - `BandEvent.description` nullable
  - 모든 모델에 `fromJson` 추가, `BandEvent.toCreateJson`/`toUpdateJson`, `SetlistItem.toRequestJson`
  - `EventType.wireName`, `BandMemberRole.wireName` (BE enum 매핑)
- Auth 연동 완료:
  - `lib/features/auth/models/auth_models.dart` (`AuthUser`, `LoginResponse`, `UserProfile`)
  - `lib/features/auth/data/auth_repository.dart` (login/logout/me/hasStoredToken)
  - `AuthNotifier`: Google ID Token → `AuthRepository.loginWithGoogle()` → JWT 저장. `_restoreSession`으로 자동 로그인.
  - `login_screen.dart`: try/catch + SnackBar 에러 처리
- 영향 범위 수정:
  - `member_list_section.dart`: profileImageUrl/instrument nullable 처리
  - `event_detail_dialog.dart`, `calendar_screen.dart`, `band_info_section.dart`: description nullable 처리
  - `band_provider.dart` mockBands: 모든 Member에 email 추가
- `flutter analyze` 결과: 에러 0개, info 15개(기존 `withOpacity` 관련)

### 다음 단계 (다음 세션)
- BandRepository, BandMemberRepository (`/bands`, `/bands/:id/members`)
- EventRepository (`/bands/:id/events` CRUD)
- 기존 `band_provider.dart` Mock 제거 + Repository 호출 + `AsyncValue` 도입
- 일정 추가 화면(`add_event_screen.dart`)에서 실제 POST 호출
- MessageRepository (폴링 기반 채팅)
- UserRepository (프로필 화면)
