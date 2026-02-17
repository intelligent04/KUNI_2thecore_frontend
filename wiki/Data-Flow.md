# 데이터 흐름

> 2 the Core 시스템의 데이터 흐름 및 시퀀스 다이어그램

---

## 개요

이 문서는 프론트엔드 애플리케이션 내 주요 데이터 흐름과 백엔드 API와의 통신 패턴을 설명합니다.

---

## 전체 데이터 흐름

```mermaid
flowchart TB
    subgraph User["사용자 인터랙션"]
        Click["클릭/입력"]
        View["화면 조회"]
    end

    subgraph Components["React 컴포넌트"]
        Page["Page Component"]
        Feature["Feature Component"]
        UI["UI Component"]
    end

    subgraph State["상태 관리"]
        LocalState["useState"]
        ZustandStore["Zustand Store"]
    end

    subgraph Services["API 서비스"]
        CarService
        AuthService
        HistoryService
    end

    subgraph API["Axios Client"]
        mainApi
        emulatorApi
        analysisApi
    end

    subgraph Backend["백엔드"]
        MainServer["메인 서버 :8080"]
        EmulServer["에뮬레이터 :8081"]
        FlaskServer["분석 서버 :5000"]
    end

    Click --> Page
    Page --> LocalState
    Page --> ZustandStore
    Page --> Feature
    Feature --> UI
    UI --> View

    Page --> Services
    Services --> API
    API --> Backend
    Backend --> API
    API --> Services
    Services --> LocalState
    LocalState --> Feature
```

---

## 인증 흐름

### 로그인 시퀀스

```mermaid
sequenceDiagram
    actor User
    participant LoginPage
    participant AuthService
    participant TokenManager
    participant mainApi
    participant Backend

    User->>LoginPage: 아이디/비밀번호 입력
    LoginPage->>AuthService: login(credentials)
    AuthService->>mainApi: POST /auth/login
    mainApi->>Backend: HTTP Request

    Backend-->>mainApi: { result: true, data: { accessToken } }
    Note over Backend: Refresh Token은 HttpOnly 쿠키로 설정

    mainApi-->>AuthService: Response
    AuthService->>TokenManager: setTokens(accessToken, loginId)
    TokenManager->>TokenManager: localStorage 저장
    AuthService-->>LoginPage: 성공
    LoginPage->>LoginPage: navigate('/')
```

### 토큰 갱신 시퀀스

```mermaid
sequenceDiagram
    participant Component
    participant Service
    participant mainApi
    participant Backend
    participant TokenManager

    Component->>Service: API 호출
    Service->>mainApi: Request with Bearer Token
    mainApi->>Backend: HTTP Request

    alt Access Token 만료
        Backend-->>mainApi: 401 + new-access-token header
        mainApi->>TokenManager: updateAccessToken(newToken)
        mainApi->>Backend: Retry with new token
        Backend-->>mainApi: Success Response
    end

    alt Refresh Token 만료
        Backend-->>mainApi: { result: false }
        mainApi->>TokenManager: clearTokens()
        mainApi->>mainApi: redirect('/login')
    end

    mainApi-->>Service: Response
    Service-->>Component: Data
```

---

## 페이지별 데이터 흐름

### 메인 대시보드 (/)

```mermaid
flowchart LR
    subgraph MainPage["page.tsx"]
        State["useState<br/>carStatusFilter"]
    end

    subgraph StatusContainer
        Fetch1["StatisticsService.getCarStatistics()"]
        Stats["차량 통계 표시"]
    end

    subgraph CarClustererMap
        Fetch2["Map 컴포넌트<br/>CarService.getCarLocations()"]
        Markers["마커 클러스터링"]
    end

    MainPage --> StatusContainer
    MainPage --> CarClustererMap
    Fetch1 --> Stats
    Fetch2 --> Markers
    State -->|필터| CarClustererMap
```

**데이터 흐름:**

1. 페이지 마운트 시 `StatisticsService.getCarStatistics()` 호출
2. `carStatusFilter` 상태로 지도 마커 필터링
3. 3초 간격으로 차량 위치 자동 갱신

**소스 코드:**
- [src/app/page.tsx:8-10](../src/app/page.tsx#L8-L10) - 상태 정의
- [src/components/status-box/status-container.tsx:27-49](../src/components/status-box/status-container.tsx#L27-L49) - 통계 로드

---

### 차량 검색 (/search)

```mermaid
sequenceDiagram
    participant User
    participant SearchBox
    participant CarService
    participant API

    Note over SearchBox: 페이지 마운트
    SearchBox->>CarService: searchCars({ status: '운행' })
    CarService->>API: GET /cars/search
    API-->>CarService: PageResponse<Car>
    CarService-->>SearchBox: 차량 목록
    SearchBox->>SearchBox: setCars(data)

    User->>SearchBox: 검색 조건 입력
    SearchBox->>CarService: searchCars(params)
    CarService->>API: GET /cars/search?...
    API-->>CarService: PageResponse<Car>
    CarService-->>SearchBox: 검색 결과
    SearchBox->>SearchBox: setCars(data), setPage(1)

    User->>SearchBox: 스크롤 (무한 스크롤)
    SearchBox->>CarService: searchCars(params, page + 1)
    CarService->>API: GET /cars/search?page=2
    API-->>CarService: PageResponse<Car>
    CarService-->>SearchBox: 추가 데이터
    SearchBox->>SearchBox: setCars([...prev, ...new])
```

**상태 관리:**

```typescript
// src/components/search-box/search-box.tsx
const [cars, setCars] = useState<Car[]>([]);
const [carNumber, setCarNumber] = useState('');
const [brandModel, setBrandModel] = useState('');
const [status, setStatus] = useState('운행');
const [hasNextPage, setHasNextPage] = useState(true);
```

**소스 코드:**
- [src/components/search-box/search-box.tsx:10-28](../src/components/search-box/search-box.tsx#L10-L28) - 상태 관리
- [src/components/search-box/search-box.tsx:93-142](../src/components/search-box/search-box.tsx#L93-L142) - 검색 로직

---

### 차량 상세 (/detail)

```mermaid
flowchart TB
    subgraph URL
        QueryParam["?carNumber=12가 1234"]
    end

    subgraph DetailPage
        Fetch["CarService.getCar(carNumber)"]
        Store["useDetailStore.setDetail()"]
        Form["차량 정보 폼"]
        Map["CarLocationMap"]
    end

    subgraph Zustand["Zustand Store"]
        DetailStore["useDetailStore<br/>{carNumber, brand, model, status, ...}"]
        ChangeStore["setDetailChangeStore<br/>{detailChange: boolean}"]
    end

    URL --> Fetch
    Fetch --> Store
    Store --> DetailStore
    DetailStore --> Form
    DetailStore --> Map
    ChangeStore -->|편집 모드| Form
```

**실시간 갱신:**

```typescript
// src/app/detail/page.tsx:75-90
useEffect(() => {
  // 3초 간격으로 차량 정보 갱신
  const intervalId = setInterval(async () => {
    const updatedCarDetail = await CarService.getCar(urlCarNumber);
    setDetail(updatedCarDetail);
  }, 3000);

  return () => clearInterval(intervalId);
}, [urlCarNumber]);
```

**소스 코드:**
- [src/app/detail/page.tsx:59-73](../src/app/detail/page.tsx#L59-L73) - 초기 데이터 로드
- [src/app/detail/page.tsx:75-90](../src/app/detail/page.tsx#L75-L90) - 실시간 갱신
- [src/store/detail-store.ts](../src/store/detail-store.ts) - Zustand 스토어

---

### 주행 기록 (/history)

```mermaid
flowchart TB
    subgraph HistoryPage
        SearchParams["searchParams state"]
        HistoryData["historyData state"]
    end

    subgraph HistorySearchBox
        DatePicker["날짜 선택"]
        Filters["필터 옵션"]
        SearchBtn["검색 버튼"]
    end

    subgraph HistoryListBox
        Table["주행 기록 테이블"]
        Sort["정렬 기능"]
        InfiniteScroll["무한 스크롤"]
    end

    subgraph HistoryService
        API["GET /drivelogs"]
    end

    DatePicker --> SearchParams
    Filters --> SearchParams
    SearchBtn --> API
    API --> HistoryData
    HistoryData --> Table
    Sort --> API
    InfiniteScroll --> API
```

**소스 코드:**
- [src/app/history/page.tsx:12-19](../src/app/history/page.tsx#L12-L19) - 상태 관리
- [src/services/history-service.ts:33-63](../src/services/history-service.ts#L33-L63) - API 호출

---

### 데이터 분석 (/analysis)

```mermaid
flowchart LR
    subgraph Tabs["분석 탭"]
        Period["월별/계절별"]
        Trend["연도별 트렌드"]
        Forecast["운행량 예측"]
        Cluster["지역별 클러스터링"]
    end

    subgraph API["Analysis API"]
        PeriodAPI["GET /analysis/period"]
        TrendAPI["GET /analysis/trend"]
        ForecastAPI["GET /forecast/daily"]
        ClusterAPI["GET /clustering/regions"]
    end

    subgraph Response["응답"]
        Visualizations["Base64 이미지<br/>(matplotlib 그래프)"]
    end

    Period --> PeriodAPI
    Trend --> TrendAPI
    Forecast --> ForecastAPI
    Cluster --> ClusterAPI
    PeriodAPI --> Visualizations
    TrendAPI --> Visualizations
    ForecastAPI --> Visualizations
    ClusterAPI --> Visualizations
```

**소스 코드:**
- [src/app/analysis/page.tsx:194-211](../src/app/analysis/page.tsx#L194-L211) - 월별/계절별 분석
- [src/app/analysis/page.tsx:214-231](../src/app/analysis/page.tsx#L214-L231) - 연도별 트렌드
- [src/app/analysis/page.tsx:234-255](../src/app/analysis/page.tsx#L234-L255) - 운행량 예측
- [src/app/analysis/page.tsx:258-280](../src/app/analysis/page.tsx#L258-L280) - 클러스터링 분석

---

## 컴포넌트 간 데이터 전달

### Props 흐름

```mermaid
flowchart TD
    MainPage["MainPage<br/>carStatusFilter state"]

    MainPage -->|"carStatusFilter, setCarStatusFilter"| StatusContainer
    MainPage -->|"carStatusFilter"| CarClustererMap
    MainPage -->|"isOpen, onClose"| MapModal

    StatusContainer -->|"num, text, active"| StatusBox
    CarClustererMap -->|"width, height, onLoad"| Map
```

### 콜백 패턴

```typescript
// 부모 → 자식: Props로 콜백 전달
<StatusContainer
  carStatusFilter={carStatusFilter}
  setCarStatusFilter={setCarStatusFilter}  // 콜백
/>

// 자식 → 부모: 콜백 호출
onClick={() => setCarStatusFilter('driving')}
```

---

## 에러 처리 흐름

```mermaid
flowchart TB
    subgraph Request["API 요청"]
        Service["Service 메서드"]
        Axios["Axios 인스턴스"]
    end

    subgraph Error["에러 처리"]
        Interceptor["응답 인터셉터"]
        ApiError["ApiError 클래스"]
        KoreanMsg["한국어 에러 메시지"]
    end

    subgraph UI["UI 피드백"]
        Alert["alert()"]
        ErrorState["error state"]
        Toast["에러 메시지 표시"]
    end

    Service --> Axios
    Axios --> Interceptor
    Interceptor -->|에러 발생| ApiError
    ApiError --> KoreanMsg
    KoreanMsg --> Service
    Service -->|catch| ErrorState
    ErrorState --> Toast
    ErrorState --> Alert
```

**에러 메시지 매핑:**

```typescript
// src/lib/api.ts:45-58
const getKoreanErrorMessage = (status: number): string => {
  const defaultMessages = {
    400: '잘못된 요청입니다.',
    401: '인증이 필요합니다. 다시 로그인해주세요.',
    403: '접근 권한이 없습니다.',
    404: '요청한 데이터를 찾을 수 없습니다.',
    500: '서버 오류가 발생했습니다.',
  };
  return defaultMessages[status] || '알 수 없는 오류가 발생했습니다.';
};
```

---

## 관련 문서

- [Architecture](Architecture) - 시스템 아키텍처
- [API-Reference](API-Reference) - API 엔드포인트 상세
- [Module-Maps](Module-Maps) - 지도 컴포넌트 데이터 흐름
