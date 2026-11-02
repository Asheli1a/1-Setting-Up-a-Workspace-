# GitHub SSH 인증 및 push 검증

## 1. 수행 범위와 현재 상태

- 수행 일자: 2026-11-02
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- GitHub 계정: `Asheli1a`
- 키 방식: ED25519, 실습 전용 경로 사용
- 현재 확인: 키 생성·공개키 지문·본인 계정 SSH 인증 성공
- 아직 미기록: SSH 원격 설정·실제 변경 커밋의 SSH push·원격 반영 결과
- README SSH 완료 체크는 실제 push 결과를 확보한 뒤 처리한다.

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

### 증상

처음 지정한 키로 연결했을 때 GitHub 호스트 키 확인 이후 아래 결과가 나왔다.

```text
git@github.com: Permission denied (publickey).
SSH exit code: 255
```

### 확인·대응

GitHub 웹에서 추가 이메일 확인 페이지가 열려 있었으나 이를 완료하지 않은 채 진행했던 것을 작성자가 확인했다. 해당 확인을 마친 뒤 같은 키 경로와 지문으로 SSH 인증을 다시 시도했다.

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

## 4. 다음 검증 — 아직 실제 로그 아님

현재 저장소의 원격 URL과 기존 core.sshCommand를 확인한 뒤, 이번 저장소에 한정해 실습 키를 사용하도록 설정하고 SSH 원격 주소를 적용한다. 실제 입력·출력은 수행 후 이 절에 추가한다.

확인할 항목:

- 저장소별 core.sshCommand와 설정 출처
- origin의 SSH 주소
- SSH로 조회한 원격 main SHA
- 이 문서 같은 실제 파일 변경 커밋
- 해당 변경의 SSH push 결과
- 로컬 HEAD와 원격 main SHA 일치

빈 커밋을 만들거나 Everything up-to-date만으로 새 변경의 push 검증을 완료했다고 기록하지 않는다.

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
- [ ] 저장소의 SSH 원격·사용 키 설정 확인
- [ ] 실제 변경 커밋의 SSH push 성공
- [ ] 로컬·원격 main SHA 대조
- [ ] 새 문서·로그 최종 공개 정보 검토

[Git·GitHub·VSCode 기록](05-git-github.md) · [환경 변수 실습](09-compose-env.md) · [프로젝트 README](../README.md)
