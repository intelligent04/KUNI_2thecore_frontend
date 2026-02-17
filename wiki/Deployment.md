# Deployment (배포 가이드)

> 2 the Core 프로덕션 배포 가이드

---

## 빌드

### 프로덕션 빌드

```bash
npm run build
```

빌드 결과물은 `dist/` 폴더에 생성됩니다.

### 빌드 미리보기

```bash
npm run preview
```

---

## 빌드 설정

**파일:** [vite.config.ts](../vite.config.ts)

```typescript
export default defineConfig({
  base: './',                    // 상대 경로 사용
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,             // 소스맵 생성
    chunkSizeWarningLimit: 1000, // 청크 크기 경고 한도
  },
});
```

---

## 환경 변수

### 프로덕션 환경 변수

`.env.production` 파일:

```env
VITE_CAR_BASE_URL=https://api.2thecore.com/api
VITE_EMULATOR_BASE_URL=https://emul.2thecore.com/api
VITE_ANALYSIS_API_BASE_URL=https://analysis.2thecore.com/api
```

### 환경 변수 사용

```typescript
// Vite 환경 변수 접근
const API_URL = import.meta.env.VITE_CAR_BASE_URL;
```

---

## 정적 호스팅 배포

### Nginx 설정

```nginx
server {
    listen 80;
    server_name 2thecore.com;

    root /var/www/2thecore/dist;
    index index.html;

    # SPA 라우팅 지원
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 정적 파일 캐싱
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # API 프록시 (선택사항)
    location /api/ {
        proxy_pass http://backend-server:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### HTTPS 설정 (Let's Encrypt)

```bash
sudo certbot --nginx -d 2thecore.com
```

---

## Docker 배포

### Dockerfile

```dockerfile
# 빌드 스테이지
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# 프로덕션 스테이지
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### nginx.conf (Docker용)

```nginx
server {
    listen 80;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Docker Compose

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    environment:
      - VITE_CAR_BASE_URL=http://api-server:8080/api
    restart: unless-stopped
```

### Docker 명령어

```bash
# 이미지 빌드
docker build -t 2thecore-frontend .

# 컨테이너 실행
docker run -d -p 80:80 --name 2thecore-frontend 2thecore-frontend

# Docker Compose 실행
docker-compose up -d
```

---

## CI/CD

### GitHub Actions 예시

`.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          VITE_CAR_BASE_URL: ${{ secrets.VITE_CAR_BASE_URL }}
          VITE_EMULATOR_BASE_URL: ${{ secrets.VITE_EMULATOR_BASE_URL }}
          VITE_ANALYSIS_API_BASE_URL: ${{ secrets.VITE_ANALYSIS_API_BASE_URL }}

      - name: Deploy to server
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          source: "dist/*"
          target: "/var/www/2thecore"
          strip_components: 1
```

---

## 서버 요구 사항

### 최소 사양

| 항목 | 요구 사항 |
|------|----------|
| CPU | 1 vCPU |
| RAM | 1 GB |
| 디스크 | 10 GB |
| OS | Ubuntu 20.04+ / Amazon Linux 2 |

### 권장 사양

| 항목 | 요구 사항 |
|------|----------|
| CPU | 2 vCPU |
| RAM | 2 GB |
| 디스크 | 20 GB |

---

## 배포 체크리스트

### 빌드 전

- [ ] 환경 변수 설정 확인 (`.env.production`)
- [ ] API 엔드포인트 URL 확인
- [ ] 빌드 테스트 (`npm run build`)

### 배포 전

- [ ] SSL 인증서 설정
- [ ] Nginx 설정 확인
- [ ] 방화벽 설정 (80, 443 포트)

### 배포 후

- [ ] 사이트 접속 테스트
- [ ] 로그인 기능 테스트
- [ ] API 연결 테스트
- [ ] 지도 표시 테스트
- [ ] 브라우저 콘솔 에러 확인

---

## 롤백

### 이전 버전 복원

```bash
# 이전 빌드 백업에서 복원
cp -r /var/www/2thecore-backup/* /var/www/2thecore/dist/

# Nginx 재시작
sudo systemctl reload nginx
```

### Docker 롤백

```bash
# 이전 이미지로 롤백
docker stop 2thecore-frontend
docker run -d -p 80:80 --name 2thecore-frontend 2thecore-frontend:previous
```

---

## 모니터링

### 로그 확인

```bash
# Nginx 액세스 로그
tail -f /var/log/nginx/access.log

# Nginx 에러 로그
tail -f /var/log/nginx/error.log

# Docker 로그
docker logs -f 2thecore-frontend
```

### 헬스 체크

```bash
# HTTP 상태 확인
curl -I https://2thecore.com

# 응답 시간 측정
curl -w "@curl-format.txt" -o /dev/null -s https://2thecore.com
```

---

## 성능 최적화

### 1. Gzip 압축

```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript;
gzip_min_length 1000;
```

### 2. 브라우저 캐싱

```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. CDN 사용

- CloudFront, Cloudflare 등 CDN 서비스 활용
- 정적 파일 캐싱으로 로딩 속도 향상

---

## 관련 문서

- [Getting-Started](Getting-Started) - 개발 환경 설정
- [Architecture](Architecture) - 시스템 아키텍처
