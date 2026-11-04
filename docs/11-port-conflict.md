# 포트 충돌 검증

## 목적과 범위

호스트 포트가 이미 사용 중일 때 어떤 일이 생기는지 두 환경에서 재현하고, 점유자를 찾아 해제한 뒤 같은 포트를 다시 쓰는 과정을 기록한다.

- 수행 일자: 2026-11-04 15:21~15:30 (KST), 초기화된 공용 노트북
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- 1부: Python HTTP 서버 두 개, `127.0.0.1:18085`
- 2부: Docker 컨테이너 두 개, `127.0.0.1:18086`
- 아래 로그는 모두 이날 터미널에서 실제로 실행한 명령과 출력이다. 붙여 넣을 때 빠진 줄바꿈 `\`는 실행 가능한 형태로 고쳐 적었고, 프롬프트는 `$`로 정리했다.

2026-11-03에 다른 공용 노트북(`4F-43`)에서 같은 실습을 한 번 했다. 그때 Docker에서 관찰한 포트 매핑 누락이 이번 재실습에서도 다시 나타났다. 1차 관찰은 [트러블슈팅 사례 8](06-troubleshooting.md#8-중지-후-다시-시작한-docker-컨테이너의-포트-매핑이-비어-있음)에 함께 정리했다.

## 실습 환경

| 항목 | 내용 |
|---|---|
| 호스트 | 공용 노트북 `5F-85` (이전 `4F-43`과 다른 장비) |
| 커널 | `6.18.54.1-microsoft-standard-WSL2` |
| 배포판 | Ubuntu 26.04.1 LTS |
| 도구 | Python 3.14.4, Git 2.53.0, `ss`, `ps`, `curl`, `lsof`, `fuser` |
| Docker | Client 29.9.2 / Server 29.9.2, Docker Desktop, Compose v5.6.1 |
| 시작 상태 | 컨테이너 0개, 볼륨 0개, 18085·18086 리스닝 항목 없음 |
| 저장소 | HTTPS로 새로 clone (`6e6796f`), 이 저장소에만 `--local`로 이름·이메일 설정 |

기존 컨테이너가 없어서 건드릴 공용 컨테이너는 없었다. 이전 장비의 SSH 키는 쓰지 않았다.

## 1부. Python 서버 포트 충돌

실습용 `site/index.html`만 제공하도록 `--directory`를 지정하고, `127.0.0.1`에만 묶었다.

### 첫 서버 실행과 점유자 확인

```console
$ python3 -u -m http.server 18085 \
    --bind 127.0.0.1 \
    --directory "$lab/site" \
    > "$first_log" 2>&1 &
[1] 1416

$ printf 'shell_pid=%s\nserver_pid=%s\nrun_id=%s\n' "$$" "$server_pid" "$run_id"
shell_pid=665
server_pid=1416
run_id=20261104-152141
```

점유자를 `ps`, `ss`, `lsof`, `fuser`로 각각 확인했다.

```console
$ ps -ww -p "$server_pid" -o pid,ppid,user,args
    PID    PPID USER     COMMAND
   1416     665 user     python3 -u -m http.server 18085 --bind 127.0.0.1 --directory /home/user/dev-workstation/cli-practice/port-conflict/site

$ ss -ltnp '( sport = :18085 )'
State     Recv-Q    Send-Q       Local Address:Port          Peer Address:Port    Process
LISTEN    0         5                127.0.0.1:18085              0.0.0.0:*        users:(("python3",pid=1416,fd=3))

$ lsof -nP -iTCP:18085 -sTCP:LISTEN
COMMAND  PID USER FD   TYPE DEVICE SIZE/OFF NODE NAME
python3 1416 user 3u  IPv4  25454      0t0  TCP 127.0.0.1:18085 (LISTEN)

$ fuser -v 18085/tcp
                     USER        PID ACCESS COMMAND
18085/tcp:           user       1416 F.... python3

$ curl --max-time 5 -i http://127.0.0.1:18085/
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.14.4
Date: Wed, 04 Nov 2026 06:21:52 GMT
Content-type: text/html
Content-Length: 108
Last-Modified: Wed, 04 Nov 2026 06:21:41 GMT

<!doctype html>
<html lang="en">
<body><h1>Port conflict verification</h1><p>version: v1</p></body>
</html>
```

네 도구가 모두 PID 1416을 가리켰고, 부모 PID 665는 현재 셸이다.

### 같은 포트로 두 번째 서버 실행 (충돌)

```console
$ python3 -u -m http.server 18085 \
    --bind 127.0.0.1 \
    --directory "$lab/site" \
    > "$second_log" 2>&1
$ conflict_exit=$?
$ printf 'second_server_exit=%s\n' "$conflict_exit"
second_server_exit=1

$ cat "$second_log"
Traceback (most recent call last):
  ...
  File "/usr/lib/python3.14/socketserver.py", line 478, in server_bind
    self.socket.bind(self.server_address)
    ~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^
OSError: [Errno 98] Address already in use
```

traceback 중간의 호출 줄은 생략했다. 충돌 뒤에도 `ps`, `ss`, `curl`에서 첫 서버(PID 1416)가 그대로 리스닝하고 HTTP 200을 반환했다.

### 확인한 PID만 종료

이름이 `python3`라는 이유로 종료하지 않았다. 실행 명령 전체와 부모 PID가 방금 만든 서버와 같을 때만 SIGTERM을 보냈다.

```console
$ expected_cmd="python3 -u -m http.server 18085 --bind 127.0.0.1 --directory $lab/site"
$ actual_cmd="$(ps -ww -p "$server_pid" -o args=)"
$ actual_ppid="$(ps -p "$server_pid" -o ppid= | tr -d '[:space:]')"

$ if [ "$actual_cmd" = "$expected_cmd" ] && [ "$actual_ppid" = "$$" ]; then
>   kill -TERM "$server_pid" && wait "$server_pid"
> fi
[1]+  Terminated                 python3 -u -m http.server 18085 --bind 127.0.0.1 --directory "$lab/site" > "$first_log" 2>&1
first_server_wait_exit=143
```

143은 SIGTERM(15)로 끝난 프로세스의 값(128+15)이고, 의도한 종료라 장애로 보지 않았다.

### 포트 해제 확인과 같은 포트 재사용

```console
$ ps -p "$server_pid" -o pid,ppid,user,args
    PID    PPID USER     COMMAND
$ ss -ltnp '( sport = :18085 )'
State        Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
$ lsof -nP -iTCP:18085 -sTCP:LISTEN
$ fuser -v 18085/tcp
$ curl --max-time 5 -i http://127.0.0.1:18085/
curl: (7) Failed to connect to 127.0.0.1 port 18085 after 0 ms: Could not connect to server
```

```console
$ python3 -u -m http.server 18085 \
    --bind 127.0.0.1 \
    --directory "$lab/site" \
    > "$reuse_log" 2>&1 &
[1] 1689

$ ps -ww -p "$reuse_pid" -o pid,ppid,user,args
    PID    PPID USER     COMMAND
   1689     665 user     python3 -u -m http.server 18085 --bind 127.0.0.1 --directory /home/user/dev-workstation/cli-practice/port-conflict/site

$ ss -ltnp '( sport = :18085 )'
LISTEN    0         5                127.0.0.1:18085              0.0.0.0:*        users:(("python3",pid=1689,fd=3))

$ curl --max-time 5 -i http://127.0.0.1:18085/
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.14.4
Content-Length: 108
```

재사용한 서버도 같은 방식으로 종료했고(`reuse_server_wait_exit=143`), 이후 `ps`와 `ss`에 항목이 없었다.

| 단계 | 결과 |
|---|---|
| 점유자 확인 | `ps`, `ss`, `lsof`, `fuser`가 모두 PID 1416 |
| 충돌 | 두 번째 서버 종료 코드 1, `OSError: [Errno 98] Address already in use` |
| 종료 | 확인한 PID에만 SIGTERM, `wait` 143 |
| 해제 | 모든 도구에서 항목 없음, `curl` 연결 실패 |
| 재사용 | 새 PID 1689, HTTP 200 |

`killall`, `pkill`, `kill -9`는 쓰지 않았다.

## 2부. Docker 컨테이너 포트 충돌

이미지를 먼저 받아서 다운로드 출력이 충돌 출력과 섞이지 않게 했다.

```console
$ docker pull nginx:alpine
alpine: Pulling from library/nginx
...
Digest: sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
Status: Downloaded newer image for nginx:alpine

$ docker image ls nginx:alpine
IMAGE          ID             DISK USAGE   CONTENT SIZE   EXTRA
nginx:alpine   785835ea65db       94.5MB         27.2MB
```

실습 때마다 라벨을 붙여 다른 컨테이너와 구분했다.

- 실습 식별자: `20261104-152602-665` (끝의 665는 셸 PID)
- 점유 컨테이너: `workspace-port-owner-20261104-152602-665`
- 충돌 컨테이너: `workspace-port-retry-20261104-152602-665`
- 라벨: `com.asheli1a.port-run=20261104-152602-665`

### 점유 컨테이너 실행

```console
$ docker run -d \
    --name "$port_owner" \
    --label "com.asheli1a.port-run=$port_run" \
    -p 127.0.0.1:18086:80 \
    nginx:alpine
9f6ae0b9c59603b20769ca5d6b03d8f74f19ec1a41e5519b4a6c246a82e376ec

$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE          COMMAND                  CREATED                  STATUS                  PORTS                     NAMES
9f6ae0b9c596   nginx:alpine   "/docker-entrypoint.…"   Less than a second ago   Up Less than a second   127.0.0.1:18086->80/tcp   workspace-port-owner-20261104-152602-665

$ docker port "$port_owner"
80/tcp -> 127.0.0.1:18086

$ ss -ltnp '( sport = :18086 )'
State        Recv-Q        Send-Q               Local Address:Port                Peer Address:Port       Process
LISTEN       0             4096                     127.0.0.1:18086                    0.0.0.0:*

$ curl --max-time 5 -I http://localhost:18086/
HTTP/1.1 200 OK
Server: nginx/1.31.8
```

`ss`의 Process 열이 비어 있다. Python 서버와 달리 Docker 포트는 `ss`로 프로세스를 알 수 없어서, Docker 컨테이너가 점유한 포트는 `docker ps`, `docker port`로 식별했다.

### 같은 포트로 두 번째 컨테이너 실행 (충돌)

```console
$ docker run -d \
    --name "$port_retry" \
    --label "com.asheli1a.port-run=$port_run" \
    -p 127.0.0.1:18086:80 \
    nginx:alpine
b825b5e5bc24bbc7d50b30535f2bc04565be1ddac29aa1b286bcc1df0a1b6679
docker: Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint workspace-port-retry-20261104-152602-665 (738caeffed49313c268cc7d6eeee813c1f96a8ea9c306c0e692f2f1f563a5e7d): Bind for 127.0.0.1:18086 failed: port is already allocated

Run 'docker run --help' for more information
$ docker_conflict_exit=$?
$ printf 'docker_conflict_exit=%s\n' "$docker_conflict_exit"
docker_conflict_exit=125

$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                     NAMES
b825b5e5bc24   nginx:alpine   "/docker-entrypoint.…"   1 second ago    Created                                  workspace-port-retry-20261104-152602-665
9f6ae0b9c596   nginx:alpine   "/docker-entrypoint.…"   6 seconds ago   Up 5 seconds   127.0.0.1:18086->80/tcp   workspace-port-owner-20261104-152602-665

$ docker port "$port_retry"

$ curl --max-time 5 -I http://localhost:18086/
HTTP/1.1 200 OK
Server: nginx/1.31.8
```

두 번째 컨테이너는 만들어지긴 했지만 시작하지 못하고 `Created`로 남았다. 첫 컨테이너는 계속 응답했다. 실패한 컨테이너가 이미 생겼으므로 같은 이름으로 `docker run`을 반복하지 않았다.

### 점유 컨테이너 중지 후 기존 컨테이너 시작

라벨이 맞을 때만 owner를 중지했고, 그 뒤 `Created`에 머문 retry를 `docker start`로 시작했다.

```console
$ docker stop "$port_owner"
workspace-port-owner-20261104-152602-665

$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS                              PORTS     NAMES
b825b5e5bc24   nginx:alpine   "/docker-entrypoint.…"   39 seconds ago   Created                                       workspace-port-retry-20261104-152602-665
9f6ae0b9c596   nginx:alpine   "/docker-entrypoint.…"   44 seconds ago   Exited (0) Less than a second ago             workspace-port-owner-20261104-152602-665

$ ss -ltnp '( sport = :18086 )'
State        Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
$ curl --max-time 5 -I http://localhost:18086/
curl: (7) Failed to connect to localhost port 18086 after 0 ms: Could not connect to server

$ docker start "$port_retry"
workspace-port-retry-20261104-152602-665
```

### 예상과 다른 관찰: 매핑이 비어 있음

```console
$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS                      PORTS     NAMES
b825b5e5bc24   nginx:alpine   "/docker-entrypoint.…"   59 seconds ago       Up 8 seconds                80/tcp    workspace-port-retry-20261104-152602-665
9f6ae0b9c596   nginx:alpine   "/docker-entrypoint.…"   About a minute ago   Exited (0) 21 seconds ago             workspace-port-owner-20261104-152602-665

$ docker port "$port_retry"

$ docker inspect "$port_retry" --format 'State={{.State.Status}}'
State=running
$ docker inspect "$port_retry" --format 'RequestedBindings={{json .HostConfig.PortBindings}}'
RequestedBindings={"80/tcp":[{"HostIp":"127.0.0.1","HostPort":"18086"}]}
$ docker inspect "$port_retry" --format 'CurrentPorts={{json .NetworkSettings.Ports}}'
CurrentPorts={"80/tcp":[]}

$ ss -ltnp '( sport = :18086 )'
State        Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
$ curl --max-time 5 -I http://localhost:18086/
curl: (7) Failed to connect to localhost port 18086 after 0 ms: Could not connect to server

$ sleep 8
$ docker inspect "$port_retry" --format 'CurrentPorts={{json .NetworkSettings.Ports}}'
CurrentPorts={"80/tcp":[]}
$ curl --max-time 5 -I http://localhost:18086/
curl: (7) Failed to connect to localhost port 18086 after 0 ms: Could not connect to server
```

`running`이고 요청한 바인딩(`RequestedBindings`)은 남아 있는데, 실제 매핑(`CurrentPorts`)은 비어 있었다. 8초를 더 기다려도 같았다. 2026-11-03 첫 실습에서도 같은 현상이 있었으니 두 번째 재현이다.

### 원인을 좁히는 실험

한 번도 실패하지 않은 owner를 다시 시작하면 매핑이 돌아오는지 비교했다.

```console
$ docker start "$port_owner"
$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS              PORTS                     NAMES
b825b5e5bc24   nginx:alpine   "/docker-entrypoint.…"   2 minutes ago   Up About a minute   80/tcp                    workspace-port-retry-20261104-152602-665
9f6ae0b9c596   nginx:alpine   "/docker-entrypoint.…"   2 minutes ago   Up 2 seconds        127.0.0.1:18086->80/tcp   workspace-port-owner-20261104-152602-665

$ docker inspect "$port_owner" --format 'CurrentPorts={{json .NetworkSettings.Ports}}'
CurrentPorts={"80/tcp":[{"HostIp":"127.0.0.1","HostPort":"18086"}]}
$ curl --max-time 5 -I http://localhost:18086/
HTTP/1.1 200 OK
```

그다음 owner를 중지해 포트를 비운 뒤 retry를 한 번 더 중지·시작했다.

```console
$ docker stop "$port_owner"
$ docker stop "$port_retry"
$ docker start "$port_retry"
$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS                     PORTS     NAMES
b825b5e5bc24   nginx:alpine   "/docker-entrypoint.…"   2 minutes ago   Up 2 seconds               80/tcp    workspace-port-retry-20261104-152602-665
9f6ae0b9c596   nginx:alpine   "/docker-entrypoint.…"   2 minutes ago   Exited (0) 2 seconds ago             workspace-port-owner-20261104-152602-665

$ docker inspect "$port_retry" --format 'CurrentPorts={{json .NetworkSettings.Ports}}'
CurrentPorts={"80/tcp":[]}
$ curl --max-time 5 -I http://localhost:18086/
curl: (7) Failed to connect to localhost port 18086 after 0 ms: Could not connect to server
```

| 실험 | 결과 | 해석 |
|---|---|---|
| 한 번도 실패하지 않은 owner를 중지 후 start | 매핑 복구, HTTP 200 | 중지 후 start만으로는 매핑이 사라지지 않음 |
| 처음 시작이 충돌로 실패한 retry를 start (포트는 비어 있음) | 매핑 없음 | 포트가 비어도 매핑을 얻지 못함 |
| retry를 한 번 더 중지·start | 여전히 매핑 없음 | 상태가 이어짐 |

이 환경에서 관찰한 범위의 결과다. 원인은 확인하지 못했고, Docker 내부 문제라고 단정하지 않는다.

### 복구와 정리

실습 라벨이 맞는 retry만 삭제하고, `-p`를 명시해 새 컨테이너를 만들었다.

```console
$ docker stop "$port_retry" && docker rm "$port_retry"
workspace-port-retry-20261104-152602-665
workspace-port-retry-20261104-152602-665

$ docker run -d \
    --name "$port_recovered" \
    --label "com.asheli1a.port-run=$port_run" \
    -p 127.0.0.1:18086:80 \
    nginx:alpine
bf4592056f2db3ce9bdbcf4bdd7904442593f02559afab88767a8cbc4da22744

$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS                          PORTS                     NAMES
bf4592056f2d   nginx:alpine   "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds                    127.0.0.1:18086->80/tcp   workspace-port-recovered-20261104-152602-665
9f6ae0b9c596   nginx:alpine   "/docker-entrypoint.…"   3 minutes ago   Exited (0) About a minute ago                             workspace-port-owner-20261104-152602-665

$ docker port "$port_recovered"
80/tcp -> 127.0.0.1:18086
$ docker inspect "$port_recovered" --format 'CurrentPorts={{json .NetworkSettings.Ports}}'
CurrentPorts={"80/tcp":[{"HostIp":"127.0.0.1","HostPort":"18086"}]}
$ curl --max-time 5 -I http://localhost:18086/
HTTP/1.1 200 OK
Server: nginx/1.31.8
```

정리할 때는 owner와 recovered의 라벨이 모두 맞을 때만 recovered를 중지하고, 두 개를 이름으로 지정해 삭제했다. `-f`와 `prune`은 쓰지 않았다.

```console
$ docker stop "$port_recovered" && docker rm "$port_owner" "$port_recovered"
workspace-port-recovered-20261104-152602-665
workspace-port-owner-20261104-152602-665
workspace-port-recovered-20261104-152602-665

$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
$ curl --max-time 5 -I http://localhost:18086/
curl: (7) Failed to connect to localhost port 18086 after 0 ms: Could not connect to server
$ docker image ls nginx:alpine
IMAGE          ID             DISK USAGE   CONTENT SIZE   EXTRA
nginx:alpine   785835ea65db       94.5MB         27.2MB

$ docker info --format 'OS={{.OperatingSystem}} Kernel={{.KernelVersion}} Containers={{.Containers}} Images={{.Images}}'
OS=Docker Desktop Kernel=6.18.54.1-microsoft-standard-WSL2 Containers=0 Images=1
```

`nginx:alpine` 이미지는 남겼다. `git status --short`에는 `?? cli-practice/port-conflict/`가 표시됐고, 로그 파일은 삭제하지 않고 보관했다.

## 검증 결과

| 확인 항목 | 결과 |
|---|---|
| Python 서버 충돌 | 재현 (`Errno 98`, 종료 코드 1) |
| 점유자 확인 | `ps`, `ss`, `lsof`, `fuser`가 같은 PID |
| 종료 방식 | 명령과 부모 PID를 대조한 PID에만 SIGTERM, `wait` 143 |
| 해제 후 같은 포트 재사용 | 성공 (새 PID 1689, HTTP 200) |
| Docker 충돌 | 재현 (`port is already allocated`, 종료 코드 125, 실패 컨테이너 `Created`로 남음) |
| Docker 점유자 식별 | `ss`에는 프로세스 이름이 없어서 `docker ps`, `docker port`로 확인 |
| 충돌로 실패한 컨테이너를 start | 실행은 됐지만 호스트 매핑 없음 (두 번 재현) |
| 새 컨테이너에 `-p` 명시 | 매핑과 HTTP 200 확인 |
| 정리 | 실습 라벨의 컨테이너만 삭제, 이미지와 로그 보관 |

## 남은 확인

- 포트 매핑이 비었던 원인은 확인하지 못했다. 같은 조건에서 항상 재현되는지, 다른 Docker 버전에서도 그런지는 확인하지 않았다.
- `127.0.0.1`에 묶은 로컬 실습이다. Windows 쪽 프로세스가 잡은 포트와 외부 접근은 확인하지 않았다.
- 이전 실습(2026-11-03)의 PID·컨테이너 ID는 이번 값과 다르다. 이 문서는 이번 재실습의 값을 기준으로 한다.

[프로젝트 README](../README.md)
