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

\- 터미널에서 ubuntu 접속을 먼저 하고, Docker Desktop에서 WSL 연동(Setting -> Resources ->WSL integration ->  "Enable integration with my default WSL distro" 와 "Enable integration with additional distros:  Ubuntu"에 체크 -> Apply \& restart로 적용)하고 기존 접속을 계속 사용했기 때문



\### 해결

터미널 종료 후 다시 실행하여 접속.



\### 재검증

$ docker --version

docker info

docker run hello-world

Docker version 29.9.2, build a82e528

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



\### 현재 상태

해결 결과 확인.

