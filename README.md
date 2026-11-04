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
| [06-troubleshooting](docs/06-troubleshooting.md) | 오류·환경 문제 9건의 분석·대응 | 해결 확인 8건(사례 8은 원인 미확인), 서버 설치 실패 1건은 원인 미확인 |
| [07-compose](docs/07-compose.md) | Compose 단일 서비스·실행·접속·종료 | 단일 서비스 및 up/down/ps/logs 검증 완료 |
| [08-compose-multi](docs/08-compose-multi.md) | Compose 두 서비스·내부 통신·종료 | 실제 로그 검증 완료 |
| [09-compose-env](docs/09-compose-env.md) | 환경 변수·NGINX 내부 포트·동일 이미지·종료 | 8080/9090 실제 비교 검증 완료 |
| [10-github-ssh](docs/10-github-ssh.md) | SSH 계정 인증·실제 push·원격 SHA | 실제 전송 검증 완료 |
| [11-port-conflict](docs/11-port-conflict.md) | Python·Docker 포트 충돌, 점유자 식별·해제·재사용, 매핑 누락 | 2026-11-04 재실습 원본 출력 검증 완료 |
| [12-volume-backup-restore](docs/12-volume-backup-restore.md) | 볼륨 tar 백업·새 볼륨 복원·체크섬 대조 | 복원·대조 구간 실제 로그 검증 완료 |

실습 기록의 검토 기준은 2026-10-31까지 제공된 파일과 실행 결과이며, 보안 점검·실명 비식별화는 2026-11-02에 추가 반영했다. 포트 충돌(11)과 볼륨 백업·복원(12)은 초기화된 공용 노트북에서 2026-11-03에 수행한 추가 실습이다. 포트 충돌은 2026-11-04에 다른 노트북에서 다시 수행해 원본 출력으로 교체했다. 문서 편집 완료와 필수 과제 전체 완료는 구분한다. 05 문서는 원격에서 내용과 캡처 링크를 확인했다. 웹 서버는 커밋 [ab1ce1a5854d598ea058c41d885a58fb826ff0a5](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/ab1ce1a5854d598ea058c41d885a58fb826ff0a5)의 별도 clone에서 재현했다.

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
- [x] 포트 충돌 재현·점유자 식별·해제·같은 포트 재사용 — Python·Docker, 2026-11-04 재실습 원본 출력
- [x] 바인드 마운트 변경 전후 응답 비교
- [x] 컨테이너 삭제·재생성 후 볼륨 데이터 유지 확인
- [x] 볼륨 tar 백업의 새 볼륨 복원과 체크섬 대조 — 파일 3개, 샘플 데이터 기준
- [x] Git 사용자 정보·기본 브랜치 설정
- [x] GitHub 저장소 연결 및 push
- [x] VSCode GitHub 로그인·저장소 연동 확인
- [x] 실제 트러블슈팅 2건 이상 작성
- [x] 동일 PC·동일 Docker 엔진의 별도 clone에서 웹 서버 재현 — 캐시 사용
- [x] 현재 제출 대상의 민감정보 검토 — 문서·로그·파일 목록 확인 및 첨부 이미지 육안 검토, 전체 과거 이력 전수 검사와 구분

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

### 4.6. 프로젝트 구조

`git pull` 뒤 `~/dev-workstation`에서 `find`로 확인한 구조다(2026-11-04, `.git`과 `docs/images` 내부는 제외).

```console
$ find . -maxdepth 2 -not -path './.git*' -not -path './docs/images/*' | sort
.
./.dockerignore
./Dockerfile
./README.md
./cli-practice
./cli-practice/bind-site
./cli-practice/empty.txt
./cli-practice/hello.txt
./cli-practice/port-conflict
./docker-compose.env.yml
./docker-compose.multi.yml
./docker-compose.yml
./docs
./docs/01-terminal.md
./docs/02-docker.md
./docs/03-web.md
./docs/04-storage.md
./docs/05-git-github.md
./docs/06-troubleshooting.md
./docs/07-compose.md
./docs/08-compose-multi.md
./docs/09-compose-env.md
./docs/10-github-ssh.md
./docs/11-port-conflict.md
./docs/12-volume-backup-restore.md
./docs/images
./nginx
./nginx/env-templates
./site
./site/index.html
```

| 위치 | 역할 |
|---|---|
| `Dockerfile`, `.dockerignore`, `site/index.html` | 커스텀 웹 이미지의 소스와 빌드 설정 ([03](docs/03-web.md)) |
| `docker-compose*.yml`, `nginx/env-templates` | Compose 단일·멀티·환경 변수 실습 설정 ([07](docs/07-compose.md), [08](docs/08-compose-multi.md), [09](docs/09-compose-env.md)) |
| `cli-practice/bind-site` | 바인드 마운트 실험용 복사본 ([04](docs/04-storage.md)) |
| `cli-practice/port-conflict` | 포트 충돌 재실습의 웹 파일(`site/index.html`)과 서버 로그 3개(`logs/`) ([11](docs/11-port-conflict.md)) |
| `docs`, `docs/images` | 실습 기록과 캡처 |

`cli-practice/basic-ops`와 `cli-practice/permissions`는 처음 노트북에서 만든 실습 폴더였고 커밋하지 않았다. 이 실습의 명령과 출력은 [01번 문서](docs/01-terminal.md)에 있다.

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
|포트 충돌|점유 재현, 점유자 식별, 해제 후 같은 포트 재사용|완료 — Python은 `Errno 98`·종료 코드 1, Docker는 `port is already allocated`·종료 코드 125. 점유자는 ps·ss·lsof·fuser로 확인(Docker는 docker ps·docker port). 복구 후 매핑·HTTP 200 확인|[기록](docs/11-port-conflict.md)|
|볼륨 백업·복원|tar.gz 백업을 새 볼륨에 복원, 압축 파일·파일별 체크섬 대조|완료 — 파일 3개 복원, 체크섬 목록 차이 없음(종료 코드 0). 샘플 데이터 기준|[기록](docs/12-volume-backup-restore.md)|
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

### Docker를 쓰는 이유

- 프로그램은 코드만으로 실행되지 않는다. 실행기, 라이브러리, 설정이 필요하고, 환경이 다르면 "내 컴퓨터에서만 된다"는 문제가 생긴다.
- Docker는 앱과 실행에 필요한 파일을 이미지로 묶고, 그 이미지로 같은 환경을 반복해서 실행한다.
- 해운 컨테이너가 화물을 옮길 때마다 내리고 다시 싣는 낭비를 없앤 것과 같은 발상이다. 다만 비유일 뿐이고, 컴퓨터 전체를 담는 것은 아니다.
- 이번 실습에서는 `workspace-web:1.0` 이미지 하나로 8080·8081 컨테이너를 만들었고([03](docs/03-web.md)), 저장소를 새로 clone해서 같은 결과를 다시 얻었다.

### 컨테이너와 가상머신

가상머신(VM)은 하이퍼바이저 위에서 게스트 OS를 통째로 부팅한다. VMware 같은 도구가 이 방식이다. 컨테이너는 호스트의 커널을 공유하는 격리된 프로세스라서 OS를 따로 부팅하지 않는다. 참고: [Docker 문서](https://docs.docker.com/learn/content/what-is-a-container/)

| 비교 | 가상머신 (VMware 등) | 컨테이너 (Docker) |
|---|---|---|
| 구성 | 하이퍼바이저 + 게스트 OS(커널 포함) | 호스트 커널 공유, 앱과 필요한 파일만 포함 |
| 시작 | 게스트 OS 부팅이 필요 | 프로세스를 시작하는 수준 |
| 크기 | 보통 수백 MB~수 GB | 보통 수십~수백 MB |
| 격리 | 하드웨어 경계로 분리되어 더 강함 | 커널을 공유해서 VM보다 약함 |
| 다른 OS | 가능 | 호스트와 같은 종류의 커널이 필요 |

가상머신이 아니라서 얻는 장점은 다음과 같다.

- 빠른 시작: 게스트 OS 부팅이 없다.
- 적은 자원: 컨테이너마다 OS를 따로 두지 않는다.
- 같은 PC에 여러 개 실행: 이미지 하나로 컨테이너를 여러 개 만들 수 있다.
- 쉬운 재현: Dockerfile과 이미지로 환경을 정의하고, 지우고 다시 만들어도 같은 모양이 된다.

이번 실습에서 확인한 값은 다음과 같다. VMware와 직접 비교해서 측정한 값은 아니다.

- `docker run -dit` 직후 `docker ps`가 `Up Less than a second`로 표시됐다. ([02](docs/02-docker.md))
- `ubuntu:latest`는 디스크 163MB, 내용 45.9MB였고, `workspace-web:1.0`은 93.6MB였다. ([02](docs/02-docker.md), [03](docs/03-web.md))
- 실행 중인 `workspace-ubuntu`는 메모리 9.543MiB, PIDS 1이었다. ([02](docs/02-docker.md))
- 컨테이너 안 NGINX 로그의 `OS: Linux 6.18.54.1-microsoft-standard-WSL2`가 호스트의 `uname -r`과 같았다. 컨테이너가 자기 커널을 부팅하지 않고 호스트 쪽 리눅스 커널을 쓴다는 근거다. Windows에서는 WSL 2가 이 리눅스 커널을 제공한다.

한계도 있다. 커널을 공유하므로 격리는 VM보다 약하고, 다른 종류의 OS가 필요하면 VM이 맞다. 도커를 쓴다고 환경 차이가 전부 사라지는 것도 아니다. 이번 실습도 `linux/amd64`와 가변 태그(`nginx:alpine`)라는 전제에서 확인했다.

### 이미지와 컨테이너

이미지는 실행에 필요한 파일과 설정을 담은 기반이며, 컨테이너는 그 이미지로 생성한 실행 단위다. 이번에는 Dockerfile의 COPY로 HTML을 포함한 workspace-web:1.0을 빌드하고, 서로 다른 ID를 가진 두 컨테이너에서 같은 콘텐츠를 제공했다. 같은 이미지를 사용해도 컨테이너는 각각 중지·시작할 수 있다.

### 포트 매핑

호스트 주소·포트와 컨테이너 포트를 연결한다. 이번에는 호스트의 127.0.0.1:8080과 8081을 각 웹 컨테이너의 80번 포트로 연결해 두 컨테이너에 동시에 접속했다. Dockerfile의 EXPOSE는 포트 사용을 명시할 뿐 이 연결을 대신하지 않는다.

### 바인드 마운트와 볼륨

- 바인드 마운트: 프로젝트의 cli-practice/bind-site를 웹 경로에 연결했다. 호스트 HTML 수정만으로 8082 응답이 v1에서 v2로 바뀌었고 8080·8081은 v1을 유지했다.
- 볼륨: workspace-data를 /data에 연결했다. 첫 컨테이너 bc3f232b6753을 삭제한 뒤 새 컨테이너 6c0da8079371에서 기존 persistent.txt를 재작성 없이 읽었다. 비교용 내부 파일은 새 컨테이너에 없었다.
- 두 실험은 변경 반영과 데이터 유지에 초점을 나눴다. 바인드 마운트가 컨테이너 삭제 시 반드시 데이터를 잃는다는 의미는 아니다.

### Git과 GitHub

Git은 로컬에서 변경 이력과 브랜치를 관리하는 도구이고, GitHub는 원격 저장소를 공유·협업하는 플랫폼이다. 로컬 commit 후 push로 원격에 반영했다. GitHub 웹에서 별도 커밋이 생겨 이력이 분기됐을 때는 merge로 통합했다. Git의 이름·이메일 설정은 원격 인증과 별개다.

## 7. 트러블슈팅

실습 중 발생한 아홉 가지 문제에 대해 증상, 원인 분석, 해결 방법 및 재검증 결과를 기록했다. 여덟 건은 해결 또는 복구 결과를 확인했으며, 외부 `code .`의 서버 설치 실패 한 건은 원인 미확인으로 구분했다. 사례 8은 복구는 확인했지만 포트 매핑이 비었던 원인은 확인하지 못했다.

| 번호 | 문제 | 해결 방법 | 재검증 결과 | 상태 | 상세 기록 |
|---|---|---|---|---|---|
| 1 | Docker 소켓 접근 권한 오류 | Docker Desktop의 Ubuntu WSL 연동 설정 적용 후 Ubuntu 터미널을 종료하고 다시 실행 | `docker info`의 Server 정보 정상 출력 및 `docker run hello-world` 성공 | 해결 완료 | [Docker 오류 기록](docs/06-troubleshooting.md#1-docker-소켓-접근-권한-오류) |
| 2 | GitHub HTTPS push 인증 실패 | GitHub CLI로 브라우저 인증 후 `gh auth setup-git`으로 Git 인증 연동 | `gh auth status`에서 로그인 확인 및 `git push -u origin main` 성공 | 해결 완료 | [GitHub 인증 오류 기록](docs/06-troubleshooting.md#2-github-https-push-인증-실패) |
| 3 | GitHub 웹 업로드 후 push 거부 및 브랜치 분기 | `git merge --no-edit origin/main`으로 원격 이미지와 로컬 문서 변경 통합 | 자동 병합, 이미지 파일 확인 및 push 성공 | 해결 완료 | [브랜치 분기 해결 기록](docs/06-troubleshooting.md#3-github-웹-업로드-후-push-거부-및-브랜치-분기) |
| 4 | VSCode PowerShell에서 Git 미인식 | WSL 통합 Bash로 연결해 Ubuntu Git과 프로젝트 조회 | `/usr/bin/git`, Git 2.53.0, 프로젝트 루트·main·원격 확인 | 해결 완료 | [실행 환경 오류 기록](docs/06-troubleshooting.md#4-vscode의-powershell에서-git-명령을-찾지-못함) |
| 5 | 공용 VSCode의 타인 GitHub 계정 | 본인 계정으로 다시 로그인하고 CLI 인증·저장소별 설정 확인 | Asheli1a 계정, CLI 활성 상태, `.git/config`의 확인 | 전환·설정 확인 완료 | [계정 확인 기록](docs/06-troubleshooting.md#5-공용-노트북의-vscode에-타인-github-계정이-로그인됨) |
| 6 | `code .` 실행 중 서버 설치 실패 | 저장 완료와 최종 실패 메시지를 함께 기록, 현재 동작하는 WSL 창 사용 | 현재 WSL Git 정상이나 해당 설치 경로의 복구는 미확인 | 원인 미확인 | [설치 실패 기록](docs/06-troubleshooting.md#6-code-실행-중-vs-code-server-설치-실패) |
| 7 | GitHub SSH 인증 실패 | GitHub 웹의 추가 이메일 확인 완료 후 같은 키로 재시험 | 본인 계정 인증 및 실제 SSH push·원격 SHA 일치 확인 | 해결 완료 | [SSH 인증 오류 기록](docs/06-troubleshooting.md#7-github-ssh-인증-실패) |
| 8 | 중지 후 다시 시작한 Docker 컨테이너의 포트 매핑 없음 | 라벨을 확인한 retry 컨테이너만 삭제하고 `-p`를 명시해 새로 생성 | `CurrentPorts`에 `127.0.0.1:18086` 표시, `docker port` 출력, HTTP 200 | 복구 확인 / 원인 미확인 / 2회 재현 | [포트 매핑 누락 기록](docs/06-troubleshooting.md#8-중지-후-다시-시작한-docker-컨테이너의-포트-매핑이-비어-있음) |
| 9 | clone한 저장소의 README 파일명이 `README`로 바뀌어 있음 | `git mv -- README README.md` | `git status --short`에 `R  README -> README.md` 표시 | 해결 완료 | [README 파일명 기록](docs/06-troubleshooting.md#9-clone한-저장소의-readme-파일명이-readme로-바뀌어-있음) |

### 해결 과정에서 확인한 점

- Docker CLI가 실행되는 것과 Docker 엔진에 정상적으로 연결되는 것은 별개다. 버전 출력뿐 아니라 Server 정보와 컨테이너 실행 결과까지 확인했다.
- Docker 오류는 WSL 연동 설정 적용 후 터미널을 다시 열어 해결했다. 다만 기존 세션에서 오류가 지속된 내부 원인까지 확정한 것은 아니다.
- Git의 사용자 이름·이메일 설정과 GitHub 원격 저장소 인증은 별개다. 이번 HTTPS 인증 오류는 GitHub CLI 인증을 통해 해결했다.
- GitHub 웹과 로컬에서 각각 커밋하면 이력이 분기될 수 있다.
  이번에는 실제 파일 충돌 없이 merge로 통합했다.
- 캡처와 관련 문서를 로컬에서 함께 커밋하는 방식으로 이후 작업 흐름을 통일한다.
- WSL 폴더를 열었다는 사실과 명령 실행 환경이 WSL이라는 사실은 다르다. VSCode의 통합 Bash에서 Linux·Git 경로를 함께 확인했다.
- 공용 장비에서는 VSCode 계정·CLI 인증·Git 정보를 각각 확인했다. 저장소별 설정은 인증 계정 전환을 대신하지 않는다.
- 서버 파일 저장 완료만으로 설치 성공을 단정하지 않았다. 현재 WSL 세션 정상 동작과 실패한 `code .` 경로의 복구 여부는 구분했다.
- SSH 키 생성·호스트 확인만으로 본인 인증이 끝났다고 보지 않는다. GitHub 웹의 추가 확인 완료, 본인 계정 인사말, 실제 push를 차례로 확인한다.
- 컨테이너가 `running`이어도 포트 매핑이 비어 있을 수 있다. `RequestedBindings`와 `CurrentPorts`, `docker port`, HTTP 응답을 따로 확인한다.
- clone 직후 링크 대상인 `README.md`가 그대로 있는지 확인한다.

## 8. 보안 점검

- 검토 일자: 2026-11-02 (추가 검토 2026-11-04)
- 검토 범위: 현재 제출 대상 문서·로그·파일 목록과 캡처. 캡처의 육안 검토 완료.
- 공개 자료의 실명은 `이XX`로 비식별화하고, 이미지의 실명 포함 영역은 불투명하게 가림 처리했다.
- 웹 페이지 제목의 `루키마리너-1_Asheli1a`는 실명과 관계없이 의도해서 바꾼 표기다. 07~09번 문서의 HTML 출력에 나온다.

- [x] 확인한 현재 문서·로그에서 마스킹되지 않은 토큰·비밀번호·개인키·인증 코드를 발견하지 못했다.
- [x] Git 설정 출력과 원격 URL에 인증정보가 포함되지 않았는지 검토했다.
- [x] 캡처의 다른 창·탭·알림과 타인 계정 정보 등을 육안 검토했다.
- [x] 추적 파일 목록과 민감 파일명 패턴을 검사했다. 해당 패턴에 일치하는 파일은 발견되지 않았다.

2026-11-04에는 11·12번 문서, 06번 사례 8·9, 문서 문장 수정, README 변경을 반영한 `main`(`969e8e5`)을 새로 받아 다시 검색했다. 이번 추가분에는 캡처 이미지가 없다.

```console
$ git grep -nEi 'gh[pousr]_[A-Za-z0-9]{20,}|github_pat_|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|(password|passwd)\s*[:=]\s*\S+' -- . ':!docs/images'
$ git ls-files | grep -Ei '\.(pem|key|env)$|id_(rsa|ed25519)$' || echo "민감 파일명 패턴 없음"
민감 파일명 패턴 없음
```

`git grep`은 일치하는 줄이 없어 출력이 없었다. 마스킹된 토큰 표기(`gho_***…`)는 패턴에 걸리지 않는다. 이 검색은 텍스트 패턴만 확인하므로 이미지 검토는 대체하지 못하고, 전체 과거 이력의 전수 검사도 아니다.

포트 충돌 로그(`cli-practice/port-conflict/logs/second-20261104-152141.log`)를 저장소에 올린 뒤에는 이 검색에서 `tls_password=tls_key_password,` 한 줄이 걸린다. Python `http.server`의 traceback에 찍힌 인자 이름이며 실제 비밀번호 값이 아니다. 로그는 원문 그대로 보관했다.

처음부터 실습 자료 작성과 제출 시 비밀번호, 개인 이메일 등 민감정보를 포함하지 않는 방향으로 진행했다. GitHub CLI 인증 상태 출력에서 토큰이 기본적으로 마스킹되어 있음을 확인했으며, 자동 마스킹 여부와 관계없이 공개 전 문서·로그·캡처를 별도로 검토했다.

공용 노트북에서 실습하므로 실습·제출용 파일은 본인이 생성한 WSL 작업 디렉터리와 Windows 개인 작업 폴더에서 관리한다. 도구가 별도로 저장하는 인증정보와 설정은 해당 도구의 저장 위치 및 장비 정책에 따라 확인·관리한다.

현재 제출 자료의 검토와 전체 과거 이력의 전수 검사는 구분한다. 이전 검토 당시 main에서 조회한 28개 커밋의 메타데이터와 일부 과거 변경 내용을 확인했으며, 초기 GitHub 인증 기록 커밋에서도 토큰은 마스킹되어 있었다. 모든 과거 커밋의 파일 내용에 대한 전수 검사나 저장소 전체 자동 비밀정보 검사를 완료했다는 뜻은 아니다. 파일명 패턴 검사만으로 비밀정보 파일이 전혀 없다고 보증하지 않는다.

문서·과거 HTTP 응답 로그의 실명 치환과 이미지 가림은 개인정보 보호를 위한 공개본 편집이다. 과거 실행의 명령·포트·상태·ID·시각·버전·응답 헤더 값은 유지했다. 따라서 비식별화한 본문 길이가 과거 로그의 Content-Length와 다를 수 있으며, 이를 새로운 실행 출력으로 간주하지 않는다. 실제 웹 소스도 변경했으므로 이후 새 이미지로 빌드할 때는 새 응답을 별도로 확인한다. 이 변경은 2026-11-02 현재 파일에 적용되며 과거 커밋의 원본·이미지까지 제거하는 이력 재작성은 포함하지 않는다

매일 작업 종료 시 웹 브라우저의 코디세이·GitHub 등 본인 로그인 세션과 VSCode 계정을 확인하고 로그아웃한다. 장비 자체를 반납해야 할 경우에는 본인 VSCode·CLI·브라우저 인증과 설정 동기화 상태까지 확인·정리한다. 다른 사용자의 인증정보나 설정은 일괄 삭제하지 않는다. 이는 작업 관리 방침이며, 특정 시점의 모든 로그아웃·토큰 폐기를 이미 수행했다는 증거를 뜻하지 않는다.

## 9. 보너스 과제

필수 과제를 완료한 뒤 선택적으로 수행한다. 필수 실습이 컨테이너를 직접 실행하고 결과를 확인하는 과정이었다면, 선택 미션은 실행 설정을 파일로 공유하고 여러 서비스를 함께 운영하는 방법으로 확장하는 과정이다.

| 선택 미션 | 의미·목적 | 실제 완료 판단 기준 |
|---|---|---|
| Compose 단일 서비스 | 긴 실행 옵션을 YAML 설정 파일로 관리해 같은 구성을 반복 실행 | 설정 파일로 기존 웹 서버를 실행하고 HTTP·브라우저 응답 확인 |
| Compose 운영 명령 | 실행·상태·로그·종료를 한 프로젝트 단위로 관리 | up·ps·logs·down의 입력과 실제 결과 기록 |
| 멀티 컨테이너 통신 | 같은 네트워크의 서비스를 서비스 이름으로 찾는 구조 이해 | 보조 컨테이너에서 웹 서비스로 요청하고 응답 확인 |
| 환경 변수 | 설정값과 코드 분리 | 값 변경이 실제 서버 설정·포트·동작에 반영되는지 확인 |
| GitHub SSH | HTTPS 외에 키 기반 원격 인증 경험 | 본인 SSH 인증과 SSH 주소를 통한 push 성공 확인 |

권장 순서는 단일 서비스와 운영 명령 → 멀티 컨테이너 통신 → 환경 변수 → SSH 인증이다. 단순히 컨테이너 두 개를 켜거나 환경 변수 값을 출력하는 것만으로 통신·동작 변경 검증을 완료했다고 기록하지 않는다. SSH 개인키는 공용 장비의 보관·정리 정책을 고려하며 저장소에 커밋하지 않는다.

- [x] Compose 단일 서비스
- [x] Compose 멀티 컨테이너 및 통신 검증
- [x] Compose up/down/ps/logs 사용
- [x] 환경 변수 변경 검증
- [x] GitHub SSH 인증

[Compose 단일 서비스 실행·접속·종료 검증](docs/07-compose.md) — 단일 서비스와 up·ps·logs·down 검증 완료.

[Compose 멀티 컨테이너 통신·종료 검증](docs/08-compose-multi.md) — 두 서비스 실행, client → web 요청, 네트워크·서버 로그 대조, 종료 후 상태 확인 완료.

[환경 변수·NGINX 내부 포트 검증](docs/09-compose-env.md) — 같은 이미지에서 8080/9090 설정·포트·HTTP를 비교하고 종료 후 상태를 확인했다.

[GitHub SSH 인증·push 검증](docs/10-github-ssh.md) — 본인 계정 인증, 저장소별 키·SSH 원격 설정, 실제 변경 전송과 로컬·원격 main SHA 일치를 확인했다. 검증 커밋은 [9088c08f6e8ec2cbe90bba1c5f3909ef805f9777](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/9088c08f6e8ec2cbe90bba1c5f3909ef805f9777)이다.

## 10. 남은 필수 확인

1. 외부 `code .`의 서버 설치 실패는 원인 미확인으로 남아 있으므로, 재발 시 로그를 수집하고 실행 진입 경로의 재현성을 확인한다.
2. 재시작한 Docker 컨테이너의 포트 매핑이 비었던 원인은 확인하지 못했다. 재발하면 `docker inspect`와 Docker Desktop 로그를 함께 수집한다.
3. 볼륨 백업·복원은 작은 샘플 데이터 기준이며 큰 데이터와 DB 일관성은 확인하지 않았다.
