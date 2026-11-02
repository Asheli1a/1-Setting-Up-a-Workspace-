# Docker Compose 멀티 컨테이너 및 내부 통신 검증

## 1. 수행 범위와 기록 기준

- 수행 일자: 2026-11-02
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- 구성: NGINX 웹 서비스와 BusyBox 요청용 보조 서비스
- 결과: 두 서비스 실행·내부 통신·호스트 접속·서버 로그·네트워크 연결·종료 검증 완료
- 단일 서비스 실습은 [07 문서](07-compose.md)에 별도로 유지한다.
- 이 문서는 멀티 컨테이너 기록이다. 환경 변수 동작 변경은 [09 문서](09-compose-env.md)의 별도 실습이며, GitHub SSH 인증은 이후 진행한다.

아래 console 블록은 제공된 실제 명령과 출력이다. 호스트 프롬프트를 `$`로 정리하고 여러 명령을 묶어 입력한 부분은 명령별로 대응시켰다. 초기 전체 컨테이너 목록 등 이번 실습과 직접 관계없는 출력은 생략했다. 예상 결과를 실제 실행 출력으로 만들지 않았다.

시작 시 조회한 HEAD는 `e345713`이었다. 이후 새로 작성한 Compose 파일이 작업 디렉터리에 포함되므로 이 HEAD만을 전체 실행 입력의 확정 커밋으로 간주하지 않는다. 실제 설정 원문과 실행 결과를 함께 기록한다.

## 2. 목적과 통신 구조

두 컨테이너가 켜졌다는 사실만이 아니라, 같은 Compose 네트워크에서 client가 서비스 이름 `web`으로 HTTP 요청을 보내고 정상 HTML을 받는지 확인한다.

```text
호스트 ── localhost:18083 ── 포트 매핑 ── web:80
                                              ▲
                                              │ HTTP 요청
                                           client
                                       http://web:80/
```

| 구분 | 사용 주소 | 의미 |
|---|---|---|
| client → web | http://web:80/ | 서비스 이름과 컨테이너 포트로 내부 통신 |
| 호스트 → web | http://localhost:18083 | 호스트 공개 포트로 접속 |

컨테이너 IP를 설정에 고정하지 않는다. 이번 inspect의 IP는 관찰값이며, 재생성 시 달라질 수 있다. client 안의 localhost를 다른 web 서비스 주소로 사용하지 않는다.

근거: [Networking in Compose](https://docs.docker.com/compose/how-tos/networking/)

## 3. 실제 구성

| 항목 | 적용값 |
|---|---|
| Compose 파일 | docker-compose.multi.yml |
| 프로젝트 | workspace-bonus-multi |
| 웹 서비스 | web |
| 보조 서비스 | client |
| 웹 이미지 | workspace-web:compose-multi / 3802657ca07b |
| 보조 이미지 | busybox:latest / a46257e06c82 |
| 웹 컨테이너 | workspace-bonus-multi-web-1 |
| 보조 컨테이너 | workspace-bonus-multi-client-1 |
| 호스트 포트 | 127.0.0.1:18083 → 80/tcp |
| 네트워크 | workspace-bonus-multi_default |
| 마운트·볼륨 | 이번 구성에서 별도 정의하지 않음 |

단일 실습의 파일·프로젝트·태그·포트와 구분했다. 기존 `docker-compose.yml`과 웹 소스·Dockerfile은 유지한다.

## 4. 사전 상태 확인

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
e345713 (HEAD -> main, origin/main, origin/HEAD) _

$ docker compose ls -a
NAME                STATUS              CONFIG FILES

$ docker ps -a \
  --filter label=com.docker.compose.project=workspace-bonus-multi
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ ss -ltn '( sport = :18083 )'
State          Recv-Q          Send-Q                   Local Address:Port                   Peer Address:Port

$ if [ -e docker-compose.multi.yml ]; then
  cat docker-compose.multi.yml
else
  echo "새로 작성할 수 있습니다."
fi
새로 작성할 수 있습니다.
```

조회 당시 대상 Compose 프로젝트·컨테이너·Compose 파일이 표시되지 않았고 ss의 리스닝 목록도 비어 있었다. ss만으로 Windows·Docker Desktop 전체 포트 예약까지 확정한 것은 아니며, 실제 up과 접속 성공으로 이번 연결을 확인했다.

## 5. Compose 설정과 해석 결과

```console
$ nano docker-compose.multi.yml

$ cat docker-compose.multi.yml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    image: workspace-web:compose-multi
    ports:
      - "127.0.0.1:18083:80"

  client:
    image: busybox:latest
    command: ["sleep", "86400"]
    depends_on:
      - web

$ docker compose -p workspace-bonus-multi \
  -f docker-compose.multi.yml config
name: workspace-bonus-multi
services:
  client:
    command:
      - sleep
      - "86400"
    image: busybox:latest
    networks:
      default: null
    depends_on:
      web:
        condition: service_started
        required: true
  web:
    image: workspace-web:compose-multi
    networks:
      default: null
    build:
      context: /home/user/dev-workstation
      dockerfile: Dockerfile
    ports:
      - mode: ingress
        host_ip: 127.0.0.1
        target: 80
        published: "18083"
        protocol: tcp
networks:
  default:
    name: workspace-bonus-multi_default
```

- web은 기존 Dockerfile을 빌드하고 호스트 포트를 공개한다.
- client는 실습 명령을 실행할 수 있도록 sleep 86400으로 대기한다. 별도 호스트 포트는 공개하지 않는다.
- 두 서비스가 기본 네트워크에 연결된다.
- depends_on은 `service_started`로 해석됐다. 서버가 요청을 받을 준비까지 확인한 상태인 `service_healthy`와 구분한다.
- 이번에는 실제 요청이 성공했지만, 모든 환경에서 준비 지연이 없다고 일반화하지 않는다.

## 6. 빌드·실행 결과

```console
$ docker compose -p workspace-bonus-multi \
  -f docker-compose.multi.yml up -d --build
[+] up 3/3
 ✔ Image busybox:latest Pulled                                                                                      2.7s
[+] Building 1.7s (9/9) FINISHED
 => [internal] load local bake definitions                                                                         0.0s
 => => reading from stdin 522B                                                                                     0.0s
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
 => exporting to image                                                                                             0.1s
 => => exporting layers                                                                                            0.0s
 => => exporting manifest sha256:7bdbf937fa0d82fcf80d89f3e94478e4a1cba9dc7a011a9e34b4305da2946d9e                  0.0s
 => => exporting config sha256:f3e86bd4e1b8f6d0e73e0cd7c89f5cfa15cdea5f3da6fed636d80d33776ca16e                    0.0s
 => => exporting attestation manifest sha256:dd8256f6c1cf4b9fdb1ab686b4ca3c2b952d67648b9d53031dec1b5d13fb617e      0.0s
 => => exporting manifest list sha256:3802657ca07ba33b704c9d52aaaa45e036e259af849f94c74e8024804d655d1b             0.0s
 => => naming to docker.io/library/workspace-web:compose-multi                                                     0.0s
 => => unpacking to docker.io/library/workspace-web:compose-multi                                                  0.0s
 => resolving provenance for metadata file                                                                         0.0s
[+] up 7/7
 ✔ Image busybox:latest                     Pulled                                                                  2.7s
 ✔ Image workspace-web:compose-multi        Built                                                                   1.9s
 ✔ Network workspace-bonus-multi_default    Created                                                                 0.0s
 ✔ Container workspace-bonus-multi-web-1    Started                                                                 0.5s
 ✔ Container workspace-bonus-multi-client-1 Started                                                                 0.6s
```

BusyBox 이미지를 가져오고 웹 이미지를 빌드한 뒤, 기본 네트워크와 두 컨테이너를 생성했다. COPY 단계는 CACHED였으므로 캐시를 사용한 빌드로 기록한다. 터미널에서 잘린 베이스 digest를 완전한 고정값으로 사용하지 않는다.

## 7. 실행 상태와 이미지 확인

```console
$ docker compose -p workspace-bonus-multi \
  -f docker-compose.multi.yml ps
NAME                             IMAGE                         COMMAND                  SERVICE   CREATED         STATUS         PORTS
workspace-bonus-multi-client-1   busybox:latest                "sleep 86400"            client    3 seconds ago   Up 2 seconds
workspace-bonus-multi-web-1      workspace-web:compose-multi   "/docker-entrypoint.…"   web       3 seconds ago   Up 2 seconds   127.0.0.1:18083->80/tcp

$ docker compose -p workspace-bonus-multi \
  -f docker-compose.multi.yml images
CONTAINER                        REPOSITORY          TAG                 PLATFORM            IMAGE ID            SIZE                CREATED
workspace-bonus-multi-client-1   busybox             latest              linux/amd64         a46257e06c82        6.81MB              5 months ago
workspace-bonus-multi-web-1      workspace-web       compose-multi       linux/amd64         3802657ca07b        93.6MB              26 minutes ago
```

두 서비스가 Up 상태이고 호스트 공개 포트는 web에만 표시됐다. 이미지의 CREATED 값은 출력 그대로 유지했으며 컨테이너의 생성·시작 경과 시간과 혼동하지 않는다.

## 8. client에서 web으로 내부 요청

```console
$ docker compose -p workspace-bonus-multi \
  -f docker-compose.multi.yml exec -T client \
  sh -c 'hostname; wget -S -O - -T 5 http://web:80/'
605f71f41430
Connecting to web:80 (172.18.0.2:80)
  HTTP/1.1 200 OK
  Server: nginx/1.31.8
  Date: Mon, 02 Nov 2026 07:43:29 GMT
  Content-Type: text/html
  Content-Length: 428
  Last-Modified: Mon, 02 Nov 2026 07:16:58 GMT
  Connection: close
  ETag: "6ae838ea-1ac"
  Accept-Ranges: bytes

writing to stdout
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
-                    100% |********************************|   428  0:00:00 ETA
written to stdout
```

서비스 이름 web이 이번 실행의 172.18.0.2로 해석됐고 80번 포트에서 HTTP 200·428바이트의 HTML을 받았다. client의 hostname 출력은 뒤의 네트워크 검사에 나온 컨테이너 ID 앞부분과 일치한다.

## 9. 호스트 접속과 웹 로그

### 호스트 curl

```console
$ curl --max-time 5 -i http://localhost:18083
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Mon, 02 Nov 2026 07:43:41 GMT
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

### 서버 로그

```console
$ docker compose -p workspace-bonus-multi \
  -f docker-compose.multi.yml logs --tail 40 web
web-1  | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
web-1  | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
web-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
web-1  | 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
web-1  | 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
web-1  | /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
web-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
web-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
web-1  | /docker-entrypoint.sh: Configuration complete; ready for start up
web-1  | 2026/11/02 07:43:20 [notice] 1#1: using the "epoll" event method
web-1  | 2026/11/02 07:43:20 [notice] 1#1: nginx/1.31.8
web-1  | 2026/11/02 07:43:20 [notice] 1#1: built by gcc 15.2.0 (Alpine 15.2.0)
web-1  | 2026/11/02 07:43:20 [notice] 1#1: OS: Linux 6.18.54.1-microsoft-standard-WSL2
web-1  | 2026/11/02 07:43:20 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker processes
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker process 30
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker process 31
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker process 32
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker process 33
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker process 34
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker process 35
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker process 36
web-1  | 2026/11/02 07:43:20 [notice] 1#1: start worker process 37
web-1  | 172.18.0.3 - - [02/Nov/2026:07:43:29 +0000] "GET / HTTP/1.1" 200 428 "-" "Wget" "-"
web-1  | 172.18.0.1 - - [02/Nov/2026:07:43:41 +0000] "GET / HTTP/1.1" 200 428 "-" "curl/8.18.0" "-"
```

| 요청 | 응답 시각 GMT | 로그상 출발 주소 | 상태·크기 |
|---|---|---|---|
| client의 Wget | 07:43:29 | 172.18.0.3 | 200 / 428 |
| 호스트의 curl | 07:43:41 | 172.18.0.1 | 200 / 428 |

각 HTTP 응답과 로그의 시각·상태·크기가 대응한다. KST로는 각각 16:43:29·16:43:41이며 전체 실습 시작·종료 시각으로 확대 해석하지 않는다. .1은 이번 로그에 표시된 요청 주소로 기록하고 물리 PC의 고유 IP라고 단정하지 않는다.

## 10. 네트워크 연결 정보

```console
$ docker network inspect workspace-bonus-multi_default \
  --format '{{json .Containers}}'
{"605f71f4143056366ee08e4845f40d58b4629dd7319a462859e99fc6e9c484a1":{"Name":"workspace-bonus-multi-client-1","EndpointID":"cd6d1519688d58c2910fee33d75404d0fafbd59d961173458be6b658ff371ec1","MacAddress":"96:33:20:bb:ea:72","IPv4Address":"172.18.0.3/16","IPv6Address":""},"e97d871c2517c77468be0dccffee967c30a3793754cfed74ce42265eb499b34b":{"Name":"workspace-bonus-multi-web-1","EndpointID":"9e6bc8c1c0ed26b3bb49d07f7a75db3256c5578fa7af474435fb99961eb63f45","MacAddress":"86:07:f2:6b:f5:3a","IPv4Address":"172.18.0.2/16","IPv6Address":""}}
```

| 컨테이너 | ID 앞부분 | 이번 네트워크 주소 |
|---|---|---|
| client | 605f71f41430 | 172.18.0.3/16 |
| web | e97d871c2517 | 172.18.0.2/16 |

같은 네트워크에 두 컨테이너가 연결됐고, Wget의 목적지·웹 로그의 출발지와 주소가 일치했다. 호스트 포트를 거치지 않는 client → web 통신을 실제 요청으로 확인한 것이다.

## 11. 종료와 잔존 여부 확인

```console
$ docker compose -p workspace-bonus-multi \
  -f docker-compose.multi.yml down
[+] down 3/3
 ✔ Container workspace-bonus-multi-client-1 Removed                                                                 3.3s
 ✔ Container workspace-bonus-multi-web-1    Removed                                                                 0.4s
 ✔ Network workspace-bonus-multi_default    Removed                                                                 0.2s

$ docker compose -p workspace-bonus-multi \
  -f docker-compose.multi.yml ps -a
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS

$ docker ps -a \
  --filter label=com.docker.compose.project=workspace-bonus-multi
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker network ls \
  --filter name=workspace-bonus-multi_default
NETWORK ID   NAME      DRIVER    SCOPE
```

두 컨테이너와 기본 네트워크가 Removed로 표시됐고, 이후 세 목록에서 해당 대상이 나타나지 않았다. 단순 중지가 아니라 제거와 잔존 여부까지 확인했다.

추가 삭제 옵션인 `-v`, `--rmi`, `prune`은 사용하지 않았다. 이 결과를 이미지·기존 볼륨·다른 프로젝트 전체의 삭제 증거로 해석하지 않는다.

근거: [docker compose down](https://docs.docker.com/reference/cli/docker/compose/down/)

## 12. 검증 요약과 완료 상태

| 항목 | 결과 |
|---|---|
| 두 서비스 실행 | web·client 모두 Up |
| 이미지 | compose-multi 3802657ca07b / busybox a46257e06c82 |
| 서비스 이름 요청 | client에서 web:80 연결 및 HTTP 200 |
| 내부 응답 | 428바이트 HTML / v1 |
| 호스트 응답 | localhost:18083 / HTTP 200 / 428바이트 |
| 서버 로그 | Wget·curl 각각 200 428 |
| 네트워크 검사 | client .3, web .2가 같은 기본 네트워크에 연결 |
| down | 컨테이너 2개와 네트워크 Removed |
| 종료 후 목록 | 컨테이너·네트워크 모두 대상 없음 |

- [x] 별도 Compose 파일로 web·client 두 서비스를 정의했다.
- [x] config와 실제 실행 상태·이미지를 확인했다.
- [x] client에서 서비스 이름 web으로 실제 요청·응답을 확인했다.
- [x] 호스트 접속과 내부 통신을 구분했다.
- [x] 서버 로그와 네트워크 주소를 서로 대조했다.
- [x] down과 컨테이너·네트워크의 종료 후 상태를 확인했다.
- [ ] 새 설정·로그의 최종 민감정보 검토 확인

제공된 실행 결과에서 별도 오류는 보고되지 않았다. 예상 오류를 실제 트러블슈팅으로 만들지 않았다. 네트워크 검증 증거는 명령·응답·로그이며 별도 브라우저 캡처를 추가하지 않았다.

## 13. 재현 주의사항과 다음 단계

- 저장소 루트에서 모든 명령에 같은 `-p workspace-bonus-multi -f docker-compose.multi.yml`을 사용한다.
- 18083 포트나 프로젝트 이름이 사용 중이면 상태를 확인하고 별도 값으로 조정한다. 기존 서비스를 임의로 제거하지 않는다.
- BusyBox latest와 NGINX alpine은 가변 태그다. 이번 이미지 ID는 관찰값이며 향후 재실행과 같다고 보장하지 않는다.
- sleep 86400은 실습용 대기이며 24시간 뒤 종료할 수 있다. 장기 운영용 보조 서비스 설계로 일반화하지 않는다.
- depends_on의 service_started는 준비 완료 검증이 아니다. 다른 환경에서 초기 요청 실패가 발생하면 상태·로그와 준비 여부를 확인한다.
- IP·MAC·EndpointID·시각은 이번 실행의 값이며 서비스 이름 대신 고정 설정값으로 사용하지 않는다.
- 이번에는 볼륨·마운트·비밀정보를 설정하지 않았다. 새로운 자료는 공개 전에 별도로 검토한다.
- 환경 변수로 실제 서버 설정과 응답을 비교한 별도 실습은 [09 문서](09-compose-env.md)에 기록했다. 남은 선택 과제인 GitHub SSH 인증은 이후 별도로 진행한다.

[단일 서비스 실습](07-compose.md) · [프로젝트 README](../README.md)
