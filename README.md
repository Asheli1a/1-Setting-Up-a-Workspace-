# 개발 워크스테이션 구축 실습

## 1. 프로젝트 개요

리눅스 CLI, Docker, Git/GitHub를 사용하여 개발 작업 환경을 구축한다.

주요 목표:

* 터미널에서 파일·디렉터리와 권한을 다룬다.
* Docker 이미지와 컨테이너를 실행·관리한다.
* 직접 작성한 Dockerfile로 웹 서버 이미지를 빌드한다.
* 포트 매핑으로 웹 서버 접속을 확인한다.
* 바인드 마운트의 변경 반영과 볼륨의 데이터 영속성을 검증한다.
* Git으로 변경 이력을 관리하고 GitHub에 결과물을 공유한다.

## 2. 실행 환경

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

[환경_확인_명령과_실제_출력](docs/02-docker.md#실행-환경)

메모: 윈도우 11 내장 WSL 2 환경에 Ubuntu 배포판 설치( wsl --install -d Ubuntu ), Docker Desktop을 공식 Windows 설치 [페이지](https://docs.docker.com/desktop/setup/install/windows-install/)에서 내려받아 설치하고 WSL 연동 설정(Setting -> Resources ->WSL integration -> "Enable integration with my default WSL distro" 와 "Enable integration with additional distros: Ubuntu"에 체크 -> Apply & restart로 적용)

## 문서 구성 및 현재 진행 상태

| 문서 | 범위 | 상태 |
|---|---|---|
| [01-terminal](docs/01-terminal.md) | 기본 조작·경로·권한 | 실제 로그 검증 완료 |
| [02-docker](docs/02-docker.md) | 환경·운영·컨테이너 수명 | 실제 로그 검증 완료 |
| [03-web](docs/03-web.md) | 커스텀 이미지·포트 접속·별도 clone 재현 | 기존 실습 및 캐시 사용 재현 검증 완료 |
| [04-storage](docs/04-storage.md) | 바인드 마운트·볼륨 | 2026-10-31 볼륨 결과까지 확인, 별도 완성본 유지 |
| [05-git-github](docs/05-git-github.md) | Git 설정·GitHub·VSCode | 실제 설정·로그인 및 상세 문서 최신 반영 확인 완료 |
| [06-troubleshooting](docs/06-troubleshooting.md) | 오류·환경 문제 6건의 분석·대응 | 해결 확인 5건, 서버 설치 실패 1건은 원인 미확인 |

검토 기준은 2026-10-31까지 제공된 파일과 실행 결과다. 문서 편집 완료와 필수 과제 전체 완료는 구분한다. 05 문서는 원격에서 내용과 캡처 링크를 확인했다. 웹 서버는 커밋 ab1ce1a5854d598ea058c41d885a58fb826ff0a5의 별도 clone에서 재현했다.

## 3. 수행 체크리스트

- [x] 작업 디렉터리 생성 및 현재 위치·숨김 파일 포함 목록 확인
- [x] 파일 생성·내용 확인·복사·이름 변경·이동·삭제
- [x] 파일 1개와 디렉터리 1개의 권한 변경 전후 검증
- [x] Docker 버전 및 데몬 연결 확인
- [x] hello-world 실행 성공
- [x] 이미지 다운로드·목록 확인
- [x] 컨테이너 실행·중지·목록 확인
- [x] 컨테이너 로그·리소스 사용량 확인
- [x] Ubuntu 컨테이너 내부에서 명령 실행
- [x] attach/exec 및 종료·유지 차이 관찰
- [x] Dockerfile 직접 작성 및 커스텀 이미지 빌드
- [x] 웹 서버 실행 및 포트 매핑 접속 확인
- [x] 바인드 마운트 변경 전후 응답 비교
- [x] 컨테이너 삭제·재생성 후 볼륨 데이터 유지 확인
- [x] Git 사용자 정보·기본 브랜치 설정
- [x] GitHub 저장소 연결 및 push
- [x] VSCode GitHub 로그인·저장소 연동 확인
- [x] 실제 트러블슈팅 2건 이상 작성
- [x] 동일 PC·동일 Docker 엔진의 별도 clone에서 웹 서버 재현 — 캐시 사용
- [ ] 로그·이미지·커밋 대상의 민감정보 검토

## 4. 재현 방법

다음은 실제로 검증한 이미지 구성과 실행 방식을 바탕으로 정리한 재현 안내다. 동일 PC의 별도 clone에서 웹 서버 빌드와 접속을 재검증했다.
새 PC 또는 초기화된 Docker 환경에서의 검증은 아니다. COPY 단계에서 기존 빌드 캐시가 사용됐다.

[별도 clone 재현 기록](docs/03-web.md#별도-clone에서-웹-서버-재현-검증)

아래 일반 재현 예시와 별도 clone의 실제 수행 로그는 구분한다. 실제 재검증에서는 workspace-web:verification과 18080·18081 포트를 사용했다.

### 4.1. 사전 준비

- Docker Desktop과 WSL Ubuntu를 준비하고 해당 배포판의 WSL Integration을 활성화한다.
- Ubuntu에서 `docker info`의 Server 출력이 정상인지 확인한다.
- Git과 curl을 사용할 수 있어야 하며 이미지 다운로드를 위한 네트워크 연결이 필요하다.
- 명령은 Ubuntu Bash에서 실행한다. clone 대상 폴더, 컨테이너 이름, 호스트 포트가 기존 작업과 충돌하지 않는지 먼저 확인한다.

### 4.2. 저장소 받기 및 빌드

새 작업 위치에서 다음을 실행한다. 이미 프로젝트를 받은 경우에는 해당 폴더로 이동하고 변경 상태를 확인한 뒤 빌드 단계부터 진행한다.

```bash
git clone https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git workspace-repro
cd workspace-repro

docker build -t workspace-web:1.0 .
```

### 4.3. 두 포트로 실행 및 접속

현재 실습 환경에서 기존 8080·8081 컨테이너가 실행 중이라면 아래 명령을 그대로 실행하지 않는다. 아래 예시의 이름·호스트 포트 또는 기존 실행 상태를 조정한다. 이미지를 바꿔 빌드하는 경우 기존 태그를 덮어쓸 수 있다는 점도 확인한다.

```bash
docker run -d --name workspace-web-check-8080 \
  -p 127.0.0.1:8080:80 workspace-web:1.0

docker run -d --name workspace-web-check-8081 \
  -p 127.0.0.1:8081:80 workspace-web:1.0

curl -i http://localhost:8080
curl -i http://localhost:8081
```

기대 결과는 HTTP 200과 직접 작성한 개발 작업실 HTML, `콘텐츠 버전: v1`이다. Windows 브라우저에서도 각 주소에 접속한다. 이 재현 예시의 컨테이너 이름은 과거 실습의 workspace-web-8080/8081과 구분했다.

### 4.4. 상태·로그 확인 및 종료

```bash
docker ps --filter ancestor=workspace-web:1.0
docker logs --tail 20 workspace-web-check-8080
docker stop workspace-web-check-8080 workspace-web-check-8081
```

종료는 중지이며 삭제가 아니다. 다시 실행하려면 기존 컨테이너를 `docker start`로 시작한다. 정리가 필요할 때만 자신이 생성한 대상임을 확인한 뒤 삭제한다.

```bash
# 위 재현 예시에서 생성하고 중지한 컨테이너만 삭제
docker rm workspace-web-check-8080 workspace-web-check-8081
```

볼륨 삭제 명령은 일반 정리 절차에 포함하지 않는다.

### 4.5. 터미널·스토리지 추가 검증

- [기본 조작 및 권한](docs/01-terminal.md): 기본 조작은 파일 생성부터 삭제까지 순서대로 실행한다. 권한 실험은 일반 사용자로 수행한다.
- [바인드 마운트 및 볼륨](docs/04-storage.md): 원본 v1에서 실험용 복사본을 준비하고, 볼륨 실험은 기존 데이터와 같은 이름의 대상이 없는지 확인한다.
- 바인드 마운트의 `$(pwd)`는 프로젝트 루트를 기준으로 한다. 개인 사용자 이름이 들어간 절대 경로는 재현 환경의 경로로 바꾼다.

## 5. 요구사항별 검증 결과

|항목|검증 방법|결과|상세 증거|
|-|-|-|-|
|터미널 기본 조작|pwd, ls -la, mkdir, touch, cat, cp, mv, rm|완료|[기록](docs/01-terminal.md)|
|파일·디렉터리 권한|ls -l, ls -ld, chmod 및 접근 시험|완료 — 파일 쓰기 및 디렉터리 진입의 실패·복구 확인|[기록](docs/01-terminal.md)|
|Docker 설치·점검|docker --version, docker version, docker info|완료 — 서버 연결 정상|[기록](docs/02-docker.md)|
|이미지·컨테이너 운영|pull, images, run, stop, start, ps, logs, stats|완료 — 이미지·상태·로그·리소스 및 재시작 확인|[기록](docs/02-docker.md)|
|Ubuntu 컨테이너 실습|내부 명령 실행 및 exec/attach 종료·분리 비교|완료 — 별도 Bash 종료·연결 분리·주 Bash 종료의 차이 확인|[기록](docs/02-docker.md)|
|커스텀 이미지|직접 작성한 Dockerfile로 build 및 run|완료 — 커스텀 HTML 포함 이미지 빌드·실행 성공|[기록](docs/03-web.md)|
|포트 매핑|8080·8081 curl 응답 및 주소창 포함 캡처|완료 — 두 포트 모두 HTTP 200 및 v1 콘텐츠 확인|[기록](docs/03-web.md)|
|바인드 마운트|마운트 설정 및 호스트 파일 변경 전후 응답 비교|완료 — 재빌드·재시작 없이 8082의 v1→v2 반영, 8080·8081은 v1 유지|[기록](docs/04-storage.md)|
|볼륨 영속성|볼륨 생성·연결, 첫 컨테이너 삭제, 새 컨테이너에서 읽기|완료 — bc3f232b6753 삭제 후 6c0da8079371에서 기존 파일 유지 확인|[기록](docs/04-storage.md)|
|Git·GitHub·VSCode|설정 출력, push 및 연동 화면|완료 — 전역·저장소별 설정, 본인 계정 및 WSL Git·원격 확인|[기록](docs/05-git-github.md) · [최신 검증](docs/06-troubleshooting.md#5-공용-노트북의-vscode에-타인-github-계정이-로그인됨)|
|별도 clone 재현|원격 커밋 clone, 빌드, 두 컨테이너 실행, HTTP·브라우저 확인|완료 — 동일 PC·동일 엔진 및 캐시 사용, 두 포트 HTTP 200·v1|[기록](docs/03-web.md#별도-clone에서-웹-서버-재현-검증)|

## 6. 핵심 개념 정리

아래 개념은 실제 실습에서 확인한 경로·권한·이미지·포트·데이터 결과와 연결해 정리했다.

### 절대 경로와 상대 경로

- 절대 경로: `/`부터 시작하는 전체 경로다.
  - 예: `/home/user/dev-workstation/cli-practice/basic-ops/archive/renamed-note.txt`
- 상대 경로: 현재 위치(작업 디렉터리)를 기준으로 해석하는 경로다.
  - 현재 위치가 `~/dev-workstation/cli-practice/basic-ops`일 때
    `archive/renamed-note.txt`로 같은 파일을 읽었다.
  - `./`: 현재 위치를 나타내며 생략이 가능
    `archive/renamed-note.txt`와 `./archive/renamed-note.txt`는 같다.
  - `../`: 현재 위치보다 한 단계 위의 상위 디렉터리를 나타내며, 중첩하여 더 상위 위치 사용 가능. 현재 위치가 `~/dev-workstation/cli-practice/basic-ops`일 때
    `../`는 `~/dev-workstation/cli-practice`이며, `../../`는 `~/dev-workstation`, `../../../`는 `~/` ('/home/user/')

### 파일·디렉터리 권한

리눅스/유닉스 시스템에서 파일 권한을 나타내는 r/w/x는 읽기, 쓰기, 실행 권한을 뜻하며, 755나 644는 이를 숫자로 합산하여 요약한 표기

권한의 세 그룹 (소유자 / 그룹 / 나머지)

숫자 세 자리(755, 644)는 왼쪽부터 순서대로 [소유자] [그룹] [나머지 사용자]의 권한을 의미.
- 첫 번째 자리 — 소유자: 파일 또는 디렉터리의 소유 사용자 (User / Owner)
- 두 번째 자리 — 그룹: 파일 또는 디렉터리에 지정된 소유 그룹 (Group)
- 세 번째 자리 — 기타 사용자: 소유자와 소유 그룹에 해당하지 않는 사용자 (Others)

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

이미지는 실행에 필요한 파일과 설정을 담은 기반이며, 컨테이너는 그 이미지로 생성한 실행 단위다. 이번에는 Dockerfile의 COPY로 HTML을 포함한 workspace-web:1.0을 빌드하고, 서로 다른 ID를 가진 두 컨테이너에서 같은 콘텐츠를 제공했다. 같은 이미지를 사용해도 컨테이너는 각각 중지·시작할 수 있다.

### 포트 매핑

호스트 주소·포트와 컨테이너 포트를 연결한다. 이번에는 호스트의 127.0.0.1:8080과 8081을 각 웹 컨테이너의 80번 포트로 연결해 두 컨테이너에 동시에 접속했다. Dockerfile의 EXPOSE는 포트 사용을 명시할 뿐 이 연결을 대신하지 않는다.

### 바인드 마운트와 볼륨

- 바인드 마운트: 프로젝트의 cli-practice/bind-site를 웹 경로에 연결했다. 호스트 HTML 수정만으로 8082 응답이 v1에서 v2로 바뀌었고 8080·8081은 v1을 유지했다.
- 볼륨: workspace-data를 /data에 연결했다. 첫 컨테이너 bc3f232b6753을 삭제한 뒤 새 컨테이너 6c0da8079371에서 기존 persistent.txt를 재작성 없이 읽었다. 비교용 내부 파일은 새 컨테이너에 없었다.
- 두 실험은 변경 반영과 데이터 유지에 초점을 나눴다. 바인드 마운트가 컨테이너 삭제 시 반드시 데이터를 잃는다는 의미는 아니다.

### Git과 GitHub

Git은 로컬에서 변경 이력과 브랜치를 관리하는 도구이고, GitHub는 원격 저장소를 공유·협업하는 플랫폼이다. 로컬 commit 후 push로 원격에 반영했다. GitHub 웹에서 별도 커밋이 생겨 이력이 분기됐을 때는 merge로 통합했다. Git의 작성자 이름·이메일 설정은 원격 인증과 별개다.

## 7. 트러블슈팅

실습 중 발생한 여섯 가지 문제에 대해 증상, 원인 분석, 해결 방법 및 재검증 결과를 기록했다. 다섯 건은 해결 결과를 확인했으며, 외부 `code .`의 서버 설치 실패 한 건은 원인 미확인으로 구분했다.

| 번호 | 문제 | 해결 방법 | 재검증 결과 | 상태 | 상세 기록 |
|---|---|---|---|---|---|
| 1 | Docker 소켓 접근 권한 오류 | Docker Desktop의 Ubuntu WSL 연동 설정 적용 후 Ubuntu 터미널을 종료하고 다시 실행 | `docker info`의 Server 정보 정상 출력 및 `docker run hello-world` 성공 | 해결 완료 | [Docker 오류 기록](docs/06-troubleshooting.md#1-docker-소켓-접근-권한-오류) |
| 2 | GitHub HTTPS push 인증 실패 | GitHub CLI로 브라우저 인증 후 `gh auth setup-git`으로 Git 인증 연동 | `gh auth status`에서 로그인 확인 및 `git push -u origin main` 성공 | 해결 완료 | [GitHub 인증 오류 기록](docs/06-troubleshooting.md#2-github-https-push-인증-실패) |
| 3 | GitHub 웹 업로드 후 push 거부 및 브랜치 분기 | `git merge --no-edit origin/main`으로 원격 이미지와 로컬 문서 변경 통합 | 자동 병합, 이미지 파일 확인 및 push 성공 | 해결 완료 | [브랜치 분기 해결 기록](docs/06-troubleshooting.md#3-github-웹-업로드-후-push-거부-및-브랜치-분기) |
| 4 | VSCode PowerShell에서 Git 미인식 | WSL 통합 Bash로 연결해 Ubuntu Git과 프로젝트 조회 | `/usr/bin/git`, Git 2.53.0, 프로젝트 루트·main·원격 확인 | 해결 완료 | [실행 환경 오류 기록](docs/06-troubleshooting.md#4-vscode의-powershell에서-git-명령을-찾지-못함) |
| 5 | 공용 VSCode의 타인 GitHub 계정 | 본인 계정으로 다시 로그인하고 CLI 인증·저장소별 작성자 설정 확인 | Asheli1a 계정, CLI 활성 상태, `.git/config`의 작성자 확인 | 전환·설정 확인 완료 | [계정 확인 기록](docs/06-troubleshooting.md#5-공용-노트북의-vscode에-타인-github-계정이-로그인됨) |
| 6 | `code .` 실행 중 서버 설치 실패 | 저장 완료와 최종 실패 메시지를 함께 기록, 현재 동작하는 WSL 창 사용 | 현재 WSL Git 정상이나 해당 설치 경로의 복구는 미확인 | 원인 미확인 | [설치 실패 기록](docs/06-troubleshooting.md#6-code-실행-중-vs-code-server-설치-실패) |

### 해결 과정에서 확인한 점

- Docker CLI가 실행되는 것과 Docker 엔진에 정상적으로 연결되는 것은 별개다. 버전 출력뿐 아니라 Server 정보와 컨테이너 실행 결과까지 확인했다.
- Docker 오류는 WSL 연동 설정 적용 후 터미널을 다시 열어 해결했다. 다만 기존 세션에서 오류가 지속된 내부 원인까지 확정한 것은 아니다.
- Git의 사용자 이름·이메일 설정과 GitHub 원격 저장소 인증은 별개다. 이번 HTTPS 인증 오류는 GitHub CLI 인증을 통해 해결했다.
- GitHub 웹과 로컬에서 각각 커밋하면 이력이 분기될 수 있다.
  이번에는 실제 파일 충돌 없이 merge로 통합했다.
- 캡처와 관련 문서를 로컬에서 함께 커밋하는 방식으로 이후 작업 흐름을 통일한다.
- WSL 폴더를 열었다는 사실과 명령 실행 환경이 WSL이라는 사실은 다르다. VSCode의 통합 Bash에서 Linux·Git 경로를 함께 확인했다.
- 공용 장비에서는 VSCode 계정·CLI 인증·Git 작성자 정보를 각각 확인했다. 저장소별 작성자 설정은 인증 계정 전환을 대신하지 않는다.
- 서버 파일 저장 완료만으로 설치 성공을 단정하지 않았다. 현재 WSL 세션 정상 동작과 실패한 `code .` 경로의 복구 여부는 구분했다.

## 8. 보안 점검

아래 항목은 저장소 전체와 실제 파일을 직접 확인한 뒤 체크한다. 첨부된 Markdown의 토큰 마스킹 확인만으로 모든 이력·이미지까지 검토 완료한 것은 아니다. 웹 콘텐츠와 캡처에는 실명이 포함돼 있으므로 공개 의도를 확인한다.

- [ ] 토큰·비밀번호·개인키·인증 코드가 포함되지 않았다.
- [ ] Git 설정 출력과 원격 URL에 민감정보가 없는지 확인했다.
- [ ] 캡처의 다른 창·탭·알림도 검토했다.
- [ ] 비밀정보 파일이 커밋 대상에 없는지 확인했다.
- 공용 장비를 반납해야 할 경우에는, 본인 VSCode·CLI·브라우저 인증과 동기화 상태를 확인·정리해야 한다.

## 9. 보너스 과제

필수 과제를 완료한 뒤 선택적으로 수행한다.

- [ ] Compose 단일 서비스
- [ ] Compose 멀티 컨테이너 및 통신 검증
- [ ] Compose up/down/ps/logs 사용
- [ ] 환경 변수 변경 검증
- [ ] GitHub SSH 인증

## 10. 남은 필수 확인

1. 완료: Git 설정·전역/저장소별 출처·전체 설정 기록을 05 문서에 반영하고 구분을 확인했다.
2. 완료: VSCode 본인 계정·WSL 저장소·CLI 인증 캡처를 05 문서에 연결하고 06 문서와의 일치를 확인했다.
3. Dockerfile·site·이미지 파일과 모든 문서 링크가 실제 저장소에 있는지 확인한다.
4. 완료: docs/04-storage.md에 볼륨 실험까지 반영한 버전을 별도 clone에서 확인했다. 상세 증거와 완료 체크를 유지한다.
5. 동일 PC의 별도 clone에서 캐시를 사용한 웹 서버 재현은 완료했다. 새 PC·캐시 없는 초기 환경 검증과 저장소 전체 보안 검토는 구분하며, 남은 최종 점검 후 제출한다.
6. 외부 `code .`의 서버 설치 실패는 원인 미확인으로 남아 있으므로, 재발 시 로그를 수집하고 실행 진입 경로의 재현성을 확인한다.
