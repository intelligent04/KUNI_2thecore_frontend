# API Reference

> 2 the Core 시스템의 전체 API 엔드포인트 문서

---

## 개요

2 the Core는 3개의 백엔드 서버와 통신합니다:

| 서버 | Base URL | 용도 |
|------|----------|------|
| 메인 API | `http://52.78.122.150:8080/api` | 차량, 인증, 주행 기록 |
| 에뮬레이터 API | `http://3.37.93.107:8081/api` | GPS 시뮬레이션 |
| 분석 API (Flask) | `http://3.34.194.140:5000/api` | 데이터 분석 |

---

## 인증 API

### 로그인

```http
POST /auth/login
Content-Type: application/json
```

**Request Body:**
```json
{
  "loginId": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "result": true,
  "message": "로그인 성공",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**참조:** [src/services/auth-service.ts:48-65](../src/services/auth-service.ts#L48-L65)

---

### 로그아웃

```http
POST /auth/logout
Authorization: Bearer {accessToken}
```

**Response:**
```json
{
  "result": true,
  "message": "로그아웃 성공",
  "data": null
}
```

**참조:** [src/services/auth-service.ts:68-79](../src/services/auth-service.ts#L68-L79)

---

### 회원가입

```http
POST /admin/signup
Content-Type: application/json
```

**Request Body:**
```json
{
  "loginId": "string",
  "password": "string",
  "name": "string",
  "email": "string",
  "birthdate": "string",
  "phoneNumber": "string"
}
```

**참조:** [src/services/auth-service.ts:87-96](../src/services/auth-service.ts#L87-L96)

---

## 차량 API

### 차량 목록 조회 (검색)

```http
GET /cars/search
Authorization: Bearer {accessToken}
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `carNumber` | string | - | 차량 번호 |
| `brand` | string | - | 브랜드명 |
| `model` | string | - | 모델명 |
| `status` | string | - | 상태 (운행/대기/수리) |
| `twoParam` | boolean | - | 브랜드+모델명 검색 여부 |
| `page` | number | - | 페이지 번호 (기본: 1) |
| `offset` | number | - | 페이지당 항목 수 (기본: 10) |

**Response:**
```json
{
  "result": true,
  "data": {
    "content": [
      {
        "carNumber": "12가 1234",
        "brand": "현대",
        "model": "아반떼",
        "brandModel": "현대 아반떼",
        "status": "운행",
        "powerStatus": "ON"
      }
    ],
    "totalPages": 10,
    "totalElements": 100,
    "number": 0,
    "size": 10,
    "first": true,
    "last": false
  }
}
```

**참조:** [src/services/car-service.ts:72-90](../src/services/car-service.ts#L72-L90)

---

### 차량 상세 조회

```http
GET /cars
Authorization: Bearer {accessToken}
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `carNumber` | string | O | 차량 번호 |

**Response:**
```json
{
  "result": true,
  "data": {
    "carNumber": "12가 1234",
    "brand": "현대",
    "model": "아반떼",
    "brandModel": "현대 아반떼",
    "status": "운행",
    "carYear": 2023,
    "sumDist": 15000.5,
    "carType": "중형",
    "lastLatitude": "37.5665",
    "lastLongitude": "126.9780"
  }
}
```

**참조:** [src/services/car-service.ts:57-62](../src/services/car-service.ts#L57-L62)

---

### 차량 통계

```http
GET /cars/statistics
Authorization: Bearer {accessToken}
```

**Response:**
```json
{
  "result": true,
  "data": {
    "total": 150,
    "driving": 80,
    "idle": 50,
    "maintenance": 20
  }
}
```

**참조:** [src/services/car-service.ts:65-69](../src/services/car-service.ts#L65-L69)

---

### 차량 등록

```http
POST /cars
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "carNumber": "12가 1234",
  "brand": "현대",
  "model": "아반떼",
  "carYear": 2023,
  "sumDist": 0,
  "carType": "중형",
  "loginId": "admin"
}
```

**참조:** [src/services/car-service.ts:101-112](../src/services/car-service.ts#L101-L112)

---

### 차량 수정

```http
PATCH /cars
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `carNumber` | string | O | 차량 번호 |

**Request Body:**
```json
{
  "brand": "현대",
  "model": "소나타",
  "status": "대기",
  "carYear": 2024,
  "sumDist": 16000,
  "carType": "중형"
}
```

**참조:** [src/services/car-service.ts:115-123](../src/services/car-service.ts#L115-L123)

---

### 차량 삭제

```http
DELETE /cars/{carNumber}
Authorization: Bearer {accessToken}
```

**참조:** [src/services/car-service.ts:127-132](../src/services/car-service.ts#L127-L132)

---

### 차량 위치 조회 (단일)

```http
GET /cars/locations
Authorization: Bearer {accessToken}
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `carNumber` | string | O | 차량 번호 |

**참조:** [src/services/car-service.ts:135-143](../src/services/car-service.ts#L135-L143)

---

### 전체 차량 위치 조회

```http
GET /cars/locations
Authorization: Bearer {accessToken}
```

**Response:**
```json
{
  "result": true,
  "data": [
    {
      "carNumber": "12가 1234",
      "status": "운행",
      "lastLatitude": "37.5665",
      "lastLongitude": "126.9780",
      "timestamp": "2024-01-15T10:30:00"
    }
  ]
}
```

**참조:** [src/services/car-service.ts:146-167](../src/services/car-service.ts#L146-L167)

---

## 주행 기록 API

### 주행 기록 조회

```http
GET /drivelogs
Authorization: Bearer {accessToken}
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `carNumber` | string | - | 차량 번호 |
| `status` | string | - | 차량 상태 |
| `brand` | string | - | 브랜드명 |
| `model` | string | - | 모델명 |
| `startTime` | string | - | 시작 날짜 (YYYY-MM-DD) |
| `endTime` | string | - | 종료 날짜 (YYYY-MM-DD) |
| `twoParam` | boolean | - | 브랜드+모델명 검색 여부 |
| `page` | number | - | 페이지 번호 |
| `offset` | number | - | 페이지당 항목 수 |
| `sortBy` | string | - | 정렬 기준 |
| `sortOrder` | string | - | 정렬 방향 (ASC/DESC) |

**Response:**
```json
{
  "result": true,
  "data": {
    "content": [
      {
        "carNumber": "12가 1234",
        "brand": "현대",
        "model": "아반떼",
        "startTime": "2024-01-15 09:00:00",
        "endTime": "2024-01-15 18:00:00",
        "startPoint": "서울시 강남구",
        "endPoint": "서울시 서초구",
        "driveDist": 45.5,
        "status": "완료"
      }
    ],
    "totalPages": 5,
    "totalElements": 50
  }
}
```

**참조:** [src/services/history-service.ts:33-63](../src/services/history-service.ts#L33-L63)

---

## 통계 API

### 대시보드 랭킹

```http
GET /dashboard
Authorization: Bearer {accessToken}
```

**Response:**
```json
{
  "result": true,
  "data": {
    "topCarModel": {
      "model1": "아반떼",
      "model2": "소나타",
      "model3": "그랜저"
    },
    "topRegion": {
      "region1": "서울 강남구",
      "region2": "서울 서초구",
      "region3": "서울 송파구"
    },
    "topCarType": {
      "type1": "중형",
      "type2": "소형",
      "type3": "대형"
    }
  }
}
```

**참조:** [src/services/statistics-service.ts:39-43](../src/services/statistics-service.ts#L39-L43)

---

## 에뮬레이터 API

### 차량 시동 제어

```http
POST /logs/power
Content-Type: application/json
```

**Base URL:** `http://3.37.93.107:8081/api`

**Request Body:**
```json
{
  "carNumber": "12가 1234",
  "powerStatus": "ON",
  "loginId": "admin"
}
```

**참조:** [src/services/emul-service.ts:23-27](../src/services/emul-service.ts#L23-L27)

---

## 분석 API (Flask)

### 월별/계절별 선호도 분석

```http
GET /analysis/period
```

**Base URL:** `http://3.34.194.140:5000/api`

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `year` | string | O | 분석 연도 |
| `period_type` | string | O | month / season |

**Response:**
```json
{
  "success": true,
  "message": "분석 완료",
  "visualizations": {
    "brand_period_heatmap": "data:image/png;base64,...",
    "market_share_pie": "data:image/png;base64,...",
    "brand_preference_line": "data:image/png;base64,..."
  }
}
```

**참조:** [src/app/analysis/page.tsx:194-211](../src/app/analysis/page.tsx#L194-L211)

---

### 연도별 트렌드 분석

```http
GET /analysis/trend
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `start_year` | number | O | 시작 연도 |
| `end_year` | number | O | 종료 연도 |
| `top_n` | number | - | 상위 N개 (기본: 5) |

**참조:** [src/app/analysis/page.tsx:214-231](../src/app/analysis/page.tsx#L214-L231)

---

### 일별 운행량 예측

```http
GET /forecast/daily
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `start_date` | string | O | 시작 날짜 (YYYY-MM-DD) |
| `end_date` | string | O | 종료 날짜 (YYYY-MM-DD) |
| `forecast_days` | number | - | 예측 일수 (기본: 7) |

**참조:** [src/app/analysis/page.tsx:234-255](../src/app/analysis/page.tsx#L234-L255)

---

### 지역별 클러스터링 분석

```http
GET /clustering/regions
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `start_date` | string | O | 시작 날짜 (YYYY-MM-DD) |
| `end_date` | string | O | 종료 날짜 (YYYY-MM-DD) |
| `k` | number | - | 클러스터 수 (기본: 5) |
| `method` | string | - | kmeans / dbscan |

**참조:** [src/app/analysis/page.tsx:258-280](../src/app/analysis/page.tsx#L258-L280)

---

## 공통 응답 형식

### 성공 응답

```json
{
  "result": true,
  "message": "성공 메시지",
  "data": { ... }
}
```

### 에러 응답

```json
{
  "result": false,
  "message": "에러 메시지",
  "data": null
}
```

### 페이징 응답

```json
{
  "content": [...],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 10
  },
  "totalPages": 10,
  "totalElements": 100,
  "first": true,
  "last": false,
  "empty": false
}
```

---

## 인증 헤더

모든 인증이 필요한 API는 다음 헤더가 필요합니다:

```http
Authorization: Bearer {accessToken}
```

토큰 관리는 [TokenManager](../src/lib/token-manager.ts)에서 자동으로 처리됩니다.

---

## 에러 코드

| 상태 코드 | 한국어 메시지 |
|-----------|---------------|
| 400 | 잘못된 요청입니다. 입력 정보를 확인해주세요. |
| 401 | 인증이 필요합니다. 다시 로그인해주세요. |
| 403 | 접근 권한이 없습니다. |
| 404 | 요청한 데이터를 찾을 수 없습니다. |
| 409 | 중복된 데이터가 존재합니다. |
| 500 | 서버 오류가 발생했습니다. |
| 503 | 서버가 일시적으로 사용할 수 없습니다. |

**참조:** [src/lib/api.ts:45-58](../src/lib/api.ts#L45-L58)

---

## 관련 문서

- [Architecture](Architecture) - 시스템 아키텍처
- [Data-Flow](Data-Flow) - 데이터 흐름
- [Module-Auth](Module-Auth) - 인증 모듈 상세
