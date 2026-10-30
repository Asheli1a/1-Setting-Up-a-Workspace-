# 커스텀 웹 서버 이미지 및 포트 매핑

## 1. 목적
NGINX 기반 커스텀 이미지를 만들고,
직접 작성한 웹 페이지의 포트 매핑 접속을 검증한다.

## 2. 베이스 이미지 및 커스텀 내용

| 항목 | 적용 내용 | 목적 |
|---|---|---|
| 베이스 이미지 | nginx:alpine | 정적 웹 페이지를 제공할 웹 서버 사용 |
| 웹 콘텐츠 | 직접 작성한 site/index.html | 기본 페이지를 실습용 페이지로 교체 |
| LABEL | Asheli1a Workspace Web | 이미지 식별 정보 추가 |
| 서비스 포트 | 80/tcp | 컨테이너의 웹 서비스 포트 명시 |

[웹 소스](../site/index.html)
[Dockerfile](../Dockerfile)
[빌드 제외 설정](../.dockerignore)

## 3. 소스 및 설정 확인
```console
$ nano site/index.html
$ cat site/index.html
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>이준호 개발 작업실</title>
</head>
<body>
  <h1>이준호의 개발 작업실</h1>
  <p>직접 만든 Docker 이미지에서 제공하는 웹 페이지입니다. Github Asheli1a</p>
  <p id="version">콘텐츠 버전: v1</p>
</body>
</html>

$ nano Dockerfile
$ cat Dockerfile
FROM nginx:alpine

LABEL org.opencontainers.image.title="Asheli1a Workspace Web"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
```
### Dockerfile 각 지시문의 목적

| 지시문 | 목적 |
|---|---|
| `FROM nginx:alpine` | 기존 NGINX 이미지를 기반으로 사용 |
| `LABEL` | 이미지에 프로젝트 식별 정보 추가 |
| `COPY site/ /usr/share/nginx/html/` | 직접 작성한 웹 콘텐츠를 이미지에 포함 |
| `EXPOSE 80` | 컨테이너의 웹 서비스 포트가 80번임을 명시 |
메모: `EXPOSE 80`만으로 호스트 포트가 공개되지는 않는다. 실제 접속을 위한 포트 연결은 `docker run -p`에서 설정했다.

```console

$ nano .dockerignore
$ cat .dockerignore
.git
docs/
cli-practice/
README.md
```
이번 웹 이미지 빌드에 필요 없는 Git 이력·문서·기본 실습 파일을 빌드 컨텍스트에서 제외하도록 구성


## 4. 이미지 빌드 및 목록 확인
```console
$ docker build -t workspace-web:1.0 .
[+] Building 6.5s (7/7) FINISHED                                                                         docker:default
 => [internal] load build definition from Dockerfile                                                               0.1s
 => => transferring dockerfile: 164B                                                                               0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                                    2.0s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 76B                                                                                   0.0s
 => [internal] load build context                                                                                  0.1s
 => => transferring context: 466B                                                                                  0.0s
 => [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed  3.1s
 => => resolve docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed  0.0s
 => => sha256:b9b388a21ecfde6ac80505f23f527146a2129dfb104e79b029bbd00d4cc1a919 20.53MB / 20.53MB                   2.5s
 => => sha256:9b0f7dfe35b2711a17f60dadd6d4035dc0cdee152538cc5c0987029e94679548 1.40kB / 1.40kB                     0.4s
 => => sha256:2ec5fb117ffa9a78b15fb6a78745ffc569c8da0aee9f36ace4cd67a44b1fef79 1.21kB / 1.21kB                     0.6s
 => => sha256:26185d08a3ec318dd85a6c9f2172e714ec13cececd7f33c533b40b1689f9fedb 404B / 404B                         0.6s
 => => sha256:7cc330898115ce55acccb0cc1e7dd091df4410c8c5f3c540710ee0ac689f5fcb 964B / 964B                         0.2s
 => => sha256:657023555a2a19dc6036468198bb350d2c7feaac7f2d0a3901b4dd3cb25e40c5 629B / 629B                         0.2s
 => => sha256:12b85cff06fd7d383d36a9c96503fe049c9d4bf3dfda5cbb9ffa6ae99b9c07a6 1.94MB / 1.94MB                     0.6s
 => => sha256:7b229517ed222597277036d94892173207d01a731ab3a88eeb1de2e963a2c788 3.85MB / 3.85MB                     0.8s
 => => extracting sha256:7b229517ed222597277036d94892173207d01a731ab3a88eeb1de2e963a2c788                          0.2s
 => => extracting sha256:12b85cff06fd7d383d36a9c96503fe049c9d4bf3dfda5cbb9ffa6ae99b9c07a6                          0.2s
 => => extracting sha256:657023555a2a19dc6036468198bb350d2c7feaac7f2d0a3901b4dd3cb25e40c5                          0.0s
 => => extracting sha256:7cc330898115ce55acccb0cc1e7dd091df4410c8c5f3c540710ee0ac689f5fcb                          0.0s
 => => extracting sha256:26185d08a3ec318dd85a6c9f2172e714ec13cececd7f33c533b40b1689f9fedb                          0.0s
 => => extracting sha256:2ec5fb117ffa9a78b15fb6a78745ffc569c8da0aee9f36ace4cd67a44b1fef79                          0.0s
 => => extracting sha256:9b0f7dfe35b2711a17f60dadd6d4035dc0cdee152538cc5c0987029e94679548                          0.0s
 => => extracting sha256:b9b388a21ecfde6ac80505f23f527146a2129dfb104e79b029bbd00d4cc1a919                          0.4s
 => [2/2] COPY site/ /usr/share/nginx/html/                                                                        0.1s
 => exporting to image                                                                                             1.0s
 => => exporting layers                                                                                            0.1s
 => => exporting manifest sha256:14209664a7bc9318882b534a3277adb0fe860a01d778dde8e0fe0daa32af1c19                  0.0s
 => => exporting config sha256:e6cf0d643c3292a9ebfd5cdcace4cb4759f082b8650d6cd705d983610cdbc852                    0.0s
 => => exporting attestation manifest sha256:96bba9d830fc238fde79228f2e48ae4a53a3ab079e7a8d048c5cb192a0e48f76      0.0s
 => => exporting manifest list sha256:e95b34537b192974d2f086a90f3a9dda9bb1f3eb1c1ff384bbc50c6c178a6c41             0.0s
 => => naming to docker.io/library/workspace-web:1.0                                                               0.0s
 => => unpacking to docker.io/library/workspace-web:1.0                                                            0.7s

$ docker images workspace-web
                                                                                                    i Info →   U  In Use
IMAGE               ID             DISK USAGE   CONTENT SIZE   EXTRA
workspace-web:1.0   e95b34537b19       93.6MB         26.3MB
user@4F-103:~/dev-workstation$ docker ps -a
CONTAINER ID   IMAGE           COMMAND    CREATED             STATUS                      PORTS     NAMES
ba7726aba893   ubuntu:latest   "bash"     About an hour ago   Exited (0) 20 minutes ago             workspace-ubuntu
c83798db7dd1   hello-world     "/hello"   26 hours ago        Exited (0) 26 hours ago               ecstatic_shamir
```

## 5. 8080 포트 실행 및 접속 검증
```console
$ docker run -d \
  --name workspace-web-8080 \
  -p 127.0.0.1:8080:80 \
  workspace-web:1.0
57d352ca37905942d73638f3da63c4fd6be3391a6ab34dfa3a77599f594fd00f

$ docker ps --filter name=workspace-web-8080
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS          PORTS                    NAMES
57d352ca3790   workspace-web:1.0   "/docker-entrypoint.…"   11 seconds ago   Up 10 seconds   127.0.0.1:8080->80/tcp   workspace-web-8080

$ curl -i http://localhost:8080
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Fri, 30 Oct 2026 08:51:45 GMT
Content-Type: text/html
Content-Length: 394
Last-Modified: Fri, 30 Oct 2026 08:48:51 GMT
Connection: keep-alive
ETag: "6ae459f3-18a"
Accept-Ranges: bytes

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>이준호 개발 작업실</title>
</head>
<body>
  <h1>이준호의 개발 작업실</h1>
  <p>직접 만든 Docker 이미지에서 제공하는 웹 페이지입니다. Github Asheli1a</p>
  <p id="version">콘텐츠 버전: v1</p>
</body>
</html>

$ docker logs --tail 20 workspace-web-8080
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/10/30 08:51:27 [notice] 1#1: using the "epoll" event method
2026/10/30 08:51:27 [notice] 1#1: nginx/1.31.8
2026/10/30 08:51:27 [notice] 1#1: built by gcc 15.2.0 (Alpine 15.2.0)
2026/10/30 08:51:27 [notice] 1#1: OS: Linux 6.18.54.1-microsoft-standard-WSL2
2026/10/30 08:51:27 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/10/30 08:51:27 [notice] 1#1: start worker processes
2026/10/30 08:51:27 [notice] 1#1: start worker process 30
2026/10/30 08:51:27 [notice] 1#1: start worker process 31
2026/10/30 08:51:27 [notice] 1#1: start worker process 32
2026/10/30 08:51:27 [notice] 1#1: start worker process 33
2026/10/30 08:51:27 [notice] 1#1: start worker process 34
2026/10/30 08:51:27 [notice] 1#1: start worker process 35
2026/10/30 08:51:27 [notice] 1#1: start worker process 36
2026/10/30 08:51:27 [notice] 1#1: start worker process 37
172.17.0.1 - - [30/Oct/2026:08:51:45 +0000] "GET / HTTP/1.1" 200 394 "-" "curl/8.18.0" "-"
```
[8080_브라우저_접속_증거](images/web-8080.png)

### 확인 결과

- workspace-web:1.0 이미지로 workspace-web-8080을 실행했다.
- 호스트의 127.0.0.1:8080을 컨테이너의 80번 포트에 연결했다.
- curl에서 HTTP 200 응답과 직접 작성한 HTML을 확인했다.
- NGINX 로그에서 해당 요청의 200 응답을 확인했다.
- Windows 브라우저에서도 같은 페이지와 콘텐츠 버전 v1을 확인했다.


## 6. 8081 포트 실행 및 접속 검증
```console
$ docker run -d \
  --name workspace-web-8081 \
  -p 127.0.0.1:8081:80 \
  workspace-web:1.0
f503d339f6a56a90557b90238a3ca6c409f8ce47cf24bab6e0df4b6ddd9132df
user@4F-103:~/dev-workstation$ docker ps --filter ancestor=workspace-web:1.0
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS          PORTS                    NAMES
f503d339f6a5   workspace-web:1.0   "/docker-entrypoint.…"   6 seconds ago    Up 5 seconds    127.0.0.1:8081->80/tcp   workspace-web-8081
57d352ca3790   workspace-web:1.0   "/docker-entrypoint.…"   16 minutes ago   Up 16 minutes   127.0.0.1:8080->80/tcp   workspace-web-8080
user@4F-103:~/dev-workstation$ curl -i http://localhost:8081
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Fri, 30 Oct 2026 09:08:04 GMT
Content-Type: text/html
Content-Length: 394
Last-Modified: Fri, 30 Oct 2026 08:48:51 GMT
Connection: keep-alive
ETag: "6ae459f3-18a"
Accept-Ranges: bytes

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>이준호 개발 작업실</title>
</head>
<body>
  <h1>이준호의 개발 작업실</h1>
  <p>직접 만든 Docker 이미지에서 제공하는 웹 페이지입니다. Github Asheli1a</p>
  <p id="version">콘텐츠 버전: v1</p>
</body>
</html>
```
[8081_브라우저_접속_증거](images/web-8081.png)

### 확인 결과

- 기존 8080 컨테이너를 유지한 상태에서, 같은 이미지로 workspace-web-8081을 추가 실행했다.
- 두 컨테이너가 동시에 Up 상태임을 확인했다.
- 8081에서도 HTTP 200 응답과 직접 작성한 HTML을 확인했다.
- Windows 브라우저에서 localhost:8081에 접속하여 동일한 페이지와 콘텐츠 버전 v1을 확인했다.


## 7. 결과 해석

### 커스텀 이미지 제작

- nginx:alpine을 베이스 이미지로 선택했다.
- COPY로 직접 작성한 HTML을 이미지에 포함했다.
- LABEL로 프로젝트 식별 정보를 추가했다.
- workspace-web:1.0 이미지의 빌드와 컨테이너 실행에 성공했다.
- 빌드 직후 표시된 이미지 ID는 e95b34537b19였다.

### 동일 이미지로 두 컨테이너 실행

| 컨테이너 이름 | 컨테이너 ID | 사용 이미지 | 호스트 주소·포트 | 컨테이너 포트 | 접속 결과 |
|---|---|---|---|---|---|
| workspace-web-8080 | 57d352ca3790 | workspace-web:1.0 | 127.0.0.1:8080 | 80/tcp | HTTP 200, v1 콘텐츠 |
| workspace-web-8081 | f503d339f6a5 | workspace-web:1.0 | 127.0.0.1:8081 | 80/tcp | HTTP 200, v1 콘텐츠 |

같은 이미지로 서로 다른 ID를 가진 두 컨테이너를 실행했다.
두 컨테이너는 같은 웹 콘텐츠를 제공했다.

### 포트 매핑의 역할

브라우저가 접속하는 호스트 포트와 컨테이너 내부의 웹 서버 포트를 구분하여 연결했다.

- localhost:8080 → workspace-web-8080의 80번 포트
- localhost:8081 → workspace-web-8081의 80번 포트

두 컨테이너 모두 내부에서는 80번 포트를 사용했지만, 호스트에서는 8080과 8081로 구분하여 동시에 접속했다.
