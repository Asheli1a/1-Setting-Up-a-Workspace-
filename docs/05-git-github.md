# Git 설정 및 GitHub·VSCode 연동

## 목적 및 기록 범위

Git 작성자 정보·기본 브랜치·기존 원격 저장소를 확인하고, VSCode의 WSL 개발 환경과 본인 GitHub 계정 연동을 검증했다.

- 수행 일자: 2026-10-31 — 초기 GitHub 인증·push는 앞선 2026-10-29 기록도 참조
- 장비: 공용 실습 노트북
- 실행 위치: WSL Ubuntu의 `~/dev-workstation`
- 아래 로그는 실제로 제공한 실행 결과다. 프롬프트와 열 간격을 정리하고, 복사 중 생긴 이메일 mailto·URL 링크 변형을 일반 텍스트로 복원했다.
- 초기 전역 설정 조회와 이후 저장소별 작성자 설정을 시점별로 구분한다. 최종 local 설정 후 전체 config를 다시 출력한 것처럼 작성하지 않았다.

## Git 사용자 정보·기본 브랜치 및 원격 확인

### 초기 설정 조회

```console
$ cd ~/dev-workstation

$ git config user.name
Asheli1a

$ git config user.email
224024412+Asheli1a@users.noreply.github.com

$ git config init.defaultBranch
main

$ git config --show-origin --get user.name
file:/home/user/.gitconfig      Asheli1a

$ git config --show-origin --get user.email
file:/home/user/.gitconfig      224024412+Asheli1a@users.noreply.github.com

$ git config --show-origin --get init.defaultBranch
file:/home/user/.gitconfig      main

$ git branch --show-current
main

$ git remote -v
origin  https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git (fetch)
origin  https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git (push)
```

| 확인 항목 | 초기 조회 결과 |
|---|---|
| 작성자 이름 | Asheli1a |
| 작성자 이메일 | 224024412+Asheli1a@users.noreply.github.com |
| 초기 작성자 설정 출처 | /home/user/.gitconfig |
| 기본 브랜치 설정 | main |
| 현재 브랜치 | main |
| 원격 저장소 | origin / 기존 과제 저장소 |

기본 브랜치 설정과 현재 브랜치는 따로 조회했다. 이메일은 GitHub에서 확인한 본인 noreply 주소이며 GitHub 로그인 비밀번호나 인증 토큰이 아니다.

### 전체 설정 조회 — 저장소별 작성자 설정을 추가하기 전

```console
$ git config --list
user.name=Asheli1a
user.email=224024412+Asheli1a@users.noreply.github.com
init.defaultbranch=main
credential.https://github.com.helper=
credential.https://github.com.helper=!/usr/bin/gh auth git-credential
credential.https://gist.github.com.helper=
credential.https://gist.github.com.helper=!/usr/bin/gh auth git-credential
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
remote.origin.url=https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.main.remote=origin
branch.main.merge=refs/heads/main
```

이 출력에서 GitHub CLI 자격 증명 helper, 기존 원격 URL 및 main 추적 설정을 확인했다. helper 설정 자체를 토큰으로 취급하지 않으며 실제 인증 상태는 아래의 gh auth status로 별도 확인했다.

## 기존 GitHub 저장소 및 push 성공 기록

새 저장소를 만들거나 다시 clone하지 않고 기존 과제 저장소를 사용했다. GitHub CLI 인증 뒤 수행한 실제 첫 push 기록에서 핵심 부분을 발췌했다.

```console
$ git push -u origin main
[전송 진행 출력 생략]
To https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

이것은 과거 첫 push의 성공 증거이며, 아래 local 설정 후 새 커밋 작성자까지 재검증한 로그는 아니다. 이후 웹 업로드로 분기된 이력을 병합하고 push한 기록도 별도 트러블슈팅에 남겼다.

- [HTTPS 인증 및 첫 push](06-troubleshooting.md#2-github-https-push-인증-실패)
- [원격 웹 업로드와 로컬 변경 통합](06-troubleshooting.md#3-github-웹-업로드-후-push-거부-및-브랜치-분기)

## VSCode WSL 및 GitHub 계정 연동

### 연결 환경

- 프로젝트: /home/user/dev-workstation
- 원격 개발 환경: WSL: Ubuntu
- 통합 터미널: Bash
- Git 실행 경로: /usr/bin/git
- Git 버전: 2.53.0
- 현재 브랜치: main
- 원격 저장소: Asheli1a/1-Setting-Up-a-Workspace-

### 계정 확인 및 변경

공용 실습 노트북의 VSCode에 기존 사용자의 GitHub 계정이
로그인되어 있는 것을 확인했다.

기존 계정을 로그아웃하고 본인 계정으로 다시 로그인한 뒤,
계정 메뉴에서 Asheli1a (GitHub)가 표시되는 것을 확인했다.

기존 사용자의 계정 정보는 공개 기록에 포함하지 않았다.

### 재검증

VSCode의 WSL Bash 통합 터미널에서
프로젝트 경로, Linux 환경, Git 버전,
저장소 루트, 브랜치 및 원격 주소를 확인했다.

다음은 통합 터미널에서 확인한 실제 명령과 출력이다. 여러 명령을 붙여 넣은 원본을 명령별로 구분했다.

```console
$ pwd
/home/user/dev-workstation

$ uname -s
Linux

$ command -v git
/usr/bin/git

$ git --version
git version 2.53.0

$ git rev-parse --show-toplevel
/home/user/dev-workstation

$ git branch --show-current
main

$ git remote -v
origin  https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git (fetch)
origin  https://github.com/Asheli1a/1-Setting-Up-a-Workspace-.git (push)
```

![WSL 통합 터미널의 Git 및 저장소 확인](images/vscode-wsl-terminal.png)

### 확인 결과

- Windows PowerShell에서 Git을 찾지 못하던 문제는 해결됐다.
- WSL Ubuntu의 Git으로 기존 프로젝트를 조회할 수 있었다.
- VSCode 계정 메뉴에서 본인 GitHub 계정을 확인했다.

![VSCode 본인 GitHub 계정 및 WSL 프로젝트 확인](images/vscode-wsl-account.png)

### 별도 관찰

외부 Ubuntu 터미널에서 실행한 code .의 서버 설치 실패 메시지는
원인을 확인하지 못했다.
현재 VSCode WSL 창에서의 Git·저장소 조회는 정상 동작했다.


### 공용 장비를 고려한 저장소별 작성자 설정

초기에는 전역 설정에서 작성자 정보를 확인했다.
이후 공용 실습 노트북임을 고려해 현재 저장소에도
본인의 작성자 정보를 명시적으로 설정했다.

```console
$ git config --local user.name "Asheli1a"
$ git config --local user.email "224024412+Asheli1a@users.noreply.github.com"

$ git config --show-origin --get user.name
file:.git/config        Asheli1a

$ git config --show-origin --get user.email
file:.git/config        224024412+Asheli1a@users.noreply.github.com
```

### GitHub CLI 인증 재확인

VSCode의 WSL 통합 터미널과 외부 Ubuntu 터미널에서
`gh auth status --hostname github.com`을 실행했다.

두 환경 모두 다음을 확인했다.

- 계정: Asheli1a
- 활성 계정: true
- Git 작업 프로토콜: HTTPS
- 인증 토큰: 마스킹 상태로 표시

아래는 CLI 인증 출력에서 계정·활성 상태·프로토콜 부분만 발췌한 것이다. 원본의 마스킹 토큰·권한 범위 행은 생략했다.

```console
$ gh auth status --hostname github.com
github.com
  ✓ Logged in to github.com account Asheli1a (/home/user/.config/gh/hosts.yml)
  - Active account: true
  - Git operations protocol: https
```

![CLI 인증 및 저장소별 Git 작성자 설정 증거](images/vscode-auth-local-config.png)

이미지에 일부 긴 줄이 줄바꿈·잘림으로 표시되는 부분은 원본 그대로이며, 이메일 전체 값은 위 텍스트 로그에서 확인한다.

## 최종 설정·연동 결과 요약

| 항목 | 확인 결과 |
|---|---|
| 초기 전역 작성자 정보 | /home/user/.gitconfig의 본인 이름·noreply |
| 최종 저장소별 작성자 정보 | .git/config의 본인 이름·동일한 noreply |
| 기본 브랜치 설정 | 전역 main — local 변경 대상 아님 |
| 현재 프로젝트 브랜치 | main |
| 기존 GitHub 원격 및 push | 확인 |
| VSCode WSL 연결 | 확인 |
| VSCode GitHub 계정 | Asheli1a |
| CLI 활성 계정 | Asheli1a / HTTPS |
| 외부 code . 서버 설치 오류 | 원인 미확인, 현재 WSL 세션 정상과 구분 |

Git 작성자 정보는 커밋 메타데이터이고 원격 인증과는 별개다. GitHub 원격 URL이 본인 저장소라는 사실만으로 현재 인증 계정까지 확인한 것은 아니므로 VSCode 계정과 CLI 활성 계정을 각각 확인했다.

## 문제 해결 기록과 남은 확인

- [PowerShell의 Git 미인식 해결](06-troubleshooting.md#4-vscode의-powershell에서-git-명령을-찾지-못함)
- [공용 장비 계정 전환 및 설정](06-troubleshooting.md#5-공용-노트북의-vscode에-타인-github-계정이-로그인됨)
- [미해결 서버 설치 관찰](06-troubleshooting.md#6-code-실행-중-vs-code-server-설치-실패)

초기 Git 설정·현재 저장소별 설정·실제 계정 연동 결과는 확인했다. local 설정 후 생성한 커밋의 Author/Committer 메타데이터와 새 환경 전체 재현은 별도로 확인하지 않았다. 이를 완료한 것처럼 기록하지 않는다.

공용 장비를 반납해야 할 경우에는 본인의 VSCode·CLI·브라우저 인증과 동기화 상태를 확인·정리해야 한다. 다른 사용자 자격 증명이나 설정을 일괄 삭제하지 않는다. 이 안내는 반납 시 정리와 저장소 전체 이력·이미지의 보안 점검을 이미 완료했다는 뜻은 아니다.

[프로젝트 README](../README.md)
