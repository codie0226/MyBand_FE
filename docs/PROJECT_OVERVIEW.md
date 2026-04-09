# PROJECT OVERVIEW

> 마지막 업데이트: 2026-04-09
> 이 문서는 다른 AI 에이전트가 프로젝트를 빠르게 파악할 수 있도록 작성된 기술 문서입니다.

---

## 프로젝트 개요

- **앱 이름**: MyBand
- **목적**: 밴드 전용 메신저 및 일정 관리 애플리케이션
- **주요 사용자 시나리오**:
  1. Google 계정으로 로그인
  2. 소속 밴드 선택 후 멤버 정보 및 일정 확인 (나의 밴드 탭)
  3. 밴드 단체 채팅 (채팅 탭)
  4. 월간 캘린더로 일정 조회 및 상세 확인 (캘린더 탭)
- **디자인 컨셉**: Black & White 모노톤 + Electric Blue(`#0038FF`) 포인트 컬러

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| Framework | Flutter (Dart SDK `>=3.11.0`) |
| State Management | `flutter_riverpod ^3.3.1` — `NotifierProvider` 패턴 |
| Routing | `go_router ^17.1.0` — `StatefulShellRoute` 기반 4탭 |
| 인증 | `google_sign_in ^6.2.2` — 웹 OAuth 2.0 / Android Firebase |
| Typography | `google_fonts ^8.0.2` — Noto Sans KR |
| Icons | `font_awesome_flutter ^11.0.0` |
| Calendar UI | `table_calendar ^3.2.0` |
| HTTP Client | `dio ^5.9.2` (추가됨, 아직 미사용) |
| Date/i18n | `intl ^0.20.2` — `ko_KR` 로케일 초기화 |

---

## 프로젝트 구조

```
lib/
 ├ core/
 │  ├ router/
 │  │  ├ app_router.dart            # GoRouter 설정, _RouterNotifier(auth redirect), 4개 탭 라우트
 │  │  └ scaffold_with_nav_bar.dart # 하단 BottomNavigationBar 레이아웃 래퍼
 │  └ theme/
 │     └ app_theme.dart             # AppColors 상수 + AppTheme.lightTheme (Material 3)
 │
 └ features/
    ├ auth/
    │  ├ providers/
    │  │  └ auth_provider.dart      # AuthNotifier (bool 상태), GoogleSignIn 연동
    │  └ views/
    │     └ login_screen.dart       # 로그인 화면 — 기타 아이콘 + Google 로그인 버튼
    │
    ├ my_band/
    │  ├ models/
    │  │  └ band_models.dart        # Band, Member, BandEvent, EventType enum + Mock 데이터
    │  ├ providers/
    │  │  └ band_provider.dart      # bandsProvider, selectedBandProvider (SelectedBandNotifier)
    │  ├ views/
    │  │  └ my_band_screen.dart     # 밴드 선택 드롭다운 + 멤버/이벤트/밴드정보 섹션
    │  └ widgets/
    │     ├ band_info_section.dart
    │     ├ member_list_section.dart
    │     ├ event_list_section.dart
    │     └ event_detail_dialog.dart # 모달 바텀시트 일정 상세
    │
    ├ chat/
    │  ├ models/
    │  │  └ chat_model.dart         # ChatMessage 모델 + 밴드별 Mock 메시지 생성 함수
    │  ├ views/
    │  │  └ chat_screen.dart        # ConsumerStatefulWidget — 채팅 메인 화면
    │  └ widgets/
    │     ├ chat_bubble.dart        # 말풍선 (isMe 분기)
    │     ├ chat_input_bar.dart     # 입력 바 + 자동 스크롤
    │     └ attachment_menu.dart    # 첨부 바텀 시트 (Mock)
    │
    ├ calendar/
    │  └ views/
    │     └ calendar_screen.dart    # TableCalendar + 날짜별 일정 목록/상세 인라인 패널
    │
    └ profile/
       └ views/
          └ profile_screen.dart    # 스텁 (미구현)
```

---

## 구현된 기능

### 1. 로그인 (`auth`)
- **화면**: `login_screen.dart` — 앱 이름, 기타 아이콘, "Google로 계속하기" 버튼
- **상태**: `authProvider` (`NotifierProvider<AuthNotifier, bool>`)
- **인증**: `google_sign_in` SDK — `signInWithGoogle()` / `signOut()`
- **라우팅 가드**: `_RouterNotifier` + `refreshListenable` — 미인증 시 `/login` 자동 redirect

### 2. 나의 밴드 (`my_band`)
- **화면**: AppBar 드롭다운으로 밴드 전환 → `selectedBandProvider` 전역 상태 변경
- **섹션**: 멤버 수평 스크롤 목록 / 이벤트 카드 목록 / 밴드 소개
- **일정 상세**: `EventDetailDialog.show()` — 모달 바텀시트, 셋리스트 포함
- **Mock 데이터**: `band_provider.dart`의 `mockBands` (밴드 2개, 인디스타즈 / Blue Note Project)

### 3. 채팅 (`chat`)
- **상태 연동**: `selectedBandProvider` watch → 밴드 전환 시 채팅 내역 갱신
- **DateSeparator**: 날짜 경계마다 `yyyy년 M월 d일` 구분선 자동 삽입
- **자동 스크롤**: 메시지 전송 시 `ScrollController.animateTo(maxScrollExtent)`
- **첨부 메뉴**: `AttachmentMenu` — 일정 생성 / 이미지 / PDF (UI만 구현)

### 4. 캘린더 (`calendar`)
- **라이브러리**: `table_calendar` — `ko_KR` 로케일, B&W + Electric Blue 테마
- **이벤트 마커**: `selectedBandProvider`의 이벤트를 날짜별 점으로 표시
- **3단계 패널** (AnimatedSwitcher): 날짜 미선택 → 날짜 선택(목록) → 이벤트 선택(상세)
- **상세 뷰**: 뒤로가기 버튼으로 목록 복귀, 셋리스트 포함
- **새 일정 추가 버튼**: UI만 존재, 기능 미구현

---

## 미구현 / TODO

| 항목 | 파일 | 비고 |
|------|------|------|
| 프로필 화면 | `profile/views/profile_screen.dart` | 아이콘만 있는 스텁 |
| 캘린더 일정 추가 | `calendar_screen.dart` | 버튼 UI는 존재, `onPressed` 비어있음 |
| 채팅 첨부 기능 | `attachment_menu.dart` | 이미지/PDF 피커, 일정 연동 미구현 |
| 실시간 채팅 | `chat/` | WebSocket / Firebase 연동 없음 |
| 백엔드 API 연동 | 전체 | `dio` 패키지만 추가됨, 실제 호출 없음 |
| 모델 직렬화 | `band_models.dart`, `chat_model.dart` | `freezed` + `json_serializable` 미적용 |
| Android Google Sign-In | `android/app/` | `google-services.json` 배치 필요 (Firebase 콘솔에서 발급) |

### 알려진 이슈
- **웹 실행 시**: `google_sign_in` 웹 OAuth 클라이언트 ID를 `web/index.html` 메타태그와 `auth_provider.dart`의 `_webClientId`에 실제 값으로 교체해야 동작함
- **Windows Developer Mode**: `flutter pub get` 시 심볼릭 링크 경고 출력되나 빌드에 무영향

---

## 에이전트를 위한 참고사항

### 디자인 규칙 (Must Follow)
- 모든 색상은 반드시 `Theme.of(context)` 또는 `AppColors` 상수 사용
- 배경: `AppColors.background` / `scaffoldBackgroundColor`
- 카드/컨테이너: `AppColors.surface`
- 텍스트: `AppColors.primaryText` (강조) / `AppColors.secondaryText` (보조)
- 포인트(클릭 액션, 선택 상태 등 제한적 사용): `AppColors.point` (`#0038FF`)
- `withOpacity()` deprecated → `withValues(alpha: 0.x)` 사용

### 코드 컨벤션
- 화면: `ConsumerWidget` 또는 `ConsumerStatefulWidget` (Riverpod 필요 시)
- 상태: `NotifierProvider` 패턴 (`StateNotifierProvider` 사용 금지)
- 라우팅: `go_router`의 `context.go()` / `context.push()` 사용
- 위젯 분리: 재사용 위젯은 `widgets/` 하위 별도 파일, 일회성은 private class로 같은 파일 내

### 폴더 규칙
- Feature 단위 폴더: `models/` → `providers/` → `views/` → `widgets/`
- 공유 리소스만 `core/`에 위치
- 새 기능 추가 시 `features/` 하위에 동일 구조로 생성
