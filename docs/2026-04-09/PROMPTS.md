# 2026-04-09 작업 기록

## 작업 요약
- 캘린더 화면 구현 (`table_calendar` 연동, 일정 마커/목록/상세 인라인 패널)
- 로그인 플로우 구축 (로그인 화면 UI + GoRouter 인증 가드)
- Google Sign-In 실제 연동 (`google_sign_in` 패키지 + Firebase/OAuth 설정)

---

## 작업 배경 및 목적

### 캘린더
기존 캘린더 화면은 아이콘 하나만 있는 스텁 상태였음. `table_calendar` 패키지가 이미 `pubspec.yaml`에 추가되어 있었으므로 곧바로 구현에 착수. `selectedBandProvider`를 통해 메인 화면과 동일한 밴드 일정 데이터를 공유하는 방식으로 구현.

### 로그인
앱 진입 시 인증 없이 바로 메인 화면으로 이동하는 구조를 개선. 로그인 상태를 Riverpod으로 전역 관리하고, GoRouter의 redirect 기능으로 미인증 사용자를 로그인 화면으로 보내는 가드를 추가.

### Google Sign-In 실연동
로그인 버튼 클릭 시 Mock(`state = true`)만 하던 구조를 실제 Google OAuth 플로우로 교체. 웹 플랫폼에서 `MissingPluginException` 에러가 발생하여 웹 OAuth 클라이언트 ID 설정을 추가함.

---

## 주요 의사결정 및 사고 과정

### 캘린더 패널 UX
- **고려한 방식 A**: `showModalBottomSheet` — 날짜 클릭 시 바텀시트, 일정 클릭 시 또 다른 바텀시트
- **고려한 방식 B**: 인라인 패널 (선택) — 화면 하단 절반을 패널 영역으로 고정, `AnimatedSwitcher`로 목록↔상세 전환
- **선택 이유**: 방식 B가 "뒤로가기 버튼으로 일정 목록으로 돌아간다"는 요구사항을 단순한 `setState`로 구현 가능하고, 화면 이탈 없이 자연스러운 흐름을 만들 수 있음

### 인증 라우터 연동 방식
- **고려한 방식 A**: `goRouterProvider`가 `authProvider`를 watch해 GoRouter를 재생성
- **고려한 방식 B**: `RouterNotifier` (선택) — `ChangeNotifier`를 `refreshListenable`로 등록, auth 변화 시 `notifyListeners()`만 호출
- **선택 이유**: 방식 A는 인증 상태 변경마다 라우터 인스턴스 전체를 재생성하는 비용이 있음. 방식 B는 라우터는 유지하고 redirect 로직만 재실행하는 공식 권장 패턴

### 웹 클라이언트 ID 관리
- `auth_provider.dart` 내 `const _webClientId`로 선언 + `web/index.html` 메타태그 이중 설정
- `google_sign_in_web`은 두 방법 중 하나만 있어도 동작하지만, 패키지 버전별 동작 차이가 있어 양쪽 모두 설정하는 것이 안전

### Gradle 플러그인 선언 방식
- 이 프로젝트는 Kotlin DSL + 신규 Plugin Management 방식(`settings.gradle.kts`) 사용
- 구버전 `android/build.gradle`의 `classpath` 방식이 아닌 `settings.gradle.kts`의 `plugins {}` 블록에 `apply false`로 선언 후 `app/build.gradle.kts`에서 적용하는 방식 채택

---

## 구현 상세

### 변경/추가된 파일

| 파일 | 작업 내용 |
|------|-----------|
| `lib/features/calendar/views/calendar_screen.dart` | 전체 구현 (스텁 → 완성) |
| `lib/features/auth/providers/auth_provider.dart` | 신규 생성 → Mock → 실제 GoogleSignIn 연동 |
| `lib/features/auth/views/login_screen.dart` | 신규 생성 |
| `lib/core/router/app_router.dart` | `_RouterNotifier` + `/login` 라우트 + redirect 로직 추가 |
| `pubspec.yaml` | `google_sign_in: ^6.2.2` 추가 |
| `android/settings.gradle.kts` | `com.google.gms.google-services` 플러그인 선언 |
| `android/app/build.gradle.kts` | `com.google.gms.google-services` 플러그인 적용 |
| `web/index.html` | `google-signin-client_id` 메타태그 추가 |

### 캘린더 화면 핵심 구조
```
CalendarScreen (ConsumerStatefulWidget)
 ├ 상태: _focusedDay, _selectedDay, _selectedEvent
 ├ _buildCalendar() — TableCalendar, eventLoader로 밴드 일정 마커
 └ AnimatedSwitcher
    ├ (null day) → _buildNoSelection()
    ├ (day 선택, null event) → _buildEventList() + 새 일정 추가 버튼
    └ (event 선택) → _buildEventDetail() + 뒤로가기 버튼
```

### 인증 흐름
```
앱 시작
 └ authProvider = false
    └ _RouterNotifier.redirect() → '/login'
       └ LoginScreen: Google 로그인 버튼 클릭
          └ AuthNotifier.signInWithGoogle()
             └ GoogleSignIn.signIn() 성공
                └ authProvider = true
                   └ notifyListeners() → redirect() → '/my_band'
```

---

## 다음 작업을 위한 메모

### 즉시 해야 할 것
- `android/app/google-services.json` 배치 (Firebase 콘솔에서 Android 앱 등록 후 다운로드)
- `web/index.html`과 `auth_provider.dart`의 `_webClientId`에 실제 웹 OAuth 클라이언트 ID 입력
- Android 디버그 키의 SHA-1을 Firebase 콘솔에 등록해야 Google 로그인 동작

### 다음 기능 후보
1. **프로필 화면** (`profile_screen.dart`) — 로그인한 Google 계정 정보 표시, 로그아웃 버튼
2. **캘린더 일정 추가** — "새 일정 추가" 버튼 기능 구현 (바텀시트 또는 별도 화면)
3. **채팅 첨부 기능** — 이미지 피커(`image_picker` 패키지), 일정 연동

### 주의사항
- `google_sign_in`의 `signIn()`은 사용자가 팝업을 닫으면 `null`을 반환함 (에러가 아님) — 로딩 스피너 처리 시 반드시 `finally` 또는 `mounted` 체크 필요
- 웹 포트를 고정하지 않으면 매번 Google Cloud Console에서 JavaScript 출처를 업데이트해야 함: `flutter run -d chrome --web-port 5000` 권장
- `_webClientId`는 현재 하드코딩됨 — 실제 서비스 시 환경변수 또는 별도 config 파일로 분리 권장
