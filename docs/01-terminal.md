# 터미널 기본 조작 및 권한 실습

## 1. 작업 디렉터리 생성과 이동

### 명령과 출력
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
$ touch empty.txtxt

printf 'Workspace CLI practice\n' > note.txt

printf 'Hidden file example\n' > .hidden-note

ls -l
ls -la

cat note.txt
cat .hidden-note

wc -c empty.txt
total 4
-rw-r--r-- 1 user user  0 Oct 29 17:45 empty.txt
-rw-r--r-- 1 user user 23 Oct 29 17:45 note.txt
total 16
drwxr-xr-x 2 user user 4096 Oct 29 17:45 .
drwxr-xr-x 4 user user 4096 Oct 29 17:39 ..
-rw-r--r-- 1 user user   20 Oct 29 17:45 .hidden-note
-rw-r--r-- 1 user user    0 Oct 29 17:45 empty.txt
-rw-r--r-- 1 user user   23 Oct 29 17:45 note.txt
Workspace CLI practice
Hidden file example
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