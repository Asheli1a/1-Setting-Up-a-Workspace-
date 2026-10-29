\# Docker 설치 및 운영 실습



\## 실행 환경



\### 1. Windows 및 WSL



실행 위치: Windows PowerShell



```console

PS> Get-CimInstance Win32\_OperatingSystem | Select-Object Caption, Version, BuildNumber



Caption                  Version    BuildNumber

\-------                  -------    -----------

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

&#x20; NAME              STATE           VERSION

\* Ubuntu            Running         2

&#x20; docker-desktop    Running         2

```



\### 2. Ubuntu 및 쉘



실행 위치: WSL Ubuntu



```console

$ date -Iseconds

2026-10-29T17:06:52+09:00



$ cat /etc/os-release

PRETTY\_NAME="Ubuntu 26.04.1 LTS"

NAME="Ubuntu"

VERSION\_ID="26.04"

VERSION="26.04.1 LTS (Resolute Raccoon)"

VERSION\_CODENAME=resolute

ID=ubuntu

ID\_LIKE=debian

HOME\_URL="https://www.ubuntu.com/"

SUPPORT\_URL="https://help.ubuntu.com/"

BUG\_REPORT\_URL="https://bugs.launchpad.net/ubuntu/"

PRIVACY\_POLICY\_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"

UBUNTU\_CODENAME=resolute

LOGO=ubuntu-logo

user@4F-103:\~/dev-workstation$ uname -r

6.18.54.1-microsoft-standard-WSL2

user@4F-103:\~/dev-workstation$ ps -p $$ -o comm=

bash



$ uname -r

6.18.54.1-microsoft-standard-WSL2



$ ps -p $$ -o comm=

bash



$ printf 'Bash version: %s\\n' "$BASH\_VERSION"

Bash version: 5.3.9(1)-release

```



\### 3. Git



```console

$ git --version

git version 2.53.0

```



\### 4. Docker



```console

$ docker --version

Docker version 29.9.2, build a82e528



$ docker version

Client:

&#x20;Version:           29.9.2

&#x20;API version:       1.56

&#x20;Go version:        go1.26.10

&#x20;Git commit:        a82e528

&#x20;Built:             Tue Oct 20 18:44:02 2026

&#x20;OS/Arch:           linux/amd64

&#x20;Context:           default



Server: Docker Desktop 4.97.0 (244584)

&#x20;Engine:

&#x20; Version:          29.9.2

&#x20; API version:      1.56 (minimum version 1.40)

&#x20; Go version:       go1.26.10

&#x20; Git commit:       0367cbe

&#x20; Built:            Tue Oct 20 18:45:02 2026

&#x20; OS/Arch:          linux/amd64

&#x20; Experimental:     false

&#x20;containerd:

&#x20; Version:          v2.4.2

&#x20; GitCommit:        b7a25261e029d68978bbf290df0a62fc819b3c51

&#x20;runc:

&#x20; Version:          1.5.2

&#x20; GitCommit:        v1.5.2-0-g29dd3dc2

&#x20;docker-init:

&#x20; Version:          0.19.0

&#x20; GitCommit:        de40ad0



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

&#x20;Containers: 1

&#x20; Running: 0

&#x20; Paused: 0

&#x20; Stopped: 1

&#x20;Images: 1

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



\### 검증 결과



\- Ubuntu가 WSL 2로 실행 중임을 확인했다.

\- Ubuntu, 커널, Bash, Git 버전을 확인했다.

\- Docker Desktop, CLI, Engine 버전을 각각 확인했다.

\- docker version과 docker info에서 Server 정보가 정상 출력됐다.

\- 이번 점검에서는 Docker 소켓 접근 권한 오류가 발생하지 않았다.

