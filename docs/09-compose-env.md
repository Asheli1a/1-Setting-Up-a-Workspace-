# Docker Compose 환경 변수와 NGINX 내부 포트 검증

## 1. 수행 범위와 상태

- 수행 일자: 2026-11-02
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- 구성: 기존 웹 이미지·HTML과 NGINX 설정 템플릿
- 검증: 같은 이미지에서 환경 변수로 내부 listen 포트 8080 → 9090 구성
- 결과: 두 실행의 환경 변수·생성 설정·포트 매핑·nginx -t·HTTP 정상 확인
- 종료: 컨테이너·네트워크 제거와 잔존 여부 확인 완료
- 이 문서는 환경 변수 실습 기록이다. GitHub SSH 인증·push는 [10 문서](10-github-ssh.md)에 별도로 기록했다.

아래 console 블록은 제공된 실제 명령과 출력이다. 호스트 프롬프트를 `$`로 정리하고 명령별 출력을 대응시켰다. 기존 전체 컨테이너 목록 등 이번 실습과 무관한 출력은 생략했다. 성공 결과·시각·ID를 임의로 만들어 넣지 않았다.

시작 시 조회한 HEAD는 [8208761](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/8208761d54567b1c6a884f4a701b5ef5d2118798)이었다. 이후 새로 작성한 Compose 파일·템플릿이 작업 디렉터리에 포함되므로 이 HEAD만으로 실습 입력 전체가 확정됐다고 기록하지 않는다. 실제 파일 내용과 응답은 아래 기록을 기준으로 한다.

## 2. 목적과 값의 전달 구조

이미지나 HTML을 바꾸지 않고 실행 시 설정값으로 서버 동작을 바꿀 수 있는지 확인한다. 환경 변수 출력만이 아니라 실제 생성된 설정과 내부 포트·정상 응답까지 비교한다.

```text
셸의 WORKSPACE_NGINX_PORT
       ↓ Compose 변수 치환
컨테이너 NGINX_PORT + ports의 target
       ↓ NGINX 시작 스크립트의 템플릿 처리
/etc/nginx/conf.d/default.conf의 listen 값
       ↓
고정된 호스트 localhost:18084에서 HTTP 응답
```

`WORKSPACE_NGINX_PORT`는 Compose 파일 해석에 사용하는 셸 변수이고, `NGINX_PORT`는 컨테이너에 전달하는 변수다. 두 이름의 역할을 구분한다. `NGINX_ENVSUBST_FILTER`는 치환 대상 환경 변수 이름을 제한하여 NGINX의 `$uri`를 유지하는 데 사용했다.

- [Compose 변수 치환](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/)
- [NGINX 공식 이미지의 템플릿 처리](https://hub.docker.com/_/nginx)

## 3. 실제 구성

| 항목 | 적용값 |
|---|---|
| Compose 파일 | docker-compose.env.yml |
| 템플릿 | nginx/env-templates/default.conf.template |
| 프로젝트 | workspace-bonus-env |
| 서비스 | web |
| 컨테이너 | workspace-bonus-env-web-1 |
| 이미지 | workspace-web:compose-env |
| 두 실행의 표시 이미지 ID | 5370cff821a2 |
| 호스트 포트 | 127.0.0.1:18084 — 고정 |
| 내부 포트 | 8080 / 9090 |
| 템플릿 연결 | 호스트 폴더 → /etc/nginx/templates / 읽기 전용 |
| 생성된 설정 | /etc/nginx/conf.d/default.conf |
| 웹 콘텐츠 | 기존 site/index.html / v1 |

기존 단일·멀티 Compose 파일과 Dockerfile·HTML은 이번 단계에서 수정하지 않았다. 이번 마운트는 설정 템플릿을 전달하기 위한 것이며 웹 콘텐츠의 바인드 변경 반영 실험과는 구분한다.

## 4. 사전 확인과 파일 작성

```console
$ cd ~/dev-workstation
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        1-Setting-Up-a-Workspace-/
        cli-practice/basic-ops/
        cli-practice/permissions/

nothing added to commit but untracked files present (use "git add" to track)

$ git log -1 --oneline
8208761 (HEAD -> main, origin/main, origin/HEAD) docs: verify compose multi-container networking and shutdown

$ docker compose ls -a
NAME                STATUS              CONFIG FILES

$ docker ps -a \
  --filter label=com.docker.compose.project=workspace-bonus-env
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ ss -ltn '( sport = :18084 )'
State          Recv-Q          Send-Q                   Local Address:Port                   Peer Address:Port

$ ls -l docker-compose.env.yml \
      nginx/env-templates/default.conf.template
ls: cannot access 'docker-compose.env.yml': No such file or directory
ls: cannot access 'nginx/env-templates/default.conf.template': No such file or directory

$ mkdir -p nginx/env-templates
$ nano nginx/env-templates/default.conf.template
$ nano docker-compose.env.yml
```

파일이 없는 것을 확인한 뒤 새로 작성했다. 이는 실습 시작 전 확인 결과이며 Docker 장애가 아니다.

### 템플릿 원문

```console
$ cat nginx/env-templates/default.conf.template
server {
    listen ${NGINX_PORT};
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Compose 원문

```console
$ cat docker-compose.env.yml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    image: workspace-web:compose-env

    environment:
      NGINX_PORT: "${WORKSPACE_NGINX_PORT:-8080}"
      NGINX_ENVSUBST_FILTER: "NGINX_PORT"

    ports:
      - "127.0.0.1:18084:${WORKSPACE_NGINX_PORT:-8080}"

    volumes:
      - type: bind
        source: ./nginx/env-templates
        target: /etc/nginx/templates
        read_only: true
```

템플릿은 읽기 전용으로 연결하지만 생성된 설정은 컨테이너의 `/etc/nginx/conf.d`에 작성된다. `ports`의 target도 같은 셸 변수에서 해석하여 서버의 listen 포트와 연결 대상을 맞췄다.

## 5. 1차 실행 — 8080

### 셸 변수와 config

```console
$ export WORKSPACE_NGINX_PORT=8080
$ printf 'WORKSPACE_NGINX_PORT=%s\n' "$WORKSPACE_NGINX_PORT"
WORKSPACE_NGINX_PORT=8080

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml config
name: workspace-bonus-env
services:
  web:
    environment:
      NGINX_ENVSUBST_FILTER: NGINX_PORT
      NGINX_PORT: "8080"
    image: workspace-web:compose-env
    networks:
      default: null
    volumes:
      - type: bind
        source: /home/user/dev-workstation/nginx/env-templates
        target: /etc/nginx/templates
        read_only: true
    build:
      context: /home/user/dev-workstation
      dockerfile: Dockerfile
    ports:
      - mode: ingress
        host_ip: 127.0.0.1
        target: 8080
        published: "18084"
        protocol: tcp
networks:
  default:
    name: workspace-bonus-env_default
```

### 빌드·실행

```console
$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml up -d --build
[+] Building 1.7s (9/9) FINISHED
 => [internal] load local bake definitions                                                                         0.0s
 => => reading from stdin 518B                                                                                     0.0s
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 164B                                                                               0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                                    1.2s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 76B                                                                                   0.0s
 => [internal] load build context                                                                                  0.0s
 => => transferring context: 61B                                                                                   0.0s
 => [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed  0.0s
 => => resolve docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed  0.0s
 => CACHED [2/2] COPY site/ /usr/share/nginx/html/                                                                 0.0s
 => exporting to image                                                                                             0.2s
 => => exporting layers                                                                                            0.0s
 => => exporting manifest sha256:2fe392fc279c041e2113fba45fcde44ab6a8b212094e0f25ea39dd7fcf38d422                  0.0s
 => => exporting config sha256:68be8cf742382b4aa07999ec6331aaea23aab29baeb99d133c9f5a7749018226                    0.0s
 => => exporting attestation manifest sha256:f185caf4e9565f1bfecdbc8307827bd15e5c1755d6648158fa3f3ab0b1a473fa      0.0s
 => => exporting manifest list sha256:5370cff821a2526cd183d96e02a644a825e7e5991af946bb3866b9a1d48c8961             0.0s
 => => naming to docker.io/library/workspace-web:compose-env                                                       0.0s
 => => unpacking to docker.io/library/workspace-web:compose-env                                                    0.0s
 => resolving provenance for metadata file                                                                         0.0s
[+] up 3/3
 ✔ Image workspace-web:compose-env     Built                                                                        1.9s
 ✔ Network workspace-bonus-env_default Created                                                                      0.0s
 ✔ Container workspace-bonus-env-web-1 Started                                                                      0.3s
```

COPY 단계는 CACHED이므로 캐시 사용 빌드로 기록한다. 베이스 digest 표시는 터미널에서 잘린 값이며 완전한 고정값으로 사용하지 않는다.

### 상태·이미지·실제 변수·생성 설정

```console
$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml ps
NAME                        IMAGE                       COMMAND                  SERVICE   CREATED         STATUS         PORTS
workspace-bonus-env-web-1   workspace-web:compose-env   "/docker-entrypoint.…"   web       5 seconds ago   Up 4 seconds   127.0.0.1:18084->8080/tcp

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml images
CONTAINER                   REPOSITORY          TAG                 PLATFORM            IMAGE ID            SIZE                CREATED
workspace-bonus-env-web-1   workspace-web       compose-env         linux/amd64         5370cff821a2        93.6MB              47 minutes ago

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml exec -T web printenv NGINX_PORT
8080

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml exec -T web \
  cat /etc/nginx/conf.d/default.conf
server {
    listen 8080;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml exec -T web nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

$ curl --max-time 5 -i http://localhost:18084
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Mon, 02 Nov 2026 08:05:09 GMT
Content-Type: text/html
Content-Length: 428
Last-Modified: Mon, 02 Nov 2026 07:16:58 GMT
Connection: keep-alive
ETag: "6ae838ea-1ac"
Accept-Ranges: bytes

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>루키마리너-1_Asheli1a 개발 작업실</title>
</head>
<body>
  <h1>루키마리너-1_Asheli1a의 개발 작업실</h1>
  <p>직접 만든 Docker 이미지에서 제공하는 웹 페이지입니다. Github Asheli1a</p>
  <p id="version">콘텐츠 버전: v1</p>
</body>
</html>
```

환경 변수·생성된 listen·실제 포트 연결·HTTP 응답을 확인했다.

## 6. 2차 실행 — 9090, 재빌드 없음

파일을 수정하지 않고 셸 변수만 지정한 뒤 같은 Compose 구성을 해석했다.

```console
$ export WORKSPACE_NGINX_PORT=9090
$ printf 'WORKSPACE_NGINX_PORT=%s\n' "$WORKSPACE_NGINX_PORT"
WORKSPACE_NGINX_PORT=9090

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml config
name: workspace-bonus-env
services:
  web:
    environment:
      NGINX_ENVSUBST_FILTER: NGINX_PORT
      NGINX_PORT: "9090"
    image: workspace-web:compose-env
    networks:
      default: null
    volumes:
      - type: bind
        source: /home/user/dev-workstation/nginx/env-templates
        target: /etc/nginx/templates
        read_only: true
    build:
      context: /home/user/dev-workstation
      dockerfile: Dockerfile
    ports:
      - mode: ingress
        host_ip: 127.0.0.1
        target: 9090
        published: "18084"
        protocol: tcp
networks:
  default:
    name: workspace-bonus-env_default

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml up -d --no-build web
[+] up 1/1
 ✔ Container workspace-bonus-env-web-1 Started                                                                      0.7s
```

```console
$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml ps
NAME                        IMAGE                       COMMAND                  SERVICE   CREATED         STATUS         PORTS
workspace-bonus-env-web-1   workspace-web:compose-env   "/docker-entrypoint.…"   web       7 seconds ago   Up 6 seconds   127.0.0.1:18084->9090/tcp

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml images
CONTAINER                   REPOSITORY          TAG                 PLATFORM            IMAGE ID            SIZE                CREATED
workspace-bonus-env-web-1   workspace-web       compose-env         linux/amd64         5370cff821a2        93.6MB              48 minutes ago

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml exec -T web printenv NGINX_PORT
9090

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml exec -T web \
  cat /etc/nginx/conf.d/default.conf
server {
    listen 9090;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml exec -T web nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

$ curl --max-time 5 -i http://localhost:18084
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Mon, 02 Nov 2026 08:05:30 GMT
Content-Type: text/html
Content-Length: 428
Last-Modified: Mon, 02 Nov 2026 07:16:58 GMT
Connection: keep-alive
ETag: "6ae838ea-1ac"
Accept-Ranges: bytes

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>루키마리너-1_Asheli1a 개발 작업실</title>
</head>
<body>
  <h1>루키마리너-1_Asheli1a의 개발 작업실</h1>
  <p>직접 만든 Docker 이미지에서 제공하는 웹 페이지입니다. Github Asheli1a</p>
  <p id="version">콘텐츠 버전: v1</p>
</body>
</html>
```

두 실행에서 표시된 이미지 ID는 같았다. --no-build로 기존 이미지를 사용하고 변경된 실행 설정을 up으로 반영했다. 실행 중인 기존 프로세스의 설정을 실시간으로 바꾼 실험은 아니다.

## 7. 템플릿 처리와 서버 로그

```console
$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml logs --tail 40 web
web-1  | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
web-1  | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
web-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
web-1  | 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
web-1  | 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
web-1  | /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
web-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
web-1  | 20-envsubst-on-templates.sh: Running envsubst on /etc/nginx/templates/default.conf.template to /etc/nginx/conf.d/default.conf
web-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
web-1  | /docker-entrypoint.sh: Configuration complete; ready for start up
web-1  | 2026/11/02 08:05:24 [notice] 1#1: using the "epoll" event method
web-1  | 2026/11/02 08:05:24 [notice] 1#1: nginx/1.31.8
web-1  | 2026/11/02 08:05:24 [notice] 1#1: built by gcc 15.2.0 (Alpine 15.2.0)
web-1  | 2026/11/02 08:05:24 [notice] 1#1: OS: Linux 6.18.54.1-microsoft-standard-WSL2
web-1  | 2026/11/02 08:05:24 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker processes
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker process 36
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker process 37
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker process 38
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker process 39
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker process 40
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker process 41
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker process 42
web-1  | 2026/11/02 08:05:24 [notice] 1#1: start worker process 43
web-1  | 172.18.0.1 - - [02/Nov/2026:08:05:30 +0000] "GET / HTTP/1.1" 200 428 "-" "curl/8.18.0" "-"
```

실제로 template → conf의 envsubst 실행이 기록됐고, 생성된 설정의 `$uri`는 유지됐다. 2차 HTTP와 로그의 시각·상태·크기도 대응한다.

HTTP 응답 시각은 1차 08:05:09 GMT, 2차 08:05:30 GMT이며 KST로 17:05:09·17:05:30이다. 이는 응답 시각이며 실습 전체의 시작·종료 시각으로 확대 해석하지 않는다.

## 8. 1차·2차 비교 및 해석

| 검증 항목 | 1차 | 2차 |
|---|---|---|
| WORKSPACE_NGINX_PORT | 8080 | 9090 |
| 컨테이너 NGINX_PORT | 8080 | 9090 |
| 생성된 listen | 8080 | 9090 |
| ps 포트 | 18084 → 8080/tcp | 18084 → 9090/tcp |
| 표시 이미지 ID | 5370cff821a2 | 5370cff821a2 |
| nginx -t | 성공 | 성공 |
| HTTP | 200 / 428바이트 / v1 | 200 / 428바이트 / v1 |
| 빌드 옵션 | --build / COPY 캐시 | --no-build |

같은 이미지와 HTML에서 실행 설정으로 실제 내부 서버 포트를 바꿨다. 호스트 포트만 바꾸거나 환경 변수만 출력하는 수준에서 끝내지 않고, NGINX 설정·매핑·정상 응답을 함께 확인했다.

이미지 ID와 CREATED의 경과 표시는 다른 의미다. 이번 비교에서는 두 실행에 표시된 같은 이미지 ID를 근거로 기록하고, 컨테이너 ID나 정확한 재생성 이벤트가 제공되지 않은 부분은 임의로 추가하지 않는다.

## 9. 종료·잔존 여부·호스트 파일 확인

```console
$ export WORKSPACE_NGINX_PORT=9090

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml down
[+] down 2/2
 ✔ Container workspace-bonus-env-web-1 Removed                                                                      0.4s
 ✔ Network workspace-bonus-env_default Removed                                                                      0.2s

$ docker compose -p workspace-bonus-env \
  -f docker-compose.env.yml ps -a
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS

$ docker ps -a \
  --filter label=com.docker.compose.project=workspace-bonus-env
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker network ls \
  --filter name=workspace-bonus-env_default
NETWORK ID   NAME      DRIVER    SCOPE

$ ls -l docker-compose.env.yml \
      nginx/env-templates/default.conf.template
-rw-r--r-- 1 user user 421 Nov  2 17:04 docker-compose.env.yml
-rw-r--r-- 1 user user 170 Nov  2 17:04 nginx/env-templates/default.conf.template

$ unset WORKSPACE_NGINX_PORT
```

컨테이너와 기본 네트워크가 제거되고 이후 세 목록에 대상이 없었다. 호스트의 Compose 파일과 템플릿은 남아 있었다. 마지막에 현재 셸의 실습 변수를 해제했다. 해제 후 변수 값을 다시 출력한 별도 로그는 없다.

`down -v`, `--rmi`, `prune`은 사용하지 않았다. 이미지나 기존 볼륨·다른 프로젝트까지 삭제됐다는 뜻이 아니다.

## 10. 완료 체크리스트

- [x] 별도 Compose 파일과 NGINX 설정 템플릿을 작성했다.
- [x] 8080·9090 각각의 config와 컨테이너 환경 변수를 확인했다.
- [x] 생성된 listen 설정과 ps의 내부 포트를 확인했다.
- [x] 두 실행의 이미지 ID가 같고 2차는 --no-build였음을 확인했다.
- [x] 두 설정에서 nginx -t와 HTTP 200·v1 응답을 확인했다.
- [x] 템플릿 처리와 HTTP 요청의 서버 로그를 확인했다.
- [x] down과 컨테이너·네트워크의 잔존 여부를 확인했다.
- [x] 종료 후 호스트 설정 파일이 남아 있음을 확인했다.
- [x] 새 설정·로그의 최종 민감정보 검토 확인

이번에 제공된 결과에서 별도 장애는 보고되지 않았다. 새 파일이 없는 초기 확인 메시지는 장애 사례로 추가하지 않는다. 증거는 명령·출력이며 이번 내부 포트 비교를 위한 별도 브라우저 캡처는 추가하지 않았다.

## 11. 재현 시 주의사항

- 모든 명령은 저장소 루트에서 같은 `-p workspace-bonus-env -f docker-compose.env.yml`을 사용한다.
- 1차 전에 `export WORKSPACE_NGINX_PORT=8080`, 2차 전에 `export WORKSPACE_NGINX_PORT=9090`을 지정한다. 새 터미널에서는 값을 다시 지정해야 한다.
- 변수를 해제하면 Compose의 기본값 8080이 해석된다. 실습 단계의 값을 명시하고 config로 확인한다.
- `NGINX_ENVSUBST_FILTER`가 없거나 달라지면 치환 범위도 달라질 수 있으므로 템플릿과 생성된 설정을 함께 확인한다.
- 포트·프로젝트 이름이 충돌하면 기존 서비스·자료를 임의로 삭제하지 않고 별도 값을 선택한다.
- 바인드 마운트의 source는 프로젝트 위치에 맞게 해석된다. 다른 PC에서는 clone한 루트를 기준으로 사용한다.
- 비밀번호·토큰은 이 실습의 환경 변수로 넣지 않았다. 이후 config·printenv·로그 공개 시 실제 값이 노출될 수 있으므로 별도로 검토한다.
- 과거 실행의 시각·ID·헤더는 당시 관찰값이다. 재실행 결과가 같다고 보장하지 않는다.

[단일 서비스](07-compose.md) · [멀티 컨테이너](08-compose-multi.md) · [프로젝트 README](../README.md)
