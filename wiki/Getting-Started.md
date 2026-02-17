# Getting Started (시작 가이드)

> 2 the Core 개발 환경 설정 및 실행 가이드

---

## 요구 사항

### 필수 소프트웨어

| 소프트웨어 | 버전 | 설명 |
|-----------|------|------|
| Node.js | 18+ | JavaScript 런타임 |
| npm | 9+ | 패키지 매니저 |
| Git | 2.30+ | 버전 관리 |

### 권장 IDE

- **VS Code** + 확장 프로그램:
  - ESLint
  - Prettier
  - Tailwind CSS IntelliSense
  - TypeScript Vue Plugin (Volar)

---

## 설치

### 1. 저장소 클론

```bash
git clone https://github.com/Kernel360/KUNI_2thecore_frontend.git
cd KUNI_2thecore_frontend
```

### 2. 의존성 설치

```bash
npm install
```

### 3. 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성합니다:

```env
# 메인 API 서버
VITE_CAR_BASE_URL=http://52.78.122.150:8080/api

# 에뮬레이터 서버
VITE_EMULATOR_BASE_URL=http://3.37.93.107:8081/api

# 분석 서버 (Flask)
VITE_ANALYSIS_API_BASE_URL=http://3.34.194.140:5000/api
```

### 4. 개발 서버 실행

```bash
npm run dev
```

브라우저에서 `http://localhost:3000` 접속

---

## 프로젝트 구조

```
KUNI_2thecore_frontend/
├── public/                 # 정적 파일
│   ├── car_green.png       # 운행 중 마커
│   ├── car_yellow.png      # 대기 중 마커
│   └── car_red.png         # 수리 중 마커
├── src/
│   ├── app/                # 페이지 컴포넌트
│   │   ├── page.tsx        # 메인 대시보드
│   │   ├── search/         # 차량 검색
│   │   ├── detail/         # 차량 상세
│   │   ├── history/        # 주행 기록
│   │   ├── analysis/       # 데이터 분석
│   │   ├── emulator/       # 에뮬레이터
│   │   └── login/          # 로그인
│   ├── components/         # 재사용 컴포넌트
│   │   ├── map/            # 지도 컴포넌트
│   │   ├── search-box/     # 검색 컴포넌트
│   │   ├── status-box/     # 상태 컴포넌트
│   │   ├── menu-box/       # 네비게이션
│   │   └── ui/             # shadcn/ui 컴포넌트
│   ├── services/           # API 서비스
│   ├── store/              # Zustand 스토어
│   ├── hooks/              # 커스텀 훅
│   ├── lib/                # 유틸리티
│   ├── types/              # TypeScript 타입
│   ├── styles/             # 전역 스타일
│   ├── App.tsx             # 앱 레이아웃
│   └── main.tsx            # 엔트리 포인트
├── wiki/                   # 문서 (GitHub Wiki용)
├── package.json
├── vite.config.ts
├── tsconfig.json
├── tailwind.config.js
└── CLAUDE.md               # 프로젝트 가이드라인
```

---

## 스크립트 명령어

| 명령어 | 설명 |
|--------|------|
| `npm run dev` | 개발 서버 실행 (포트 3000) |
| `npm run build` | 프로덕션 빌드 |
| `npm run preview` | 빌드 결과 미리보기 |
| `npm run lint` | ESLint 검사 |
| `npm run format` | Prettier 포맷팅 |
| `npm run format:check` | 포맷팅 검사 |

---

## 개발 워크플로우

### 1. 브랜치 전략

```
main (프로덕션)
  └── dev (개발)
       ├── feature/xxx (기능)
       ├── fix/xxx (버그 수정)
       └── refactor/xxx (리팩토링)
```

### 2. 코드 작성 규칙

#### 파일명
- 컴포넌트: `kebab-case.tsx` (예: `car-clusterer-map.tsx`)
- 스타일: `kebab-case.module.css`
- 서비스: `kebab-case.ts` (예: `car-service.ts`)

#### 컴포넌트명
- PascalCase (예: `CarClustererMap`)

#### 변수명
- camelCase (예: `carStatusFilter`)

#### 상수명
- UPPER_SNAKE_CASE (예: `API_BASE_URL`)

### 3. 커밋 메시지

```
feat: 새 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 리팩토링
test: 테스트 추가
chore: 빌드 설정 변경
```

예시:
```bash
git commit -m "feat: 차량 검색 필터 기능 추가"
git commit -m "fix: 토큰 갱신 오류 수정"
```

---

## API 서버 연결

### 개발 환경

기본 API 서버 URL (`.env` 없을 경우):

```typescript
// src/lib/api.ts
const API_BASE_URL = 'http://43.203.110.104:8080/api';
const EMULATOR_API_BASE_URL = 'http://3.37.93.107:8081/api';
const ANALYSIS_API_BASE_URL = 'http://3.34.194.140:5000/api';
```

### 로컬 백엔드 연결

로컬에서 백엔드를 실행하는 경우:

```env
VITE_CAR_BASE_URL=http://localhost:8080/api
VITE_EMULATOR_BASE_URL=http://localhost:8081/api
VITE_ANALYSIS_API_BASE_URL=http://localhost:5000/api
```

---

## Kakao Maps 설정

Kakao Maps SDK는 [KakaoMapScript](../src/components/map/kakao-map-script.tsx) 컴포넌트에서 동적으로 로드됩니다.

### API 키 설정

Kakao Developers에서 JavaScript 키를 발급받아 설정합니다.

**참조:** [Kakao Maps API 가이드](https://apis.map.kakao.com/)

---

## 테스트 계정

개발 환경에서 사용할 수 있는 테스트 계정:

```
아이디: admin
비밀번호: (관리자에게 문의)
```

---

## 트러블슈팅

### CORS 오류

개발 서버에서 CORS 오류 발생 시:

1. 백엔드 서버의 CORS 설정 확인
2. `vite.config.ts`에 프록시 설정 추가:

```typescript
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
});
```

### 토큰 만료

- 자동 토큰 갱신이 실패하면 로그인 페이지로 리다이렉트됩니다.
- 개발 중 토큰 문제 시: `localStorage.clear()` 실행 후 재로그인

### 지도 로딩 실패

- Kakao Developers 콘솔에서 도메인 등록 확인
- 개발 환경: `http://localhost:3000` 등록 필요

---

## 다음 단계

- [Architecture](Architecture) - 시스템 아키텍처 이해
- [Data-Flow](Data-Flow) - 데이터 흐름 파악
- [Module-Dashboard](Module-Dashboard) - 메인 페이지 구조

---

## 도움말

문제가 발생하면:

1. [CLAUDE.md](../CLAUDE.md) 참조
2. GitHub Issues 확인
3. 팀 Slack 채널 문의
