

## 4부: Local vs Remote (3시간)

---

### 4.1 Remote Repository 연결 (40분)

#### 학습 목표

- GitHub에 원격 저장소를 생성하고 로컬 저장소와 연결할 수 있다
- `git push`를 통해 로컬 커밋을 원격으로 업로드할 수 있다
- Upstream 설정의 의미를 이해한다

#### 실습 1: GitHub Repository 생성 (10분)

**단계별 진행:**

1. GitHub 접속 ([https://github.com](https://github.com))
2. 우측 상단 `+` 버튼 → `New repository` 클릭
3. Repository 설정:
    - Repository name: `git-workshop`
    - Description: "Git 실습용 저장소"
    - Public/Private 선택
    - **중요: Initialize 옵션 모두 체크 해제** (README, .gitignore 등)
4. `Create repository` 클릭

**왜 Initialize 하지 않나요?**

bash

```bash
# 우리는 이미 로컬에 저장소가 있습니다
# GitHub에서 README를 만들면 충돌이 발생합니다
# 빈 저장소를 만들어야 합니다
```

#### 실습 2: Remote 연결 및 Push (30분)

**현재 상태 확인:**

bash

```bash
# 로컬 저장소 위치 확인
pwd

# 현재 커밋 히스토리 확인
git log --oneline

# Remote 상태 확인 (아직 없어야 함)
git remote -v
```

**Remote 저장소 연결:**

bash

```bash
# GitHub에서 제공하는 URL 복사 (HTTPS 또는 SSH)
# 예: https://github.com/username/git-workshop.git

# Remote 추가
git remote add origin https://github.com/username/git-workshop.git

# 연결 확인
git remote -v
# origin  https://github.com/username/git-workshop.git (fetch)
# origin  https://github.com/username/git-workshop.git (push)
```

**용어 설명:**

- `origin`: 원격 저장소의 기본 별칭 (관례적으로 사용)
- `fetch`: 다운로드용 URL
- `push`: 업로드용 URL

**첫 Push - Upstream 설정:**

bash

```bash
# -u 옵션으로 upstream 설정
git push -u origin main # -u는 --set-upstream 을 의미

# 또는 (main 브랜치가 아닌 경우)
git branch  # 현재 브랜치 확인
git push -u origin <브랜치명>
```

**Upstream이란?**

bash

```bash
# -u (--set-upstream) 옵션의 의미:
# "이 로컬 브랜치(main)는 origin/main과 연결되어 있다"고 설정

# 한 번 설정하면, 다음부터는 간단하게:
git push  # 자동으로 origin main으로 push
git pull  # 자동으로 origin main에서 pull

# Upstream 설정 확인
git branch -vv
# * main 7a3b2c1 [origin/main] Latest commit message
```

**실습 체크리스트:**

- [ ]  GitHub에 저장소 생성 완료
- [ ]  `git remote -v`로 연결 확인
- [ ]  `git push -u origin main` 성공
- [ ]  GitHub 웹페이지에서 커밋 내역 확인

**트러블슈팅:**

bash

```bash
# 문제 1: "failed to push some refs"
# → 원격에 로컬에 없는 커밋이 있음 (README 등)
git pull origin main --allow-unrelated-histories
git push -u origin main

# 문제 2: "remote origin already exists"
git remote remove origin
git remote add origin <새로운-URL>

# 문제 3: 인증 실패
# → GitHub 토큰 사용 (비밀번호는 더 이상 지원 안 됨)
# Settings → Developer settings → Personal access tokens
```

---

### 4.2 Local Branch vs Remote Branch - 강화 (70분)

#### 학습 목표
- `main`과 `origin/main`이 **완전히 다른 브랜치**임을 체득한다
- `git fetch`와 `git pull`의 차이를 명확히 이해한다
- 원격 브랜치 추적 개념을 이해한다

#### 개념 설명 (10분)

**핵심 진실:**
```
main과 origin/main은 별개의 브랜치입니다!

main         → 내 컴퓨터의 브랜치
origin/main  → GitHub 서버의 브랜치를 추적하는 로컬 복사본
```

**시각화:**
```
[내 컴퓨터]                    [GitHub 서버]
main ─┐                       origin (실제 저장소)
      │                              │
origin/main (추적용 복사본)          main (실제 브랜치)
      └───────── fetch ──────────────┘
```

#### 실습 3: 브랜치 확인 명령어 (10분)

bash

```bash
# 로컬 브랜치만 보기
git branch
# * main
#   feature-x

# 원격 브랜치만 보기
git branch -r
# origin/main
# origin/feature-y

# 모든 브랜치 보기
git branch -a
# * main
#   feature-x
#   remotes/origin/main
#   remotes/origin/feature-y

# 더 자세한 정보 (추적 관계 포함)
git branch -vv
# * main      7a3b2c1 [origin/main] Latest commit
#   feature-x 4d2e1f3 New feature
```

**관찰 포인트:**

- `origin/main`은 `remotes/` 접두사가 붙음
- Local 브랜치는 별표(`*`)로 표시
- `[origin/main]`은 upstream 추적 관계 표시

#### 실습 4: 2개 터미널로 분리 확인 (50분)

**준비 작업:**

bash

```bash
# 작업 디렉토리 준비
mkdir ~/git-workshop-demo
cd ~/git-workshop-demo
git clone https://github.com/username/git-workshop.git
cd git-workshop
```

**Terminal 1: 로컬 커밋 만들기**

bash

```bash
# Terminal 1 시작
cd ~/git-workshop-demo/git-workshop

# 새 파일 생성 및 커밋
echo "Local only change" > local-file.txt
git add local-file.txt
git commit -m "Add local file"

# 현재 상태 확인
git log --oneline --all --graph -5
# * a3f2b1c (HEAD -> main) Add local file
# * 7a3b2c1 (origin/main) Previous commit
# * ...
```

**중요 관찰:**
```
HEAD -> main     : 로컬 브랜치가 여기
origin/main      : 원격 추적 브랜치는 이전 커밋에 머물러 있음

→ 로컬이 원격보다 1커밋 앞서 있음!
```

**Terminal 2: Fetch로 동기화**

bash

```bash
# 새 터미널 열기
# Terminal 2 시작

# 같은 저장소의 다른 위치로 이동
cd ~/git-workshop-demo
git clone https://github.com/username/git-workshop.git workshop2
cd workshop2

# 또는 Terminal 1에서 push 후:
# cd ~/git-workshop-demo/git-workshop

# Fetch 전 상태
git log --oneline --all --graph -5
# * 7a3b2c1 (HEAD -> main, origin/main) Previous commit

# Fetch 실행
git fetch origin

# Fetch 후 상태
git log --oneline --all --graph -5
# * a3f2b1c (origin/main) Add local file
# * 7a3b2c1 (HEAD -> main) Previous commit
```

**핵심 관찰:**

bash

```bash
# Fetch 후:
# - origin/main은 업데이트됨 (새 커밋 인식)
# - main은 그대로 (작업 디렉토리 변화 없음)
# - 두 브랜치가 분리되어 있음을 명확히 확인!

# 파일 시스템 확인
ls -la
# local-file.txt가 없음! (아직 merge 안 했으므로)
```

**Merge로 완전 동기화:**

bash

```bash
# 현재 브랜치 확인
git branch
# * main

# origin/main의 변경사항을 main으로 병합
git merge origin/main
# Updating 7a3b2c1..a3f2b1c
# Fast-forward
#  local-file.txt | 1 +
#  1 file changed, 1 insertion(+)

# 파일 확인
ls -la
# local-file.txt가 나타남!

# 최종 상태
git log --oneline --all --graph -5
# * a3f2b1c (HEAD -> main, origin/main) Add local file
# * 7a3b2c1 Previous commit
```

#### 핵심 정리: Fetch vs Pull

**명령어 비교 표:**

|명령어|동작|origin/main|main|작업 디렉토리|
|---|---|---|---|---|
|`git fetch`|다운로드만|✅ 업데이트|❌ 그대로|❌ 변화 없음|
|`git merge origin/main`|병합만|❌ 그대로|✅ 업데이트|✅ 파일 반영|
|`git pull`|fetch + merge|✅ 업데이트|✅ 업데이트|✅ 파일 반영|

**실제 증명:**

bash

```bash
# Pull은 정말 fetch + merge일까?
# 직접 확인해봅시다

# 방법 1: Pull 사용
git pull origin main

# 방법 2: Fetch + Merge 사용
git fetch origin
git merge origin/main

# 결과는 동일합니다!
```

**언제 무엇을 사용하나?**

bash

```bash
# Fetch를 사용하는 경우:
# 1. 변경사항을 먼저 검토하고 싶을 때
git fetch origin
git log origin/main  # 무엇이 바뀌었는지 확인
git diff main origin/main  # 차이점 확인
git merge origin/main  # 괜찮으면 병합

# 2. 여러 브랜치 정보를 한 번에 가져올 때
git fetch origin  # 모든 브랜치 업데이트

# Pull을 사용하는 경우:
# 1. 빠르게 최신 상태로 동기화
git pull  # 바로 병합까지

# 2. 협업 중 팀원 변경사항 받기
git pull origin main
```

**실습 체크리스트:**

- [ ]  `git branch -r`로 원격 브랜치 확인
- [ ]  `git log --all --graph`로 main과 origin/main 분리 확인
- [ ]  `git fetch` 후 origin/main만 업데이트됨 확인
- [ ]  `git merge origin/main`으로 동기화 완료
- [ ]  fetch와 pull의 차이 이해

---

### 4.3 Push와 Pull의 이해 (50분)

#### 학습 목표

- 2인 협업 시나리오를 통해 Push/Pull 흐름 체득
- 충돌 없는 협업 방법 이해
- Pull Request 없이 직접 Push하는 워크플로우 경험

#### 실습 5: 2인 1조 협업 시나리오 (50분)

**사전 준비:**

bash

```bash
# 강사가 공용 저장소 생성
# Repository name: git-team-workshop
# Collaborator 추가: Settings → Collaborators → Add people

# 각 학생이 Clone
git clone https://github.com/instructor/git-team-workshop.git
cd git-team-workshop
```

**역할 분담:**

- **A 학생**: Feature 개발자
- **B 학생**: Bug 수정자

**시나리오 1: 순차적 작업 (충돌 없음) - 20분**

**A 학생 작업:**

bash

```bash
# 1. 새 기능 파일 생성
echo "def greet(name):" > feature.py
echo "    return f'Hello, {name}!'" >> feature.py

# 2. 커밋
git add feature.py
git commit -m "Add greet function"

# 3. Push
git push origin main

# 4. 팀원에게 알림: "feature.py 푸시 완료!"
```

**B 학생 작업:**

bash

```bash
# 1. A의 변경사항 받기
git pull origin main
# remote: Counting objects: 3, done.
# remote: Compressing objects: 100% (2/2), done.
# Updating a3f2b1c..d4e5f6a
# Fast-forward
#  feature.py | 2 ++
#  1 file changed, 2 insertions(+)

# 2. 파일 확인
cat feature.py
# def greet(name):
#     return f'Hello, {name}!'

# 3. 다른 파일에 작업
echo "# Bug Fixes" > bugfix.md
echo "- Fixed issue #123" >> bugfix.md

# 4. 커밋 및 Push
git add bugfix.md
git commit -m "Add bugfix documentation"
git push origin main
```

**A 학생이 B의 작업 받기:**

bash

```bash
# Pull로 최신 상태 유지
git pull origin main

# 파일 확인
ls -la
# bugfix.md  feature.py

cat bugfix.md
# # Bug Fixes
# - Fixed issue #123

# 히스토리 확인
git log --oneline --graph
# * e5f6a7b (HEAD -> main, origin/main) Add bugfix documentation
# * d4e5f6a Add greet function
# * ...
```

**시나리오 2: 동시 작업 (다른 파일) - 20분**

**A 학생과 B 학생 동시 작업:**

bash

```bash
# A 학생
echo "def goodbye(name):" > farewell.py
echo "    return f'Goodbye, {name}!'" >> farewell.py
git add farewell.py
git commit -m "Add farewell function"

# B 학생 (동시에)
echo "test_greet.py" > test_greet.py
echo "# TODO: Add tests" >> test_greet.py
git add test_greet.py
git commit -m "Add test file"
```

**A 학생이 먼저 Push:**

bash

```bash
git push origin main
# To https://github.com/instructor/git-team-workshop.git
#    e5f6a7b..f6a7b8c  main -> main
```

**B 학생이 Push 시도:**

bash

```bash
git push origin main
# To https://github.com/instructor/git-team-workshop.git
#  ! [rejected]        main -> main (fetch first)
# error: failed to push some refs
# hint: Updates were rejected because the remote contains work
# hint: that you do not have locally. Try 'git pull' first.
```

**거절 이유 이해:**
```
GitHub의 상태:
  ... → e5f6a7b → f6a7b8c (A가 push한 커밋)

B의 로컬 상태:
  ... → e5f6a7b → g7b8c9d (B의 커밋)

→ GitHub는 f6a7b8c를 모르는데,
  B가 갑자기 g7b8c9d를 보내려 함
→ "먼저 f6a7b8c를 받아!"
```

**B 학생이 해결:**

bash

```bash
# 1. Pull로 A의 작업 받기
git pull origin main
# From https://github.com/instructor/git-team-workshop
#  * branch            main       -> FETCH_HEAD
# Merge made by the 'recursive' strategy.
#  farewell.py | 2 ++
#  1 file changed, 2 insertions(+)

# 2. 자동 Merge 커밋 생성됨
git log --oneline --graph -5
# *   h8c9d0e (HEAD -> main) Merge branch 'main' of ...
# |\
# | * f6a7b8c (origin/main) Add farewell function
# * | g7b8c9d Add test file
# |/
# * e5f6a7b Add bugfix documentation

# 3. 이제 Push 가능
git push origin main
```

**최종 상태 (양쪽 모두):**

bash

```bash
git log --oneline --graph -5
# *   h8c9d0e (HEAD -> main, origin/main) Merge branch 'main'
# |\
# | * f6a7b8c Add farewell function
# * | g7b8c9d Add test file
# |/
# * e5f6a7b Add bugfix documentation

# 파일 확인
ls -la
# bugfix.md  farewell.py  feature.py  test_greet.py
```

**협업 베스트 프랙티스:**

bash

```bash
# 규칙 1: Push 전에 항상 Pull
git pull origin main  # 최신 상태 확인
git push origin main  # 이제 Push

# 규칙 2: 자주 Push하기
# × 나쁜 예: 하루 종일 작업 후 한 번에 Push
# ✓ 좋은 예: 의미 있는 단위로 커밋하고 자주 Push

# 규칙 3: Pull 후 테스트
git pull origin main
# 코드 실행해보고 문제 없는지 확인
git push origin main
```

**실습 체크리스트:**

- [ ]  2인 1조로 순차적 작업 완료
- [ ]  동시 작업 후 Pull 필요성 경험
- [ ]  Merge 커밋 자동 생성 확인
- [ ]  `git log --graph`로 협업 히스토리 시각화

---

### 4.4 Local Branch의 생명주기 (20분)

#### 학습 목표

- 로컬 브랜치는 개인 실험 공간임을 이해
- 로컬 브랜치 삭제가 원격에 영향 없음을 확인
- 브랜치 기반 실험 문화 체득

#### 실습 6: 실험용 브랜치 생성 및 삭제 (20분)

**시나리오: 새로운 아이디어 실험**

bash

```bash
# 현재 위치 확인
git branch
# * main

git log --oneline -3
# h8c9d0e Merge branch 'main'
# f6a7b8c Add farewell function
# g7b8c9d Add test file
```

**실험 브랜치 생성:**

bash

```bash
# 새로운 아이디어를 위한 브랜치
git checkout -b experiment-new-feature

# 브랜치 확인
git branch
#   main
# * experiment-new-feature

# 원격 브랜치도 확인
git branch -a
#   main
# * experiment-new-feature
#   remotes/origin/main
# → experiment-new-feature는 로컬에만 존재!
```

**실험 작업:**

bash

```bash
# 대담한 실험
echo "def experimental_function():" > experiment.py
echo "    # 이건 될까? 안 될까?" >> experiment.py
echo "    return 'Who knows!'" >> experiment.py

git add experiment.py
git commit -m "Try experimental approach"

# 또 다른 시도
echo "    # 다른 방법도 시도" >> experiment.py
git commit -am "Try alternative approach"

# 히스토리 확인
git log --oneline --graph
# * j9d0e1f (HEAD -> experiment-new-feature) Try alternative approach
# * i8c9d0e Try experimental approach
# * h8c9d0e (origin/main, main) Merge branch 'main'
```

**실험 결과 판단:**

**Case 1: 실험 성공 → Merge**

bash

```bash
# main으로 돌아가기
git checkout main

# 실험 브랜치 병합
git merge experiment-new-feature
# Updating h8c9d0e..j9d0e1f
# Fast-forward
#  experiment.py | 3 +++
#  1 file changed, 3 insertions(+)

# 원격에 Push (팀과 공유)
git push origin main

# 실험 브랜치 삭제 (역할 완료)
git branch -d experiment-new-feature
```

**Case 2: 실험 실패 → 삭제**

bash

```bash
# main으로 돌아가기
git checkout main

# 실험 브랜치 삭제 (미련 없이!)
git branch -D experiment-new-feature
# Deleted branch experiment-new-feature (was j9d0e1f).

# -D 옵션: 병합 안 된 브랜치도 강제 삭제
# -d 옵션: 병합된 브랜치만 삭제 (안전)

# 브랜치 확인
git branch
# * main
# → experiment-new-feature 사라짐!

# 원격 확인
git branch -r
# origin/main
# → 원격에는 애초에 없었음!
```

**핵심 메시지:**

bash

```bash
# Local Branch의 특성:
# 1. 혼자만 알 수 있음
git branch  # 내 컴퓨터에만 보임

# 2. 삭제해도 안전 (원격에 영향 없음)
git branch -D my-secret-experiment
# → GitHub에는 아무 일도 안 일어남

# 3. 실험의 자유
# "이거 될까?" → 브랜치 만들어서 시도
# "안 되네?" → 삭제
# "됐다!" → Merge 후 Push
```

**실전 활용 패턴:**

bash

```bash
# 패턴 1: 빠른 테스트
git checkout -b quick-test
# ... 코드 수정 ...
# 작동 확인
git checkout main
git branch -D quick-test  # 버리기

# 패턴 2: 단계별 실험
git checkout -b experiment-v1
# ... 1차 시도 ...
git checkout -b experiment-v2  # v1 기반
# ... 2차 시도 ...
git checkout main
git merge experiment-v2  # v2가 최선
git branch -D experiment-v1 experiment-v2

# 패턴 3: 장기 실험
git checkout -b long-term-research
# 며칠 동안 작업
# 필요 시 main에서 pull
git checkout main
git pull origin main
git checkout long-term-research
git merge main  # 최신 유지
```

**원격 브랜치와의 비교:**

bash

```bash
# 로컬 브랜치 삭제
git branch -D my-branch
# → 내 컴퓨터에서만 삭제

# 원격 브랜치 삭제 (다음 시간에 배울 내용)
git push origin --delete my-branch
# → GitHub에서 삭제 (팀원들도 영향받음)

# 지금은: 로컬만 신경 쓰기!
```

**실습 체크리스트:**
- [ ] 실험 브랜치 생성 및 작업 완료
- [ ] `git branch -a`로 로컬 전용 확인
- [ ] 브랜치 삭제 후 원격에 영향 없음 확인
- [ ] 실험-삭제 사이클 3회 반복

---

## 5부: 실전 명령어들 및 안전망 (1.5시간)

---

### 5.1 Stash - 임시 저장소 (30분)

#### 학습 목표
- 작업 중단 시 변경사항을 임시 저장할 수 있다
- Stash를 활용한 컨텍스트 스위칭 기법을 익힌다
- 급한 버그 수정 시나리오를 처리할 수 있다

#### 개념 설명 (5분)

**Stash란?**
```
"급한 불 끄러 가야 하는데, 지금 작업은 커밋하기 애매할 때"

현재 작업 → [임시 보관] → 다른 작업 → [다시 꺼내기] → 원래 작업
```

**Stash의 특징:**

- Working Directory와 Staging Area를 모두 저장
- 커밋하지 않은 변경사항 임시 보관
- 스택 구조 (여러 개 저장 가능)
- 브랜치 이동 전 깨끗한 상태 만들기

#### 실습 7: 급한 버그 수정 시나리오 (25분)

**초기 상황 설정:**

bash

```bash
# feature 브랜치에서 작업 중
git checkout -b feature-user-profile
# Switched to a new branch 'feature-user-profile'

# 열심히 작업 중...
echo "class UserProfile:" > profile.py
echo "    def __init__(self, name):" >> profile.py
echo "        self.name = name" >> profile.py
echo "        # TODO: Add email field" >> profile.py

# 파일 수정 중
echo "    def get_info(self):" >> profile.py
echo "        # 작업 중..." >> profile.py

# 현재 상태 확인
git status
# On branch feature-user-profile
# Untracked files:
#   profile.py
```

**긴급 상황 발생!**

bash

```bash
# 슬랙 메시지: "프로덕션 버그! main 브랜치 긴급 수정 필요!"
# 문제: 현재 작업은 미완성 (커밋하기 애매)

# 브랜치 전환 시도
git checkout main
# error: Your local changes to the following files would be overwritten:
#   profile.py
# Please commit your changes or stash them before you switch branches.
```

**Stash로 해결:**

bash

```bash
# 1. 현재 작업 임시 저장
git add profile.py  # 추적 파일로 만들기
git stash save "WIP: User profile implementation"
# Saved working directory and index state On feature-user-profile: WIP: User profile implementation

# 또는 간단하게
git stash
# Saved working directory and index state WIP on feature-user-profile: ...

# 2. 작업 디렉토리 확인
git status
# On branch feature-user-profile
# nothing to commit, working tree clean

ls -la
# profile.py가 사라짐!

# 3. 이제 안전하게 main으로 이동
git checkout main
# Switched to branch 'main'
```

**긴급 버그 수정:**

bash

```bash
# main 브랜치에서 버그 수정
echo "# Critical Fix" > hotfix.md
echo "Fixed production bug #456" >> hotfix.md

git add hotfix.md
git commit -m "Fix critical production bug #456"

git push origin main
# 긴급 수정 완료!
```

**원래 작업으로 복귀:**

bash

```bash
# 1. feature 브랜치로 돌아가기
git checkout feature-user-profile
# Switched to branch 'feature-user-profile'

# 2. Stash 목록 확인
git stash list
# stash@{0}: On feature-user-profile: WIP: User profile implementation

# 3. Stash 내용 확인 (적용 전 미리보기)
git stash show
# profile.py | 6 ++++++
# 1 file changed, 6 insertions(+)

# 더 자세히
git stash show -p
# diff --git a/profile.py b/profile.py
# new file mode 100644
# +class UserProfile:
# +    def __init__(self, name):
# ...

# 4. Stash 적용 및 삭제
git stash pop
# On branch feature-user-profile
# Changes to be committed:
#   new file:   profile.py

# 파일 확인
cat profile.py
# class UserProfile:
#     def __init__(self, name):
#         self.name = name
#         # TODO: Add email field
#     def get_info(self):
#         # 작업 중...

# 5. 작업 계속
echo "        return self.name" >> profile.py
git commit -am "Complete user profile class"
```

**Stash 고급 활용:**

bash

```bash
# 여러 Stash 관리
git stash list
# stash@{0}: WIP on feature-user-profile: abc123 Latest work
# stash@{1}: WIP on feature-login: def456 Login form
# stash@{2}: On main: ghi789 Quick experiment

# 특정 Stash 적용
git stash apply stash@{1}  # 1번 적용 (삭제 안 함)
git stash pop stash@{1}    # 1번 적용 및 삭제

# Stash 삭제
git stash drop stash@{0}   # 0번 삭제
git stash clear            # 전부 삭제

# Untracked 파일도 Stash
git stash -u  # --include-untracked
# 새로 만든 파일도 함께 저장

# Stash 메시지와 함께
git stash save "Feature X: Before testing alternative approach"
```

**실전 시나리오:**

**시나리오 1: 실험 중 긴급 작업**

bash

```bash
# 실험 중
git stash save "Experimental refactoring - checkpoint 1"
git checkout main
# 긴급 작업 수행
git checkout experiment
git stash pop
# 실험 계속
```

**시나리오 2: 여러 작업 동시 진행**

bash

```bash
# Feature A 작업 중
git stash save "Feature A: half done"
git checkout feature-b
# Feature B 작업
git stash save "Feature B: debugging"
git checkout main
# Code review
git checkout feature-a
git stash pop  # Feature A 복귀
```

**시나리오 3: Pull 전 충돌 회피**

bash

```bash
# 로컬 수정 사항이 있는데 Pull 필요
git stash
git pull origin main
git stash pop
# 로컬 변경 + 원격 변경 합쳐짐
```

**주의사항:**

bash

```bash
# 주의 1: Stash는 로컬 전용
# → 팀원과 공유 안 됨
# → Push/Pull 영향 없음

# 주의 2: Stash pop 충돌
git stash pop
# Auto-merging profile.py
# CONFLICT (content): Merge conflict in profile.py
# → 수동 해결 필요
# → 충돌 해결 후: git add profile.py

# 주의 3: Stash는 임시방편
# → 커밋이 더 나은 선택일 수 있음
# → 오래 보관하지 말기 (1-2일 내 정리)
```

**실습 체크리스트:**

- [ ]  `git stash`로 작업 임시 저장
- [ ]  `git stash list`로 목록 확인
- [ ]  브랜치 이동 후 긴급 작업 완료
- [ ]  `git stash pop`으로 작업 복구
- [ ]  여러 Stash 관리 실습

---

### 5.2 Reset - 되돌리기 (안전장치 포함) (35분)

#### 학습 목표

- Reset의 3가지 모드를 정확히 이해한다
- **안전하게** Reset을 사용하는 방법을 익힌다
- Reset 실수 시 복구 방법을 알고 있다

#### ⚠️ 안전 수칙 먼저! (5분)

**Reset 사용 전 필수 백업:**

bash

```bash
# 규칙: Reset 전 항상 백업 브랜치 생성!
git branch backup-before-reset

# 확인
git branch
# * main
#   backup-before-reset
#   feature-user-profile

# 이제 안심하고 Reset 가능
# 실수해도: git checkout backup-before-reset
```

#### 개념 설명: Reset의 3단계 (5분)

**Git의 3가지 영역:**
```
[Working Directory] ← 파일 실제 수정
         ↓
 [Staging Area]    ← git add
         ↓
    [Repository]   ← git commit
```

**Reset 모드별 영향:**

|모드|Repository|Staging Area|Working Directory|
|---|---|---|---|
|`--soft`|← 여기로 이동|유지|유지|
|`--mixed` (기본)|← 여기로 이동|초기화|유지|
|`--hard`|← 여기로 이동|초기화|**삭제** ⚠️|

#### 실습 8: Reset 3단계 실습 (25분)

**준비 작업:**

bash

```bash
# 테스트용 커밋 3개 만들기
echo "Version 1" > file.txt
git add file.txt
git commit -m "Commit 1: Version 1"

echo "Version 2" > file.txt
git commit -am "Commit 2: Version 2"

echo "Version 3" > file.txt
git commit -am "Commit 3: Version 3"

# 현재 히스토리
git log --oneline
# c3 (HEAD -> main) Commit 3: Version 3
# c2 Commit 2: Version 2
# c1 Commit 1: Version 1
# ...

# 파일 내용
cat file.txt
# Version 3
```

**실습 A: `--soft` Reset (5분)**

bash

```bash
# 안전 백업
git branch backup-soft

# Soft Reset (Commit 2로 이동)
git reset --soft HEAD~1

# 상태 확인
git log --oneline
# c2 (HEAD -> main) Commit 2: Version 2
# c1 Commit 1: Version 1
# → Commit 3 사라짐

git status
# On branch main
# Changes to be committed:
#   modified:   file.txt
# → Staging Area에 변경사항 유지!

cat file.txt
# Version 3
# → Working Directory도 그대로!

# Staging Area 내용 확인
git diff --cached
# -Version 2
# +Version 3
```

**Soft Reset 용도:**

bash

```bash
# 커밋 메시지 수정
git reset --soft HEAD~1
# 파일 수정 (필요 시)
git commit -m "Better commit message"

# 여러 커밋 합치기
git reset --soft HEAD~3
git commit -m "Combined three commits"
```

**실습 B: `--mixed` Reset (기본값) (10분)**

bash

```bash
# 원상복구
git checkout backup-soft
git branch -D main
git checkout -b main

# 또는
git reset --hard c3  # Commit 3로 복귀

# Mixed Reset (기본 동작)
git reset HEAD~1
# 또는
git reset --mixed HEAD~1

# 상태 확인
git log --oneline
# c2 (HEAD -> main) Commit 2: Version 2
# c1 Commit 1: Version 1

git status
# On branch main
# Changes not staged for commit:
#   modified:   file.txt
# → Staging Area 초기화! (unstaged)

cat file.txt
# Version 3
# → Working Directory는 유지!

# 변경사항 확인
git diff
# -Version 2
# +Version 3
```

**Mixed Reset 용도:**

bash

```bash
# 잘못 Staging한 파일 되돌리기
git add wrong-file.txt
git reset HEAD wrong-file.txt
# 또는
git reset  # 전체 unstage

# 커밋 취소 후 재작업
git reset HEAD~1
# 파일 수정
git add -p  # 선택적 staging
git commit -m "Better organized commit"
```

**실습 C: `--hard` Reset ⚠️ (10분)**

bash

```bash
# ⚠️ 위험: 반드시 백업 먼저!
git branch backup-hard

# Hard Reset
git reset --hard HEAD~1

# 상태 확인
git log --oneline
# c2 (HEAD -> main) Commit 2: Version 2
# c1 Commit 1: Version 1

git status
# On branch main
# nothing to commit, working tree clean

cat file.txt
# Version 2
# → Working Directory까지 삭제!

# 변경사항 완전 소멸
git diff
# (결과 없음)
```

**Hard Reset 위험성 체험:**

bash

```bash
# 위험 시나리오: 작업 중인 파일 날리기
echo "Important work in progress" > important.txt
git add important.txt

git reset --hard HEAD
# → important.txt 삭제됨!

ls important.txt
# ls: important.txt: No such file or directory
# ⚠️ 복구 불가능!
```

**복구 방법:**

bash

```bash
# 백업 브랜치로 복구
git checkout backup-hard
git log --oneline
# c3 (HEAD -> backup-hard) Commit 3: Version 3
# c2 Commit 2: Version 2
# c1 Commit 1: Version 1

# 다시 main으로
git checkout main
git reset --hard backup-hard
# → 복구 완료!
```

**Reset 비교 표:**

bash

```bash
# 실험 환경 재설정
git checkout c3
git branch -D main
git checkout -b main

# 초기 상태
echo "Line 1" > test.txt
git add test.txt
git commit -m "Initial"

echo "Line 2" >> test.txt
git commit -am "Add line 2"

echo "Line 3" >> test.txt
git add test.txt  # Staged
echo "Line 4" >> test.txt  # Not staged

# 현재 상태:
# Repository: Line 1, Line 2
# Staging: Line 1, Line 2, Line 3
# Working: Line 1, Line 2, Line 3, Line 4

# --soft HEAD~1
git reset --soft HEAD~1
# Repository: Line 1
# Staging: Line 1, Line 2, Line 3
# Working: Line 1, Line 2, Line 3, Line 4

# --mixed HEAD~1 (기본)
git reset HEAD~1
# Repository: Line 1
# Staging: Line 1
# Working: Line 1, Line 2, Line 3, Line 4

# --hard HEAD~1
git reset --hard HEAD~1
# Repository: Line 1
# Staging: Line 1
# Working: Line 1  ← Line 2, 3, 4 모두 삭제!
```

**안전한 Reset 체크리스트:**

bash

```bash
# ✅ 안전한 사용법
# 1. 항상 백업
git branch backup-$(date +%Y%m%d-%H%M%S)

# 2. 로컬 브랜치에만 사용
# × git reset on main (pushed)
# ✓ git reset on feature-branch (local)

# 3. Push 전에만
# × git push → git reset (팀원 피해)
# ✓ git reset → git push

# 4. --hard는 최후의 수단
git reset --soft   # 먼저 시도
git reset --mixed  # 다음 시도
git reset --hard   # 정말 확실할 때만
```

**실습 체크리스트:**

- [ ]  `git branch backup` 습관화
- [ ]  `--soft`: Staging 유지 확인
- [ ]  `--mixed`: Staging 초기화 확인
- [ ]  `--hard`: Working Directory 삭제 확인
- [ ]  백업 브랜치로 복구 성공

---

### 5.3 Checkout - 시간 여행 (25분)

#### 학습 목표

- Detached HEAD 상태를 이해하고 안전하게 탐색한다
- 과거 커밋으로 이동하여 코드를 검토할 수 있다
- 특정 파일만 복원하는 방법을 익힌다

#### 개념 설명 (5분)

**Checkout의 두 얼굴:**

bash

```bash
# 1. 브랜치 전환 (우리가 아는 것)
git checkout main

# 2. 시간 여행 (새로운 용도!)
git checkout <commit-hash>
```

**Detached HEAD란?**
```
일반 상태:
HEAD → main → c3 (latest commit)

Detached HEAD:
HEAD → c1 (과거 commit)
main → c3 (여기 그대로)

→ "브랜치 없이 커밋을 직접 가리킴"
```

#### 실습 9: 과거로 시간 여행 (15분)

**준비: 타임라인 만들기**

bash

```bash
# v1 커밋
echo "Version 1.0" > app.py
echo "def greet(): return 'Hello'" >> app.py
git add app.py
git commit -m "Release v1.0"

# v2 커밋
echo "Version 2.0" > app.py
echo "def greet(name): return f'Hello {name}'" >> app.py
git commit -am "Release v2.0 - Add name parameter"

# v3 커밋
echo "Version 3.0" > app.py
echo "def greet(name, lang='en'): return f'Hello {name}'" >> app.py
git commit -am "Release v3.0 - Add language support"

# 현재 히스토리
git log --oneline
# c3 (HEAD -> main) Release v3.0 - Add language support
# c2 Release v2.0 - Add name parameter
# c1 Release v1.0
```

**과거로 이동:**

bash

```bash
# v1으로 이동
git checkout c1  # 실제 해시 사용: git checkout a3f2b1c

# 경고 메시지 확인
# You are in 'detached HEAD' state. You can look around, make experimental
# changes and commit them, and you can discard any commits you make in this
# state without impacting any branches by switching back to a branch.

# 현재 상태
cat app.py
# Version 1.0
# def greet(): return 'Hello'

git log --oneline
# c1 (HEAD) Release v1.0
# → c2, c3가 안 보임! (미래이므로)

# HEAD 위치 확인
git log --oneline --all --graph
# * c3 (main) Release v3.0 - Add language support
# * c2 Release v2.0 - Add name parameter
# * c1 (HEAD) Release v1.0
```

**Detached HEAD 상태에서 실험:**

bash

```bash
# 과거에서 실험 가능
echo "# Experimental change in the past" >> app.py
git commit -am "Experiment in v1"

# 새 커밋 생성됨!
git log --oneline
# e4 (HEAD) Experiment in v1
# c1 Release v1.0

# 하지만 main에는 영향 없음
git log --oneline --all --graph
#   c3 (main) Release v3.0
#   c2 Release v2.0
#   c1 Release v1.0
#  /
# e4 (HEAD) Experiment in v1
# → 분리된 타임라인!
```

**현재로 복귀:**

bash

```bash
# main으로 돌아가기
git checkout main
# Warning: you are leaving 1 commit behind, not connected to
# any of your branches:
#   e4 Experiment in v1

# 파일 확인
cat app.py
# Version 3.0
# def greet(name, lang='en'): return f'Hello {name}'
# → 최신 상태로 복귀!

# e4 커밋은?
git log --oneline
# c3 (HEAD -> main) Release v3.0
# c2 Release v2.0
# c1 Release v1.0
# → e4 사라짐 (버려짐)
```

**Detached HEAD 활용 시나리오:**

**시나리오 1: 버그 발생 시점 찾기**

bash

```bash
# 언제 버그가 생겼나?
git log --oneline
# c10 (HEAD -> main) Current version - BUG!
# c9 Add feature Z
# c8 Refactor module X
# ...
# c1 Initial commit

# 이진 탐색으로 찾기
git checkout c5
# 테스트 → 버그 있음

git checkout c3
# 테스트 → 버그 없음

git checkout c4
# 테스트 → 버그 발견! c4가 원인

# 원인 파악 후 복귀
git checkout main
```

**시나리오 2: 과거 코드 참고**

bash

```bash
# 예전엔 어떻게 구현했더라?
git checkout c5
cat old_implementation.py
# 참고용으로 코드 확인
git checkout main
# 현재 코드에 적용
```

#### 실습 10: 특정 파일만 복원 (5분)

**시나리오: 파일을 잘못 수정했을 때**

bash

```bash
# 현재 상태
cat app.py
# Version 3.0
# def greet(name, lang='en'): return f'Hello {name}'

# 실수로 파일 망침
echo "BROKEN CODE" > app.py
cat app.py
# BROKEN CODE

# 커밋은 안 했음
git status
# Changes not staged for commit:
#   modified:   app.py
```

**특정 파일만 복원:**

bash

```bash
# 방법 1: 최근 커밋에서 복원
git checkout HEAD -- app.py

cat app.py
# Version 3.0
# def greet(name, lang='en'): return f'Hello {name}'
# → 복구 완료!

# 방법 2: 특정 커밋에서 복원
echo "BROKEN AGAIN" > app.py
git checkout c2 -- app.py

cat app.py
# Version 2.0
# def greet(name): return f'Hello {name}'
# → v2 버전으로 복원!

git status
# Changes to be committed:
#   modified:   app.py
# → Staged 상태로 복원됨
```

**고급 활용:**

bash

```bash
# 여러 파일 복원
git checkout HEAD~3 -- file1.txt file2.txt

# 디렉토리 전체 복원
git checkout c5 -- src/

# 특정 브랜치에서 파일 가져오기
git checkout feature-branch -- new-feature.py
```

**Checkout vs Reset 비교:**

bash

```bash
# Reset: HEAD와 브랜치를 이동
git reset HEAD~1
# → HEAD와 main이 함께 이동

# Checkout: HEAD만 이동
git checkout c1
# → HEAD만 이동 (Detached)
# → main은 그대로

# Checkout: 파일 복원
git checkout HEAD -- file.txt
# → HEAD 이동 없음
# → 파일만 복원
```

**실습 체크리스트:**
- [ ] `git checkout <hash>`로 과거 이동
- [ ] Detached HEAD 상태 확인
- [ ] `git log --all --graph`로 전체 히스토리 확인
- [ ] `git checkout main`으로 복귀
- [ ] `git checkout HEAD -- <file>`로 파일 복원

---

### 5.4 Reflog - 잃어버린 커밋 복구 (30분)

#### 학습 목표
- Reflog를 통해 Git의 안전망을 이해한다
- `git reset --hard`로 잃어버린 커밋을 복구할 수 있다
- Git은 30일간 모든 기록을 보관함을 확신한다

#### 개념 설명 (5분)

**Reflog란?**
```
"Git의 블랙박스"

HEAD의 모든 이동 기록 저장:
- git commit
- git checkout
- git reset
- git merge
- ...

기본 보관 기간: 30일
```

**왜 필요한가?**

bash

```bash
# 이런 실수를 했을 때:
git reset --hard HEAD~10
# "앗! 중요한 커밋 날렸다!"

# Reflog가 있다면:
# → 걱정 마세요, 복구 가능합니다!
```

#### 실습 11: 커밋 잃어버리기와 복구 (25분)

**Phase 1: 중요한 작업 만들기 (5분)**

bash

```bash
# 중요한 작업 시뮬레이션
echo "Critical Feature" > important.py
echo "def critical_function():" >> important.py
echo "    return 'This is important!'" >> important.py
git add important.py
git commit -m "Add critical feature - DO NOT LOSE!"

# 몇 개 더 추가
echo "    # Enhancement 1" >> important.py
git commit -am "Enhance critical feature - v1"

echo "    # Enhancement 2" >> important.py
git commit -am "Enhance critical feature - v2"

# 현재 히스토리
git log --oneline
# c6 (HEAD -> main) Enhance critical feature - v2
# c5 Enhance critical feature - v1
# c4 Add critical feature - DO NOT LOSE!
# c3 Release v3.0
# ...

# 해시 기록 (나중에 사용)
git rev-parse HEAD > /tmp/critical-commit.txt
```

**Phase 2: 실수로 커밋 날리기 (5분)**

bash

```bash
# 실수: 너무 많이 되돌림
git reset --hard HEAD~10
# HEAD is now at c0 Initial commit

# 패닉!
git log --oneline
# c0 (HEAD -> main) Initial commit
# → c4, c5, c6 모두 사라짐!

ls -la
# important.py 없음!

# 일반적인 방법으로는 복구 불가
git log --all --oneline
# c0 (HEAD -> main) Initial commit
# → 정말 사라짐...?
```

**Phase 3: Reflog로 구조 (15분)**

**Step 1: Reflog 확인**

bash

```bash
# HEAD의 이동 기록 보기
git reflog
# c0 (HEAD -> main) HEAD@{0}: reset: moving to HEAD~10
# c6 HEAD@{1}: commit: Enhance critical feature - v2
# c5 HEAD@{2}: commit: Enhance critical feature - v1
# c4 HEAD@{3}: commit: Add critical feature - DO NOT LOSE!
# c3 HEAD@{4}: commit: Release v3.0
# ...

# 발견! c6가 HEAD@{1}에 있음!
```

**Reflog 읽는 법:**

bash

```bash
# 형식:
# <hash> HEAD@{n}: <action>: <description>

# HEAD@{0}: 현재 (최신)
# HEAD@{1}: 1단계 전
# HEAD@{2}: 2단계 전
# ...

# 시간으로도 조회 가능
git reflog HEAD@{1.hour.ago}
git reflog HEAD@{yesterday}
git reflog HEAD@{2024-01-15}
```

**Step 2: 잃어버린 커밋 확인**

bash

```bash
# c6 커밋 내용 확인
git show c6
# commit c6...
# Author: ...
# Date: ...
#
#     Enhance critical feature - v2
#
# diff --git a/important.py b/important.py
# +    # Enhancement 2

# 맞다! 이게 우리가 찾던 커밋!
```

**Step 3: 복구 방법 3가지**

**방법 1: Reset으로 복구**

bash

```bash
# 가장 간단
git reset --hard c6
# HEAD is now at c6 Enhance critical feature - v2

# 확인
git log --oneline
# c6 (HEAD -> main) Enhance critical feature - v2
# c5 Enhance critical feature - v1
# c4 Add critical feature - DO NOT LOSE!
# ...

ls -la
# important.py ← 복구됨!

cat important.py
# Critical Feature
# def critical_function():
#     return 'This is important!'
#     # Enhancement 1
#     # Enhancement 2
```

**방법 2: Checkout + Branch로 복구**

bash

```bash
# 먼저 다시 실수 상태로
git reset --hard HEAD~10

# Detached HEAD로 이동
git checkout c6
# HEAD is now at c6 Enhance critical feature - v2

# 브랜치 생성으로 구출
git branch recovery-branch
git checkout recovery-branch

# 또는 한 줄로
git checkout -b recovery-branch c6

# main으로 가져오기
git checkout main
git merge recovery-branch
git branch -d recovery-branch
```

**방법 3: Cherry-pick으로 선택적 복구**

bash

```bash
# 다시 실수 상태로
git reset --hard c0

# 특정 커밋만 가져오기
git cherry-pick c4  # Add critical feature
git cherry-pick c5  # Enhancement 1
git cherry-pick c6  # Enhancement 2

# 히스토리는 달라지지만 내용은 같음
git log --oneline
# c9 (HEAD -> main) Enhance critical feature - v2
# c8 Enhance critical feature - v1
# c7 Add critical feature - DO NOT LOSE!
# c0 Initial commit
```

**실전 시나리오:**

**시나리오 1: 잘못된 Merge 취소**

bash

```bash
# 실수로 Merge
git merge wrong-branch
# 엉망진창...

# Reflog 확인
git reflog
# abc123 HEAD@{0}: merge wrong-branch: Merge made by...
# def456 HEAD@{1}: commit: Last good commit

# Merge 전으로 복구
git reset --hard def456
```

**시나리오 2: 삭제한 브랜치 복구**

bash

```bash
# 브랜치 삭제
git branch -D feature-important
# Deleted branch feature-important (was ghi789)

# Reflog에서 찾기
git reflog | grep feature-important
# ghi789 HEAD@{5}: checkout: moving to feature-important

# 브랜치 재생성
git branch feature-important ghi789
```

**시나리오 3: Rebase 실수 복구**

bash

```bash
# Rebase 후 문제 발생
git rebase main
# 충돌 해결 실패...

# Rebase 전으로 복구
git reflog
# jkl012 HEAD@{1}: rebase: ...
# mno345 HEAD@{2}: checkout: moving to feature-branch

git reset --hard mno345
```

**Reflog 관리:**

bash

```bash
# Reflog 전체 보기
git reflog show

# 특정 브랜치의 Reflog
git reflog show main
git reflog show feature-branch

# Reflog 유효 기간 설정 확인
git config gc.reflogExpire
# 기본값: 90 days

git config gc.reflogExpireUnreachable
# 기본값: 30 days

# Reflog 정리 (조심!)
git reflog expire --expire=now --all
git gc --prune=now
# → 복구 불가능해짐!
```

**안전 수칙:**

bash

```bash
# ✅ Reflog는 로컬 전용
# → Push/Pull과 무관
# → 내 컴퓨터에만 존재

# ✅ 30일 보호 기간
# → 1달 안에는 복구 가능
# → 그래도 백업 브랜치는 만들자!

# ✅ Reflog 만능 아님
# → 커밋 안 한 변경사항은 복구 불가
# → git add 안 한 파일도 복구 불가

# ⚠️ 이건 복구 안 됨
echo "Not committed" > file.txt
git reset --hard HEAD
# → file.txt 영원히 사라짐 (커밋 안 했으므로)
```

**핵심 메시지:**
```
"Git은 안전하다!"

- 커밋한 내용은 30일간 보관
- Reflog로 거의 모든 실수 복구 가능
- 하지만 백업 브랜치는 기본

git branch backup  ← 이 습관만 들이면
모든 실수에서 안전합니다!
```

**실습 체크리스트:**

- [ ]  `git reflog`로 HEAD 이동 기록 확인
- [ ]  `git reset --hard`로 커밋 잃어버리기
- [ ]  Reflog에서 잃어버린 커밋 찾기
- [ ]  `git reset --hard <hash>`로 복구
- [ ]  브랜치 삭제 후 Reflog로 복구

---

## 종합 실습: 안전망 완전 마스터 (보너스 15분)

### 실습 12: 최악의 시나리오 극복하기

**시나리오: 모든 게 꼬인 상황**

bash

```bash
# 1. 중요한 작업
git checkout -b critical-feature
echo "Critical Code" > critical.py
git add critical.py
git commit -m "Critical: Must not lose this"

# 2. 실험 작업 (Stash)
echo "Experiment" > experiment.py
git add experiment.py
git stash save "Risky experiment"

# 3. 브랜치 이동 및 작업
git checkout main
echo "Main work" > main.py
git add main.py
git commit -m "Work on main"

# 4. 심각한 실수들
git branch -D critical-feature  # 브랜치 삭제!
git reset --hard HEAD~5  # 과도한 Reset!
git stash drop  # Stash 삭제!

# 5. 패닉 상태
git log --oneline
# → critical-feature 커밋 안 보임
# → main 작업도 사라짐
git stash list
# → Stash도 비어 있음
```

**복구 미션:**

bash

```bash
# Mission 1: Reflog로 모든 커밋 찾기
git reflog | grep "Critical"
# abc123 HEAD@{8}: commit: Critical: Must not lose this

# Mission 2: 브랜치 복구
git branch critical-feature abc123

# Mission 3: main 작업 복구
git reflog | grep "Work on main"
# def456 HEAD@{2}: commit: Work on main
git reset --hard def456

# Mission 4: Stash 복구 (고급)
git fsck --lost-found
# dangling commit ghi789
git show ghi789  # Stash 내용 확인
git stash apply ghi789

# 완전 복구 성공!
```

---

## 마무리 및 정리

### 핵심 명령어 요약

bash

```bash
# Stash
git stash save "작업 내용"    # 임시 저장
git stash list                # 목록 확인
git stash pop                 # 적용 및 삭제
git stash apply stash@{n}     # 적용만

# Reset
git branch backup             # 필수!
git reset --soft HEAD~n       # Staging 유지
git reset --mixed HEAD~n      # Staging 초기화 (기본)
git reset --hard HEAD~n       # 전부 삭제 (위험)

# Checkout
git checkout <hash>           # 시간 여행
git checkout main             # 복귀
git checkout HEAD -- <file>   # 파일 복원

# Reflog
git reflog                    # HEAD 기록
git reset --hard <hash>       # 복구
git branch recovery <hash>    # 브랜치로 복구
```

### 안전 수칙 5계명

bash

```bash
# 1. 항상 백업
git branch backup-$(date +%Y%m%d)

# 2. 커밋 자주 하기
# 커밋 = 세이브 포인트

# 3. --hard는 신중히
git reset --soft   # 먼저
git reset --mixed  # 다음
git reset --hard   # 최후

# 4. 30일 규칙 기억
# Reflog = 30일 안전망

# 5. 의심되면 Reflog
git reflog  # 만능 열쇠
```
