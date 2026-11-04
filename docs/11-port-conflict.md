# 포트 충돌 검증

## 목적과 범위

호스트 포트가 이미 사용 중일 때 어떤 일이 생기는지 두 환경에서 재현하고, 점유자를 찾아 해제한 뒤 같은 포트를 다시 쓰는 과정을 기록한다.

- 수행 일자: 2026-11-03 (KST), 초기화된 공용 노트북
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- 1부: Python HTTP 서버 두 개, `127.0.0.1:18085`
- 2부: Docker 컨테이너 두 개, `127.0.0.1:18086`

값의 출처는 둘로 나눠 표시한다.

| 표기 | 의미 |
|---|---|
| 원본 출력 | 터미널 출력을 그대로 옮긴 것 |
| 대화 기록 | 실습 대화에서 정리된 값. 출력 전문은 보관본에 없음 |

2부 첫 충돌 단계는 이미지 다운로드 출력과 입력이 섞여 있어서 복원하지 않았다. 붙여 넣은 명령에서 빠진 줄바꿈 `\`는 실행 가능한 형태로 고쳐 적었다.

## 실습 환경

| 항목 | 내용 |
|---|---|
| 장비 | 초기화 후 다시 쓴 공용 노트북. 이전 환경 표는 이 장비의 결과로 덮어쓰지 않음 |
| 시작 위치 | `/mnt/c/Users/User` (저장소 없음). WSL 홈에 HTTPS로 새로 clone |
| Docker | Client·Server 정상, 볼륨 없음 |
| 기존 컨테이너 | `mybox`, `unruffled_blackburn`. 용도를 몰라서 시작·삭제하지 않음 |
| 도구 | `python3`, `ss`, `ps`, `curl` 사용 가능 |
| 사전 점검 | 18085·18086 리스닝 항목 없음 |
| Git | 이 저장소에만 `--local`로 이름·이메일 설정. 이전 장비의 SSH 키는 사용하지 않음 |

clone 직후 최신 커밋이 `Rename README.md to README`였다. 이 내용은 [트러블슈팅 사례 9](06-troubleshooting.md#9-clone한-저장소의-readme-파일명이-readme로-바뀌어-있음)에 정리했다.

## 1부. Python 서버 포트 충돌

실습용 `site/index.html`만 제공하도록 `--directory`를 지정하고, `127.0.0.1`에만 묶었다.

```bash
python3 -u -m http.server 18085 --bind 127.0.0.1 --directory "$lab/site" > "$first_log" 2>&1 &
server_pid=$!
```

| 단계 | 결과 | 출처 |
|---|---|---|
| 첫 서버 | PID 1666, 부모 PID 1099(현재 셸), `127.0.0.1:18085` 리스닝, HTTP 200, 108바이트 | 대화 기록 |
| 같은 포트로 두 번째 서버 | 종료 코드 1, `OSError: [Errno 98] Address already in use` | 대화 기록 |
| 충돌 뒤 첫 서버 | 계속 리스닝, HTTP 200 | 대화 기록 |

### 점유자 확인과 종료

이름이 `python3`라는 이유로 종료하지 않았다. 실행 명령 전체와 부모 PID가 방금 만든 서버와 같을 때만 SIGTERM을 보냈다.

```bash
expected_cmd="python3 -u -m http.server 18085 --bind 127.0.0.1 --directory $lab/site"
actual_cmd="$(ps -ww -p "$server_pid" -o args=)"
actual_ppid="$(ps -p "$server_pid" -o ppid= | tr -d '[:space:]')"

if [ "$actual_cmd" = "$expected_cmd" ] && [ "$actual_ppid" = "$$" ]; then
  kill -TERM "$server_pid" && wait "$server_pid"
fi
```

| 단계 | 결과 | 출처 |
|---|---|---|
| 종료 | 확인한 PID에만 SIGTERM. `wait`가 신호 종료 값(143)을 반환할 수 있고, 의도한 종료라 장애로 보지 않음 | 대화 기록 |
| 포트 해제 | 기존 PID와 LISTEN 항목이 사라지고 `curl` 연결 실패 | 대화 기록 |
| 같은 포트 재사용 | 새 PID 1853으로 18085 실행, HTTP 200 | 대화 기록 |
| 정리 | 재사용 서버도 같은 방식으로 종료, PID·LISTEN 항목 없음 | 대화 기록 |

`killall`, `kill -9`는 쓰지 않았다.

## 2부. Docker 컨테이너 포트 충돌

실습 때마다 라벨을 붙여 기존 컨테이너와 구분했다.

- 실습 식별자: `20261103-161131-1099` (끝의 1099는 셸 PID)
- 점유 컨테이너: `workspace-port-owner-20261103-161131-1099`
- 충돌 컨테이너: `workspace-port-retry-20261103-161131-1099`
- 라벨: `com.asheli1a.port-run=20261103-161131-1099`
- 이미지: `nginx:alpine`

```bash
docker run -d --name "$port_owner" \
  --label "com.asheli1a.port-run=$port_run" \
  -p 127.0.0.1:18086:80 nginx:alpine
```

| 단계 | 결과 | 출처 |
|---|---|---|
| 점유 컨테이너 | `e83fe33bea10`, Up, `18086 → 80/tcp`, HTTP 200 | 대화 기록 |
| 같은 포트로 두 번째 컨테이너 | `fedbfc98b2a8`가 `Created`로 남음, 오류 `port is already allocated`, `docker run` 종료 코드 125 | 대화 기록 |
| 점유 컨테이너 중지 | 라벨이 맞을 때만 `docker stop`, 이후 `Exited (0)` | 원본 출력 |

충돌로 `Created`에 머문 컨테이너가 이미 있으니 같은 이름으로 `docker run`을 다시 하지 않고, 점유 컨테이너를 멈춘 뒤 `docker start`로 시작했다.

### 예상과 다른 관찰

`running`인데 `CurrentPorts`가 `{"80/tcp":[]}`로 비어 있었고 호스트 접속이 실패했다. 새 컨테이너를 `-p`로 만들어 복구했다. 원인은 확인하지 못했다. 명령 출력과 분석은 [트러블슈팅 사례 8](06-troubleshooting.md#8-중지-후-다시-시작한-docker-컨테이너의-포트-매핑이-비어-있음)에 있다.

```console
$ docker ps -a --filter "label=com.asheli1a.port-run=$port_run"
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS                     PORTS                     NAMES
cc93dd0b87a0   nginx:alpine   "/docker-entrypoint.…"   5 seconds ago   Up 4 seconds               127.0.0.1:18086->80/tcp   workspace-port-recovered-20261103-161131-1099
e83fe33bea10   nginx:alpine   "/docker-entrypoint.…"   9 minutes ago   Exited (0) 6 minutes ago                             workspace-port-owner-20261103-161131-1099
```

### 정리

라벨이 모두 맞을 때만 recovered를 중지하고, owner와 recovered 두 개를 이름으로 지정해 삭제했다. `-f`와 `prune`은 쓰지 않았다. 정리 뒤 실습 라벨의 컨테이너가 없었고 18086 접속이 실패했으며, `nginx:alpine` 이미지는 남겼다(대화 기록). `mybox`, `unruffled_blackburn`은 건드리지 않았다.

## 검증 결과

| 확인 항목 | 결과 |
|---|---|
| Python 서버 충돌 | 재현 (`Errno 98`, 종료 코드 1) |
| 점유자 확인 | PID, 부모 PID, 실행 명령으로 확인 |
| 종료 방식 | 확인한 PID에만 SIGTERM |
| 해제 후 같은 포트 재사용 | 성공 (새 PID, HTTP 200) |
| Docker 충돌 | 재현 (`port is already allocated`, 종료 코드 125) |
| 점유 컨테이너 중지 후 기존 컨테이너 start | 실행은 됐지만 호스트 매핑 없음 |
| 새 컨테이너에 `-p` 명시 | 매핑과 HTTP 200 확인 |
| 기존 공용 컨테이너 | 변경 없음 |

## 남은 확인

- Python 1부의 PID, 응답 크기, 종료 코드와 2부 첫 충돌의 컨테이너 ID, 오류 문구는 대화 기록 기준이다. 터미널 출력 전문이 있으면 교체한다.
- 포트 매핑이 비었던 원인은 확인하지 못했다.
- `127.0.0.1`에 묶은 로컬 실습이다. Windows 쪽 프로세스가 잡은 포트와 외부 접근은 확인하지 않았다.

[프로젝트 README](../README.md)
