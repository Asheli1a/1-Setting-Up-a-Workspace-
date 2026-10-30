\# 트러블슈팅



\## 1. Docker 소켓 접근 권한 오류



\### 증상



```console

$ docker info

Client:

&#x20;Version: 29.9.2

...



Server:

permission denied while trying to connect to the docker API at unix:///var/run/docker.sock

```



위 출력은 오류와 관련된 부분만 발췌했다.



\### 원인

\- 현재 사용자에게 Docker 소켓 접근 권한이 없다.

\- 터미널에서 ubuntu 접속을 먼저 하고, Docker Desktop에서 WSL 연동(Setting -> Resources ->WSL integration ->  "Enable integration with my default WSL distro" 와 "Enable integration with additional distros:  Ubuntu"에 체크 -> Apply \& restart로 적용)하고 기존 접속을 계속 사용했기 때문(기존 세션에 연동 상태가 정상 반영되지 않았음)



\### 해결

터미널 종료 후 다시 실행하여 접속.



\### 재검증

```console

$ docker --version
Docker version 29.9.2, build a82e528


$ docker info

Client:

&#x20;Version:    29.9.2

&#x20;Context:    default

&#x20;Debug Mode: false

&#x20;Plugins:

&#x20; agent: Docker AI Agent Runner (Docker Inc.)

&#x20;   Version:  v1.152.0

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-agent

&#x20; ai: Docker AI Agent - Ask Gordon (Docker Inc.)

&#x20;   Version:  v1.33.0

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-ai

&#x20; buildx: Docker Buildx (Docker Inc.)

&#x20;   Version:  v0.38.1

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-buildx

&#x20; compose: Docker Compose (Docker Inc.)

&#x20;   Version:  v5.6.1

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-compose

&#x20; debug: Get a shell into any image or container (Docker Inc.)

&#x20;   Version:  0.49.0

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-debug

&#x20; desktop: Docker Desktop commands (Docker Inc.)

&#x20;   Version:  4.97.0

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-desktop

&#x20; dhi: CLI for managing Docker Hardened Images (Docker Inc.)

&#x20;   Version:  v0.0.9

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-dhi

&#x20; extension: Manages Docker extensions (Docker Inc.)

&#x20;   Version:  v0.2.32

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-extension

&#x20; init: Creates Docker-related starter files for your project (Docker Inc.)

&#x20;   Version:  v1.4.1

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-init

&#x20; mcp: Docker MCP Plugin (Docker Inc.)

&#x20;   Version:  v0.44.2

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-mcp

&#x20; model: Docker Model Runner (Docker Inc.)

&#x20;   Version:  v1.2.9

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-model

&#x20; offload: Docker Offload (Docker Inc.)

&#x20;   Version:  v0.7.21

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-offload

&#x20; pass: Docker Pass Secrets Manager Plugin (beta) (Docker Inc.)

&#x20;   Version:  v0.3.2

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-pass

&#x20; sandbox: "docker sandbox" is deprecated, use Docker Sandboxes instead (Docker Inc.)

&#x20;   Version:  v0.13.0

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-sandbox

&#x20; scout: Docker Scout (Docker Inc.)

&#x20;   Version:  v1.27.0

&#x20;   Path:     /usr/local/lib/docker/cli-plugins/docker-scout



Server:

&#x20;Containers: 0

&#x20; Running: 0

&#x20; Paused: 0

&#x20; Stopped: 0

&#x20;Images: 0

&#x20;Server Version: 29.9.2

&#x20;Storage Driver: overlayfs

&#x20; driver-type: io.containerd.snapshotter.v1

&#x20;Logging Driver: local

&#x20;Cgroup Driver: cgroupfs

&#x20;Cgroup Version: 2

&#x20;Plugins:

&#x20; Volume: local

&#x20; Network: bridge host ipvlan macvlan null overlay

&#x20; Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog

&#x20;CDI spec directories:

&#x20; /etc/cdi

&#x20; /var/run/cdi

&#x20;Discovered Devices:

&#x20; cdi: docker.com/gpu=webgpu

&#x20;Swarm: inactive

&#x20;Runtimes: io.containerd.runc.v2 nvidia runc

&#x20;Default Runtime: runc

&#x20;Init Binary: docker-init

&#x20;containerd version: b7a25261e029d68978bbf290df0a62fc819b3c51

&#x20;runc version: v1.5.2-0-g29dd3dc2

&#x20;init version: de40ad0

&#x20;Security Options:

&#x20; seccomp

&#x20;  Profile: builtin

&#x20; cgroupns

&#x20;Kernel Version: 6.18.54.1-microsoft-standard-WSL2

&#x20;Operating System: Docker Desktop

&#x20;OSType: linux

&#x20;Architecture: x86\_64

&#x20;CPUs: 8

&#x20;Total Memory: 7.605GiB

&#x20;Name: docker-desktop

&#x20;ID: debdbb45-0f13-4be0-a40e-3410badffff0

&#x20;Docker Root Dir: /var/lib/docker

&#x20;Debug Mode: false

&#x20;HTTP Proxy: http.docker.internal:3128

&#x20;HTTPS Proxy: http.docker.internal:3128

&#x20;No Proxy: hubproxy.docker.internal

&#x20;Labels:

&#x20; com.docker.desktop.address=unix:///var/run/docker-cli.sock

&#x20;Experimental: false

&#x20;Insecure Registries:

&#x20; hubproxy.docker.internal:5555

&#x20; 127.0.0.0/8

&#x20; ::1/128

&#x20;Live Restore Enabled: false

&#x20;Firewall Backend: iptables

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

&#x20;1. The Docker client contacted the Docker daemon.

&#x20;2. The Docker daemon pulled the "hello-world" image from the Docker Hub.

&#x20;   (amd64)

&#x20;3. The Docker daemon created a new container from that image which runs the

&#x20;   executable that produces the output you are currently reading.

&#x20;4. The Docker daemon streamed that output to the Docker client, which sent it

&#x20;   to your terminal.



To try something more ambitious, you can run an Ubuntu container with:

&#x20;$ docker run -it ubuntu bash



Share images, automate workflows, and more with a free Docker ID:

&#x20;https://hub.docker.com/



For more examples and ideas, visit:

&#x20;https://docs.docker.com/get-started/

```



\### 현재 상태

Docker 엔진 연결 및 hello-world 실행 성공을 확인했다.


## 2. GitHub HTTPS push 인증 실패



\### 증상



```console

$ git push -u origin main

remote: Invalid username or token. Password authentication is not supported for Git operations.

fatal: Authentication failed for '(https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git/)'

```



\### 원인

GitHub HTTPS Git 작업에서는 계정 비밀번호 인증을 사용할 수 없다.

Git 사용자 이름·이메일 설정과 원격 저장소 인증은 별개다.



\### 해결

GitHub CLI로 브라우저 인증을 완료하고 Git 인증 연동을 설정했다.



```bash

gh auth login --hostname github.com --git-protocol https --web

gh auth setup-git

```



\### 재검증



```console

$ gh auth setup-git

gh auth status

github.com

&#x20; ✓ Logged in to github.com account Asheli1a (/home/user/.config/gh/hosts.yml)

&#x20; - Active account: true

&#x20; - Git operations protocol: https

&#x20; - Token: gho\_\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

&#x20; - Token scopes: 'gist', 'read:org', 'repo', 'workflow'



$ git push -u origin main

Enumerating objects: 7, done.

Counting objects: 100% (7/7), done.

Delta compression using up to 8 threads

Compressing objects: 100% (6/6), done.

Writing objects: 100% (7/7), 5.50 KiB | 5.50 MiB/s, done.

Total 7 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)

To https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git

&#x20;\* \[new branch]      main -> main

branch 'main' set up to track 'origin/main'.



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
error: failed to push some refs to '[https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git)'
```

이후 `git pull`을 실행했지만, 분기된 브랜치의 통합 방식을 지정해야 한다는 메시지와 함께 중단됐다.

```console
$ git pull
From [https://github.com/Asheli1a/1-Setting-Up-a-Workspace-](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-)
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
To [https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git)
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
