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

## 2. Docker 볼륨 영속성

### 목적

컨테이너를 삭제한 뒤 새 컨테이너에 같은 이름 있는 볼륨을 연결하여, 저장한 데이터를 다시 작성하지 않고 읽을 수 있는지 확인한다. 컨테이너 내부에만 작성한 비교용 파일도 함께 확인한다.

### 실습 구성 및 기록 범위

- 수행 일자: 2026-10-31
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- 이미지: `ubuntu:latest`
- 볼륨: `workspace-data`
- 연결 경로: `/data`
- 첫 번째 컨테이너: `workspace-volume-1`
- 두 번째 컨테이너: `workspace-volume-2`
- 주 프로세스: `sleep infinity`
- 볼륨 파일: `/data/persistent.txt`
- 비교용 내부 파일: `/tmp/container-only.txt`

다음은 앞서 실제로 수행해 제공한 로그다. 여러 명령을 한 번에 입력한 부분은 명령과 출력을 대응하도록 정리했고, 호스트 프롬프트는 `$`로 통일했다. 최초 프로젝트 전체 목록과 기존 웹 컨테이너 목록은 이번 검증과 무관하여 생략했다. 바인드 마운트와 볼륨 실습은 서로 다른 시점의 기록이다.

### 볼륨 생성 및 설정 확인

```console
$ cd ~/dev-workstation
$ pwd
/home/user/dev-workstation

$ docker volume ls
DRIVER    VOLUME NAME

$ docker volume create workspace-data
workspace-data

$ docker volume ls
DRIVER    VOLUME NAME
local     workspace-data

$ docker volume inspect workspace-data
[
    {
        "CreatedAt": "2026-10-31T05:23:33Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/workspace-data/_data",
        "Name": "workspace-data",
        "Options": null,
        "Scope": "local"
    }
]
```

이름 있는 볼륨이 없는 상태에서 `workspace-data`를 생성하고 이름·드라이버·생성 시각·저장 경로를 확인했다. 이 저장 경로는 Docker 엔진이 관리하는 경로이며, 이번 실험에서는 호스트에서 직접 편집하지 않고 컨테이너에 연결하여 접근했다.

### 첫 번째 컨테이너 실행 및 볼륨 연결

```console
$ docker run -d \
  --name workspace-volume-1 \
  --mount type=volume,source=workspace-data,target=/data \
  ubuntu:latest sleep infinity
bc3f232b67532966e9550043bb06a73ab47516c676b9e817a4e636d0111b4d7f

$ docker ps --filter name=workspace-volume-1
CONTAINER ID   IMAGE           COMMAND            CREATED          STATUS         PORTS     NAMES
bc3f232b6753   ubuntu:latest   "sleep infinity"   10 seconds ago   Up 9 seconds             workspace-volume-1

$ docker inspect workspace-volume-1 --format '{{json .Mounts}}'
[{"Type":"volume","Name":"workspace-data","Source":"/var/lib/docker/volumes/workspace-data/_data","Destination":"/data","Driver":"local","Mode":"z","RW":true,"Propagation":""}]
```

| 확인 항목 | 실제 설정 |
|---|---|
| 종류 | `Type=volume` |
| 볼륨 이름 | `workspace-data` |
| 연결 경로 | `/data` |
| 쓰기 설정 | `RW=true` |

바인드 마운트 실험의 `Type=bind`와 달리, 이번에는 Docker 볼륨 이름으로 저장소를 연결했다.

### 볼륨 파일과 컨테이너 내부 전용 파일 작성

```console
$ docker exec workspace-volume-1 sh -c \
  'printf "Persistent data from volume test\n" > /data/persistent.txt'

$ docker exec workspace-volume-1 sh -c \
  'printf "Container-only data\n" > /tmp/container-only.txt'

$ docker exec workspace-volume-1 cat /data/persistent.txt
Persistent data from volume test

$ docker exec workspace-volume-1 cat /tmp/container-only.txt
Container-only data

$ docker exec workspace-volume-1 ls -l \
  /data/persistent.txt /tmp/container-only.txt
-rw-r--r-- 1 root root 33 Oct 31 05:24 /data/persistent.txt
-rw-r--r-- 1 root root 20 Oct 31 05:24 /tmp/container-only.txt
```

두 파일이 모두 존재하고 내용이 기록됐음을 확인했다. `/data`는 볼륨에 연결했고, 비교용 `/tmp`에는 별도 마운트를 설정하지 않았다.

### 첫 번째 컨테이너 삭제 및 볼륨 잔존 확인

```console
$ docker rm -f workspace-volume-1
workspace-volume-1

$ docker ps -a --filter name=workspace-volume-1
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker volume ls
DRIVER    VOLUME NAME
local     workspace-data

$ docker volume inspect workspace-data
[
    {
        "CreatedAt": "2026-10-31T05:23:33Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/workspace-data/_data",
        "Name": "workspace-data",
        "Options": null,
        "Scope": "local"
    }
]
```

첫 번째 컨테이너를 단순히 중지한 것이 아니라 삭제했다. 전체 컨테이너 목록에서 해당 컨테이너는 사라졌지만, 볼륨은 같은 이름·생성 시각·저장 경로로 남아 있었다.

### 새 컨테이너에 같은 볼륨 연결

```console
$ docker run -d \
  --name workspace-volume-2 \
  --mount type=volume,source=workspace-data,target=/data \
  ubuntu:latest sleep infinity
6c0da80793710e8dee9deeb227ebc2e516cccabb51ff5b8f6208d0172a72c5fb

$ docker ps --filter name=workspace-volume-2
CONTAINER ID   IMAGE           COMMAND            CREATED         STATUS         PORTS     NAMES
6c0da8079371   ubuntu:latest   "sleep infinity"   5 seconds ago   Up 4 seconds             workspace-volume-2

$ docker inspect workspace-volume-2 --format '{{json .Mounts}}'
[{"Type":"volume","Name":"workspace-data","Source":"/var/lib/docker/volumes/workspace-data/_data","Destination":"/data","Driver":"local","Mode":"z","RW":true,"Propagation":""}]
```

새 컨테이너는 다른 ID를 가졌지만 볼륨 이름과 연결 경로는 동일했다.

### 데이터 유지 및 비교용 파일 부재 확인

```console
$ docker exec workspace-volume-2 cat /data/persistent.txt
Persistent data from volume test

$ docker exec workspace-volume-2 sh -c \
  'if [ -e /tmp/container-only.txt ]; then echo "Unexpected: container-only file exists"; else echo "Container-only file is absent"; fi'
Container-only file is absent
```

두 번째 컨테이너에서는 파일을 다시 작성하지 않고 바로 읽었다. 볼륨 파일은 유지됐고, 첫 번째 컨테이너 내부에만 쓴 파일은 새 컨테이너에 없었다.

### 결과

| 검증 항목 | 관찰 결과 |
|---|---|
| 첫 번째 컨테이너 ID | `bc3f232b6753` |
| 첫 번째 컨테이너 삭제 | `docker rm -f` 후 목록에서 사라짐 |
| 삭제 후 볼륨 | `workspace-data` 유지 |
| 두 번째 컨테이너 ID | `6c0da8079371` — 첫 번째와 다름 |
| 새 컨테이너의 볼륨 | 동일한 `workspace-data`, 동일한 연결 경로 `/data` |
| 새 컨테이너에서 파일 재작성 | 수행하지 않음 |
| 볼륨 파일 | `Persistent data from volume test` 유지 |
| 내부 전용 파일 | 새 컨테이너에서 존재하지 않음 |

### 해석

컨테이너를 삭제한 뒤에도 이름 있는 볼륨이 남았고, 다른 ID의 새 컨테이너에서 같은 볼륨의 파일을 읽는 데 성공했다. 컨테이너 내부에만 쓴 비교용 파일은 새 컨테이너에 없었다.

따라서 영속 데이터는 단순히 컨테이너의 경로에 쓰는 것과 그 경로에 별도 볼륨을 연결해 쓰는 것을 구분해야 한다. 이번에 검증한 것은 컨테이너 삭제에 대한 데이터 유지이며, 볼륨 자체 삭제나 저장 장치 장애에 대한 보호·백업까지 검증한 것은 아니다.

## 3. 두 실험 비교 및 재현 시 주의사항

| 구분 | 바인드 마운트 | 이름 있는 볼륨 |
|---|---|---|
| 연결 대상 | 호스트의 `cli-practice/bind-site` | Docker가 관리하는 `workspace-data` |
| 컨테이너 경로 | `/usr/share/nginx/html` | `/data` |
| 쓰기 설정 | 읽기 전용 | 읽기·쓰기 |
| 검증 초점 | 호스트 수정의 웹 응답 반영 | 컨테이너 삭제 후 기존 데이터 읽기 |
| 관찰 결과 | 재빌드·재시작 없이 v1 → v2 | 새 컨테이너에서 기존 파일 유지 |

- 위 표는 이번 실험의 초점을 비교한 것이며, 바인드 마운트가 컨테이너 삭제 시 반드시 데이터를 잃는다는 의미는 아니다.
- 바인드 마운트의 `$(pwd)`는 프로젝트 루트 기준이다. 개인 PC의 경로는 재현 환경에 맞게 바꾼다.
- 바인드 실험 재시작 시에는 원본 `site/index.html`의 v1을 실험용 디렉터리에 복사해 초기 상태를 준비한다.
- 컨테이너·볼륨 이름이 이미 있으면 상태와 기존 데이터를 먼저 확인한다. 재현을 위해 다른 실습 대상을 임의로 삭제하지 않는다.
- 태그와 출력의 시각·ID는 당시 값이다. 재실험에서는 달라질 수 있다.
- 이 로그 종료 시점에 `workspace-volume-1`은 삭제했고, `workspace-volume-2`와 `workspace-data`는 삭제하지 않았다.
- 이번 검증 과정에서는 볼륨 삭제 명령을 사용하지 않았다.

[프로젝트 README](../README.md)
