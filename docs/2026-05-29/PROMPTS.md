# 2026-05-29 작업 기록

## 작업 요약

일정 삭제/수정 권한, 이미지 미리보기 가독성, 업로드 파일 시그니처 검증, 텍스트 선택, 새 일정 채팅 알림, 웹 아이콘 안정화, 프로필 초대 코드 가입을 구현했다.

## 작업 배경 및 목적

사용자가 정리한 개선점은 운영 권한, 파일 보안, 웹 사용성, 일정과 채팅의 연결성에 걸쳐 있었다. 일정은 owner와 생성자 권한을 구분해야 했고, 첨부 파일은 확장자만으로 판단하면 악성 파일이나 알 수 없는 형식이 통과할 수 있었다. 웹/PWA 환경에서는 외부 아이콘 폰트가 깨지는 문제가 있었고, 일반 텍스트가 드래그 선택되지 않아 복사가 어려웠다.

## 주요 의사결정 및 사고 과정

- 일정 삭제는 owner 전용으로 노출하고, 프론트 액션 핸들러에서도 `canDelete`를 다시 확인하게 했다.
- 일정 수정은 owner 또는 이벤트 생성자에게만 노출한다. 생성자 판단은 백엔드가 내려줄 수 있는 여러 키(`creatorId`, `createdById`, `createdByUserId`, `userId`, `creator.id`)를 유연하게 읽는다.
- 기존 `AddEventScreen`을 수정 화면까지 담당하는 공용 폼으로 확장했다. 라우트는 `/edit_event`, 전달 객체는 `EventFormArgs`로 분리했다.
- 파일 검증은 `AttachmentRepository` 앞단의 공통 유틸로 뒀다. PDF와 알려진 이미지 형식의 매직 바이트 및 확장자가 모두 맞아야 업로드한다.
- 웹 아이콘 문제는 외부 FontAwesome 폰트 의존성을 제거하고 Material Icons 및 텍스트 표식으로 치환하는 방향을 선택했다.
- 새 일정 알림은 일정 생성 성공 이후 일반 채팅 메시지로 전송한다. 알림 전송 실패가 일정 저장 자체를 롤백하지 않도록 경고만 띄운다.

## 구현 상세

- `lib/features/my_band/models/band_models.dart`
  - `BandEvent.creatorId`와 `EventFormArgs` 추가.
- `lib/features/my_band/views/add_event_screen.dart`
  - 일정 생성/수정 공용 폼으로 확장.
  - 생성 성공 후 `[새 일정]` 요약 채팅 메시지 전송.
- `lib/features/my_band/widgets/event_detail_dialog.dart`, `lib/features/calendar/views/calendar_screen.dart`
  - owner 삭제, owner/생성자 수정 액션 추가.
- `lib/features/my_band/widgets/setlist_item_form.dart`
  - 기존 셋리스트와 악보 URL을 수정 폼에 복원.
- `lib/core/network/attachment_repository.dart`, `lib/core/utils/file_signature.dart`
  - 업로드 파일 시그니처 및 확장자 검증 추가.
- `lib/features/chat/widgets/chat_bubble.dart`, `lib/features/my_band/widgets/sheet_music_gallery.dart`
  - 이미지/악보 미리보기 파일명 영역 고대비 처리.
- `lib/main.dart`
  - 앱 루트에 `SelectionArea` 적용.
- `lib/core/router/scaffold_with_nav_bar.dart`, `lib/features/auth/views/login_screen.dart`, `lib/features/chat/widgets/*`
  - FontAwesome 의존 아이콘을 Material Icons/텍스트로 교체.
- `lib/features/profile/views/profile_screen.dart`
  - 프로필 화면에서 초대 코드로 다른 밴드 가입 가능.
- `test/file_signature_test.dart`, `test/widget_test.dart`
  - 파일 시그니처 검증 테스트 추가, 오래된 카운터 테스트 정리.

## 다음 작업을 위한 메모

- 일정 생성자 수정 권한은 백엔드 이벤트 응답에 생성자 id가 포함되어야 일반 멤버에게 노출된다.
- 파일 MIME/시그니처 검증과 일정 권한은 백엔드에서도 반드시 동일하게 강제해야 한다.
- `flutter test`는 통과하도록 정리했지만, 앱 라우터/인증 흐름에 대한 위젯 테스트는 별도 mock provider 설계가 필요하다.
