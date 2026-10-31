# 터미널 기본 조작 및 권한 실습

## 실습 개요

파일·디렉터리 조작과 경로 해석을 확인하고, 파일의 쓰기 권한과 디렉터리의 탐색 권한을 실제 접근 결과로 검증했다.

- 기본 조작 수행 일자: 2026-10-29
- 권한 실험 수행 일자: 2026-10-30
- 실행 환경: WSL Ubuntu / 일반 사용자 `user`
- 아래 코드블록은 수행 당시의 기록이다. 출력의 경로·시각·크기는 당시 값이며 재실험에서 달라질 수 있다.
- 권한 실험은 `sudo` 없이 수행했다. 예기치 않은 오류가 아니라 의도한 접근 거부를 포함한다.
- 1~6번은 기본 조작을 순서대로 실행한 기록이며, 7번은 프로젝트 루트에서 별도로 시작한다.

## 1. 작업 디렉터리 생성과 이동

### 명령과 출력

실행 위치: `~/dev-workstation`
```console
$ mkdir -p cli-practice
$ mkdir -v cli-practice/basic-ops
mkdir: created directory 'cli-practice/basic-ops'

$ cd cli-practice/basic-ops

$ pwd
/home/user/dev-workstation/cli-practice/basic-ops

$ ls -la
total 8
drwxr-xr-x 2 user user 4096 Oct 29 17:39 .
drwxr-xr-x 4 user user 4096 Oct 29 17:39 ..
```

### 확인 결과
실습 폴더를 만들고 `pwd`로 현재 위치를 확인했다.

## 2. 파일 생성·내용 확인·숨김 파일 확인

### 명령과 출력
```console
$ touch empty.txt

$ printf 'Workspace CLI practice\n' > note.txt
$ printf 'Hidden file example\n' > .hidden-note

$ ls -l
total 4
-rw-r--r-- 1 user user  0 Oct 29 17:45 empty.txt
-rw-r--r-- 1 user user 23 Oct 29 17:45 note.txt

$ ls -la
total 16
drwxr-xr-x 2 user user 4096 Oct 29 17:45 .
drwxr-xr-x 4 user user 4096 Oct 29 17:39 ..
-rw-r--r-- 1 user user   20 Oct 29 17:45 .hidden-note
-rw-r--r-- 1 user user    0 Oct 29 17:45 empty.txt
-rw-r--r-- 1 user user   23 Oct 29 17:45 note.txt

$ cat note.txt
Workspace CLI practice

$ cat .hidden-note
Hidden file example

$ wc -c empty.txt
0 empty.txt
```

### 확인 결과
빈 파일, 내용이 있는 파일, 숨김 파일을 생성했다.
파일 내용과 빈 파일의 크기, 숨김 파일의 표시 여부를 확인했다.

## 3. 파일 복사

### 명령과 출력
```console
$ cp -v note.txt note-copy.txt
'note.txt' -> 'note-copy.txt'

$ ls -l note.txt note-copy.txt
-rw-r--r-- 1 user user 23 Oct 29 17:46 note-copy.txt
-rw-r--r-- 1 user user 23 Oct 29 17:45 note.txt

$ cat note.txt
Workspace CLI practice

$ cat note-copy.txt
Workspace CLI practice
```

### 확인 결과
`note.txt`를 `note-copy.txt`로 복사했다.
두 파일이 모두 존재하고, `cat`으로 확인한 내용이 같았다.

## 4. 이름 변경과 이동

### 명령과 출력
```console
$ mv -v note-copy.txt renamed-note.txt
renamed 'note-copy.txt' -> 'renamed-note.txt'

$ ls -la
total 20
drwxr-xr-x 2 user user 4096 Oct 29 17:47 .
drwxr-xr-x 4 user user 4096 Oct 29 17:39 ..
-rw-r--r-- 1 user user   20 Oct 29 17:45 .hidden-note
-rw-r--r-- 1 user user    0 Oct 29 17:45 empty.txt
-rw-r--r-- 1 user user   23 Oct 29 17:45 note.txt
-rw-r--r-- 1 user user   23 Oct 29 17:46 renamed-note.txt

$ mkdir -v archive
mkdir: created directory 'archive'

$ mv -v renamed-note.txt archive/
renamed 'renamed-note.txt' -> 'archive/renamed-note.txt'

$ ls -la
total 20
drwxr-xr-x 3 user user 4096 Oct 29 17:48 .
drwxr-xr-x 4 user user 4096 Oct 29 17:39 ..
-rw-r--r-- 1 user user   20 Oct 29 17:45 .hidden-note
drwxr-xr-x 2 user user 4096 Oct 29 17:48 archive
-rw-r--r-- 1 user user    0 Oct 29 17:45 empty.txt
-rw-r--r-- 1 user user   23 Oct 29 17:45 note.txt

$ ls -la archive
total 12
drwxr-xr-x 2 user user 4096 Oct 29 17:48 .
drwxr-xr-x 3 user user 4096 Oct 29 17:48 ..
-rw-r--r-- 1 user user   23 Oct 29 17:46 renamed-note.txt

$ cat archive/renamed-note.txt
Workspace CLI practice
```

### 확인 결과
복사본 note-copy.txt의 이름을 renamed-note.txt로 변경한 뒤 archive 디렉터리로 이동했다.

## 5. 절대 경로와 상대 경로

### 명령과 출력
```console
$ pwd
/home/user/dev-workstation/cli-practice/basic-ops

$ cat archive/renamed-note.txt
Workspace CLI practice

$ cat /home/user/dev-workstation/cli-practice/basic-ops/archive/renamed-note.txt
Workspace CLI practice

$ cd archive

$ pwd
/home/user/dev-workstation/cli-practice/basic-ops/archive

$ ls -la
total 12
drwxr-xr-x 2 user user 4096 Oct 29 17:48 .
drwxr-xr-x 3 user user 4096 Oct 29 17:48 ..
-rw-r--r-- 1 user user   23 Oct 29 17:46 renamed-note.txt

$ cd ..
$ pwd
/home/user/dev-workstation/cli-practice/basic-ops
```

### 확인 결과

- 절대 경로: `/`부터 시작하는 전체 경로다.
  - 예: `/home/user/dev-workstation/cli-practice/basic-ops/archive/renamed-note.txt`
- 상대 경로: 현재 작업 디렉터리를 기준으로 해석하는 경로다.
  - 현재 위치가 `~/dev-workstation/cli-practice/basic-ops`일 때
    `archive/renamed-note.txt`로 같은 파일을 읽었다.
- `pwd`로 현재 위치를 확인한 뒤, 두 경로에서 같은 내용이 출력되는 것을 확인했다.

## 6. 파일·빈 디렉터리 삭제

### 명령과 출력
```console
$ pwd
/home/user/dev-workstation/cli-practice/basic-ops

$ rm -v archive/renamed-note.txt
removed 'archive/renamed-note.txt'

$ ls -la archive
total 8
drwxr-xr-x 2 user user 4096 Oct 29 17:55 .
drwxr-xr-x 3 user user 4096 Oct 29 17:48 ..

$ rmdir -v archive
rmdir: removing directory, 'archive'

$ ls -la
total 16
drwxr-xr-x 2 user user 4096 Oct 29 17:55 .
drwxr-xr-x 4 user user 4096 Oct 29 17:39 ..
-rw-r--r-- 1 user user   20 Oct 29 17:45 .hidden-note
-rw-r--r-- 1 user user    0 Oct 29 17:45 empty.txt
-rw-r--r-- 1 user user   23 Oct 29 17:45 note.txt
```

### 확인 결과
복사본 renamed-note.txt를 삭제한 뒤 비어 있는 archive 디렉터리를 삭제했다.
원본 파일은 유지했다.

## 7. 파일 권한 변경 실험

### 목적
파일의 쓰기 권한 변경이 실제 내용 수정에 영향을 주는지 확인한다.

### 명령과 실제 출력

실행 위치: `~/dev-workstation`
```console
$ cd ~/dev-workstation
$ mkdir -p cli-practice/permissions
$ cd cli-practice/permissions

$ whoami
user
$ pwd
/home/user/dev-workstation/cli-practice/permissions

$ printf 'Permission test\n' > permission-note.txt
$ mkdir -p access-dir
$ chmod 644 permission-note.txt
$ ls -l permission-note.txt
-rw-r--r-- 1 user user 16 Oct 30 15:32 permission-note.txt
$ cat permission-note.txt
Permission test

$ chmod 444 permission-note.txt
$ ls -l permission-note.txt
-r--r--r-- 1 user user 16 Oct 30 15:32 permission-note.txt
$ echo 'Write test' >> permission-note.txt
-bash: permission-note.txt: Permission denied
$ cat permission-note.txt
Permission test

$ chmod 644 permission-note.txt
$ echo 'Write restored' >> permission-note.txt
$ ls -l permission-note.txt
-rw-r--r-- 1 user user 31 Oct 30 15:34 permission-note.txt
$ cat permission-note.txt
Permission test
Write restored
```

### 결과

| 단계 | 권한 | 검증 |
|---|---|---|
| 기준 설정 | 644 / -rw-r--r-- | 소유자의 읽기·쓰기 허용 |
| 쓰기 금지 | 444 / -r--r--r-- | 내용 추가 실패, 읽기 성공 |
| 복구 | 644 / -rw-r--r-- | 내용 추가 및 결과 확인 성공 |

## 8. 디렉터리 권한 변경 실험

### 목적
디렉터리의 x 권한이 진입·탐색에 미치는 영향을 확인한다.

### 명령과 실제 출력

실행 위치: `~/dev-workstation/cli-practice/permissions`
```console
$ chmod 755 access-dir
$ ls -ld access-dir
drwxr-xr-x 2 user user 4096 Oct 30 15:32 access-dir
$ cd access-dir
$ pwd
/home/user/dev-workstation/cli-practice/permissions/access-dir
$ cd ..

$ chmod 644 access-dir
$ ls -ld access-dir
drw-r--r-- 2 user user 4096 Oct 30 15:32 access-dir
$ cd access-dir
-bash: cd: access-dir: Permission denied
$ pwd
/home/user/dev-workstation/cli-practice/permissions

$ chmod 755 access-dir
$ ls -ld access-dir
drwxr-xr-x 2 user user 4096 Oct 30 15:32 access-dir
$ cd access-dir
$ pwd
/home/user/dev-workstation/cli-practice/permissions/access-dir
```

### 결과

| 단계 | 권한 | 검증 |
|---|---|---|
| 기준 설정 | 755 / drwxr-xr-x | cd 진입 성공 |
| 탐색 금지 | 644 / drw-r--r-- | cd 진입 실패 |
| 복구 | 755 / drwxr-xr-x | cd 진입 성공 |

### 해석
이번 실험에서는 다음을 실제로 확인했다.

- 일반 파일: 쓰기 권한을 제거하자 내용 추가가 실패했고,
  권한 복구 후에는 성공했다.
- 디렉터리: 탐색 권한을 제거하자 `cd`가 실패했고,
  권한 복구 후에는 성공했다.

개념적으로 일반 파일의 `x`는 실행 권한,
디렉터리의 `x`는 탐색 권한이다.
이번 실습에서는 일반 파일의 실행 권한 변경은 별도로 시험하지 않았다.

### 권한 표기 정리

소유자는 해당 파일의 소유 사용자, 그룹은 해당 파일에 지정된 소유 그룹을 뜻한다. `ls -l`의 사용자·그룹 열과 함께 해석한다.

권한 숫자는 왼쪽부터 소유자 → 그룹 → 기타 사용자 순서이며, 각 자리에서 `r=4`, `w=2`, `x=1`을 더한다.

| 숫자 | 권한 | 계산 |
|---|---|---|
| 7 | `rwx` | 4 + 2 + 1 |
| 6 | `rw-` | 4 + 2 |
| 5 | `r-x` | 4 + 1 |
| 4 | `r--` | 4 |

파일과 디렉터리에서는 권한의 의미가 다음처럼 달라진다.

| 권한 | 일반 파일 | 디렉터리 |
|---|---|---|
| `r` | 내용 읽기 | 내부 이름 목록 읽기 |
| `w` | 내용 수정 | 내부 항목 생성·삭제 등. 보통 `x`도 함께 필요 |
| `x` | 프로그램으로 실행 | 디렉터리 진입·내부 경로 탐색 |

파일의 `444`는 내용 쓰기를 금지하지만 삭제까지 금지하는 것은 아니다.
삭제 가능 여부는 상위 디렉터리의 쓰기·탐색 권한과 추가 제한에 영향을 받는다.
## 9. 요구사항별 검증 요약

| 요구사항 | 수행 증거 | 판정 |
|---|---|---|
| 현재 위치·목록·숨김 파일 | `pwd`, `ls -l`, `ls -la` | 확인 |
| 이동·디렉터리 생성 | `cd`, `mkdir` | 확인 |
| 빈 파일·내용 생성 및 읽기 | `touch`, `printf`, `cat`, `wc -c` | 확인 |
| 복사·이름 변경·이동 | `cp`, `mv` 및 전후 목록 | 확인 |
| 파일·빈 디렉터리 삭제 | `rm`, `rmdir` 및 삭제 후 목록 | 확인 |
| 절대·상대 경로 | 두 경로로 같은 파일 내용 읽기 | 확인 |
| 파일 권한 | `644 → 444 → 644`, 쓰기 실패 후 성공 | 확인 |
| 디렉터리 권한 | `755 → 644 → 755`, 진입 실패 후 성공 | 확인 |

## 10. 재현 시 주의사항

- 명령의 기준 위치를 먼저 확인한다. 개인 PC의 `/home/user`는 재현 환경의 홈 경로로 바꾼다.
- 기본 조작의 `archive/renamed-note.txt`는 6번에서 삭제했다. 경로 비교를 다시 하려면 파일 생성부터 순서대로 수행한다.
- `touch`는 기존 파일 내용을 비우지 않는다. 0바이트 생성 검증은 같은 이름의 기존 파일이 없는 상태를 전제로 한다.
- `>`는 기존 내용을 덮어쓴다. 예제의 실습 파일에만 사용한다.
- 기존 `basic-ops`에 파일이 남아 있으면 당시 목록과 달라질 수 있으므로 상태를 먼저 확인한다. 불필요하게 전체 디렉터리를 강제 삭제하지 않는다.
- 권한 실험 후 파일은 `644`, 디렉터리는 `755`로 복구했다. 마지막 작업 위치는 `permissions/access-dir`이므로 다음 실습 전 프로젝트 루트로 이동한다.
- 일반 파일 실행 권한, ACL, sticky bit 등의 추가 권한 동작은 별도 실험하지 않았다.

[프로젝트 README](../README.md)
