# Diagrams (다이어그램 모음)

> 2 the Core 시스템의 시각화 다이어그램 모음

---

## 시스템 아키텍처

### 전체 시스템 구성

```mermaid
graph TB
    subgraph Client["클라이언트"]
        Browser["웹 브라우저<br/>React 19 + Vite"]
    end

    subgraph Frontend["프론트엔드 애플리케이션"]
        direction TB
        UI["UI Layer<br/>(Pages, Components)"]
        State["State Layer<br/>(Zustand, useState)"]
        Service["Service Layer<br/>(API Services)"]
        HTTP["HTTP Client<br/>(Axios)"]
    end

    subgraph Backend["백엔드 서버"]
        MainAPI["메인 API<br/>Spring Boot :8080"]
        EmulAPI["에뮬레이터<br/>:8081"]
        FlaskAPI["분석 서버<br/>Flask :5000"]
    end

    subgraph External["외부 서비스"]
        Kakao["Kakao Maps SDK"]
    end

    subgraph Storage["저장소"]
        LS["LocalStorage<br/>(JWT Token)"]
        Cookie["HttpOnly Cookie<br/>(Refresh Token)"]
    end

    Browser --> UI
    UI --> State
    UI --> Service
    Service --> HTTP
    HTTP --> MainAPI
    HTTP --> EmulAPI
    HTTP --> FlaskAPI
    UI --> Kakao
    Browser --> LS
    MainAPI --> Cookie
```

---

## 라우팅 구조

```mermaid
graph TD
    Root["/"]
    Login["/login"]

    subgraph ProtectedRoutes["ProtectedRoute"]
        App["App (Layout)"]
        Main["/ (Dashboard)"]
        Search["/search"]
        Detail["/detail"]
        History["/history"]
        Analysis["/analysis"]
        Emulator["/emulator"]
    end

    Root --> ProtectedRoutes
    Login --> LoginPage["LoginPage"]

    App --> Main
    App --> Search
    App --> Detail
    App --> History
    App --> Analysis
    App --> Emulator

    Main -->|"StatusContainer<br/>CarClustererMap"| MainComponents
    Search -->|"SearchBox"| SearchComponents
    Detail -->|"CarLocationMap<br/>Form"| DetailComponents
```

---

## 컴포넌트 계층

### 전체 컴포넌트 트리

```mermaid
graph TD
    App["App"]

    subgraph Layout["레이아웃"]
        TopBar
        MenuBox
        AccountDropdown
    end

    subgraph Pages["페이지"]
        MainPage["MainPage"]
        SearchPage
        DetailPage
        HistoryPage
        AnalysisPage
        EmulatorPage
        LoginPage
    end

    subgraph MapComponents["지도 컴포넌트"]
        KakaoMapScript
        Map
        CarClustererMap
        CarLocationMap
        MapModal
    end

    subgraph SearchComponents["검색 컴포넌트"]
        SearchBox
        NumberSearchBox
        BrandFilterBox
        ListBox
        CarRegisterModal
    end

    subgraph StatusComponents["상태 컴포넌트"]
        StatusContainer
        StatusBox
        StatusText
    end

    subgraph HistoryComponents["기록 컴포넌트"]
        HistorySearchBox
        HistoryListBox
        DoubleCalendar
    end

    App --> Layout
    App --> Pages

    MainPage --> StatusComponents
    MainPage --> MapComponents
    SearchPage --> SearchComponents
    DetailPage --> MapComponents
    HistoryPage --> HistoryComponents
```

---

## 데이터 흐름

### API 요청 흐름

```mermaid
sequenceDiagram
    participant Component
    participant Service
    participant Axios
    participant Interceptor
    participant API

    Component->>Service: 메서드 호출
    Service->>Axios: HTTP 요청
    Axios->>Interceptor: 요청 인터셉터
    Note over Interceptor: JWT 토큰 추가
    Interceptor->>API: 실제 요청

    alt 성공
        API-->>Interceptor: 200 OK
        Note over Interceptor: new-access-token 확인
        Interceptor-->>Axios: 응답
        Axios-->>Service: 데이터
        Service-->>Component: 결과
    end

    alt 토큰 만료 (401)
        API-->>Interceptor: 401 Unauthorized
        Note over Interceptor: 토큰 갱신 시도
        Interceptor->>API: 재시도
        API-->>Interceptor: 성공
        Interceptor-->>Component: 데이터
    end

    alt 세션 만료
        API-->>Interceptor: result: false
        Note over Interceptor: 토큰 삭제
        Interceptor-->>Component: redirect /login
    end
```

### 상태 업데이트 흐름

```mermaid
flowchart LR
    subgraph User["사용자 액션"]
        Click["클릭/입력"]
    end

    subgraph Component["React 컴포넌트"]
        Handler["이벤트 핸들러"]
        Render["리렌더링"]
    end

    subgraph State["상태"]
        LocalState["useState"]
        Zustand["Zustand Store"]
    end

    subgraph API["API 호출"]
        Service["Service"]
        Backend["백엔드"]
    end

    Click --> Handler
    Handler --> Service
    Service --> Backend
    Backend --> Service
    Service --> LocalState
    Service --> Zustand
    LocalState --> Render
    Zustand --> Render
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
    participant API
    participant LocalStorage

    User->>LoginPage: 로그인 정보 입력
    LoginPage->>AuthService: login(credentials)
    AuthService->>API: POST /auth/login
    API-->>AuthService: { accessToken }
    Note over API: Refresh Token → HttpOnly Cookie

    AuthService->>TokenManager: setTokens(accessToken, loginId)
    TokenManager->>LocalStorage: 토큰 저장
    AuthService-->>LoginPage: 성공
    LoginPage->>LoginPage: navigate('/')
```

### 토큰 갱신 시퀀스

```mermaid
sequenceDiagram
    participant Component
    participant Axios
    participant API
    participant TokenManager

    Component->>Axios: API 요청
    Axios->>API: Request + Bearer Token

    alt Access Token 만료
        API-->>Axios: 401 + new-access-token header
        Axios->>TokenManager: updateAccessToken(newToken)
        Axios->>API: 재시도 (new token)
        API-->>Axios: 성공
        Axios-->>Component: 데이터
    end

    alt Refresh Token 만료
        API-->>Axios: { result: false }
        Axios->>TokenManager: clearTokens()
        Axios-->>Component: redirect /login
    end
```

---

## 서비스 클래스 다이어그램

```mermaid
classDiagram
    class CarService {
        +getAllCars(page, offset) PageResponse~CarDetail~
        +getCar(carNumber) CarDetail
        +getCarStatistics() CarSummary
        +searchCars(params) PageResponse~Car~
        +createCar(carData) CarDetail
        +updateCar(carNumber, carData) CarDetail
        +deleteCar(carNumber) void
        +getCarLocations() CarLocation[]
    }

    class AuthService {
        +login(credentials) AuthTokenData
        +logout() void
        +signUp(userData) void
        +hasValidTokens() boolean
    }

    class HistoryService {
        +getDriveLogs(params, page, offset) PageResponse~DriveLog~
    }

    class StatisticsService {
        +getCarStatistics() CarStatistics
        +getDashboardRanking() DashboardRanking
    }

    class EmulService {
        +powerCar(carData) CarDetail
    }

    class TokenManager {
        -ACCESS_TOKEN_KEY string
        -LOGIN_ID_KEY string
        +setTokens(accessToken, loginId) void
        +updateAccessToken(accessToken) void
        +getAuthHeader() string
        +getAccessToken() string
        +getLoginId() string
        +hasValidTokens() boolean
        +clearTokens() void
    }

    AuthService --> TokenManager
    CarService --> mainApi
    AuthService --> mainApi
    HistoryService --> mainApi
    StatisticsService --> mainApi
    EmulService --> emulatorApi
```

---

## 타입 관계

```mermaid
classDiagram
    class Car {
        +carNumber string
        +brand string
        +model string
        +brandModel string
        +status "운행"|"대기"|"수리"
        +powerStatus string
    }

    class CarDetail {
        +carYear number
        +sumDist number
        +carType string
        +lastLatitude string
        +lastLongitude string
    }

    class DriveLog {
        +carNumber string
        +brand string
        +model string
        +startTime string
        +endTime string
        +startPoint string
        +endPoint string
        +driveDist number
        +status string
    }

    class ApiResponse~T~ {
        +result boolean
        +message string
        +data T
        +newAccessToken string
    }

    class PageResponse~T~ {
        +content T[]
        +totalPages number
        +totalElements number
        +first boolean
        +last boolean
    }

    CarDetail --|> Car
    ApiResponse --> Car
    ApiResponse --> CarDetail
    PageResponse --> Car
    PageResponse --> DriveLog
```

---

## 지도 컴포넌트 흐름

```mermaid
flowchart TB
    subgraph Initialization["초기화"]
        SDK["KakaoMapScript<br/>SDK 로딩"]
        MapInit["Map 컴포넌트<br/>지도 초기화"]
    end

    subgraph DataFetch["데이터 조회"]
        API["CarService.getCarLocations()"]
        Timer["3초 간격 갱신"]
    end

    subgraph Rendering["렌더링"]
        Filter["상태별 필터링"]
        Markers["마커 생성"]
        Cluster["클러스터링"]
    end

    SDK --> MapInit
    MapInit --> API
    Timer --> API
    API --> Filter
    Filter --> Markers
    Markers --> Cluster
```

---

## 상태 매핑

```mermaid
flowchart LR
    subgraph Korean["한국어 상태"]
        K1["운행"]
        K2["대기"]
        K3["수리"]
    end

    subgraph English["영어 상태"]
        E1["driving"]
        E2["idle"]
        E3["maintenance"]
    end

    subgraph Color["마커 색상"]
        C1["🟢 녹색"]
        C2["🟡 노란색"]
        C3["🔴 빨간색"]
    end

    K1 --> E1 --> C1
    K2 --> E2 --> C2
    K3 --> E3 --> C3
```

---

## 분석 모듈 흐름

```mermaid
flowchart TB
    subgraph Tabs["분석 탭"]
        T1["월별/계절별"]
        T2["연도별 트렌드"]
        T3["운행량 예측"]
        T4["클러스터링"]
    end

    subgraph FlaskAPI["Flask 분석 서버"]
        A1["GET /analysis/period"]
        A2["GET /analysis/trend"]
        A3["GET /forecast/daily"]
        A4["GET /clustering/regions"]
    end

    subgraph Output["출력"]
        Viz["Base64 이미지<br/>(matplotlib)"]
        Data["분석 데이터"]
    end

    T1 --> A1
    T2 --> A2
    T3 --> A3
    T4 --> A4

    A1 --> Viz
    A2 --> Viz
    A3 --> Viz
    A4 --> Viz
    A4 --> Data
```

---

## 무한 스크롤 흐름

```mermaid
sequenceDiagram
    participant User
    participant Component
    participant Observer
    participant API

    Note over Component: 초기 데이터 로드
    Component->>API: page=1
    API-->>Component: 10개 데이터

    loop 스크롤 시
        User->>Observer: 마지막 요소 감지
        Observer->>Component: page++
        Component->>API: page=N
        API-->>Component: 추가 데이터
        Component->>Component: [...prev, ...new]
    end

    alt 더 이상 데이터 없음
        API-->>Component: 빈 배열
        Component->>Component: hasNextPage = false
    end
```

---

## 관련 문서

- [Architecture](Architecture) - 아키텍처 상세
- [Data-Flow](Data-Flow) - 데이터 흐름 상세
- [API-Reference](API-Reference) - API 문서
