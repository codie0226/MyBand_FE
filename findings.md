# Findings — 백엔드 API 스펙 조사

## 조사 대상
- Swagger 문서 위치: `http://localhost:3000/docs/`
- OpenAPI 스펙: `http://localhost:3000/docs/swagger-ui-init.js` 안에 인라인 임베드
- 비교 기준: `docs/api/API_LIST.md` (FE에서 추정한 스펙)

---

## 서버 정보
- **이름**: `myband-be`
- **버전**: `0.1.0`
- **스택**: Express + Tsoa + Prisma/SQLite
- **OpenAPI 버전**: 3.0.0
- **Base Path**: `/` (버전 prefix 없음)
- **인증 방식**: `Authorization` 헤더 + JWT Bearer 토큰 (스펙상 `apiKey` 타입으로 등록되어 있으나 설명에 "Bearer JWT issued by POST /auth/google" 명시)

---

## 차이점 기록 (실제 스펙 vs 기존 추정)

### 1. 인증 (Auth)
- ✅ `POST /auth/google` — 일치 (요청: `{idToken}`, 응답: `{accessToken, user}`)
- ✅ `POST /auth/logout` — 일치 (응답: 204 No Content)
- ⚠️ `GET /auth/me` — 응답이 `UserProfileResponse`로 `/users/me`와 동일 (스펙상 둘 다 존재)
- 🆕 `LoginResponse.user`는 `AuthUser` 스키마: `{id, name, email, profileImageUrl}` (instrument 필드 없음)

### 2. 사용자 (User)
- ✅ `GET /users/me`, `PATCH /users/me` — 일치
- ⚠️ `UpdateUserProfileRequest`의 모든 필드가 optional (이전 추정도 같았으나 명시 필요)
- ⚠️ `UserProfileResponse`에 `email` 필수 (이전 추정과 동일)

### 3. 밴드 (Band)
- ✅ 5개 엔드포인트 모두 일치 (`GET/POST /bands`, `GET/PATCH/DELETE /bands/:bandId`)
- ⚠️ `BandResponse`에 `members` 배열이 **없음** — 멤버는 별도 `/bands/:bandId/members` 호출 필요
- ⚠️ `CreateBandRequest`: `name`만 필수 (`description` 선택)
- ⚠️ `UpdateBandRequest`: 모든 필드 선택
- ⚠️ `BandResponse.memberCount`: 정수가 아닌 `number/double` 타입

### 4. 밴드 멤버 (Members)
- ✅ 4개 엔드포인트 일치
- 🆕 `BandMemberRole` enum 존재: `owner | member`
- 🆕 `BandMemberResponse`에 `role` 필드 추가 (이전 추정에 없었음)
- 🆕 `BandMemberResponse`에 `email` 필드 추가 (이전 추정에 없었음)
- ⚠️ `UpdateBandMemberRequest`로 `instrument`와 `role` 모두 수정 가능
- ⚠️ `InviteBandMemberRequest`: `email`만 필수 (`instrument` 선택)

### 5. 일정 (Events)
- ✅ 5개 엔드포인트 모두 일치
- ⚠️ `EventResponse.description`이 nullable (이전 추정은 항상 string으로 가정)
- ⚠️ `CreateEventRequest`: `title`, `date`, `type`만 필수 (`description`, `setlist` 선택)
- ⚠️ `UpdateEventRequest`: 모든 필드 선택
- 🆕 `SetlistItemRequest`: `id`도 선택 가능 (기존 셋리스트 항목 업데이트 시 사용 가능)
- ✅ `SetlistItem` 스키마는 이전 추정과 일치 (`id, title, artist, key?, sheetMusicUrl?, references[]`)
- ✅ `EventType` enum 일치: `practice | performance | other`

### 6. 채팅 (Chat / Messages)
- ✅ `GET /bands/:bandId/messages?cursor&limit` — 일치
- ✅ `POST /bands/:bandId/messages` — 일치
- 🚫 **WebSocket 엔드포인트 없음** — 실시간 채팅은 현재 미지원, 폴링 또는 별도 구현 필요
- ⚠️ `tags`가 `Messages` (단일) — 채팅이라기보다 메시지 단위로 모델링됨
- 🆕 `MessageResponse`에 `senderProfileImageUrl` 필드 (nullable)
- ⚠️ `MessageListResponse.nextCursor`가 nullable (마지막 페이지일 때 null)

### 7. 첨부파일 (Attachments)
- ✅ `POST /attachments/images`, `POST /attachments/files` — 일치
- ⚠️ Swagger에 `requestBody` 명세가 **누락** — multipart/form-data로 추정되나 서버 코드 또는 별도 문서 확인 필요
- ✅ 응답: `{url}` — 일치

---

## 공통 사항 검증 결과

| 항목 | 결과 |
|------|------|
| 인증 헤더 형식 | `Authorization: Bearer {JWT}` (스펙상 apiKey/Authorization 헤더, 설명에 Bearer 명시) |
| Base URL | `/` (버전 prefix 없음) |
| 페이지네이션 | Cursor 기반 (Messages만 해당, `cursor` + `limit`) |
| 날짜 포맷 | `string` 타입만 명시, 형식 미지정 (ISO 8601 추정) |
| 에러 응답 | Swagger에 명시 없음 — 별도 확인 필요 |
| 응답 코드 | POST: 201 Created, DELETE: 204 No Content, GET/PATCH: 200 OK |

---

## 추가 발견 사항

### 누락 또는 미지원 기능
1. **WebSocket 실시간 채팅**: 백엔드가 미구현 — 폴링 또는 향후 추가 필요
2. **에러 응답 스키마**: Swagger에 정의 없음 — Tsoa의 기본 에러 형식(`{name, message, fields?, status?}`) 또는 별도 확인 필요
3. **첨부파일 업로드 형식**: multipart 명세 누락 — 서버 코드 확인 필요
4. **이벤트의 작성자/생성자 정보**: `EventResponse`에 createdBy/createdAt 등 없음
5. **밴드 가입/탈퇴 자기 액션**: 현재 멤버 추가는 invite 형식, 본인이 직접 가입은 별도 API 없음

### 클라이언트 영향도
- FE의 `Member` 모델에 `role`, `email` 필드 추가 필요
- FE의 `Band` 모델에서 `members`/`events` 직접 포함 구조 → 별도 API 호출 후 결합으로 변경 필요
- FE의 `BandEvent.description`을 nullable로 변경 필요
- 채팅은 폴링 기반으로 임시 구현 후, WebSocket 추가 시 마이그레이션
