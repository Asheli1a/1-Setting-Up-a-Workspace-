# GitHub SSH 인증 및 push 검증

## 1. 수행 범위와 현재 상태

- 수행 일자: 2026-11-02
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- GitHub 계정: `Asheli1a`
- 키 방식: ED25519, 실습 전용 경로 사용
- 현재 확인: 키 생성·본인 계정 인증·저장소별 SSH 설정·실제 push·원격 SHA 대조 완료
- 실제 검증 커밋: [9088c08f6e8ec2cbe90bba1c5f3909ef805f9777](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/9088c08f6e8ec2cbe90bba1c5f3909ef805f9777)

개인키·암호 문구·이메일 확인 코드는 기록하지 않는다. 공개키 원문 전체 대신 지문과 인증 성공 결과를 남긴다. 아래 console 블록은 실제 제공된 명령·출력 중 필요한 부분을 발췌한 것이다.

## 2. 전용 키 생성과 권한 확인

```console
$ mkdir -p "$HOME/.ssh/codyssey-asheli1a"
$ chmod 700 "$HOME/.ssh/codyssey-asheli1a"
$ key="$HOME/.ssh/codyssey-asheli1a/id_ed25519"
$ ls -ld "$HOME/.ssh/codyssey-asheli1a"
drwx------ 2 user user 4096 Nov  2 17:20 /home/user/.ssh/codyssey-asheli1a

$ ssh-keygen -t ed25519 \
  -C "codyssey-Asheli1a-20261102" \
  -f "$key"
[입력 프롬프트·randomart 출력 생략]
Your identification has been saved in /home/user/.ssh/codyssey-asheli1a/id_ed25519
Your public key has been saved in /home/user/.ssh/codyssey-asheli1a/id_ed25519.pub

$ ls -l "$key" "$key.pub"
-rw------- 1 user user 464 Nov  2 17:20 /home/user/.ssh/codyssey-asheli1a/id_ed25519
-rw-r--r-- 1 user user 108 Nov  2 17:20 /home/user/.ssh/codyssey-asheli1a/id_ed25519.pub

$ ssh-keygen -lf "$key.pub"
256 SHA256:UGCi4CrIpDFV0+Iuuq23HT92Q1TrRyP0Wm75ziYrOSs codyssey-Asheli1a-20261102 (ED25519)
```

실제 생성 명령은 같은 경로에 파일이 없을 때만 실행하는 조건문 안에서 수행했다. 위에는 그 안에서 실행된 핵심 명령과 출력만 발췌했다. 개인키 내용을 출력하거나 저장소에 추가하지 않았다.

## 3. 인증 실패와 재확인

중앙 트러블슈팅 기록은 [사례 7: GitHub SSH 인증 실패](06-troubleshooting.md#7-github-ssh-인증-실패)를 참조한다. 아래 인증 증거와 이 문서의 실제 push 기록은 유지한다.

### 증상

처음 지정한 키로 연결했을 때 GitHub 호스트 키 확인 이후 아래 결과가 나왔다.

```text
git@github.com: Permission denied (publickey).
SSH exit code: 255
```

### 확인·대응

GitHub 웹에서 추가 이메일 확인 페이지가 열려 있었으나 이를 완료하지 않은 채 진행했던 것을 확인했다. 해당 확인을 마친 뒤 같은 키 경로와 지문으로 SSH 인증을 다시 시도했다.

이 기록은 이번에 관찰한 진행 경위다. 모든 publickey 오류의 원인이 이메일 확인이라는 뜻은 아니며, GitHub 내부의 거부 사유 전체를 별도 확인한 것은 아니다. 해결을 위해 키를 재생성하거나 다른 사용자의 키·호스트 기록을 삭제하지 않았다.

### 재검증: 실제 명령과 핵심 출력

```console
$ ssh -F /dev/null \
  -o IdentitiesOnly=yes \
  -o IdentityAgent=none \
  -i "$HOME/.ssh/codyssey-asheli1a/id_ed25519" \
  -vT git@github.com
[접속·키 교환 등의 상세 debug 출력은 생략]
debug1: Host 'github.com' is known and matches the ED25519 host key.
debug1: Offering public key: /home/user/.ssh/codyssey-asheli1a/id_ed25519 ED25519 SHA256:UGCi4CrIpDFV0+Iuuq23HT92Q1TrRyP0Wm75ziYrOSs explicit
debug1: Server accepts key: /home/user/.ssh/codyssey-asheli1a/id_ed25519 ED25519 SHA256:UGCi4CrIpDFV0+Iuuq23HT92Q1TrRyP0Wm75ziYrOSs explicit
Enter passphrase for key '/home/user/.ssh/codyssey-asheli1a/id_ed25519':
Authenticated to github.com ([20.200.245.247]:22) using "publickey".
[후속 debug 출력은 생략]
Hi Asheli1a! You've successfully authenticated, but GitHub does not provide shell access.
debug1: Exit status 1
```

서버의 키 수락·publickey 인증·본인 계정 인사말을 확인했다. GitHub는 일반 셸을 제공하지 않으므로 이 성공 메시지의 종료 상태 1을 앞선 인증 실패 255와 구분한다.

복사 과정에서 생긴 mailto 링크 표기는 명령의 일반 텍스트로 정리했다. 암호 문구의 내용은 수집하거나 기록하지 않았다.

## 4. 저장소별 SSH 설정과 실제 push

### 기존 설정 확인과 실습 키 지정

```console
$ git config --show-origin --get core.sshCommand

$ git config --local core.sshCommand \
  "ssh -F /dev/null -o IdentitiesOnly=yes -o IdentityAgent=none -i $HOME/.ssh/codyssey-asheli1a/id_ed25519"

$ git config --show-origin --get core.sshCommand
file:.git/config        ssh -F /dev/null -o IdentitiesOnly=yes -o IdentityAgent=none -i /home/user/.ssh/codyssey-asheli1a/id_ed25519
```

최초 조회는 출력이 없었다. 저장소별 설정을 추가한 뒤 `.git/config` 출처와 사용할 키 경로를 확인했다. 전역 SSH 설정을 변경하지 않았고 `.git/config` 자체를 커밋하지 않았다.

### 원격 주소와 SSH 읽기 확인

```console
$ git remote set-url origin \
  git@github.com:Asheli1a/1-Setting-Up-a-Workspace-.git

$ git remote -v
origin  git@github.com:Asheli1a/1-Setting-Up-a-Workspace-.git (fetch)
origin  git@github.com:Asheli1a/1-Setting-Up-a-Workspace-.git (push)

$ git ls-remote origin refs/heads/main
Enter passphrase for key '/home/user/.ssh/codyssey-asheli1a/id_ed25519':
d9a3a4efc0e334b3743cc2848efd18abef3c3290        refs/heads/main
```

origin의 fetch·push 주소가 SSH 형식이며 지정한 키로 원격 main을 조회할 수 있었다. 암호 문구 입력 프롬프트는 기록하되 입력값은 기록하지 않았다.

### 실제 변경 파일과 커밋·push

인증 기록 문서를 추가한 실제 변경을 사용했다. 다음은 스테이징 대상·커밋·push의 실제 출력이며, 빈 커밋이나 Everything up-to-date를 새 전송 증거로 대신하지 않았다.

```console
$ git add -- docs/10-github-ssh.md

$ git diff --cached --check

$ git diff --cached --stat
 docs/10-github-ssh.md | 114 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 114 insertions(+)

$ git diff --cached --name-only
docs/10-github-ssh.md

$ git commit -m "docs: record github ssh authentication evidence"
[main 9088c08] docs: record github ssh authentication evidence
 1 file changed, 114 insertions(+)
 create mode 100755 docs/10-github-ssh.md

$ git push origin main
Enter passphrase for key '/home/user/.ssh/codyssey-asheli1a/id_ed25519':
Enumerating objects: 6, done.
Counting objects: 100% (6/6), done.
Delta compression using up to 8 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 3.04 KiB | 3.04 MiB/s, done.
Total 4 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To github.com:Asheli1a/1-Setting-Up-a-Workspace-.git
   d9a3a4e..9088c08  main -> main
```

주소가 SSH 형식인 origin으로 실제 새 커밋이 전송됐다. 최초 추가 당시의 100755 모드는 실행 비트가 설정된 문서라는 뜻으로 기록을 유지했다. 일반 Markdown 문서의 실행 비트 정리는 이후 마무리 커밋에서 별도로 확인할 수 있으며, 이 과거 출력은 수정하지 않는다.

### 로컬·원격 main 대조

```console
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
9088c08 (HEAD -> main, origin/main, origin/HEAD) docs: record github ssh authentication evidence

$ git rev-parse HEAD
9088c08f6e8ec2cbe90bba1c5f3909ef805f9777

$ git ls-remote origin refs/heads/main
Enter passphrase for key '/home/user/.ssh/codyssey-asheli1a/id_ed25519':
9088c08f6e8ec2cbe90bba1c5f3909ef805f9777        refs/heads/main
```

로컬 HEAD와 원격 main이 같은 전체 SHA였다. 미추적 실습 폴더는 새 커밋에 포함하지 않았다.

| 검증 항목 | 실제 결과 |
|---|---|
| 인증 계정 | Asheli1a |
| 사용할 키 설정 | 현재 저장소의 core.sshCommand |
| 설정 출처 | file:.git/config |
| 원격 | git@github.com:Asheli1a/1-Setting-Up-a-Workspace-.git |
| 실제 SSH push | [d9a3a4e](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/d9a3a4efc0e334b3743cc2848efd18abef3c3290) → [9088c08](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/9088c08f6e8ec2cbe90bba1c5f3909ef805f9777) / main → main |
| 대조한 로컬·원격 SHA | [9088c08f6e8ec2cbe90bba1c5f3909ef805f9777](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/9088c08f6e8ec2cbe90bba1c5f3909ef805f9777) |

이 문서를 완성하는 후속 커밋은 별도로 생긴다. 위 SHA는 실제 SSH push를 확인한 검증 커밋으로 유지하며, 후속 문서 커밋을 처음부터 검증했던 것처럼 바꾸지 않는다.

### 검증 커밋과 후속 기록 커밋

- 실제 SSH push를 확인한 커밋: [9088c08f6e8ec2cbe90bba1c5f3909ef805f9777](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/9088c08f6e8ec2cbe90bba1c5f3909ef805f9777)
- push 결과와 README 체크리스트를 정리한 후속 커밋: [39ec3c8944fe94ccdc478d5ab4b74dbe6a7a60c4](https://github.com/Asheli1a/1-Setting-Up-a-Workspace-/commit/39ec3c8944fe94ccdc478d5ab4b74dbe6a7a60c4)
- 두 커밋은 역할이 다르다. 실제 전송 검증 SHA를 후속 문서 커밋 SHA로 바꾸지 않는다.

## 5. 보안·공용 장비 관리

- 개인키는 프로젝트 밖의 실습 전용 경로에서 보호하고 공개키만 GitHub에 등록한다.
- 개인키·암호 문구·인증 코드를 Git·문서·스크린샷에 넣지 않는다.
- 이 공개키 지문은 인증 비밀 자체가 아니며, 전체 개인키와 구분한다.
- 키의 등록·사용은 본인 계정에 한정하고 다른 사용자의 키를 덮어쓰거나 삭제하지 않는다.
- 로그아웃·로컬 키 보관·GitHub에 등록한 키의 제거는 서로 다른 관리 항목이다. 실습 종료·장비 정책에 맞는 정리 여부는 별도로 확인한다.
- 이번 기록만으로 키 폐기·전체 로그인 세션 정리를 완료했다고 주장하지 않는다.

## 6. 현재 체크리스트

- [x] 실습 전용 키 생성·공개키 지문 확인
- [x] GitHub 추가 확인 후 같은 키로 본인 계정 인증 성공
- [x] 저장소의 SSH 원격·사용 키 설정 확인
- [x] 실제 변경 커밋의 SSH push 성공
- [x] 로컬·원격 main SHA 대조
- [x] 새 문서·로그 최종 공개 정보 검토

[Git·GitHub·VSCode 기록](05-git-github.md) · [환경 변수 실습](09-compose-env.md) · [프로젝트 README](../README.md)
