# 개발 워크스테이션 구축 실습

## 1\. 프로젝트 개요

리눅스 CLI, Docker, Git/GitHub를 사용하여 개발 작업 환경을 구축한다.

주요 목표:

* 터미널에서 파일·디렉터리와 권한을 다룬다.
* Docker 이미지와 컨테이너를 실행·관리한다.
* 직접 작성한 Dockerfile로 웹 서버 이미지를 빌드한다.
* 포트 매핑으로 웹 서버 접속을 확인한다.
* 바인드 마운트의 변경 반영과 볼륨의 데이터 영속성을 검증한다.
* Git으로 변경 이력을 관리하고 GitHub에 결과물을 공유한다.

## 2\. 실행 환경

| 항목 | 실제 환경 |
|---|---|
| 호스트 OS | Windows 11 Pro |
| Windows 버전·빌드 | 10.0.26300.9711 — 기본 빌드 26300 |
| Linux 실행 환경 | Ubuntu on WSL 2 |
| WSL 소프트웨어 버전 | 3.0.3.0 |
| Linux 배포판 | Ubuntu 26.04.1 LTS (Resolute Raccoon) |
| Linux 커널 | 6.18.54.1-microsoft-standard-WSL2 |
| Shell | Bash 5.3.9(1)-release |
| 터미널 앱 | Windows Terminal |
| Docker 실행 방식 | Docker Desktop의 WSL 2 연동 |
| Docker Desktop 버전 | 4.97.0 (244584) |
| Docker CLI 버전 | 29.9.2 — build a82e528 |
| Docker Engine 버전 | 29.9.2 |
| Docker 플랫폼 | linux/amd64 |
| Docker Compose 버전 | v5.6.1 |
| Git 버전 | 2.53.0 |
| 작업 디렉터리 | `~/dev-workstation` |
| 검증 일시 | 2026-10-29 17:06:52 (KST) — 확인 시작 시각 |

\(환경 확인 명령과 실제 출력)[기록](docs/02-docker.md#실행-환경)


## 3\. 수행 체크리스트

- [x] 작업 디렉터리 생성 및 현재 위치·숨김 파일 포함 목록 확인
- [x] 파일 생성·내용 확인·복사·이름 변경·이동·삭제
- [x] 파일 1개와 디렉터리 1개의 권한 변경 전후 검증
- [x] Docker 버전 및 데몬 연결 확인
- [x] hello-world 실행 성공
- [ ] 이미지 다운로드·목록 확인
- [ ] 컨테이너 실행·중지·목록 확인
- [ ] 컨테이너 로그·리소스 사용량 확인
- [ ] Ubuntu 컨테이너 내부에서 명령 실행
- [ ] attach/exec 및 종료·유지 차이 관찰
- [ ] Dockerfile 직접 작성 및 커스텀 이미지 빌드
- [ ] 웹 서버 실행 및 포트 매핑 접속 확인
- [ ] 바인드 마운트 변경 전후 응답 비교
- [ ] 컨테이너 삭제·재생성 후 볼륨 데이터 유지 확인
- [ ] Git 사용자 정보·기본 브랜치 설정
- [x] GitHub 저장소 연결 및 push
- [ ] VSCode GitHub 로그인·저장소 연동 확인
- [x] 실제 트러블슈팅 2건 이상 작성
- [ ] 로그·이미지·커밋 대상의 민감정보 검토

## 4\. 재현 방법

미수행 — 웹 서버 빌드·실행을 검증한 뒤 실제 명령으로 작성한다.

작성할 내용:

1. 사전 준비 사항
2. 저장소 clone 및 프로젝트 폴더 이동
3. 이미지 빌드
4. 컨테이너 실행
5. 접속 URL 및 기대 응답
6. 종료·정리 방법

주의 사항:

* 명령어를 실행할 기준 디렉터리를 명시한다.
* 사용 중인 포트와 충돌할 경우의 대체 방법을 적는다.
* 특정 사용자 이름이나 개인 PC 경로를 전제하지 않는다.

## 5\. 요구사항별 검증 결과

|항목|검증 방법|결과|상세 증거|
|-|-|-|-|
|터미널 기본 조작|pwd, ls -la, mkdir, touch, cat, cp, mv, rm|완료|[기록](docs/01-terminal.md)|
|파일·디렉터리 권한|ls -l, ls -ld, chmod 및 접근 시험|완료 — 파일 쓰기 및 디렉터리 진입의 실패·복구 확인|[기록](docs/01-terminal.md)|
|Docker 설치·점검|docker --version, docker version, docker info|완료 — 서버 연결 정상|[기록](docs/02-docker.md)|
|이미지·컨테이너 운영|pull, images, run, stop, ps, logs, stats|미수행|[기록](docs/02-docker.md)|
|Ubuntu 컨테이너 실습|컨테이너 내부 명령 및 상태 비교|미수행|[기록](docs/02-docker.md)|
|커스텀 이미지|Dockerfile 작성, build, run|미수행|[기록](docs/03-web.md)|
|포트 매핑|curl 응답 및 주소창 포함 브라우저 캡처|미수행|[기록](docs/03-web.md)|
|바인드 마운트|호스트 파일 변경 전후 응답 비교|미수행|[기록](docs/04-storage.md)|
|볼륨 영속성|컨테이너 삭제·재생성 전후 데이터 비교|미수행|[기록](docs/04-storage.md)|
|Git·GitHub·VSCode|설정 출력, push 및 연동 화면|진행 중 — GitHub push 완료, Git 설정 증거 및 VSCode 연동 확인 필요|[기록](docs/05-git-github.md)|

## 6\. 핵심 개념 정리

실습 결과를 바탕으로 자신의 표현으로 작성한다.

### 절대 경로와 상대 경로

- 절대 경로: `/`부터 시작하는 전체 경로다.
  - 예: `/home/user/dev-workstation/cli-practice/basic-ops/archive/renamed-note.txt`
- 상대 경로: 현재 위치(작업 디렉터리)를 기준으로 해석하는 경로다.
  - 현재 위치가 `~/dev-workstation/cli-practice/basic-ops`일 때
    `archive/renamed-note.txt`로 같은 파일을 읽었다.
  - ./ : 현재 위치를 나타내며 생략이 가능
    `archive/renamed-note.txt`와 `./archive/renamed-note.txt`는 같다.
  - ../ : 현재 위치보다 한 단계 위의 상위 디렉터리를 나타내며, 중첩하여 더 상위 위치 사용 가능. 현재 위치가 `~/dev-workstation/cli-practice/basic-ops`일 때
    `../`는 `~/dev-workstation/cli-practice`이며, `../../`는 `~/dev-workstation`, `../../../`는 `~/` ('/home/user/')

### 파일·디렉터리 권한

리눅스/유닉스 시스템에서 파일 권한을 나타내는 r/w/x는 읽기, 쓰기, 실행 권한을 뜻하며, 755나 644는 이를 숫자로 합산하여 요약한 표기


권한의 세 그룹 (소유자 / 그룹 / 나머지)

숫자 세 자리(755, 644)는 왼쪽부터 순서대로 [소유자] [그룹] [나머지 사용자]의 권한을 의미.
• 첫 번째 자리- 소유자: 파일 또는 디렉터리의 소유 사용자 (User / Owner)
• 두 번째 자리- 그룹: 파일 또는 디렉터리에 지정된 소유 그룹 (Group)
• 세 번째 자리- 기타 사용자: 소유자와 소유 그룹에 해당하지 않는 사용자 (Others)


각 자리에서 `r=4`, `w=2`, `x=1`을 더한다.

| 숫자 | 권한 | 계산 |
|---|---|---|
| 7 | `rwx` | 4 + 2 + 1 |
| 6 | `rw-` | 4 + 2 |
| 5 | `r-x` | 4 + 1 |
| 4 | `r--` | 4 |

파일과 디렉터리에서는 권한의 의미가 다음처럼 달라진다.

| 권한 | 일반 파일 | 디렉터리 |
|---|---|---|
| `r` | 내용 읽기 | 내부 이름 목록 읽기 |
| `w` | 내용 수정 | 내부 항목 생성·삭제 등. 보통 `x`도 함께 필요 |
| `x` | 프로그램으로 실행 | 디렉터리 진입·내부 경로 탐색 |

파일의 `444`는 내용 쓰기를 금지하지만 삭제까지 금지하는 것은 아니다.
삭제 가능 여부는 상위 디렉터리의 쓰기·탐색 권한과 추가 제한에 영향을 받는다.

### 이미지와 컨테이너

* 빌드한 이미지와 실행한 컨테이너의 관계를 설명한다.

### 포트 매핑

* 실제 사용한 호스트 포트와 컨테이너 포트를 구분한다.

### 바인드 마운트와 볼륨

* 각각 무엇을 연결했고, 무엇을 검증했는지 설명한다.

### Git과 GitHub

* 로컬 변경 이력 관리와 원격 저장소의 역할을 구분한다.

## 7\. 트러블슈팅

실습 중 발생한 두 가지 문제에 대해 증상, 원인 분석, 해결 방법 및 재검증 결과를 기록했다.

| 번호 | 문제 | 해결 방법 | 재검증 결과 | 상태 | 상세 기록 |
|---|---|---|---|---|---|
| 1 | Docker 소켓 접근 권한 오류 | Docker Desktop의 Ubuntu WSL 연동 설정 적용 후 Ubuntu 터미널을 종료하고 다시 실행 | `docker info`의 Server 정보 정상 출력 및 `docker run hello-world` 성공 | 해결 완료 | [Docker 오류 기록](docs/06-troubleshooting.md#1-docker-소켓-접근-권한-오류) |
| 2 | GitHub HTTPS push 인증 실패 | GitHub CLI로 브라우저 인증 후 `gh auth setup-git`으로 Git 인증 연동 | `gh auth status`에서 로그인 확인 및 `git push -u origin main` 성공 | 해결 완료 | [GitHub 인증 오류 기록](docs/06-troubleshooting.md#2-github-https-push-인증-실패) |

### 해결 과정에서 확인한 점

- Docker CLI가 실행되는 것과 Docker 엔진에 정상적으로 연결되는 것은 별개다. 버전 출력뿐 아니라 Server 정보와 컨테이너 실행 결과까지 확인했다.
- Docker 오류는 WSL 연동 설정 적용 후 터미널을 다시 열어 해결했다. 다만 기존 세션에서 오류가 지속된 내부 원인까지 확정한 것은 아니다.
- Git의 사용자 이름·이메일 설정과 GitHub 원격 저장소 인증은 별개다. 이번 HTTPS 인증 오류는 GitHub CLI 인증을 통해 해결했다.

## 8\. 보안 점검

* \[ ] 토큰·비밀번호·개인키·인증 코드가 포함되지 않았다.
* \[ ] Git 설정 출력과 원격 URL에 민감정보가 없는지 확인했다.
* \[ ] 캡처의 다른 창·탭·알림도 검토했다.
* \[ ] 비밀정보 파일이 커밋 대상에 없는지 확인했다.

## 9\. 보너스 과제

필수 과제를 완료한 뒤 선택적으로 수행한다.

* \[ ] Compose 단일 서비스
* \[ ] Compose 멀티 컨테이너 및 통신 검증
* \[ ] Compose up/down/ps/logs 사용
* \[ ] 환경 변수 변경 검증
* \[ ] GitHub SSH 인증

