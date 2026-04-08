# MyBand

밴드 멤버들을 위한 협업 및 커뮤니케이션 앱입니다. 합주, 공연, 일정 관리와 팀 채팅을 하나의 앱에서 편리하게 이용할 수 있습니다.

---

## 주요 기능

### 내 밴드 (My Band)
- 여러 밴드를 드롭다운으로 전환하여 확인
- 밴드 멤버 목록 및 담당 악기 표시
- 합주 / 공연 / 기타 유형별 일정 목록
- 일정 상세 모달 (제목, 날짜, 설명, 셋리스트)
- 밴드 소개글 표시

### 채팅 (Chat)
- 밴드별 단체 채팅방
- 말풍선 UI (내 메시지 / 상대방 메시지 구분)
- 날짜 구분선 자동 표시
- 첨부 메뉴: 일정 생성, 이미지 공유, PDF 공유

### 캘린더 (Calendar)
- 밴드 일정을 캘린더로 확인 (개발 예정)

### 프로필 (Profile)
- 내 프로필 관리 (개발 예정)

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| **언어** | Dart 3.11.0 |
| **프레임워크** | Flutter |
| **상태 관리** | flutter_riverpod ^3.3.1 |
| **라우팅** | go_router ^17.1.0 |
| **HTTP 클라이언트** | dio ^5.9.2 |
| **아이콘** | font_awesome_flutter ^11.0.0 |
| **폰트** | Google Fonts - Noto Sans KR |
| **달력** | table_calendar ^3.2.0 |
| **다국어/날짜** | intl ^0.20.2 |

---

## 프로젝트 구조

```
lib/
├── main.dart
├── core/
│   ├── router/
│   │   ├── app_router.dart              # GoRouter 설정
│   │   └── scaffold_with_nav_bar.dart   # 하단 내비게이션 바
│   └── theme/
│       └── app_theme.dart               # 컬러 및 텍스트 테마
└── features/
    ├── my_band/
    │   ├── models/band_models.dart       # Band, Member, BandEvent 모델
    │   ├── providers/band_provider.dart  # Riverpod 프로바이더 & 목 데이터
    │   ├── views/my_band_screen.dart
    │   └── widgets/
    │       ├── band_info_section.dart
    │       ├── member_list_section.dart
    │       ├── event_list_section.dart
    │       └── event_detail_dialog.dart
    ├── chat/
    │   ├── models/chat_model.dart        # ChatMessage 모델 & 더미 데이터
    │   ├── views/chat_screen.dart
    │   └── widgets/
    │       ├── chat_bubble.dart
    │       ├── chat_input_bar.dart
    │       └── attachment_menu.dart
    ├── calendar/
    │   └── views/calendar_screen.dart
    └── profile/
        └── views/profile_screen.dart
```

---

## 디자인 시스템

| 요소 | 값 |
|------|----|
| **Primary** | Black `#111111` |
| **Point (강조)** | Electric Blue `#0038FF` |
| **Background** | White `#FFFFFF` |
| **Surface** | Off-white `#F8F8F8` |
| **Secondary Text** | Gray `#757575` |
| **폰트** | Noto Sans KR |
| **카드 스타일** | 그림자 없음, 1px 라인 테두리 |

---

## 시작하기

### 요구 사항
- Flutter SDK 3.x 이상
- Dart 3.11.0 이상

### 설치 및 실행

```bash
# 패키지 설치
flutter pub get

# 앱 실행
flutter run
```

---

## 개발 현황

| 기능 | 상태 |
|------|------|
| 내 밴드 화면 | 완료 |
| 채팅 UI | 완료 |
| 채팅 실시간 연동 | 미완료 |
| 캘린더 | 미완료 |
| 프로필 | 미완료 |
| 첨부파일 (이미지/PDF) | 미완료 |
| API 연동 | 미완료 |
