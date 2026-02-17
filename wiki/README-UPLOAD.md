# GitHub Wiki 업로드 가이드

## 1. GitHub Wiki 활성화

1. GitHub 저장소로 이동: https://github.com/Kernel360/KUNI_2thecore_frontend
2. **Settings** → **General** → **Features**
3. **Wikis** 체크박스 활성화
4. **Wiki** 탭에서 첫 번째 페이지 생성 (빈 페이지로 저장 가능)

## 2. Wiki 업로드

### 자동 업로드 (권장)

터미널에서 다음 명령어 실행:

```bash
# 프로젝트 루트에서 실행
./wiki/upload-wiki.sh
```

### 수동 업로드

```bash
# 1. Wiki 저장소 클론
git clone https://github.com/Kernel360/KUNI_2thecore_frontend.wiki.git wiki-repo

# 2. 파일 복사
cp wiki/*.md wiki-repo/

# 3. 변경사항 커밋 및 푸시
cd wiki-repo
git add .
git commit -m "docs: Add comprehensive project documentation"
git push origin master
```

## 3. 확인

업로드 후 Wiki 페이지 확인:
https://github.com/Kernel360/KUNI_2thecore_frontend/wiki

---

## 생성된 문서 목록

| 파일 | 설명 |
|------|------|
| Home.md | 메인 페이지 |
| Architecture.md | 시스템 아키텍처 |
| Data-Flow.md | 데이터 흐름 |
| Diagrams.md | 다이어그램 모음 |
| API-Reference.md | API 엔드포인트 문서 |
| Module-Dashboard.md | 대시보드 모듈 |
| Module-Search.md | 검색 모듈 |
| Module-Detail.md | 상세 모듈 |
| Module-History.md | 주행 기록 모듈 |
| Module-Analysis.md | 분석 모듈 |
| Module-Auth.md | 인증 모듈 |
| Module-Emulator.md | 에뮬레이터 모듈 |
| Module-Maps.md | 지도 모듈 |
| Getting-Started.md | 시작 가이드 |
| Deployment.md | 배포 가이드 |
| _Sidebar.md | 사이드바 네비게이션 |
