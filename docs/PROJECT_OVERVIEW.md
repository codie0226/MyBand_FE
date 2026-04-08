# MyBand Frontend - 프로젝트 명세서 및 진행 현황

본 문서는 지금까지 진행된 MyBand 애플리케이션의 개발 현황과 아키텍처, 그리고 향후 개발을 이어갈 작업자(또는 AI 에이전트)가 프로젝트를 즉시 파악하고 이어나갈 수 있도록 작성된 가이드 문서입니다.

---

## 1. 프로젝트 요약
- **목적**: 밴드 전용 메신저 및 일정 관리 애플리케이션
- **디자인 컨셉**: 모던 **Black & White** 인터페이스. 핵심 요소에만 **Electric Blue (`#0038FF`)**를 포인트 컬러로 사용하여 높은 가독성과 세련됨을 추구합니다.

---

## 2. 사용된 기술 스택 및 라이브러리
- **Framework**: Flutter (Dart SDK `>=3.11.0`)
- **State Management**: `flutter_riverpod` (밴드 상태 공유, 앱 내 전역 상태 관리)
- **Routing**: `go_router` (선언적 라우팅 및 탭 기반 네비게이션 관리)
- **Typography**: `google_fonts` (글로벌 Noto Sans KR 폰트 적용)
- **Icons**: `font_awesome_flutter` (UI 내 첨부 및 메뉴 아이콘)
- **Utilities**: `intl` (날짜 및 시간 포맷팅)

---

## 3. 주요 구현 완료 기능 (Features Implemented)

### 3.1. 글로벌 테마 및 네비게이션 (`AppTheme`, `ScaffoldWithNavBar`)
- 앱 전반에 걸쳐 백그라운드 색상(`ScaffoldBackgroundColor`), `Surface`, 텍스트 강도 등을 모노톤으로 정비.
- 앱의 메인 라우터 역할을 하는 네비게이션 바를 Material 3의 버블 디자인에서 미니멀한 `BottomNavigationBar` 형태로 개편하여 시각적 피로도를 낮춤.

### 3.2. 대시보드 (나의 밴드 화면)
- `lib/features/my_band/` 에 모듈화되어 있음.
- **선택된 밴드 상태 연동**: 좌측 상단 드롭다운 형태의 헤더를 통해 Riverpod의 `selectedBandProvider` 상태를 변경 가능.
- **정보 섹션 (Band Info / Member List)**: 멤버의 악기명 및 기타 설명을 회색 및 불투명도(Opacity) 조절과 폰트 굵기를 통해 세련되게 분리.
- **일정 섹션 (Event List)**: 원색 계열이었던 일정 컴포넌트를 무채색/포인트 컬러 테두리와 배지로 개편 완료.

### 3.3. 채팅 시스템 (`ChatScreen`)
해당 컴포넌트는 실제 백엔드를 연결하기 직전까지의 UI/UX 완성 테스트를 통과했습니다.

- **상태 동기화**: `selectedBandProvider`를 구독(watch)하여 헤더의 방 이름(`[밴드명] 채팅방`)이 즉시 변경되고, 선택된 밴드의 `bandId`에 따라 종속적인 목(Mock) 대화 내역이 불러와집니다.
- **말풍선 컴포넌트 (`ChatBubble`)**:
  - 상대방(`!isMe`): 좌측 정렬, 하얀색/연한 회색 표면(`Surface`), 상단에 발신자 닉네임 노출, 우측 하단 시간 노출.
  - 본인(`isMe`): 우측 정렬, 테마 포인트 색상(블루) 바탕, 백색 글씨, 좌측 하단 시간 노출.
- **날짜 구분선 생성 로직 (`DateSeparator`)**: `ListView.builder`가 렌더링될 때, 이전 메시지와 날짜(연/월/일)가 다르거나 첫 번째 메시지일 경우 `yyyy년 M월 d일` 형태의 중앙 구분선을 자동 생성함 (버그 패치 완료).
- **사용자 입력 및 첨부 바 (Chat Input Bar)**:
  - 전송 버튼 클릭 시 ListView의 `ScrollController`를 통해 **최하단(maxScrollExtent)으로 자동 애니메이션 스크롤**됨.
  - `+` 버튼을 통해 애니메이션과 함께 올라오는 **첨부 바텀 시트(`AttachmentMenu`)** 제공.
  - 첨부 시트 내부에는 '일정 생성', '이미지', '문서(PDF)' 모조 기능 아이콘이 구현되어 있음.

---

## 4. 폴더 구조 및 파일 역할 요약

```text
lib/
 ┣ core/
 ┃ ┣ router/          // go_router 설정 및 하단 네비게이션 레이아웃
 ┃ ┗ theme/           // AppTheme 글로벌 테마 정의 구역
 ┣ features/
 ┃ ┣ calendar/        // 캘린더 기능 폴더 (비어있는 상태, UI 기본 틀만 존재)
 ┃ ┣ chat/
 ┃ ┃ ┣ models/        // chat_model.dart (채팅 데이터 스키마 및 Mock 생성 함수)
 ┃ ┃ ┣ views/         // chat_screen.dart (최상단 메인 UI. Riverpod Consumer State 포함)
 ┃ ┃ ┗ widgets/       // chat_bubble.dart, chat_input_bar.dart, attachment_menu.dart
 ┃ ┣ my_band/         // 메인 대시보드 뷰, 프로바이더 및 각 섹션 위젯
 ┃ ┃ ┣ providers/     // band_provider.dart (SelectedBandNotifier 상태 관리)
 ┃ ┃ ┗ widgets/       // 이벤트 리스트, 멤버 리스트 UI 렌더링 컴포넌트
 ┃ ┗ profile/         // 프로필/설정 탭
 ┗ main.dart          // 진입점 및 ProviderScope 래핑
```

---

## 5. 다음 작업자(에이전트)를 위한 TO-DO (Next Action Items)

이 문서를 바탕으로 개발을 넘겨받은 작업자는 즉시 아래 내용 중 하나를 선택하여 진행하면 됩니다:

1. **캘린더 기능 구현** `lib/features/calendar/views/calendar_screen.dart`:
   - 밴드별로 연동되는 일정 캘린더 라이브러리(e.g., `table_calendar`) 세팅 및 디자인 테마(B&W) 적용 작업.
2. **채팅 기능 고도화**:
   - 웹소켓(Socket.io 또는 Firebase 등) 설정 및 실시간 `ChatProvider` 연동 아키텍처 설계.
   - 첨부 메뉴(일정 생성, 이미지) 클릭 시 실제 로컬 디바이스의 다이얼로그 혹은 카메라 앱과 연동.
3. **상태 관리 구조 개선**:
   - 기존에 정적 Mock 데이터로 구현한 Model 객체들을 `freezed` + `json_serializable` 어노테이션으로 리팩토링하여 백엔드 REST/GraphQL 연동 구조 대비.

---
> **디자인 규칙 (Must Follow)**
> 이후 추가되는 모든 스크린과 위젯은 반드시 `Theme.of(context)` 컬러 스킴을 준수할 것.
> 기본 배경은 `scaffoldBackgroundColor`, 카드는 `surface`, 텍스트는 `onSurface`. 주의를 환기하거나 버튼 클릭 시에만 `secondary`(Electric Blue)를 제한적으로 사용할 것.
