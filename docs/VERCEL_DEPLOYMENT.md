# Vercel 배포 가이드

이 프로젝트는 Flutter Web 정적 산출물(`build/web`)을 Vercel에 배포한다. Vercel은 Flutter SDK를 기본으로 제공하지 않으므로, 기본 권장 방식은 로컬 또는 CI에서 Flutter 빌드를 먼저 만들고 `build/web` 디렉터리를 Vercel CLI로 배포하는 것이다.

## 사전 준비

1. Vercel 계정과 프로젝트를 준비한다.
2. 로컬에 Flutter SDK와 Node.js/npm을 설치한다.
3. Vercel CLI를 설치하고 로그인한다.

```powershell
npm i -g vercel
vercel login
```

## 중요한 환경 값

앱의 API 주소는 런타임 환경변수가 아니라 Flutter 컴파일 시점 값이다.

```dart
String.fromEnvironment('API_BASE_URL')
```

따라서 배포 빌드 때 반드시 `--dart-define=API_BASE_URL=...`로 주입해야 한다.

주의: Vercel 배포 URL은 HTTPS다. API가 `http://...`만 지원하면 브라우저 mixed content 정책 때문에 API 요청이 막힐 수 있다. 운영 배포에서는 가능하면 HTTPS API 주소를 사용한다.

## 권장 배포 방식: 로컬 빌드 후 Vercel 배포

### 1. 의존성 설치

```powershell
flutter pub get
```

### 2. Flutter Web 릴리즈 빌드

운영 API가 HTTPS를 지원하는 경우:

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://pagomnini.kro.kr
```

현재처럼 HTTP API로 테스트 배포하는 경우:

```powershell
flutter build web --release --dart-define=API_BASE_URL=http://pagomnini.kro.kr
```

### 3. SPA 라우팅 설정 파일 생성

Vercel에 `build/web` 자체를 배포하므로, `vercel.json`도 빌드 산출물 안에 넣는다. Flutter의 `go_router` 경로 새로고침이 `404`가 되지 않게 모든 경로를 `index.html`로 rewrite한다.

```powershell
@'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
'@ | Set-Content -Encoding UTF8 build\web\vercel.json
```

### 4. Preview 배포

```powershell
vercel deploy build\web
```

### 5. Production 배포

```powershell
vercel deploy build\web --prod
```

첫 배포 때 CLI가 프로젝트 연결을 물어보면 기존 프로젝트를 선택하거나 새 프로젝트를 만든다.

## 한 번에 실행하는 PowerShell 예시

```powershell
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://pagomnini.kro.kr
@'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
'@ | Set-Content -Encoding UTF8 build\web\vercel.json
vercel deploy build\web --prod
```

## Git 연동으로 Vercel에서 직접 빌드하는 방식

Vercel 대시보드에서 Git 저장소를 연결해 자동 배포하려면 Flutter SDK 설치를 Build Command에 포함해야 한다.

권장 설정:

- Framework Preset: `Other`
- Build Command:

```bash
git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter" &&
export PATH="$HOME/flutter/bin:$PATH" &&
flutter config --no-analytics &&
flutter pub get &&
flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL &&
cat > build/web/vercel.json <<'JSON'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
JSON
```

- Output Directory: `build/web`
- Install Command: 비워두거나 기본값 사용
- Environment Variables:
  - `API_BASE_URL=https://pagomnini.kro.kr`

Git 연동 방식은 빌드 때마다 Flutter SDK를 내려받기 때문에 느릴 수 있다. 안정성과 속도를 우선하면 로컬/CI에서 빌드한 `build/web`을 CLI로 배포하는 방식을 권장한다.

## 배포 후 확인

```powershell
vercel ls
vercel inspect <deployment-url>
```

브라우저에서 다음을 확인한다.

- `/my_band`, `/chat`, `/calendar`, `/profile` 같은 앱 경로를 새로고침해도 앱이 열린다.
- Google OAuth 콘솔에 Vercel 배포 도메인이 승인된 JavaScript origin으로 등록되어 있다.
- API 요청이 mixed content 또는 CORS로 막히지 않는다.

## 롤백

Vercel 대시보드의 Deployments 탭에서 이전 Production 배포를 Promote하거나, CLI로 이전 배포 URL을 확인해 다시 승격한다.

```powershell
vercel ls
```
