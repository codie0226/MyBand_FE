# ── Stage 1: Flutter Web 빌드 ─────────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# 의존성만 먼저 복사해서 캐시 활용
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG API_BASE_URL=http://localhost:3000
RUN flutter build web --release --no-wasm-dry-run \
    --dart-define=API_BASE_URL=${API_BASE_URL}

# ── Stage 2: nginx 서빙 ────────────────────────────────────────────────────────
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -qO- http://localhost/ || exit 1
