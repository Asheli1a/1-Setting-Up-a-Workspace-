# 볼륨 백업·복원 검증

## 목적과 범위

Docker 볼륨의 데이터를 tar.gz로 백업하고, 새 볼륨에 복원한 뒤 원본과 같은지 체크섬으로 대조한다.

- 수행 일시: 2026-11-03 16:26~16:29 (KST)
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- 실습 식별자: `20261103-162630-1099`
- 복원·검증 구간은 터미널 출력 원문이다. 원본 볼륨과 tar 생성 구간은 대화 기록 기준이다.
- 붙여 넣은 명령에서 빠진 줄바꿈 `\`는 실행 가능한 형태로 고쳐 적었다.

## 실습 변수

```console
$ printf 'backup_run=%s\nsource_volume=%s\nrestore_volume=%s\nbackup_dir=%s\n' \
    "${backup_run:?기존 터미널의 변수가 필요합니다}" \
    "$source_volume" "$restore_volume" "$backup_dir"
backup_run=20261103-162630-1099
source_volume=workspace-backup-src-20261103-162630-1099
restore_volume=workspace-backup-dst-20261103-162630-1099
backup_dir=/home/user/workspace-backups/volume-20261103-162630-1099
```

백업 폴더는 저장소 밖(`~/workspace-backups`)에 두어 Git에 섞이지 않게 했다.

## 1. 백업 생성 (대화 기록)

- 원본 볼륨에 일반 파일, 숨김 파일, 하위 폴더 파일 3개를 만들고 파일별 SHA-256을 `source.sha256`에 저장했다(3줄).
- 원본 볼륨을 읽기 전용으로 연결해 `tar -czvf`로 `volume-data.tar.gz`를 만들었다(270바이트, 압축 목록에 파일 3개와 폴더 포함).
- `volume-data.tar.gz.sha256`로 압축 파일 검사 결과 `OK`.

이 구간의 명령 출력 원문은 보관본에 없다.

## 2. 복원 전 확인

```console
$ if [ "$source_volume" = "$restore_volume" ]; then
>   echo "원본과 복원 대상이 같습니다. 진행하지 마세요."
> else
>   echo "원본과 복원 대상이 구분되어 있습니다."
> fi
원본과 복원 대상이 구분되어 있습니다.
```

복원용 볼륨은 같은 이름이 없을 때만 실습 라벨을 붙여 만들었다.

```console
$ docker volume create \
    --label "com.asheli1a.backup-run=$backup_run" \
    "$restore_volume"
workspace-backup-dst-20261103-162630-1099

$ docker volume inspect "$source_volume" "$restore_volume" \
    --format 'Name={{.Name}} Driver={{.Driver}} Labels={{json .Labels}}'
Name=workspace-backup-src-20261103-162630-1099 Driver=local Labels={"com.asheli1a.backup-run":"20261103-162630-1099"}
Name=workspace-backup-dst-20261103-162630-1099 Driver=local Labels={"com.asheli1a.backup-run":"20261103-162630-1099"}
```

## 3. 빈 볼륨에 복원

라벨이 맞고 원본과 다른 볼륨일 때만 복원했다. 컨테이너 안에서도 복원 볼륨이 비어 있는지 확인하고, 비어 있지 않으면 중단하게 했다. 백업 폴더는 읽기 전용으로 연결했고 네트워크는 끊었다.

```console
$ docker run --rm --network none \
    --mount "type=volume,source=$restore_volume,target=/restore" \
    --mount "type=bind,source=$backup_dir,target=/backup,readonly" \
    ubuntu:latest sh -c '
      set -eu
      if [ -n "$(find /restore -mindepth 1 -print -quit)" ]; then
        echo "복원 볼륨이 비어 있지 않습니다. 복원하지 않습니다."
        exit 1
      fi
      echo "복원 대상이 비어 있습니다."
      cd /backup
      sha256sum -c volume-data.tar.gz.sha256
      tar -xzvf volume-data.tar.gz -C /restore
    '
복원 대상이 비어 있습니다.
volume-data.tar.gz: OK
./
./.backup-config
./persistent.txt
./nested/
./nested/note.txt
```

## 4. 복원 내용 확인

```console
$ docker run --rm --network none \
    --mount "type=volume,source=$restore_volume,target=/restore,readonly" \
    --mount "type=bind,source=$backup_dir,target=/backup,readonly" \
    ubuntu:latest sh -c '
      set -eu
      ls -la /restore /restore/nested
      for file in /restore/persistent.txt /restore/.backup-config /restore/nested/note.txt
      do
        printf "\n--- %s ---\n" "$file"
        cat "$file"
      done
      cd /restore
      sha256sum -c /backup/source.sha256
    '
/restore:
total 20
drwxr-xr-x 3 root root 4096 Nov  3 07:26 .
drwxr-xr-x 1 root root 4096 Nov  3 07:29 ..
-rw-r--r-- 1 root root   17 Nov  3 07:26 .backup-config
drwxr-xr-x 2 root root 4096 Nov  3 07:26 nested
-rw-r--r-- 1 root root   27 Nov  3 07:26 persistent.txt

/restore/nested:
total 12
drwxr-xr-x 2 root root 4096 Nov  3 07:26 .
drwxr-xr-x 3 root root 4096 Nov  3 07:26 ..
-rw-r--r-- 1 root root   22 Nov  3 07:26 note.txt

--- /restore/persistent.txt ---
Volume backup verification
--- /restore/.backup-config ---
backup-config=v1
--- /restore/nested/note.txt ---
Nested file preserved
./.backup-config: OK
./nested/note.txt: OK
./persistent.txt: OK
```

파일 수정 시각은 복원 후에도 07:26으로 유지됐다. 컨테이너 시각은 UTC라서 KST 16:26과 같은 시각이다.

## 5. 체크섬 목록 비교

```console
$ docker run --rm --network none \
    --mount "type=volume,source=$restore_volume,target=/restore,readonly" \
    ubuntu:latest sh -c '
      set -eu
      cd /restore
      find . -type f -print0 | sort -z | xargs -0 -r sha256sum
    ' > "$backup_dir/restored.sha256"

$ cat "$backup_dir/restored.sha256"
96bb9ae9ad929311e2bcf712625623ffea0368511d0d449676c7c6495415d24d  ./.backup-config
4ce220831ffc74f61ec5d14ba8cd2428624f23bb389e79b0b49a674c08252209  ./nested/note.txt
f1f3b906baf19871b5ae52ddb026cd98f6549e766e5360eb11b15a7739ad8bfb  ./persistent.txt

$ wc -l "$backup_dir/restored.sha256"
3 /home/user/workspace-backups/volume-20261103-162630-1099/restored.sha256

$ diff -u "$backup_dir/source.sha256" "$backup_dir/restored.sha256"
$ compare_exit=$?
$ printf 'checksum_compare_exit=%s\n' "$compare_exit"
checksum_compare_exit=0
```

`diff` 출력이 없고 종료 코드가 0이었다.

## 6. 종료 후 상태

```console
$ docker volume ls --filter "label=com.asheli1a.backup-run=$backup_run"
DRIVER    VOLUME NAME
local     workspace-backup-dst-20261103-162630-1099
local     workspace-backup-src-20261103-162630-1099

$ ls -lh "$backup_dir"
total 16K
-rw-r--r-- 1 user user 250 Nov  3 16:29 restored.sha256
-rw-r--r-- 1 user user 250 Nov  3 16:27 source.sha256
-rw-r--r-- 1 user user 270 Nov  3 16:27 volume-data.tar.gz
-rw-r--r-- 1 user user  85 Nov  3 16:27 volume-data.tar.gz.sha256

$ git status --short
R  README -> README.md
?? cli-practice/port-conflict/
```

볼륨 2개와 백업 파일 4개는 삭제하지 않고 보관했다. 백업 폴더가 저장소 밖이라 `git status`에 나오지 않는다.

## 검증 결과

| 확인 항목 | 결과 |
|---|---|
| 원본과 복원 대상 이름 | 구분됨 |
| 복원 볼륨 라벨 | 실습 식별자와 일치 |
| 복원 전 대상 볼륨 | 비어 있음 |
| 압축 파일 체크섬 | `volume-data.tar.gz: OK` |
| 복원 항목 | 파일 3개(숨김 파일, 하위 폴더 파일 포함) |
| 파일 내용 | 세 파일 모두 기대한 문자열 |
| 원본 체크섬 대조 | 세 파일 모두 `OK` |
| 복원본 목록 vs `source.sha256` | 차이 없음, 종료 코드 0 |
| 복원 중 네트워크, 백업 폴더 | `--network none`, 읽기 전용 |
| 볼륨·백업 파일 | 삭제 없이 보관 |

## 남은 확인

- 원본 볼륨 생성과 tar 생성 단계는 출력 전문이 없고 대화 기록 기준이다.
- 백업 뒤 원본 볼륨이 바뀌지 않았는지는 다시 조회하지 않았다. 원본과의 일치는 백업 시점에 만든 체크섬 목록과의 비교다.
- 파일 3개의 작은 샘플이다. 큰 데이터, 다양한 소유자·권한, 심볼릭 링크, 실행 중인 DB의 백업은 확인하지 않았다.
- 대상 볼륨이 비어 있지 않을 때 중단하는 분기는 실행하지 않았다.
- `ubuntu:latest`는 버전을 고정하지 않았다.

## 운영 시 참고 (권장 사항, 이번 실습에서 실행하지 않음)

이번에는 작은 샘플 파일로 tar 백업과 복원을 한 번 확인했다. 실제 데이터에 적용한다면 아래를 고려한다. 이 목록은 실행한 내용이 아니라 참고 사항이다.

| 항목 | 권장 내용 |
|---|---|
| 방식 | 보조 컨테이너로 볼륨을 읽기 전용 연결하고 tar로 묶는 방식이 기본이다. 데이터가 크면 변경분만 복사하는 도구(rsync, restic 등)를 검토한다. |
| 일관성 | 실행 중인 DB의 파일을 그대로 tar로 묶으면 복원이 깨질 수 있다. 컨테이너를 멈추고 백업하거나 `mysqldump`, `pg_dump` 같은 덤프 도구를 쓴다. |
| 복원 대상 | 원본을 덮어쓰지 않고 새 빈 볼륨에 복원한다. 이번 실습의 방식이다. |
| 검증 | 압축 파일 체크섬과 복원 후 파일별 체크섬을 함께 확인한다. 주기적으로 복원 연습을 한다. |
| 보관 위치 | 볼륨과 저장소 밖에 두고, 중요하면 다른 저장 장치나 원격에도 사본을 둔다. |
| 주기 | 데이터가 바뀌는 빈도와 잃어도 되는 시간으로 정한다. 하루에 한 번 바뀌는 데이터라면 하루 1회 이상처럼 정한다. 이번 실습 데이터는 바뀌지 않아 수동 1회로 충분했다. |

참고: [Docker Desktop 데이터 백업·복원](https://docs.docker.com/desktop/settings-and-maintenance/backup-and-restore/)에서 이름 있는 볼륨은 볼륨 백업·복원 문서를 따로 보라고 안내한다.

## 재실습 시 주의

- 실습 식별자와 라벨이 같은 볼륨만 대상으로 한다.
- 복원 대상은 새 빈 볼륨으로 하고, 원본 볼륨에는 복원하지 않는다.
- `docker volume rm`, `docker volume prune`, `docker system prune`은 쓰지 않는다. 다른 실습의 볼륨까지 지울 수 있다.

[프로젝트 README](../README.md)
