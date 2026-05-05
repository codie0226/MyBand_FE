# MyBand API 목록

> 작성일: 2026-04-20  
> 마지막 업데이트: 2026-05-04 (`localhost:3000/docs` Swagger 스펙 기반)  
> 출처: `myband-be v0.1.0` — Express + Tsoa + Prisma/SQLite

---

## 공통 사항

- **Base URL**: `http://localhost:3000` (버전 prefix 없음)
- **OpenAPI 버전**: 3.0.0
- **인증 방식**: 모든 API (`/auth/google` 제외) — `Authorization: Bearer {JWT}` 헤더
- **응답 코드 규칙**:
  - `200 OK`: 일반 GET/PATCH 성공
  - `201 Created`: POST 리소스 생성 성공
  - `204 No Content`: DELETE 또는 본문 없는 응답
- **에러 응답**: Swagger 명세 없음 — Tsoa 기본 형식(`{ name, message, fields?, status? }`) 또는 서버 구현 별도 확인 필요
- **날짜 포맷**: ISO 8601 추정 (`YYYY-MM-DD` 또는 `YYYY-MM-DDTHH:mm:ssZ`)

---

## 1. 인증 (Auth)

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| `POST` | `/auth/google` | ✗ | Google ID Token으로 로그인, 서버 JWT 발급 |
| `POST` | `/auth/logout` | ✓ | 로그아웃 (서버 측 토큰 무효화) — 204 |
| `GET` | `/auth/me` | ✓ | 현재 로그인 사용자 정보 조회 |

### `POST /auth/google`
**Request:**
```json
{
  "idToken": "Google에서_받은_ID_토큰"
}
```
**Response (200):** `LoginResponse`
```json
{
  "accessToken": "서버_JWT",
  "user": {
    "id": "user_001",
    "name": "김보컬",
    "email": "user@gmail.com",
    "profileImageUrl": null
  }
}
```

### `GET /auth/me`
**Response (200):** `UserProfileResponse` (아래 `/users/me`와 동일한 스키마)

---

## 2. 사용자 (Users)

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| `GET` | `/users/me` | ✓ | 내 프로필 조회 |
| `PATCH` | `/users/me` | ✓ | 내 프로필 수정 |

### `UserProfileResponse`
```json
{
  "id": "user_001",
  "email": "user@gmail.com",
  "name": "김보컬",
  "profileImageUrl": null,    // nullable
  "instrument": "Vocal/Guitar" // nullable
}
```

### `PATCH /users/me` Request
모든 필드 optional:
```json
{
  "name": "김보컬",
  "instrument": "Vocal/Guitar",
  "profileImageUrl": "https://..."
}
```

---

## 3. 밴드 (Bands)

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| `GET` | `/bands` | ✓ | 내 소속 밴드 목록 |
| `POST` | `/bands` | ✓ | 새 밴드 생성 — 201 |
| `GET` | `/bands/{bandId}` | ✓ | 밴드 상세 |
| `PATCH` | `/bands/{bandId}` | ✓ | 밴드 정보 수정 |
| `DELETE` | `/bands/{bandId}` | ✓ | 밴드 삭제 — 204 |

### `BandResponse`
```json
{
  "id": "b1",
  "name": "인디스타즈",
  "description": "홍대 모던락 밴드", // nullable
  "memberCount": 4
}
```
> ⚠️ `BandResponse`에 `members`/`events` 배열은 **없음**. 멤버는 `/bands/:bandId/members`, 일정은 `/bands/:bandId/events`로 별도 조회 필요.

### `POST /bands` Request — `CreateBandRequest`
```json
{
  "name": "인디스타즈",        // required
  "description": "홍대 모던락"  // optional
}
```

### `PATCH /bands/{bandId}` Request — `UpdateBandRequest`
모든 필드 optional:
```json
{
  "name": "변경된 이름",
  "description": "변경된 소개"
}
```

---

## 4. 밴드 멤버 (BandMembers)

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| `GET` | `/bands/{bandId}/members` | ✓ | 멤버 목록 |
| `POST` | `/bands/{bandId}/members` | ✓ | 멤버 초대 — 201 |
| `PATCH` | `/bands/{bandId}/members/{userId}` | ✓ | 멤버 정보 수정 |
| `DELETE` | `/bands/{bandId}/members/{userId}` | ✓ | 멤버 추방/탈퇴 — 204 |

### `BandMemberResponse`
```json
{
  "id": "user_001",
  "name": "김보컬",
  "email": "user@gmail.com",
  "instrument": "Vocal/Guitar", // nullable
  "profileImageUrl": "https://...", // nullable
  "role": "owner"                // "owner" | "member"
}
```

### `POST /bands/{bandId}/members` Request — `InviteBandMemberRequest`
```json
{
  "email": "newmember@gmail.com", // required
  "instrument": "Bass"            // optional
}
```

### `PATCH /bands/{bandId}/members/{userId}` Request — `UpdateBandMemberRequest`
모든 필드 optional:
```json
{
  "instrument": "Drum",
  "role": "member"
}
```

---

## 5. 일정 (Events)

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| `GET` | `/bands/{bandId}/events` | ✓ | 일정 목록 (날짜 필터 가능) |
| `POST` | `/bands/{bandId}/events` | ✓ | 일정 생성 — 201 |
| `GET` | `/bands/{bandId}/events/{eventId}` | ✓ | 일정 상세 |
| `PATCH` | `/bands/{bandId}/events/{eventId}` | ✓ | 일정 수정 |
| `DELETE` | `/bands/{bandId}/events/{eventId}` | ✓ | 일정 삭제 — 204 |

### `GET /bands/{bandId}/events` 쿼리 파라미터
- `from`: 시작 날짜 (`YYYY-MM-DD`, optional)
- `to`: 종료 날짜 (`YYYY-MM-DD`, optional)

### `EventType` enum
`"practice"` | `"performance"` | `"other"`

### `SetlistItem`
```json
{
  "id": "s1",
  "title": "별빛이 내린다",
  "artist": "안녕바다",
  "key": "C Major",                  // nullable
  "sheetMusicUrl": "https://...",    // nullable
  "references": ["https://youtube.com/..."]
}
```

### `EventResponse`
```json
{
  "id": "e1",
  "title": "정기 합주",
  "date": "2026-04-25",
  "type": "practice",
  "description": "리허설 및 사운드 체킹", // nullable
  "setlist": [ /* SetlistItem 배열 */ ]
}
```

### `POST /bands/{bandId}/events` Request — `CreateEventRequest`
```json
{
  "title": "정기 합주",        // required
  "date": "2026-04-25",       // required
  "type": "practice",         // required (EventType)
  "description": "리허설",     // optional
  "setlist": [                // optional, SetlistItemRequest[]
    {
      "title": "별빛이 내린다",  // required
      "artist": "안녕바다",      // required
      "key": "C Major",         // optional
      "sheetMusicUrl": "...",   // optional
      "references": ["..."]     // optional
    }
  ]
}
```

### `PATCH /bands/{bandId}/events/{eventId}` Request — `UpdateEventRequest`
모든 필드 optional. 셋리스트 항목 업데이트 시 `SetlistItemRequest.id`를 포함하면 기존 항목 식별 가능.

---

## 6. 메시지 / 채팅 (Messages)

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| `GET` | `/bands/{bandId}/messages` | ✓ | 메시지 목록 (커서 페이지네이션) |
| `POST` | `/bands/{bandId}/messages` | ✓ | 텍스트 메시지 전송 — 201 |

> ⚠️ **WebSocket 미지원** — 현재 백엔드는 REST만 제공. 실시간 수신은 폴링 또는 향후 추가 필요.

### `GET /bands/{bandId}/messages` 쿼리 파라미터
- `cursor`: 마지막 메시지 ID (optional)
- `limit`: 페이지 크기 (optional, number)

### `MessageResponse`
```json
{
  "id": "msg_001",
  "senderId": "user_001",
  "senderName": "김보컬",
  "senderProfileImageUrl": null, // nullable
  "text": "이번 주 합주 준비 다들 됐나요?",
  "createdAt": "2026-04-20T14:30:00Z"
}
```

### `MessageListResponse`
```json
{
  "messages": [ /* MessageResponse[] */ ],
  "nextCursor": "msg_050" // nullable, 마지막 페이지면 null
}
```

### `POST /bands/{bandId}/messages` Request — `SendMessageRequest`
```json
{
  "text": "메시지 내용" // required
}
```

---

## 7. 첨부파일 (Attachments)

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| `POST` | `/attachments/images` | ✓ | 이미지 업로드 — 201 |
| `POST` | `/attachments/files` | ✓ | PDF/파일 업로드 — 201 |

### `AttachmentResponse`
```json
{
  "url": "https://cdn.../images/abc123.jpg"
}
```

> ⚠️ Swagger에 `requestBody` 명세가 누락되어 있음. `multipart/form-data`로 추정 — 서버 코드 또는 추가 문서 확인 필요.

---

## 스키마 요약

### Auth 관련
- `GoogleLoginRequest { idToken }`
- `LoginResponse { accessToken, user: AuthUser }`
- `AuthUser { id, name, email, profileImageUrl? }`

### User 관련
- `UserProfileResponse { id, email, name, profileImageUrl?, instrument? }`
- `UpdateUserProfileRequest { name?, instrument?, profileImageUrl? }`

### Band 관련
- `BandResponse { id, name, description?, memberCount }`
- `CreateBandRequest { name, description? }`
- `UpdateBandRequest { name?, description? }`

### BandMember 관련
- `BandMemberRole`: `"owner" | "member"`
- `BandMemberResponse { id, name, email, instrument?, profileImageUrl?, role }`
- `InviteBandMemberRequest { email, instrument? }`
- `UpdateBandMemberRequest { instrument?, role? }`

### Event 관련
- `EventType`: `"practice" | "performance" | "other"`
- `SetlistItem { id, title, artist, key?, sheetMusicUrl?, references[] }`
- `SetlistItemRequest { id?, title, artist, key?, sheetMusicUrl?, references? }`
- `EventResponse { id, title, date, type, description?, setlist[] }`
- `CreateEventRequest { title, date, type, description?, setlist? }`
- `UpdateEventRequest { title?, date?, type?, description?, setlist? }`

### Message 관련
- `MessageResponse { id, senderId, senderName, senderProfileImageUrl?, text, createdAt }`
- `MessageListResponse { messages[], nextCursor? }`
- `SendMessageRequest { text }`

### Attachment 관련
- `AttachmentResponse { url }`

---

## API 구현 우선순위 (FE 연동 관점)

| 우선순위 | 도메인 | 이유 |
|---------|--------|------|
| 1 | Auth (`/auth/google`, `/auth/me`) | 다른 모든 API의 전제 조건 |
| 2 | Bands (`GET /bands`, `GET /bands/:id`) | 메인 화면 드롭다운/소개 |
| 3 | BandMembers (`GET /bands/:id/members`) | 멤버 목록 표시 |
| 4 | Events (`GET`, `POST`, `PATCH`, `DELETE`) | 일정 추가 화면 이미 구현됨 — 즉시 연결 가능 |
| 5 | Messages (`GET`, `POST` + 폴링) | 채팅 UI 이미 구현됨 |
| 6 | Attachments | 채팅 첨부 UI도 미구현이라 후순위 |
| 7 | User (`PATCH /users/me`) | 프로필 화면 자체가 미구현 |

---

## FE 연동 시 주의점

### 모델 변경 필요
1. **`Member`**: `email`, `role` 필드 추가 (`BandMemberResponse` 매핑)
2. **`Band`**: `members`/`events` 직접 포함 → 별도 API 호출 후 결합 (또는 향후 `Band` aggregate 응답 추가 요청)
3. **`BandEvent.description`**: nullable로 변경

### 응답 스키마 차이
- `Band` 단독 조회 시 멤버/이벤트가 함께 오지 않음 — Repository 레이어에서 병렬 호출 후 조립 필요
- `LoginResponse.user`는 `AuthUser`로 `instrument` 필드가 없음. 로그인 후 별도 `/auth/me` 또는 `/users/me` 호출로 풀 프로필 획득 권장

### 미지원 기능
- 실시간 채팅(WebSocket): REST 폴링으로 임시 구현
- 첨부파일 multipart 명세: 서버 구현 확인 후 추가 문서화 필요
- 에러 응답 형식: 명세 누락 — 실제 호출 시 확인 후 본 문서 업데이트
