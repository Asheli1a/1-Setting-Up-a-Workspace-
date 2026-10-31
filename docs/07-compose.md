# Docker Compose 선택 실습 — 계획 및 기록 초안

## 1. 문서 상태와 기록 원칙

- 초안 작성일: 2026-10-31
- 상태: 미실행 — 아래 명령은 앞으로 수행할 절차이며 실제 수행 로그가 아니다.
- 대상: 선택 미션 중 Compose 단일 서비스와 운영 명령을 우선 수행한다.
- 예정 환경: 기존 Windows / WSL Ubuntu / Docker Desktop 환경
- 기준 디렉터리: `~/dev-workstation` — 다른 PC에서는 clone한 저장소 루트로 바꾼다.
- 기존 필수 과제 기록과 웹 원본, Dockerfile, 볼륨 데이터는 유지한다.
- 설정·명령 예시는 bash/yaml 블록으로, 실행 후 수집한 명령과 출력은 별도의 console 블록으로 기록한다.
- 아직 관찰하지 않은 이미지 ID·컨테이너 ID·시각·HTTP 성공 응답은 만들어 넣지 않는다.
- 초안을 커밋해도 보너스 체크리스트는 미완료로 둔다.

## 2. 선택 미션의 의미와 이번 범위

Dockerfile은 이미지를 어떻게 만들지 정의하고, Compose 파일은 그 이미지를 어떤 서비스 구성으로 실행할지 정의한다. Compose는 Dockerfile을 없애는 기능이 아니라 함께 사용하는 실행 설정 관리 도구다.

| 항목 | 의미·목적 | 이번 단계 |
|---|---|---|
| 단일 서비스 | docker run의 이미지·포트 설정을 YAML로 관리 | 우선 수행 |
| 운영 명령 | 같은 프로젝트의 실행·상태·로그·종료 확인 | 단일 서비스와 함께 수행 |
| 멀티 컨테이너 | 서비스 이름과 내부 네트워크 통신 이해 | 후속 계획 |
| 환경 변수 | 같은 코드에서 설정만 바꿔 동작 변경 | 후속 계획 |
| GitHub SSH | 공개키·개인키로 GitHub 원격 인증 | 별도 후속 실습. 이번 Compose 완료에 포함하지 않음 |

Compose 공식 설명: [What is Docker Compose?](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-docker-compose/)

## 3. 예정 구성과 기존 과제 보호

| 항목 | 계획값 |
|---|---|
| Compose 파일 | 저장소 루트의 `docker-compose.yml` |
| 프로젝트 이름 | `workspace-bonus-single` |
| 서비스 이름 | `web` |
| 빌드 컨텍스트 | 저장소 루트 `.` |
| Dockerfile | 기존 루트 Dockerfile |
| 이미지 태그 | `workspace-web:compose-single` |
| 호스트 주소·포트 | `127.0.0.1:18082` |
| 컨테이너 포트 | `80/tcp` |
| 웹 소스 | 기존 `site/index.html` — v1 |
| 스토리지 | 이번 단계에서는 별도 마운트·볼륨 없음 |

- 기존 `workspace-web:1.0`, `workspace-web:verification` 태그와 구분한다.
- 기존 8080·8081·8082·18080·18081 대신 18082를 계획값으로 쓴다. 실제 점유 여부는 수행 직전에 확인한다.
- 프로젝트 이름을 구분해도 호스트 포트 충돌까지 해결되지는 않는다.
- `container_name`을 고정하지 않고 Compose가 프로젝트·서비스에 따라 생성한 이름을 실제 ps 결과로 기록한다.
- 모든 Compose 명령에서 동일한 `-p`와 `-f`를 사용한다. `down`에서도 다른 프로젝트를 지정하지 않도록 주의한다.
- `workspace-data` 등 기존 볼륨은 연결하거나 삭제하지 않는다.
- 이 문서의 초안에는 실행용 YAML을 예시로 담았으며, 실제 루트 `docker-compose.yml` 파일을 이미 작성·검증했다는 뜻은 아니다.

프로젝트·파일 지정: [docker compose의 -p와 -f](https://docs.docker.com/reference/cli/docker/compose/)

## 4. 실행 전 확인 — 예정 명령

```bash
cd ~/dev-workstation
pwd
git status

docker info
docker compose version
docker compose ls
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
docker image ls workspace-web:compose-single
ss -ltn '( sport = :18082 )'
ls -l Dockerfile site/index.html
```

확인할 사항:

- Docker 엔진에 연결되고 Compose 명령을 사용할 수 있는가?
- 같은 프로젝트 이름이 기존 실습에서 이미 사용 중이지 않은가?
- 같은 이미지 태그가 이미 있다면 이번 실습용인지 확인했는가?
- 포트를 사용 중인 컨테이너·서비스가 없는가? `ss` 출력만으로 Docker Desktop·Windows 전체 포트 점유를 확정하지 않는다. 실행 시 포트 충돌이 나면 기존 서비스를 종료하지 말고 다른 포트를 선택한다.
- 현재 위치가 Dockerfile과 site가 있는 프로젝트 루트인가?
- 기존 변경 사항을 덮어쓸 위험이 없는가?

## 5. Compose 파일 작성 — 설정 예시

기존 `docker-compose.yml`이 있으면 내용을 먼저 확인한다. 새 실습을 위해 임의로 덮어쓰지 않는다.

```bash
nano docker-compose.yml
```

루트 파일에 작성할 계획 설정:

```yaml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    image: workspace-web:compose-single
    ports:
      - "127.0.0.1:18082:80"
```

| 설정 | 의미 |
|---|---|
| `services.web` | web이라는 서비스 정의 |
| `build.context` | 빌드에 사용할 프로젝트 위치 |
| `build.dockerfile` | 사용할 Dockerfile |
| `image` | 빌드한 이미지에 사용할 태그 |
| `ports` | 호스트의 로컬 주소·포트와 컨테이너 포트 연결 |

이 설정은 기존 Dockerfile로 v1 콘텐츠를 포함한 이미지를 빌드하고 실행하는 구성이며, 바인드 마운트 실험은 아니다. 내용이 바뀌면 COPY 기반 이미지의 재빌드가 필요하다.

## 6. 설정 해석 확인 — 예정 명령

```bash
docker compose -p workspace-bonus-single -f docker-compose.yml config
```

기대 확인 사항:

- YAML을 정상적으로 해석하는지 확인한다.
- 빌드 경로·이미지 태그·포트가 계획과 일치하는지 확인한다.
- 오류가 있으면 실행 전에 수정한다.
- config의 성공은 설정 해석 확인이며 웹 서버의 기동·접속 성공 증거는 아니다.
- 향후 환경 변수·비밀정보를 넣는다면 config의 해석 결과에도 값이 나타날 수 있으므로 공개 전 내용을 검토한다.

## 7. 빌드·실행과 상태 확인 — 예정 명령

```bash
docker compose -p workspace-bonus-single -f docker-compose.yml up -d --build

docker compose -p workspace-bonus-single -f docker-compose.yml ps

docker compose -p workspace-bonus-single -f docker-compose.yml images
```

- `--build`: 시작 전에 이미지를 빌드한다.
- `-d`: 백그라운드로 실행한다.
- build 성공과 컨테이너 상태를 따로 확인한다.
- ps에서 Running/Up이어도 HTTP가 정상이라는 뜻은 아니므로 다음 접속 확인까지 수행한다.
- `--build`가 캐시 없는 빌드를 뜻하지는 않는다. 빌드 로그에 CACHED가 있으면 실제 캐시 사용을 기록한다.

근거: [docker compose up](https://docs.docker.com/reference/cli/docker/compose/up/)

## 8. HTTP·브라우저·서버 로그 확인 — 예정 절차

```bash
curl --max-time 5 -i http://localhost:18082

docker compose -p workspace-bonus-single -f docker-compose.yml logs --tail 30 web
```

기대 결과이며 아직 실제 관찰값은 아님:

- HTTP 200 응답
- 직접 작성한 개발 작업실 HTML과 콘텐츠 버전 v1
- web 로그에서 해당 요청에 대한 성공 응답

기동 직후 연결이 실패하면 ps와 logs를 먼저 확인한다. 웹 서버 준비 지연과 지속적인 오류를 구분하며 최초 실패와 후속 확인 결과를 실제대로 기록한다.

Windows 브라우저에서도 `http://localhost:18082`에 접속한다. 주소창의 포트와 페이지가 함께 보이게 캡처하고, 다른 창·탭·알림·인증정보를 검토한다.

캡처 예정 파일명은 `docs/images/compose-single-18082.png`이다. 아직 파일을 생성하지 않았으므로 이미지 링크는 추가하지 않는다. 실제 파일을 추가한 뒤 이 문서에서 상대 경로 `images/compose-single-18082.png`로 연결한다.

## 9. 해당 Compose 프로젝트 종료·정리 — 예정 명령

아래는 향후 이번 프로젝트의 종료를 검증할 때 사용할 명령이다. 지금 실행·삭제했다는 뜻은 아니다.

```bash
docker compose -p workspace-bonus-single -f docker-compose.yml down

docker compose -p workspace-bonus-single -f docker-compose.yml ps -a

docker ps -a --filter label=com.docker.compose.project=workspace-bonus-single
```

- `down`은 단순 중지가 아니라 해당 Compose 구성의 서비스 컨테이너와 기본 네트워크 등을 제거한다.
- 이 구성은 볼륨을 정의하지 않는다. `down -v`, `--rmi`, `prune` 같은 추가 정리 옵션은 사용하지 않는다.
- 기본 down만으로 빌드 이미지가 삭제됐다고 기록하지 않는다.
- ps와 프로젝트 라벨 필터로 이번 대상이 남아 있는지 확인한다.
- 기존 실습 컨테이너·이미지·볼륨은 정리 대상에 포함하지 않는다.

근거: [docker compose down](https://docs.docker.com/reference/cli/docker/compose/down/)

## 10. 실제 수행 결과 — 아직 미작성

실습 후 아래 표를 실제 값으로 채우고, 각 단계의 입력 명령과 출력을 console 코드블록으로 추가한다. 앞의 예정 명령을 실행 로그로 복사해 완료 처리하지 않는다.

| 기록 항목 | 현재 상태 |
|---|---|
| 실제 수행 일시 | 미실행 |
| 실제 소스 커밋 SHA | 미기록 |
| Compose 버전 | 이번 실습에서 미확인 |
| config 결과 | 미실행 |
| 빌드 결과·표시 ID·캐시 여부 | 미실행 |
| 프로젝트·컨테이너 이름·ID·상태 | 미실행 |
| 실제 호스트 주소·포트 | 미실행 — 계획값 127.0.0.1:18082 |
| HTTP 응답 | 미실행 |
| 브라우저 캡처 | 미수집 |
| 서버 로그 | 미실행 |
| down과 종료 후 목록 | 미실행 |
| 이번 단계 오류·해결 | 아직 관찰 없음 |

기록 순서: 수행 전 확인 → 설정 원문 → config → up/빌드 → ps/images → curl → logs → 브라우저 → down → 종료 후 목록.

오류가 발생하면 증상 → 원인 가설 → 확인 명령·결과 → 해결 또는 대안 → 재확인 순서로 기록한다. 예상 오류를 실제 발생한 오류로 작성하지 않는다.

## 11. 완료 체크리스트 — 실행 후에만 변경

- [ ] 실제 docker-compose.yml을 작성하고 config 결과를 확인했다.
- [ ] Compose로 빌드·실행하고 실제 컨테이너 상태를 확인했다.
- [ ] HTTP 응답과 v1 콘텐츠를 확인했다.
- [ ] 주소창 포함 브라우저 캡처를 추가했다.
- [ ] web 서비스 로그에서 요청 결과를 확인했다.
- [ ] up·ps·logs·down 명령과 실제 결과를 기록했다.
- [ ] 해당 프로젝트의 종료 후 상태를 확인했다.
- [ ] 새 로그·설정·캡처의 민감정보를 검토했다.

단일 서비스와 운영 명령을 검증한 경우에만 README의 해당 두 체크 항목을 완료로 바꾼다. 멀티 컨테이너·환경 변수·SSH 항목은 별도의 실행 증거가 필요하다.

## 12. 후속 확장 계획 — 미실행

### 멀티 컨테이너 통신

웹과 검증용 보조 서비스를 같은 Compose 구성에 정의한다. 보조 서비스에서 `http://web:80`으로 요청하고 실제 HTML 응답과 web 로그를 확인한다. 서비스 이름 web으로 찾는 내부 통신과 호스트의 localhost:18082 접속을 구분한다. 컨테이너 안의 localhost는 일반적으로 그 컨테이너 자신이며 다른 web 서비스 주소를 뜻하지 않는다.

두 서비스를 실행한 사실만으로 완료 처리하지 않는다. 준비 전 요청 실패가 발생할 수 있으므로 재시도·준비 확인 방법도 설계한다.

근거: [Networking in Compose](https://docs.docker.com/compose/how-tos/networking/)

### 환경 변수로 실제 동작 변경

NGINX 설정 템플릿의 listen 포트 같은 값을 환경 변수로 치환하고, 생성된 설정·컨테이너 내부 포트·호스트 매핑·HTTP 응답을 함께 비교하는 방향으로 진행한다. 실제 파일과 포트 설계는 후속 단계에서 확정한다.

`APP_ENV=dev` 같은 변수를 전달하기만 하면 NGINX 동작이 자동으로 바뀌는 것은 아니다. 단순 변수 출력이나 호스트 매핑만의 변경을 NGINX 내부 listen 포트 변경으로 기록하지 않는다. 값 변경을 실제로 사용하는 설정이 있어야 한다.

근거: [NGINX 공식 이미지의 환경 변수 템플릿 안내](https://hub.docker.com/_/nginx)

### SSH 인증

Compose와 별개의 GitHub 인증 실습으로 진행한다. 개인키는 로컬에서 보호하고 공개키만 GitHub에 등록한다. 본인 계정의 SSH 인증과 실제 push 성공을 검증한다. 공용 장비의 기존 타인 키를 덮어쓰거나 개인키를 저장소에 추가하지 않는다.

근거: [GitHub SSH 연결 안내](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

[NGINX 이미지와 포트 실습](03-web.md) · [스토리지 실습](04-storage.md) · [Git·GitHub·VSCode 연동](05-git-github.md) · [프로젝트 README](../README.md)
