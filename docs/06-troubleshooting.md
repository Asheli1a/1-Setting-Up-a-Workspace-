# 트러블슈팅

## 기록 원칙 및 요약

실제 발생한 문제 3건을 증상 → 원인 분석·확인 → 해결 → 재검증 순서로 기록했다. 원인 가설과 직접 확인한 사실은 구분한다.

| 번호 | 문제 | 확인된 해결 결과 |
|---|---|---|
| 1 | Docker 소켓 접근 거부 | WSL 연동 적용 후 터미널 재실행으로 엔진 연결·hello-world 성공 |
| 2 | GitHub HTTPS 인증 실패 | GitHub CLI 인증 후 push 성공 |
| 3 | 웹 업로드 후 브랜치 분기 | 파일 충돌 없는 자동 병합 후 push 성공 |

기존 파일에서 생긴 Markdown 이스케이프·HTML 공백 엔터티·코드블록 내부 링크 변환은 원래 로그 형태로 정리했다. 로그인 출력의 토큰은 마스킹 상태를 유지했다.

## 1. Docker 소켓 접근 권한 오류

### 증상

```console
$ docker info
Client:
 Version: 29.9.2
...
Server:
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

위 출력은 오류와 관련된 부분만 발췌했다.

### 원인 분석 및 확인 범위

- 확인된 증상: Docker CLI 정보는 출력됐지만 소켓 접근에서 `permission denied`가 발생했다.
- 수행 기록: Ubuntu 세션을 먼저 연 상태에서 Docker Desktop의 WSL Integration에서 기본 배포판 및 Ubuntu 연동을 활성화하고 적용했다. 기존 세션에서는 문제가 지속됐다.
- 해결 관찰: Ubuntu 터미널을 종료하고 다시 열자 엔진 연결과 hello-world 실행에 성공했다.
- 가설: 기존 세션에 연동 상태가 정상 반영되지 않았을 가능성이 있다.
- 미확인 사항: 소켓 소유권·그룹·권한 전후 값을 수집하지 않았으므로 특정 그룹 누락이나 내부 연동 갱신 원인을 확정하지 않는다.

### 해결

터미널 종료 후 다시 실행하여 접속.

### 재검증

```console
$ docker --version
Docker version 29.9.2, build a82e528

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
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
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

```console
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
4f55086f7dd0: Pull complete
d5e71e642bf5: Download complete
Digest: sha256:c567b231f65614688711a75f31518a064258a51d442117a3e771a3a8fdba78ef
Status: Downloaded newer image for hello-world:latest
Hello from Docker!
This message shows that your installation appears to be working correctly.
To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash
Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/
For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

### 현재 상태

Docker 엔진 연결 및 hello-world 실행 성공을 확인했다.

## 2. GitHub HTTPS push 인증 실패

### 증상

```console
$ git push -u origin main
remote: Invalid username or token. Password authentication is not supported for Git operations.
fatal: Authentication failed for 'https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git/'
```

### 원인

GitHub HTTPS Git 작업에서는 계정 비밀번호 인증을 사용할 수 없다.

Git 사용자 이름·이메일 설정과 원격 저장소 인증은 별개다.

### 해결

GitHub CLI로 브라우저 인증을 완료하고 Git 인증 연동을 설정했다.

```bash
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
```

### 재검증

```console
$ gh auth setup-git

$ gh auth status
github.com
  ✓ Logged in to github.com account Asheli1a (/home/user/.config/gh/hosts.yml)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'

$ git push -u origin main
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 8 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (7/7), 5.50 KiB | 5.50 MiB/s, done.
Total 7 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

### 현재 상태

해결 완료. GitHub CLI의 HTTPS 인증을 이용해 첫 push와 main 추적 설정에 성공했다.

### 보안 및 구분

- Git의 user.name/user.email은 작성자 정보이며 push 인증을 대신하지 않는다.
- 인증 코드·실제 토큰·인증 설정 파일 원문은 공개하지 않는다.
- 이 인증 성공은 VSCode GitHub 계정 로그인·연동 증거를 대신하지 않는다.

## 3. GitHub 웹 업로드 후 push 거부 및 브랜치 분기

### 증상

바인드 마운트 실습 중 브라우저 접속 증거 이미지를 윈도우상의 GitHub 웹에서 업로드한 뒤, 로컬에서 바인드 마운트 실습 문서를 커밋하고 push했다.
그러나 원격 변경을 먼저 가져와야 한다는 메시지와 함께 거부됐다.

```console
$ git commit -m "docs: record verified bind mount content updates"
[main f3cf6ff] docs: record verified bind mount content updates
 3 files changed, 250 insertions(+), 3 deletions(-)
 create mode 100644 cli-practice/bind-site/index.html

$ git push origin main
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git'
```

이후 `git pull`을 실행했지만, 분기된 브랜치의 통합 방식을 지정해야 한다는 메시지와 함께 중단됐다.

```console
$ git pull
From https://github.com/Asheli1a/1-Setting-Up-a-Workspace-
   10c69f3..c60296f  main       -> origin/main
hint: You have divergent branches and need to specify how to reconcile them.
fatal: Need to specify how to reconcile divergent branches.
```

출력은 오류와 관련된 부분만 발췌했다.

### 원인 가설

- GitHub 웹에서 이미지를 업로드하면서 원격 main에 새 커밋이 생겼다.
- 로컬에서도 별도의 문서 커밋을 만들어 양쪽 이력이 분기됐을 가능성이 있다.
- 처음에는 이미지 파일 충돌을 의심했지만, 실제 파일 충돌인지 이력 통합 문제인지 구분할 필요가 있었다.

### 확인

`git pull`은 원격 변경을 가져왔지만, merge 또는 rebase 방식이 지정되지 않아 통합을 수행하지 않았다.

이후 확인한 커밋 그래프에서는 공통 커밋 이후 로컬 문서 커밋과 원격 웹 업로드 커밋이 각각 존재했다.

```console
$ git log --oneline --graph --decorate -8
*   3576cc1 (HEAD -> main) Merge remote-tracking branch 'origin/main'
|\
| * c60296f (origin/main, origin/HEAD) Add files via upload
| * a9640de Add files via upload
| * 5d48f46 Add files via upload
* | f3cf6ff docs: record verified bind mount content updates
|/
* 10c69f3 _
* e0f55a9 docs: complete custom web image and dual-port verification
* b75be04 docs: record Docker operations and container lifecycle experiments
```

위 그래프는 병합 후, 최종 push 전에 확인한 결과다.

### 해결

로컬 문서 커밋과 원격 이미지 커밋을 모두 보존하기 위해 merge 방식으로 통합했다.

```console
$ git merge --no-edit origin/main
Merge made by the 'ort' strategy.
 docs/images/bind-after.png  | Bin 0 -> 35287 bytes
 docs/images/bind-before.png | Bin 0 -> 22995 bytes
 docs/images/web-8080.png    | Bin 0 -> 23626 bytes
 docs/images/web-8081.png    | Bin 0 -> 24641 bytes
 4 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 docs/images/bind-after.png
 create mode 100644 docs/images/bind-before.png
 create mode 100644 docs/images/web-8081.png
```

실제 파일 충돌 없이 자동 병합됐으며, 병합 커밋 `3576cc1`이 생성됐다.
강제 push나 기존 커밋 삭제는 사용하지 않았다.

### 재검증

원격에서 업로드한 이미지가 로컬에도 반영됐는지 확인했다.

```console
$ ls -l docs/images/
total 112
-rw-r--r-- 1 user user 35287 Oct 30 19:14 bind-after.png
-rw-r--r-- 1 user user 22995 Oct 30 19:14 bind-before.png
-rw-r--r-- 1 user user 23626 Oct 30 19:14 web-8080.png
-rw-r--r-- 1 user user 24641 Oct 30 19:14 web-8081.png
```

병합 결과를 GitHub에 push했다.

```console
$ git push origin main
To https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git
   c60296f..3576cc1  main -> main
```

push 출력은 핵심 부분만 발췌했다.

### 현재 상태

해결 완료.
로컬 문서 변경과 GitHub 웹 업로드 이미지를 통합하고, 병합 결과를 원격 main에 반영했다.

### 배운 점 및 재발 방지

- 이번 문제는 이미지 내용 충돌이 아니라, 원격과 로컬에서 각각 커밋하면서 발생한 브랜치 분기였다.
- push 거부와 실제 파일 병합 충돌을 구분해야 한다.
- `git pull`에서 통합 방식 지정 오류가 발생한 경우, 아직 파일 충돌이 발생했다고 단정할 수 없다.
- 앞으로는 캡처도 로컬의 docs/images에 저장하고, 관련 문서와 함께 커밋하는 방식으로 작업 흐름을 통일한다.
- GitHub 웹에서 직접 변경했다면 로컬 작업을 이어가기 전에 원격 변경을 확인하고 동기화한다.

## 4. 한계 및 추가 점검

- 사례 3은 실제 텍스트·이미지 병합 충돌을 해결한 사례가 아니다. 이력 분기를 merge 방식으로 통합한 사례다.
- 그래프의 `origin/main=c60296f` 표시는 병합 후 push 전 시점이며, 최종 push 출력은 `c60296f..3576cc1`이다.
- 당시의 미추적 폴더는 병합 충돌이 아니었으며, 전체를 무조건 추가하거나 삭제하지 않았다.
- 토큰 마스킹 로그를 확인했지만 저장소 전체 이력·모든 이미지에 대한 보안 검토가 끝났다는 뜻은 아니다.

[프로젝트 README](../README.md)
