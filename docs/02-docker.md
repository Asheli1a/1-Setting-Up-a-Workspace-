# Docker 설치 및 운영 실습

## 실습 개요

Windows / WSL / Ubuntu / 쉘 / Git / Docker 환경을 확인하고, 이미지·컨테이너 운영 및 주 프로세스의 수명과 연결 세션의 차이를 관찰했다.

- 환경 점검: 2026-10-29 / Ubuntu 컨테이너 운영 실습: 2026-10-30
- 호스트 명령은 `$`, 컨테이너 내부 명령은 `root@...:/#`, PowerShell 명령은 `PS>`로 구분한다.
- 제목·코드에 잘못 적용된 이스케이프와 HTML 엔터티는 원래 표기로 정리했다. 상태·ID·버전은 당시 관찰값이다.
- 설치 절차 전체의 원시 로그는 제공되지 않았다. 아래는 설치 후 점검과 운영 검증이며, 설치 과정 전체를 새 실행 로그처럼 작성하지 않았다.

## 실행 환경

### 1. Windows 및 WSL

실행 위치: Windows PowerShell

```console
PS> Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber
Caption                  Version    BuildNumber
-------                  -------    -----------
Microsoft Windows 11 Pro 10.0.26300 26300

PS> wsl --version
WSL 버전: 3.0.3.0
커널 버전: 6.18.54.1-1
WSLg 버전: 1.0.79
MSRDC 버전: 1.2.7391
Direct3D 버전: 1.611.1-81528511
DXCore 버전: 10.0.26100.1-240331-1435.ge-release
Windows 버전: 10.0.26300.9711

PS> wsl -l -v
  NAME              STATE           VERSION
* Ubuntu            Running         2
  docker-desktop    Running         2
```

### 2. Ubuntu 및 쉘

실행 위치: WSL Ubuntu

```console
$ date -Iseconds
2026-10-29T17:06:52+09:00

$ cat /etc/os-release
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04.1 LTS (Resolute Raccoon)"
VERSION_CODENAME=resolute
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=resolute
LOGO=ubuntu-logo

$ uname -r
6.18.54.1-microsoft-standard-WSL2

$ ps -p $$ -o comm=
bash

$ printf 'Bash version: %s\n' "$BASH_VERSION"
Bash version: 5.3.9(1)-release
```

### 3. Git

```console
$ git --version
git version 2.53.0
```

### 4. Docker

```console
$ docker --version
Docker version 29.9.2, build a82e528

$ docker version
Client:
 Version:           29.9.2
 API version:       1.56
 Go version:        go1.26.10
 Git commit:        a82e528
 Built:             Tue Oct 20 18:44:02 2026
 OS/Arch:           linux/amd64
 Context:           default
Server: Docker Desktop 4.97.0 (244584)
 Engine:
  Version:          29.9.2
  API version:      1.56 (minimum version 1.40)
  Go version:       go1.26.10
  Git commit:       0367cbe
  Built:            Tue Oct 20 18:45:02 2026
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.4.2
  GitCommit:        b7a25261e029d68978bbf290df0a62fc819b3c51
 runc:
  Version:          1.5.2
  GitCommit:        v1.5.2-0-g29dd3dc2
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

$ docker info
Client:
 Version:    29.9.2
 Context:    default
 Debug Mode: false
 Plugins:
  agent: Docker AI Agent Runner (Docker Inc.)
    Version:  v1.152.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-agent
  ai: Docker AI Agent - Ask Gordon (Docker Inc.)
    Version:  v1.33.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-ai
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.38.1
    Path:     /usr/local/lib/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v5.6.1
    Path:     /usr/local/lib/docker/cli-plugins/docker-compose
  debug: Get a shell into any image or container (Docker Inc.)
    Version:  0.49.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-debug
  desktop: Docker Desktop commands (Docker Inc.)
    Version:  4.97.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-desktop
  dhi: CLI for managing Docker Hardened Images (Docker Inc.)
    Version:  v0.0.9
    Path:     /usr/local/lib/docker/cli-plugins/docker-dhi
  extension: Manages Docker extensions (Docker Inc.)
    Version:  v0.2.32
    Path:     /usr/local/lib/docker/cli-plugins/docker-extension
  init: Creates Docker-related starter files for your project (Docker Inc.)
    Version:  v1.4.1
    Path:     /usr/local/lib/docker/cli-plugins/docker-init
  mcp: Docker MCP Plugin (Docker Inc.)
    Version:  v0.44.2
    Path:     /usr/local/lib/docker/cli-plugins/docker-mcp
  model: Docker Model Runner (Docker Inc.)
    Version:  v1.2.9
    Path:     /usr/local/lib/docker/cli-plugins/docker-model
  offload: Docker Offload (Docker Inc.)
    Version:  v0.7.21
    Path:     /usr/local/lib/docker/cli-plugins/docker-offload
  pass: Docker Pass Secrets Manager Plugin (beta) (Docker Inc.)
    Version:  v0.3.2
    Path:     /usr/local/lib/docker/cli-plugins/docker-pass
  sandbox: "docker sandbox" is deprecated, use Docker Sandboxes instead (Docker Inc.)
    Version:  v0.13.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-sandbox
  scout: Docker Scout (Docker Inc.)
    Version:  v1.27.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-scout
Server:
 Containers: 1
  Running: 0
  Paused: 0
  Stopped: 1
 Images: 1
 Server Version: 29.9.2
 Storage Driver: overlayfs
  driver-type: io.containerd.snapshotter.v1
 Logging Driver: local
 Cgroup Driver: cgroupfs
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 CDI spec directories:
  /etc/cdi
  /var/run/cdi
 Discovered Devices:
  cdi: docker.com/gpu=webgpu
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 nvidia runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: b7a25261e029d68978bbf290df0a62fc819b3c51
 runc version: v1.5.2-0-g29dd3dc2
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 6.18.54.1-microsoft-standard-WSL2
 Operating System: Docker Desktop
 OSType: linux
 Architecture: x86_64
 CPUs: 8
 Total Memory: 7.605GiB
 Name: docker-desktop
 ID: debdbb45-0f13-4be0-a40e-3410badffff0
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 HTTP Proxy: http.docker.internal:3128
 HTTPS Proxy: http.docker.internal:3128
 No Proxy: hubproxy.docker.internal
 Labels:
  com.docker.desktop.address=unix:///var/run/docker-cli.sock
 Experimental: false
 Insecure Registries:
  hubproxy.docker.internal:5555
  127.0.0.0/8
  ::1/128
 Live Restore Enabled: false
 Firewall Backend: iptables
```

### 검증 결과

- Ubuntu가 WSL 2로 실행 중임을 확인했다.

- Ubuntu, 커널, Bash, Git 버전을 확인했다.

- Docker Desktop, CLI, Engine 버전을 각각 확인했다.

- docker version과 docker info에서 Server 정보가 정상 출력됐다.

- 이번 점검에서는 Docker 소켓 접근 권한 오류가 발생하지 않았다.

## hello-world 실행 검증

초기 Docker 소켓 오류 해결 후 수행한 실제 기록을 [트러블슈팅 사례 1](06-troubleshooting.md#1-docker-소켓-접근-권한-오류)에서 핵심 부분만 발췌했다. 아래 생략 표시는 편집 표시다.

```console
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
[이미지 다운로드 진행 출력 생략]
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
[안내 문구 생략]
```

Docker 엔진 연결뿐 아니라 이미지 다운로드와 테스트 컨테이너 실행까지 성공했다.

## 이미지 다운로드 및 목록 확인
```console
$ cd ~/dev-workstation

$ docker pull ubuntu:latest
latest: Pulling from library/ubuntu
f3f25b84a7d7: Pull complete
edafa32f5d9e: Pull complete
21594acc2d8b: Download complete
Digest: sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest

$ docker images
                                                                                                    i Info →   U  In Use
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
hello-world:latest   c567b231f656       25.9kB         9.49kB    U
ubuntu:latest        6a06111c3b0a        163MB         45.9MB
```
### 확인 결과

- `docker pull ubuntu:latest`로 Ubuntu 이미지를 다운로드했다.
- `docker images`에서 다운로드한 이미지가 목록에 표시되는 것을 확인했다.
- 이미지 태그: `ubuntu:latest`
- 표시된 IMAGE ID: `6a06111c3b0a`

## 컨테이너 생성 및 실행 상태 확인

실행 위치: `~/dev-workstation`

### 실행 전 전체 목록

```console
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED        STATUS                    PORTS     NAMES
c83798db7dd1   hello-world   "/hello"   25 hours ago   Exited (0) 25 hours ago             ecstatic_shamir
```

### Ubuntu 컨테이너 생성 및 실행

```console
$ docker run -dit --name workspace-ubuntu ubuntu:latest bash
ba7726aba893153beaea19989fd6393f536eafe26818902f0e40d4b0d2066a7a
```

### 실행 중인 컨테이너 확인

```console
$ docker ps
CONTAINER ID   IMAGE           COMMAND   CREATED                  STATUS                  PORTS     NAMES
ba7726aba893   ubuntu:latest   "bash"    Less than a second ago   Up Less than a second             workspace-ubuntu
```

### 전체 컨테이너 확인

```console
$ docker ps -a
CONTAINER ID   IMAGE           COMMAND    CREATED                  STATUS                    PORTS     NAMES
ba7726aba893   ubuntu:latest   "bash"     Less than a second ago   Up Less than a second               workspace-ubuntu
c83798db7dd1   hello-world     "/hello"   25 hours ago             Exited (0) 25 hours ago             ecstatic_shamir
```

### 확인 결과

- `ubuntu:latest` 이미지로 `workspace-ubuntu` 컨테이너를 생성했다.
- 컨테이너에서 실행한 명령은 `bash`다.
- `docker ps`의 `Up` 상태로 실행 중임을 확인했다.
- `docker ps -a`에서는 실행 중인 Ubuntu뿐 아니라 종료된 hello-world도 확인했다.

## exec를 통한 내부 명령 실행
```console
$ cd ~/dev-workstation

$ pwd
/home/user/dev-workstation

$ docker exec -it workspace-ubuntu bash
root@ba7726aba893:/# whoami
root
root@ba7726aba893:/# pwd
/
root@ba7726aba893:/# cat /etc/os-release
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04.1 LTS (Resolute Raccoon)"
VERSION_CODENAME=resolute
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=resolute
LOGO=ubuntu-logo
root@ba7726aba893:/# ls /
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@ba7726aba893:/# echo "Hello from the Ubuntu container"
Hello from the Ubuntu container
root@ba7726aba893:/# exit
exit

$ docker ps --filter name=workspace-ubuntu
CONTAINER ID   IMAGE           COMMAND   CREATED         STATUS         PORTS     NAMES
ba7726aba893   ubuntu:latest   "bash"    7 minutes ago   Up 7 minutes             workspace-ubuntu

$ pwd
/home/user/dev-workstation
```
### 확인 결과

- `docker exec -it workspace-ubuntu bash`로 실행 중인 컨테이너에 별도의 Bash 세션을 열었다.
- 컨테이너 내부 사용자는 `root`, 작업 디렉터리는 `/`였다.
- `/etc/os-release`에서 컨테이너의 배포판이
  Ubuntu 26.04.1 LTS임을 확인했다.
- `ls /`와 `echo`로 내부 명령 실행을 확인했다.
- `exit` 후 호스트의 Ubuntu 터미널로 돌아왔다.
- 이후 `docker ps`에서 `workspace-ubuntu`가 `Up` 상태임을 확인했다.
- 따라서 이번 구성에서는 exec로 실행한 Bash 종료가 컨테이너 종료로 이어지지 않았다.

## attach와 연결 분리
```console
$ cd ~/dev-workstation

$ pwd
/home/user/dev-workstation

$ docker attach workspace-ubuntu
root@ba7726aba893:/# echo "Message from the main container shell"
Message from the main container shell
root@ba7726aba893:/# printf 'Main shell PID: %s\n' "$$"
Main shell PID: 1
root@ba7726aba893:/# read escape sequence

$ docker ps --filter name=workspace-ubuntu
CONTAINER ID   IMAGE           COMMAND   CREATED          STATUS          PORTS     NAMES
ba7726aba893   ubuntu:latest   "bash"    22 minutes ago   Up 22 minutes             workspace-ubuntu

$ pwd
/home/user/dev-workstation
```
### 수행 방법

- `docker attach workspace-ubuntu`로 컨테이너의 주 Bash에 연결했다.
- 문자열을 출력하고 `$$`로 현재 Bash의 PID를 확인했다.
- `Ctrl+P` 다음 `Ctrl+Q`를 눌러 연결을 분리했다.(로그에서 'read escape sequence'가 출력된 부분)
- 호스트로 돌아온 뒤 `docker ps`로 컨테이너 상태를 확인했다.

### 확인 결과

- 현재 Bash의 PID가 `1`로 출력됐다.
- 연결 분리 후 호스트의 Ubuntu 터미널로 돌아왔다.
- `workspace-ubuntu`는 `Up 22 minutes` 상태였다.
- 따라서 이번 연결 분리는 주 Bash나 컨테이너를 종료하지 않았다.

## 로그 및 리소스 확인

실행 위치: `~/dev-workstation`

### 로그 확인

```console
$ docker logs --tail 30 workspace-ubuntu
root@ba7726aba893:/# echo "Message from the main container shell"
Message from the main container shell
root@ba7726aba893:/# printf 'Main shell PID: %s\n' "$$"
Main shell PID: 1
```

### 리소스 확인

```console
$ docker stats --no-stream workspace-ubuntu
CONTAINER ID   NAME               CPU %     MEM USAGE / LIMIT     MEM %     NET I/O        BLOCK I/O        PIDS
ba7726aba893   workspace-ubuntu   0.00%     9.543MiB / 7.605GiB   0.12%     1.7kB / 126B   19.5MB / 4.1kB   1
```

### 확인 결과

- 주 Bash에서 실행한 명령과 출력이 컨테이너 로그에 남아 있음을 확인했다.
- `docker stats --no-stream`으로 리소스 정보를 확인했다.
- 측정 시 표시된 CPU 사용률은 0.00%, 메모리 사용량은 9.543MiB였다. 표시 정밀도와 반올림·버림 방식은 별도로 확인하지 않았다.
- 수치는 이번 실습에서 측정한 시점의 결과다.

## 중지 및 재시작
```console
$ cd ~/dev-workstation

$ pwd
/home/user/dev-workstation

$ docker stop workspace-ubuntu
workspace-ubuntu

$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker ps -a
CONTAINER ID   IMAGE           COMMAND    CREATED          STATUS                       PORTS     NAMES
ba7726aba893   ubuntu:latest   "bash"     33 minutes ago   Exited (137) 8 seconds ago             workspace-ubuntu
c83798db7dd1   hello-world     "/hello"   26 hours ago     Exited (0) 26 hours ago                ecstatic_shamir

$ docker start workspace-ubuntu
workspace-ubuntu

$ docker ps --filter name=workspace-ubuntu
CONTAINER ID   IMAGE           COMMAND   CREATED          STATUS         PORTS     NAMES
ba7726aba893   ubuntu:latest   "bash"    34 minutes ago   Up 4 seconds             workspace-ubuntu

$ pwd
/home/user/dev-workstation
```
### 확인 결과

- `docker stop workspace-ubuntu`로 컨테이너를 중지했다.
- 중지 후 `docker ps`에는 해당 컨테이너가 표시되지 않았다.
- `docker ps -a`에서는 `Exited (137)` 상태로 확인됐다.
- `docker start workspace-ubuntu`로 다시 시작했다.
- 재시작 후 `Up 4 seconds` 상태를 확인했다.
- 컨테이너 ID가 `ba7726aba893`으로 동일하여, 새로 생성한 것이 아니라 기존 컨테이너를 재시작했음을 확인했다.

### 종료 코드 관찰

종료 코드는 137이었다. Docker 문서상 SIGKILL에 의한 종료에 해당한다.(docker stop은 기본적으로 먼저 SIGTERM을 보내고, 유예 시간 안에 종료되지 않으면 SIGKILL로 강제 종료한다.)
이번에는 docker stop 과정에서 주 프로세스가 유예 시간 내 종료되지 않아 강제 종료됐을 가능성이 있으나, 신호 처리 과정 자체를 추가 검증하지는 않았다.

## 주 프로세스 종료와 컨테이너 상태
```console
$ pwd
/home/user/dev-workstation

$ docker attach workspace-ubuntu
root@ba7726aba893:/# echo "Exiting the main shell"
Exiting the main shell
root@ba7726aba893:/# exit
exit

$ docker ps --filter name=workspace-ubuntu
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker ps -a --filter name=workspace-ubuntu
CONTAINER ID   IMAGE           COMMAND   CREATED          STATUS                      PORTS     NAMES
ba7726aba893   ubuntu:latest   "bash"    42 minutes ago   Exited (0) 10 seconds ago             workspace-ubuntu

$ docker logs --tail 30 workspace-ubuntu
root@ba7726aba893:/# echo "Message from the main container shell"
Message from the main container shell
root@ba7726aba893:/# printf 'Main shell PID: %s\n' "$$"
Main shell PID: 1
root@ba7726aba893:/# echo "Exiting the main shell"
Exiting the main shell
root@ba7726aba893:/# exit
exit

$ pwd
/home/user/dev-workstation
```

### 확인 결과

- `docker attach workspace-ubuntu`로 컨테이너의 주 Bash에 연결했다.
- 메시지를 출력한 뒤 `exit`로 주 Bash를 종료했다.
- 호스트로 돌아온 후 `docker ps`에서는 해당 컨테이너가 표시되지 않았다.
- `docker ps -a`에서는 `Exited (0)` 상태로 확인됐다.
- `docker logs`에서 종료 전 메시지와 `exit` 기록을 확인했다.
- 컨테이너는 삭제되지 않고 종료 상태로 남아 있었다.

### 종료·분리 방식 비교

| 실험 | 수행 방법 | 실제 관찰 결과 |
|---|---|---|
| 별도 Bash 종료 | `docker exec -it workspace-ubuntu bash`로 들어간 뒤 `exit` | 컨테이너 실행 유지 |
| 주 Bash 연결 분리 | `docker attach` 후 `Ctrl+P`, `Ctrl+Q` | 컨테이너 실행 유지 |
| Docker 중지 명령 | `docker stop workspace-ubuntu` | `Exited (137)` |
| 주 Bash 직접 종료 | `docker attach` 후 `exit` | `Exited (0)` |

### 해석

- exec로 추가 실행한 Bash를 종료하는 것과 컨테이너의 주 Bash를 종료하는 것은 다르다.
- 연결 분리는 주 프로세스를 종료하지 않는다.
- 이번 구성에서는 주 Bash가 종료되면 컨테이너도 종료됐다.
- stop 이후에는 같은 컨테이너를 start로 다시 실행할 수 있었다.

## 검증 요약 및 재현 주의사항

| 항목 | 관찰 결과 |
|---|---|
| WSL 소프트웨어 버전 | 3.0.3.0 |
| Ubuntu 배포판 실행 방식 | WSL 2 — 소프트웨어 버전의 3과 구분 |
| Docker Desktop / CLI / Engine | 4.97.0 / 29.9.2 / 29.9.2 |
| hello-world | 실행 성공 |
| 이미지 다운로드·목록 | ubuntu:latest / 당시 표시 ID 6a06111c3b0a |
| 컨테이너 주 프로세스 | workspace-ubuntu의 bash / PID 1 |
| exec Bash에서 exit | 주 프로세스 유지, 컨테이너 Up |
| attach 후 분리 키 | 연결만 분리, 컨테이너 Up |
| stop 및 start | Exited (137) 후 동일 ID로 Up |
| 주 Bash에서 exit | Exited (0) |
| 로그·리소스 | 주 Bash 출력 및 측정 시 CPU 0.00%, 메모리 9.543MiB |

- WSL Ubuntu의 배포판 버전과 컨테이너 내부 Ubuntu 버전은 각각 확인했다. 이번에는 같았지만 서로 다른 실행 환경이다.
- `docker info`의 CPU·메모리 값은 Docker 엔진이 보는 자원이며, PC 전체의 물리 사양을 확정하는 값으로 사용하지 않는다.
- `read escape sequence`는 연결 분리 과정의 표시이며 직접 입력한 셸 명령이 아니다.
- `Exited (137)`은 SIGKILL에 의한 종료와 부합한다. stop 유예 시간 후 강제 종료 가능성은 있지만 당시 신호·이벤트/OOM 자료는 수집하지 않았으므로 구체 원인은 단정하지 않는다.
- `Exited (0)`은 주 Bash가 정상 종료 코드를 반환한 관찰 결과다.
- 같은 컨테이너 이름이 있으면 새로 run하기 전에 상태를 확인한다. 기존 컨테이너를 임의로 삭제하지 않는다.
- 기록된 리소스·실행 시간·이미지 ID는 역사적 관찰값이며 현재 상태나 재실행 결과가 같다는 보장은 없다.

[웹 이미지 제작](03-web.md) · [스토리지 실험](04-storage.md) · [트러블슈팅](06-troubleshooting.md) · [프로젝트 README](../README.md)
