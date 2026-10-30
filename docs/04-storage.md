# 바인드 마운트 및 볼륨 실습

## 1. 바인드 마운트 변경 반영

### 목적
호스트 파일 변경이 이미지 재빌드와 컨테이너 재시작 없이
웹 응답에 반영되는지 확인한다.

### 실습 구성
- 이미지: workspace-web:1.0
- 컨테이너: workspace-web-bind
- 호스트 경로: 프로젝트의 cli-practice/bind-site
- 컨테이너 경로: /usr/share/nginx/html
- 접속 주소: http://localhost:8082
- 마운트 모드: 읽기 전용
- 기존 site/index.html은 변경하지 않고 복사본으로 실험한다.

### 파일 준비 및 컨테이너 실행
```console
$ cd ~/dev-workstation
mkdir -p cli-practice/bind-site
cp -v site/index.html cli-practice/bind-site/index.html
'site/index.html' -> 'cli-practice/bind-site/index.html'

$ pwd
/home/user/dev-workstation

$ cat cli-practice/bind-site/index.html
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

$ docker ps -a
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS                         PORTS                    NAMES
f503d339f6a5   workspace-web:1.0   "/docker-entrypoint.…"   31 minutes ago   Up 31 minutes                  127.0.0.1:8081->80/tcp   workspace-web-8081
57d352ca3790   workspace-web:1.0   "/docker-entrypoint.…"   47 minutes ago   Up 47 minutes                  127.0.0.1:8080->80/tcp   workspace-web-8080
ba7726aba893   ubuntu:latest       "bash"                   2 hours ago      Exited (0) About an hour ago                            workspace-ubuntu
c83798db7dd1   hello-world         "/hello"                 27 hours ago     Exited (0) 27 hours ago                                 ecstatic_shamir

$ docker run -d \
  --name workspace-web-bind \
  -p 127.0.0.1:8082:80 \
  --mount "type=bind,source=$(pwd)/cli-practice/bind-site,target=/usr/share/nginx/html,readonly" \
  workspace-web:1.0
7c04d46644d182c51d27666a7396342383a6e8da2aed13830ea816b669b5287b
```
### 마운트 설정의 의미

| 설정 | 의미 |
|---|---|
| `type=bind` | 호스트 디렉터리를 컨테이너에 연결 |
| `source=...` | 연결할 호스트 디렉터리 |
| `target=...` | 컨테이너에서 연결받을 경로 |
| `readonly` | 컨테이너 쪽에서 연결된 파일에 쓰지 못하도록 설정 |

읽기 전용 설정은 컨테이너의 쓰기를 제한한다.
호스트에서는 파일을 편집할 수 있으며, 컨테이너는 변경된 파일을 읽어 제공할 수 있다.
메모: 이번에는 inspect로 읽기 전용 설정을 확인한 것이고, 컨테이너 내부에서 쓰기 실패까지 시험한 것은 아님.


### 마운트 설정 확인
```console
$ docker ps --filter name=workspace-web-bind
CONTAINER ID   IMAGE               COMMAND                  CREATED              STATUS              PORTS                    NAMES
7c04d46644d1   workspace-web:1.0   "/docker-entrypoint.…"   About a minute ago   Up About a minute   127.0.0.1:8082->80/tcp   workspace-web-bind

$ docker inspect workspace-web-bind --format '{{json .Mounts}}'
[{"Type":"bind","Source":"/home/user/dev-workstation/cli-practice/bind-site","Destination":"/usr/share/nginx/html","Mode":"","RW":false,"Propagation":"rprivate"}]
```
### 마운트 설정 확인 결과

- 종류: `bind`
- 호스트 경로: `/home/user/dev-workstation/cli-practice/bind-site`
- 컨테이너 경로: `/usr/share/nginx/html`
- 쓰기 허용 여부: `RW=false` — 읽기 전용 설정


### 변경 전 확인
```console
$ curl -i http://localhost:8082
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Fri, 30 Oct 2026 09:42:59 GMT
Content-Type: text/html
Content-Length: 394
Last-Modified: Fri, 30 Oct 2026 09:37:42 GMT
Connection: keep-alive
ETag: "6ae46566-18a"
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
[8082_브라우저-접속_증거](images/bind-before.png)


### 호스트 파일 수정
```console
$ nano cli-practice/bind-site/index.html
user@4F-103:~/dev-workstation$ cat cli-practice/bind-site/index.html
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
  <p id="version">콘텐츠 버전: v2 - 바인드 마운트 반영</p>
</body>
</html>
```
### 검증 조건

변경 전 응답을 확인한 뒤 호스트의 HTML만 수정했다.
변경 후 응답을 확인할 때까지 다음 작업은 수행하지 않았다.

- 이미지 재빌드: `docker build`
- 컨테이너 재시작: `docker restart`
- 컨테이너 중지 후 시작: `docker stop` / `docker start`
파일 수정만으로 반영되는지를 검증해야 하기 때문


### 변경 후 확인
```console
$ curl -i http://localhost:8082
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Fri, 30 Oct 2026 09:49:12 GMT
Content-Type: text/html
Content-Length: 423
Last-Modified: Fri, 30 Oct 2026 09:47:03 GMT
Connection: keep-alive
ETag: "6ae46797-1a7"
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
  <p id="version">콘텐츠 버전: v2 - 바인드 마운트 반영</p>
</body>
</html>

$ docker ps --filter name=workspace-web-bind
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS          PORTS                    NAMES
7c04d46644d1   workspace-web:1.0   "/docker-entrypoint.…"   10 minutes ago   Up 10 minutes   127.0.0.1:8082->80/tcp   workspace-web-bind

$ curl -s http://localhost:8080
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

$ curl -s http://localhost:8081
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
[8082_변경-후_브라우저-접속_증거](images/bind-after.png)


### 결과

| 검증 항목 | 관찰 결과 |
|---|---|
| 변경 전 8082 응답 | v1 |
| 변경 후 8082 응답 | v2 - 바인드 마운트 반영 |
| 이미지 재빌드 | 수행하지 않음 |
| 컨테이너 재시작 | 수행하지 않음 |
| 변경 전후 컨테이너 ID | `7c04d46644d1`로 동일 |
| 변경 전후 실행 상태 | `Up About a minute` → `Up 10 minutes` |
| 기존 8080·8081 응답 | v1 유지 |

컨테이너 ID가 동일하고 실행 시간이 증가한 것을 확인했다.
이는 호스트 파일 수정 후에도 기존 컨테이너가 계속 실행됐다는 관찰 결과를 뒷받침한다.


### 해석
8082 컨테이너는 이미지에 포함된 HTML 대신, 바인드 마운트로 연결한 호스트의 실험용 HTML을 제공했다.

호스트 파일만 수정했으며, 이미지 재빌드와 컨테이너 재시작 없이 웹 응답이 v1에서 v2로 변경됐다.

반면 바인드 마운트를 사용하지 않은 기존 8080·8081 컨테이너는 이미지에 포함된 v1 콘텐츠를 계속 제공했다.

따라서 이번 실험에서 확인한 것은 호스트 파일 변경의 실시간 반영이다.