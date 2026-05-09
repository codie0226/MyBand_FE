# PROJECT OVERVIEW

> 마지막 업데이트: 2026-05-07
> 이 문서는 다른 AI 에이전트가 MyBand 프론트엔드 구조와 구현 상태를 빠르게 파악하도록 돕는 기술 문서입니다.

## 프로젝트 개요

- **프로젝트명**: MyBand
- **목적**: 밴드 멤버를 위한 메신저, 일정 관리, 멤버 정보 확인 앱
- **주요 사용자 시나리오**
  - Google 계정으로 로그인한다.
  - 소속 밴드를 선택하고 멤버, 일정, 밴드 정보를 확인한다.
  - 밴드 채팅방에서 이전 메시지 로그를 보고 실시간 메시지를 주고받는다.
  - 캘린더와 밴드 화면에서 일정을 확인하고 새 일정을 등록한다.
- **디자인 컨셉**: Black & White 기반, Electric Blue(`#0038FF`) 포인트 컬러

## 기술 스택

| 항목 | 내용 |
| --- | --- |
| Framework | Flutter, Dart SDK `>=3.11.0` |
| State Management | `flutter_riverpod ^3.3.1` |
| Routing | `go_router ^17.1.0`, `StatefulShellRoute` 기반 하단 탭 |
| HTTP | `dio ^5.9.2` |
| WebSocket | `web_socket_channel ^3.0.3` |
| Auth | `google_sign_in ^6.2.2`, `flutter_secure_storage ^9.2.2` |
| UI | `google_fonts`, `font_awesome_flutter`, `table_calendar`, `intl` |

## 프로젝트 구조

```text
lib/
  core/
    config/app_config.dart          # API base URL, mock flag, timeout
    network/                        # Dio client, token storage, API providers
    router/                         # GoRouter, shell route, bottom navigation
    theme/app_theme.dart            # AppColors, Material theme
  features/
    auth/                           # Google login, JWT 저장/복원
    my_band/                        # 밴드/멤버/일정 조회와 일정 생성
    calendar/                       # 월간 캘린더와 일정 상세
    chat/
      data/chat_repository.dart     # 메시지 GET/POST, WebSocket 연결
      models/chat_model.dart        # ChatMessage, ChatMessagePage
      views/chat_screen.dart        # 채팅 로그 로드, 실시간 구독, 전송
      widgets/                      # 말풍선, 입력바, 첨부 메뉴
    profile/                        # 사용자 프로필 조회/수정
```

## 구현된 기능

### 인증

- `AuthNotifier`가 저장된 JWT를 복원하고 Google 로그인 성공 시 서버 JWT를 `FlutterSecureStorage`에 저장한다.
- `ApiClient`가 모든 Dio 요청에 `Authorization: Bearer {token}` 헤더를 자동으로 붙인다.

### 밴드와 일정

- `bandsProvider`, `selectedBandIdProvider`, `selectedBandProvider`로 밴드 목록과 선택 상태를 관리한다.
- 선택된 밴드 상세는 멤버 목록과 일정 목록을 병렬로 조회해 조립한다.
- 일정 추가 화면은 메인, 캘린더, 채팅 첨부 메뉴에서 동일한 `/add_event` 라우트로 진입한다.

### 채팅

- `ChatRepository.getMessages()`가 `GET /bands/{bandId}/messages?limit&cursor`로 DB에 저장된 채팅 로그를 조회한다.
- `ChatRepository.sendMessage()`가 `POST /bands/{bandId}/messages`로 메시지를 저장하고 서버 응답을 화면에 반영한다.
- `ChatRepository.connectMessages()`가 `ws://.../bands/{bandId}/chat?token={JWT}`에 연결해 실시간 메시지를 수신한다.
- `ChatScreen`은 선택 밴드나 사용자 id가 바뀌면 기존 WebSocket을 닫고 새 밴드 채팅 로그를 로드한다.
- POST 응답과 WebSocket echo가 동시에 들어와도 메시지 id로 upsert하여 중복 말풍선을 방지한다.
- 서버는 최신순으로 메시지를 내려주므로 화면에서는 시간 오름차순으로 뒤집어 보여준다.

### 프로필

- `userProfileProvider`가 `GET /users/me` 응답을 제공하고, 프로필 저장 후 선택 밴드 상세를 invalidate해 멤버 정보에 반영한다.

## 미구현 / TODO

| 항목 | 파일 | 비고 |
| --- | --- | --- |
| 채팅 이미지 첨부 | `chat/widgets/attachment_menu.dart` | 이미지 피커와 업로드 API 연결 필요 |
| 채팅 PDF 첨부 | `chat/widgets/attachment_menu.dart` | 파일 피커와 업로드 API 연결 필요 |
| 채팅 무한 스크롤 | `chat/views/chat_screen.dart` | `nextCursor`를 이용한 이전 메시지 추가 로드 필요 |
| 일정 수정/삭제 | `my_band/` | 현재 생성과 조회 중심 |
| Google Sign-In 배포 설정 | `android/`, `web/`, `auth_provider.dart` | 실제 OAuth client id와 Firebase 설정 확인 필요 |

## 에이전트 참고사항

- 프론트 API 기준 서버 주소는 `AppConfig.apiBaseUrl`이다. 기본값은 `http://localhost:3000`이다.
- Android 에뮬레이터에서 로컬 백엔드를 붙일 때는 `localhost` 대신 `10.0.2.2`가 필요할 수 있다.
- 채팅 WebSocket 인증은 헤더가 아니라 query token 방식이다.
- Riverpod은 현재 `NotifierProvider` / `AsyncNotifierProvider` 패턴을 사용한다.
- deprecated `withOpacity()` 대신 `withValues(alpha: ...)`를 사용한다.
