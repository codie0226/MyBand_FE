# 2026-05-07 작업 기록

## 작업 요약

채팅 화면을 더미 데이터 기반에서 백엔드 메시지 API와 WebSocket 기반으로 전환했다. 메시지를 전송하면 서버 DB에 저장되고, 채팅방 진입 시 저장된 로그를 불러오며, WebSocket으로 새 메시지를 실시간 수신한다.

## 작업 배경 및 목적

기존 채팅 화면은 밴드별 mock 메시지만 보여주고 있었다. 백엔드에는 이미 `GET/POST /bands/{bandId}/messages`와 `WS /bands/{bandId}/chat?token=...`가 구현되어 있으므로, 프론트에서 실제 서버 계약에 맞춰 채팅 로그 조회, 메시지 저장, 실시간 반영 흐름을 연결하는 것이 목적이었다.

## 주요 의사결정

- 전송은 WebSocket send가 아니라 `POST /messages`를 사용한다. 서버가 POST 저장 후 같은 메시지를 WebSocket으로 publish하므로 DB 저장과 브로드캐스트 경로가 하나로 유지된다.
- 화면에는 POST 응답도 즉시 반영한다. WebSocket echo와 중복될 수 있어 메시지 id 기준 upsert로 처리한다.
- 서버 목록 응답은 최신순이므로 최초 렌더링 시 뒤집어서 시간 오름차순으로 보여준다.
- 현재 사용자 id는 `userProfileProvider`에서 가져와 `senderId`와 비교하고, `isMe` 말풍선 분기에 사용한다.
- `web_socket_channel`을 직접 의존성으로 추가했다. 기존 lock에는 transitive로 존재했지만 직접 import를 위해 `pubspec.yaml`에 명시했다.

## 구현 상세

- `lib/features/chat/data/chat_repository.dart`
  - 메시지 목록 조회, 메시지 전송, WebSocket 연결, WebSocket 이벤트 파싱을 담당하는 repository를 추가했다.
- `lib/features/chat/models/chat_model.dart`
  - mock 생성기를 제거하고 서버 DTO 기반 `ChatMessage.fromJson()`과 `ChatMessagePage`를 추가했다.
- `lib/features/chat/views/chat_screen.dart`
  - 밴드/사용자 변경 감지, 로그 로드, WebSocket 구독 해제/재연결, 메시지 upsert, 재시도 UI를 구현했다.
- `lib/features/chat/widgets/attachment_menu.dart`, `chat_input_bar.dart`
  - 채팅 디렉터리 분석 통과를 위해 deprecated `withOpacity()` 사용을 `withValues(alpha: ...)`로 교체했다.
- `pubspec.yaml`, `pubspec.lock`
  - `web_socket_channel ^3.0.3`을 direct dependency로 반영했다.

## 검증

- `flutter pub get` 성공
- `flutter analyze --no-pub lib/features/chat` 성공
- 백엔드 TypeScript 타입체크: `node node_modules/typescript/bin/tsc -p tsconfig.json --noEmit` 성공

## 다음 작업 메모

- `nextCursor`를 이용해 채팅방 상단 스크롤 시 이전 메시지를 추가 로드하는 기능이 남아 있다.
- 이미지/PDF 첨부는 UI만 있고 파일 선택 및 업로드 API 연결은 아직 필요하다.
- Android 에뮬레이터에서 테스트할 경우 `AppConfig.apiBaseUrl`의 host를 `10.0.2.2`로 바꿔야 할 수 있다.
