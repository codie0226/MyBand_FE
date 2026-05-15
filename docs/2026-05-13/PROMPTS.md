# 2026-05-13 작업 기록

## 작업 요약

프로필 화면에서 새 밴드를 생성할 수 있는 버튼과 생성 화면을 추가했다. 생성 화면은 온보딩의 밴드 생성 입력 형식과 동일하게 밴드 아이콘, 밴드명, 장르, 설명을 입력받고 `POST /bands` API로 새 밴드를 만든다.

## 작업 배경 및 목적

기존에는 신규 사용자가 온보딩 중에만 밴드를 생성할 수 있었다. 이미 온보딩을 완료한 사용자가 추가 밴드를 만들려면 별도 진입점이 필요했으므로, 프로필 화면에서 독립적으로 새 밴드 생성 흐름에 접근할 수 있도록 구현했다.

## 주요 의사결정 및 사고 과정

- 백엔드에 이미 `POST /bands` API가 있으므로 온보딩 완료 API를 재사용하지 않고 밴드 전용 저장소 메서드를 추가했다.
- 생성 화면은 온보딩의 `밴드 생성` 필드 구성을 그대로 따른다. 사용자는 아이콘 선택, 밴드명 입력, 장르/설명 입력 후 생성한다.
- 생성 성공 후 `bandsProvider`와 `selectedBandProvider`를 갱신하고, 새로 생성된 밴드 id를 `selectedBandIdProvider`에 반영해 메인 밴드 화면에서 바로 새 밴드가 보이도록 했다.

## 구현 상세

- `lib/features/my_band/data/band_repository.dart`
  - `createBand()`를 추가해 `POST /bands` 요청을 보낸다.
- `lib/features/my_band/views/create_band_screen.dart`
  - 새 밴드 생성 화면을 추가했다.
  - `image_picker`로 밴드 아이콘을 선택하고 `attachmentRepositoryProvider`로 업로드한다.
  - 생성 성공 시 밴드 상태를 갱신하고 `/my_band`로 이동한다.
- `lib/core/router/app_router.dart`
  - 루트 라우트 `/create_band`를 추가했다.
- `lib/features/profile/views/profile_screen.dart`
  - 읽기 전용 프로필 화면 하단에 `새 밴드 생성` 버튼을 추가했다.
- `lib/features/profile/data/user_repository.dart`, `lib/features/my_band/data/event_repository.dart`
  - 기존 payload/query map의 null-aware element 문법을 정리해 분석이 통과하도록 했다.

## 다음 작업을 위한 메모

- 밴드 생성 후 초대 코드 공유 UX를 추가하면 흐름이 더 자연스럽다.
- 밴드 정보 수정/삭제 UI는 아직 없으므로 추후 밴드 관리 화면이 필요하다.
- 이미지 선택 후 실제 미리보기 대신 아이콘 상태만 바뀌는 형태다. 필요하면 로컬 이미지 프리뷰를 추가할 수 있다.

---

## 작업 요약

남은 기능 목록 중 밴드 정보 수정, owner 전용 멤버 관리, 채팅 이미지/PDF 첨부, 밴드 탈퇴, 빈 밴드 화면, 캘린더 전체 밴드 일정 필터링을 구현했다. 백엔드에는 멤버 soft delete와 메시지 첨부 저장 필드를 추가했다.

## 작업 배경 및 목적

앱이 단일 밴드 조회 중심에서 여러 밴드를 실제로 운영할 수 있는 구조로 확장되어야 했다. owner 권한이 있는 사용자만 관리 기능을 보고, 일반 멤버는 수정/관리 버튼이 보이지 않도록 권한 기반 UI를 추가했다. 채팅은 텍스트뿐 아니라 일정 첨부와 같은 방식의 파일 공유가 필요했고, 캘린더는 선택 밴드 하나가 아니라 모든 소속 밴드의 일정을 한 번에 보는 방식으로 바꾸었다.

## 주요 의사결정 및 사고 과정

- 밴드 정보 수정 화면은 `CreateBandScreen`을 확장해 생성/수정 모드를 함께 처리하게 했다.
- owner 여부는 선택된 밴드의 `members` 중 현재 사용자 role을 확인해 판단한다.
- 멤버 강퇴/탈퇴는 백엔드 `BandMember.leftAt`으로 soft delete 처리한다. 목록 조회, owner 카운트, 소속 밴드 조회는 `leftAt == null`만 사용한다.
- 채팅 첨부는 메시지의 `attachments` JSON 배열로 저장한다. 이미지/PDF 모두 기존 attachment 업로드 API를 재사용한다.
- 캘린더는 `allBandEventsProvider`에서 소속 밴드별 일정을 병렬 조회하고, 화면 상태의 밴드 id 집합으로 다중 필터링한다.

## 구현 상세

- FE `lib/features/my_band/views/create_band_screen.dart`
  - 새 밴드 생성과 밴드 정보 수정을 같은 화면에서 처리한다.
- FE `lib/features/my_band/views/manage_band_members_screen.dart`
  - 멤버 owner 승격과 강퇴 UI를 추가했다.
- FE `lib/features/my_band/views/join_band_screen.dart`, `widgets/empty_band_actions.dart`
  - 밴드가 없을 때 가입/생성 버튼만 보이는 공통 화면을 추가했다.
- FE `lib/features/my_band/views/my_band_screen.dart`
  - owner 전용 수정/관리 버튼과 밴드 탈퇴 확인 플로우를 추가했다.
- FE `lib/features/chat/*`
  - 이미지/PDF 업로드, 첨부 메시지 전송, 이미지 전체 화면 미리보기, 다운로드/열기 동작을 추가했다.
- FE `lib/features/calendar/views/calendar_screen.dart`
  - 모든 밴드 일정 조회와 밴드별 다중 필터를 추가했다.
- BE `prisma/schema.prisma`
  - `BandMember.leftAt`, `Message.attachments`를 추가했다.
- BE `src/repositories/*`, `src/services/*`, `src/dtos/message.dto.ts`
  - soft delete 멤버십, 재가입 복구, 메시지 첨부 응답/요청 처리를 추가했다.

## 다음 작업을 위한 메모

- 채팅 이전 메시지 무한 스크롤은 아직 남아 있다.
- 멤버 등급 관리는 현재 member -> owner 승격만 UI로 제공한다. owner 강등 UI가 필요하면 마지막 owner 보호 정책과 함께 추가하면 된다.
- 밴드 삭제 UI는 아직 없다.
