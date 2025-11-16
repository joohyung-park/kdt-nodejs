# Git 실전 협업 시나리오 - 7부 강의 교안

## 7.1 Fork & Pull Request (60분)

### 사전 준비

- 강사용 GitHub 계정 2개 (instructor, assistant)
- Demo 저장소: `instructor/company-project`
- 프로젝터 연결 (GitHub UI + 터미널 화면 전환)
- 학생들 2인 1조 편성 완료

---

### Part 1: 개념 설명 (10분)

#### Fork와 Clone의 차이

**화면 공유: 다이어그램**

```
[GitHub: facebook/react]
         │
         │ Fork (서버→서버 복사)
         ↓
[GitHub: yourname/react]
         │
         │ Clone (서버→로컬 복사)
         ↓
[Local: ~/react]
```

**핵심 메시지:**

- Clone: 저장소를 내 컴퓨터로 복사
- Fork: 저장소를 내 GitHub 계정으로 복사
- Fork는 Push 권한이 없는 저장소에 기여할 때 사용

**실무 컨텍스트:**

```
상황 1: 회사 내부 프로젝트
→ Clone만 사용 (모두 Collaborator 권한 있음)

상황 2: 오픈소스 기여
→ Fork + Clone 사용 (외부인이므로 권한 없음)

상황 3: 회사에서 엄격한 권한 관리
→ Fork + Clone + PR 워크플로우
```

#### Pull Request 전체 흐름

**화면 공유: 워크플로우 차트**

```
1. Fork        → 원본을 내 계정으로 복사
2. Clone       → Fork를 로컬로 복사  
3. Branch      → feature/login-button
4. Commit      → 기능 개발 및 커밋
5. Push        → origin (내 Fork)에 푸시
6. Pull Request → upstream (원본)에 병합 요청
7. Code Review → 팀원 검토 + 코멘트
8. Approve     → 승인
9. Merge       → 원본에 병합
10. Delete Branch → PR 브랜치 정리
```

**실무 원칙:**

- main 브랜치 직접 수정 금지
- 모든 변경은 PR을 통해서만
- 최소 1명 이상 Approve 필요
- CI/CD 테스트 통과 필수

---

### Part 2: 강사 시연 (25분)

#### 시연 시나리오

**상황:** 신입 개발자가 회사 프로젝트에 첫 기여 **작업:** 로그인 페이지에 "비밀번호 보기" 버튼 추가

---

#### Step 1: Fork (GitHub UI)

**[instructor 계정 화면]**

저장소 구조:

```
instructor/company-project
├── src/
│   ├── login.html
│   ├── style.css
│   └── app.js
├── README.md
└── .gitignore
```

**[assistant 계정으로 전환]**

1. `https://github.com/instructor/company-project` 접속
2. 우측 상단 **Fork** 버튼 클릭
3. Fork 설정:

```
   Owner: assistant
   Repository name: company-project
   Description: (기본값 유지)
   ☑ Copy the main branch only
```

4. **Create fork** 클릭

**결과 확인:**

```
URL 변화:
원본: github.com/instructor/company-project
Fork: github.com/assistant/company-project
```

**주의사항 설명:**

- Fork는 특정 시점의 스냅샷
- 원본이 업데이트되어도 자동 동기화 안 됨
- 주기적으로 upstream에서 pull 필요

---

#### Step 2: Clone & Upstream 설정 (터미널)

**[터미널 화면 전환]**

**잘못된 Clone (시연):**

bash

```bash
# ❌ 원본을 직접 Clone하면?
git clone https://github.com/instructor/company-project.git
cd company-project

# Push 시도
echo "test" >> README.md
git commit -am "Test commit"
git push origin main
# remote: Permission to instructor/company-project.git denied to assistant.
# fatal: unable to access 'https://github.com/instructor/company-project.git/': 
# The requested URL returned error: 403
```

**올바른 Clone:**

bash

```bash
# ✅ 내 Fork를 Clone
cd ~/workspace
git clone https://github.com/assistant/company-project.git
cd company-project

# Remote 확인
git remote -v
# origin  https://github.com/assistant/company-project.git (fetch)
# origin  https://github.com/assistant/company-project.git (push)
```

**Upstream 추가 (핵심!):**

bash

```bash
# 원본 저장소를 upstream으로 추가
git remote add upstream https://github.com/instructor/company-project.git

# 최종 Remote 구성
git remote -v
# origin    https://github.com/assistant/company-project.git (fetch)
# origin    https://github.com/assistant/company-project.git (push)
# upstream  https://github.com/instructor/company-project.git (fetch)
# upstream  https://github.com/instructor/company-project.git (push)
```

**다이어그램 (화이트보드):**
```
[upstream: instructor/company-project] ← 원본 (읽기 전용)
         ↓ fetch/pull
[local: ~/company-project]
         ↓ push
[origin: assistant/company-project] ← 내 Fork (읽기/쓰기)
         ↓ Pull Request
[upstream: instructor/company-project] ← 병합 요청
```

---

#### Step 3: Feature Branch 생성 및 작업

**최신 상태 확인:**

bash

```bash
# upstream에서 최신 코드 받아오기
git fetch upstream
git checkout main
git merge upstream/main
# Already up to date.

# 또는 한 줄로
git pull upstream main
```

**Feature Branch 생성:**

bash

```bash
# 브랜치 네이밍 컨벤션
git checkout -b feature/password-toggle
# 또는
# git checkout -b feat/password-toggle
# git checkout -b feature/issue-123-password-toggle

# 브랜치 확인
git branch
#   main
# * feature/password-toggle
```

**코드 작업:**

bash

```bash
# login.html 수정
cat >> src/login.html << 'EOF'
<!-- 비밀번호 보기 버튼 추가 -->
<div class="password-wrapper">
  <input type="password" id="password" name="password">
  <button type="button" id="toggle-password">👁️</button>
</div>
EOF

# app.js에 기능 추가
cat >> src/app.js << 'EOF'

// 비밀번호 보기 토글
document.getElementById('toggle-password').addEventListener('click', function() {
  const passwordInput = document.getElementById('password');
  const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
  passwordInput.setAttribute('type', type);
  this.textContent = type === 'password' ? '👁️' : '🙈';
});
EOF

# style.css 스타일 추가
cat >> src/style.css << 'EOF'

.password-wrapper {
  position: relative;
  display: inline-block;
}

#toggle-password {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  border: none;
  background: none;
  cursor: pointer;
}
EOF
```

**커밋:**

bash

```bash
# 변경사항 확인
git status
# On branch feature/password-toggle
# Modified:   src/login.html
# Modified:   src/app.js
# Modified:   src/style.css

# 스테이징
git add src/

# 커밋 (의미 있는 메시지)
git commit -m "feat: Add password visibility toggle button

- Add toggle button to password input field
- Implement click handler to switch between text/password types
- Add CSS styling for button positioning

Resolves #123"

# 히스토리 확인
git log --oneline -3
# abc1234 (HEAD -> feature/password-toggle) feat: Add password visibility toggle button
# def5678 (upstream/main, origin/main, main) docs: Update README
# ghi9012 fix: Login validation bug
```

---

#### Step 4: Push to Fork

bash

```bash
# origin (내 Fork)에 푸시
git push origin feature/password-toggle
# Enumerating objects: 7, done.
# Counting objects: 100% (7/7), done.
# Delta compression using up to 8 threads
# Compressing objects: 100% (4/4), done.
# Writing objects: 100% (4/4), 523 bytes | 523.00 KiB/s, done.
# Total 4 (delta 2), reused 0 (delta 0), pack-reused 0
# To https://github.com/assistant/company-project.git
#  * [new branch]      feature/password-toggle -> feature/password-toggle

# GitHub에서 브랜치 확인 가능
```

**주의사항:**

bash

```bash
# ❌ 절대 하지 말 것
git push upstream feature/password-toggle
# → upstream은 읽기 전용! Permission denied

# ✅ 항상 origin으로
git push origin <브랜치명>
```

---

#### Step 5: Pull Request 생성 (GitHub UI)

**[GitHub: assistant/company-project 화면]**

1. 푸시 직후 나타나는 배너:
```
   feature/password-toggle had recent pushes less than a minute ago
   [Compare & pull request]
```

2. 또는 **Pull requests** 탭 → **New pull request**

3. **Base repository 설정 (중요!):**
```
   base repository: instructor/company-project
   base: main
   
   head repository: assistant/company-project
   compare: feature/password-toggle
```

4. **PR 템플릿 작성:**

markdown

```markdown
   ## 📝 Description
   로그인 페이지에 비밀번호 표시/숨김 토글 버튼을 추가했습니다.
   
   ## 🎯 Changes
   - `src/login.html`: 비밀번호 입력 필드에 토글 버튼 추가
   - `src/app.js`: 클릭 이벤트 핸들러 구현
   - `src/style.css`: 버튼 위치 스타일링
   
   ## 🧪 Testing
   - [ ] Chrome 브라우저에서 테스트 완료
   - [ ] 비밀번호 표시/숨김 정상 작동 확인
   - [ ] 모바일 반응형 확인
   
   ## 📸 Screenshots
   [스크린샷 첨부]
   
   ## 🔗 Related Issues
   Closes #123
   
   ## ✅ Checklist
   - [x] 코드 스타일 가이드 준수
   - [x] 주석 추가
   - [x] 테스트 완료
   - [ ] 문서 업데이트 (필요 시)
   
   ## 👀 Reviewers
   @instructor @senior-dev
```

5. **Create pull request** 클릭

**PR 생성 후 화면:**
```
Pull Request #45
feat: Add password visibility toggle button

assistant wants to merge 1 commit into instructor:main from assistant:feature/password-toggle

[Conversation] [Commits] [Files changed]

Checks: ✓ All checks passed
Reviewers: instructor, senior-dev
Labels: enhancement, good first issue
```

---

#### Step 6: Code Review 시연 (강사 역할 전환)

**[instructor 계정으로 전환]**

**PR 확인:**

1. **Files changed** 탭 클릭
2. 라인별 코드 리뷰:

**긍정적 피드백:**
```
src/app.js (Line 15-20):
💬 instructor: "좋은 접근입니다! 이벤트 리스너를 명확하게 분리했네요. 👍"
```

**개선 제안:**
```
src/app.js (Line 18):
💬 instructor: "보안 고려사항: 
비밀번호가 text 타입일 때 브라우저 자동완성이 작동할 수 있습니다.
autocomplete="off" 속성 추가를 제안합니다.

예시:
passwordInput.setAttribute('autocomplete', 'off');

어떻게 생각하시나요?"

[Start a review] [Add single comment]
```

**버그 발견:**
```
src/login.html (Line 12):
❌ instructor: "문제 발견!
id="toggle-password"인데 app.js에서는
getElementById('toggle-btn')로 찾고 있습니다.
ID 불일치로 기능이 작동하지 않을 것 같습니다.

Request changes를 선택하겠습니다."
```

**전체 리뷰 제출:**
```
Review changes:
⚪ Comment
⚪ Approve  
🔘 Request changes

Comment:
전반적으로 좋은 구현입니다! 다만 몇 가지 수정 필요:

1. ID 불일치 수정 필요
2. autocomplete 속성 추가 고려
3. 접근성(a11y): 버튼에 aria-label 추가 제안

수정 후 다시 리뷰 요청 부탁드립니다! 💪

[Submit review]
```

---

#### Step 7: 피드백 반영 (assistant 역할)

**[터미널로 복귀]**

bash

```bash
# 같은 브랜치에서 계속 작업
git checkout feature/password-toggle

# 피드백 반영
# 1. ID 불일치 수정
sed -i 's/toggle-btn/toggle-password/g' src/app.js

# 2. autocomplete 추가
sed -i 's/<input type="password"/<input type="password" autocomplete="off"/g' src/login.html

# 3. 접근성 개선
sed -i 's/<button type="button"/<button type="button" aria-label="비밀번호 표시\/숨김"/g' src/login.html

# 변경사항 확인
git diff

# 커밋
git add src/
git commit -m "fix: Address code review feedback

- Fix ID mismatch (toggle-btn → toggle-password)
- Add autocomplete=off for security
- Add aria-label for accessibility

Co-authored-by: instructor <instructor@example.com>"

# 같은 브랜치에 푸시
git push origin feature/password-toggle
```

**GitHub PR 페이지 자동 업데이트:**
```
New commits pushed:
✓ abc1234 feat: Add password visibility toggle button
✓ def5678 fix: Address code review feedback

instructor: "수정 확인했습니다! 완벽합니다 👍"
```

---

#### Step 8: Approve & Merge (instructor 역할)

**[GitHub PR 화면]**

**최종 승인:**
```
Review changes:
⚪ Comment
🔘 Approve  
⚪ Request changes

Comment:
LGTM! (Looks Good To Me)
모든 피드백이 잘 반영되었습니다. 
훌륭한 첫 기여입니다! 🎉

[Submit review]
```

**Merge 옵션 선택:**
```
Merge pull request #45

3가지 옵션:
1. ✓ Merge commit
   - 모든 커밋 히스토리 유지
   - Merge 커밋 생성
   
2. Squash and merge
   - 모든 커밋을 하나로 합침
   - 깔끔한 히스토리
   
3. Rebase and merge
   - 선형 히스토리 유지
   - Merge 커밋 없음

[회사 정책에 따라 선택, 여기서는 Squash 사용]

Title: feat: Add password visibility toggle button (#45)
Description:
- Add toggle button to password input field
- Implement click handler
- Add CSS styling
- Address code review feedback

[Confirm squash and merge]
```

**Merge 후 정리:**
```
Pull request successfully merged and closed

[Delete branch] ← 클릭 (브랜치 삭제)
```

---

#### Step 9: 로컬 동기화 (assistant)

**[터미널]**

bash

```bash
# main으로 전환
git checkout main

# upstream에서 최신 변경사항 가져오기
git pull upstream main
# From https://github.com/instructor/company-project
#  * branch            main       -> FETCH_HEAD
# Updating ghi9012..jkl3456
# Fast-forward
#  src/login.html | 5 ++++-
#  src/app.js     | 8 ++++++++
#  src/style.css  | 9 +++++++++
#  3 files changed, 21 insertions(+), 1 deletion(-)

# origin(내 Fork)도 업데이트
git push origin main

# 로컬 feature 브랜치 삭제
git branch -d feature/password-toggle
# Deleted branch feature/password-toggle (was def5678).

# 원격 브랜치도 삭제 (GitHub에서 안 했다면)
git push origin --delete feature/password-toggle

# 최종 상태 확인
git log --oneline -3
# jkl3456 (HEAD -> main, upstream/main, origin/main) feat: Add password visibility toggle button (#45)
# ghi9012 docs: Update README
# mno7890 fix: Login validation bug
```

---

### Part 3: 학생 실습 (20분)

#### 실습 구성

- 2인 1조 (A 학생, B 학생)
- A가 저장소 owner, B가 contributor

#### 실습 저장소 준비 (강사)

bash

```bash
# 실습용 템플릿 저장소
# https://github.com/git-workshop/pr-practice-template

구조:
pr-practice/
├── index.html
├── style.css
├── script.js
├── README.md
└── CONTRIBUTING.md
```

#### 실습 시나리오

**A 학생 (Repository Owner):**

1. `pr-practice-template` Fork
2. 본인 계정의 Fork를 Clone
3. README에 "Team Members" 섹션 추가 후 Push

**B 학생 (Contributor):**

1. A 학생의 저장소 Fork
2. Clone 및 Upstream 설정
3. Feature 브랜치 생성: `feature/add-profile`
4. 작업: `profiles/본인이름.md` 파일 생성

markdown

```markdown
   # 홍길동
   
   ## 소개
   안녕하세요! Git을 배우는 홍길동입니다.
   
   ## 관심사
   - JavaScript
   - React
   - Node.js
   
   ## 연락처
   - GitHub: @gildong-hong
   - Email: gildong@example.com
```

5. Commit & Push to origin
6. Pull Request 생성
7. A 학생의 코드 리뷰 대기

**A 학생 (Reviewer):**

1. B의 PR 확인
2. 코드 리뷰 (최소 1개 코멘트)
3. Request changes 또는 Approve
4. Merge
5. 로컬 동기화

**역할 교대:**

- 이번엔 B가 Owner, A가 Contributor
- 동일 프로세스 반복

#### 체크리스트 (학생용)

**Contributor:**

- [ ]  Fork 생성 완료
- [ ]  Clone 완료
- [ ]  Upstream 설정 (`git remote -v`로 확인)
- [ ]  Feature 브랜치 생성
- [ ]  파일 작성 및 커밋
- [ ]  origin에 Push
- [ ]  PR 생성 (설명 포함)
- [ ]  리뷰 피드백 확인
- [ ]  피드백 반영 후 재푸시

**Reviewer:**

- [ ]  PR 알림 확인
- [ ]  Files changed 탭에서 코드 검토
- [ ]  최소 1개 코멘트 작성
- [ ]  Approve 또는 Request changes
- [ ]  Merge 완료
- [ ]  브랜치 삭제
- [ ]  로컬 main 업데이트

---

### Part 4: Q&A 및 트러블슈팅 (5분)

#### 자주 발생하는 문제

**Q1: "origin과 upstream 헷갈려요"**

bash

```bash
# 외우는 방법:
origin = 내가 push할 곳 (내 Fork)
upstream = 원본 (Pull만 가능)

# 확인:
git remote -v
```

**Q2: "PR을 잘못 보냈어요"**
```
방법 1: PR 화면에서 Close pull request
방법 2: 브랜치를 삭제하면 PR도 자동 닫힘
방법 3: 같은 브랜치에 수정 커밋 푸시 (PR 업데이트)
```

**Q3: "upstream/main이 업데이트됐는데 제 PR이 conflict 나요"**

bash

```bash
# Feature 브랜치에서:
git fetch upstream
git merge upstream/main
# 충돌 해결
git push origin feature/my-feature
# PR 자동 업데이트
```

**Q4: "Squash merge 후 로컬 브랜치 삭제가 안 돼요"**

bash

```bash
# Squash는 커밋 해시가 바뀌므로 -d 옵션 실패
git branch -d feature/my-feature
# error: The branch 'feature/my-feature' is not fully merged.

# 강제 삭제
git branch -D feature/my-feature
```

---

## 7.2 Conflict 해결 (60분)

### Part 1: Conflict의 원리 (15분)

#### Conflict가 발생하는 이유

**다이어그램 (프로젝터):**
```
시점 1: 두 개발자가 같은 시작점
main: A → B → C

개발자 1:                개발자 2:
C → D (login.html 수정)  C → E (login.html 수정)

시점 2: Merge 시도
main: A → B → C → D
                   ↓ merge E?
                   
같은 파일, 같은 라인 수정!
→ Git이 자동 병합 불가
→ Conflict 발생!
```

#### Conflict가 발생하지 않는 경우
```
Case 1: 다른 파일 수정
개발자 1: login.html 수정
개발자 2: style.css 수정
→ Auto-merge 성공

Case 2: 같은 파일, 다른 라인
개발자 1: login.html 10번 줄 수정
개발자 2: login.html 50번 줄 수정  
→ Auto-merge 성공

Case 3: 같은 파일, 같은 라인
개발자 1: login.html 10번 줄 수정
개발자 2: login.html 10번 줄 수정
→ CONFLICT! 수동 해결 필요
```

#### Conflict Marker 구조

html

```html
<<<<<<< HEAD (현재 브랜치)
<h1>Welcome to Our Site</h1>
=======
<h1>Welcome to My Website</h1>
>>>>>>> feature/update-title (병합하려는 브랜치)
```

**설명:**

- `<<<<<<< HEAD`: 현재 브랜치의 내용 시작
- `=======`: 구분선
- `>>>>>>> branch`: 병합하려는 브랜치의 내용 끝
- 이 마커들을 포함한 섹션을 수동으로 편집해야 함

---

### Part 2: 강사 시연 - Conflict 발생 및 해결 (25분)

#### 시연 준비

**[instructor 계정 - Terminal 1]**

bash

```bash
# 새 저장소 생성
mkdir conflict-demo
cd conflict-demo
git init
echo "# Conflict Demo" > README.md
git add README.md
git commit -m "Initial commit"

# 초기 파일 생성
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
</head>
<body>
    <h1>Welcome</h1>
    <p>This is the homepage.</p>
</body>
</html>
EOF

git add index.html
git commit -m "Add initial homepage"
git push origin main
```

#### 시나리오: 두 개발자가 동시에 작업

**[Terminal 1 - 개발자 A: 타이틀 변경]**

bash

```bash
# Feature 브랜치 생성
git checkout -b feature/update-welcome

# index.html 수정 (라인 7)
sed -i 's/<h1>Welcome<\/h1>/<h1>Welcome to TechCorp<\/h1>/' index.html

cat index.html
# ...
#     <h1>Welcome to TechCorp</h1>
# ...

git commit -am "feat: Update welcome message to include company name"
git push origin feature/update-welcome
```

**[Terminal 2 - 개발자 B: 동시에 타이틀 변경]**

bash

```bash
# 같은 저장소 Clone
cd ~/workspace
git clone <repository-url> conflict-demo-b
cd conflict-demo-b

# Feature 브랜치 생성 (다른 이름)
git checkout -b feature/improve-heading

# 같은 파일, 같은 라인 수정!
sed -i 's/<h1>Welcome<\/h1>/<h1>Welcome to Our Platform<\/h1>/' index.html

cat index.html
# ...
#     <h1>Welcome to Our Platform</h1>
# ...

git commit -am "feat: Improve welcome heading"
git push origin feature/improve-heading
```

#### Merge 시도 및 Conflict 발생

**[GitHub에서 A의 PR 먼저 Merge]**
```
PR #1: feature/update-welcome
✓ Merged successfully
```

**[B가 Pull Request 생성]**
```
PR #2: feature/improve-heading
⚠️ This branch has conflicts that must be resolved
```

**[Terminal 2 - B가 로컬에서 해결 시도]**

bash

```bash
# main 업데이트
git checkout main
git pull origin main
# Fast-forward to include A's changes

# Feature 브랜치로 돌아가기
git checkout feature/improve-heading

# main을 merge 시도
git merge main
# Auto-merging index.html
# CONFLICT (content): Merge conflict in index.html
# Automatic merge failed; fix conflicts and then commit the result.

# 상태 확인
git status
# On branch feature/improve-heading
# You have unmerged paths.
#   (fix conflicts and run "git commit")
#   (use "git merge --abort" to abort the merge)
# 
# Unmerged paths:
#   (use "git add <file>..." to mark resolution)
#         both modified:   index.html
```

#### Conflict 내용 확인

bash

```bash
cat index.html
```

**출력:**

html

```html
<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
</head>
<body>
<<<<<<< HEAD
    <h1>Welcome to Our Platform</h1>
=======
    <h1>Welcome to TechCorp</h1>
>>>>>>> main
    <p>This is the homepage.</p>
</body>
</html>
```

**코드 설명:**
```
<<<<<<< HEAD
현재 브랜치(feature/improve-heading)의 변경사항
=======
병합하려는 브랜치(main, A의 변경사항)
>>>>>>> main
```

#### Conflict 해결 과정

**방법 1: 한쪽 선택**

bash

```bash
# A의 변경사항 채택
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
</head>
<body>
    <h1>Welcome to TechCorp</h1>
    <p>This is the homepage.</p>
</body>
</html>
EOF
```

**방법 2: 양쪽 병합**

bash

```bash
# 두 변경사항 모두 반영
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
</head>
<body>
    <h1>Welcome to TechCorp Platform</h1>
    <p>This is the homepage.</p>
</body>
</html>
EOF
```

**방법 3: 완전히 새로운 내용**

bash

```bash
# 팀 논의 후 새로운 문구
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
</head>
<body>
    <h1>Welcome to TechCorp - Your Innovation Platform</h1>
    <p>This is the homepage.</p>
</body>
</html>
EOF
```

#### Conflict 해결 완료

bash

```bash
# 해결된 파일 확인
cat index.html
# (conflict marker가 모두 제거되었는지 확인)

# Staging
git add index.html

# 상태 재확인
git status
# On branch feature/improve-heading
# All conflicts fixed but you are still merging.
#   (use "git commit" to conclude merge)
# 
# Changes to be committed:
#         modified:   index.html

# Merge 커밋 (자동 메시지 생성됨)
git commit
# Merge branch 'main' into feature/improve-heading
# 
# Conflicts:
#   index.html

# 또는 수동 메시지
git commit -m "Merge main into feature/improve-heading

Resolved conflict in index.html:
- Combined company name with platform description
- Final heading: 'Welcome to TechCorp Platform'"

# Push
git push origin feature/improve-heading
```

**[GitHub PR 업데이트]**
```
PR #2: feature/improve-heading
✓ All conflicts resolved
✓ Ready to merge
```

---

### Part 3: 학생 실습 - 의도적 Conflict (20분)

#### 실습 시나리오

**2인 1조 역할:**

- A 학생: 먼저 Merge되는 개발자
- B 학생: Conflict 해결하는 개발자

**실습 파일 준비 (강사가 미리 생성):**

html

```html
<!-- team-page.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Our Team</title>
</head>
<body>
    <h1>Meet Our Team</h1>
    <div class="team-member">
        <h2>Team Lead: [이름]</h2>
        <p>Role: [역할]</p>
        <p>Skills: [기술스택]</p>
    </div>
</body>
</html>
```

#### A 학생 작업

bash

```bash
# 1. Clone 및 브랜치 생성
git clone <repo-url>
cd team-page
git checkout -b feature/add-teamlead-a

# 2. 파일 수정
# team-page.html 편집:
<div class="team-member">
    <h2>Team Lead: 김철수</h2>
    <p>Role: Frontend Developer</p>
    <p>Skills: React, TypeScript, CSS</p>
</div>

# 3. Commit & Push
git commit -am "Add team lead info - 김철수"
git push origin feature/add-teamlead-a

# 4. PR 생성 및 즉시 Merge (강사 승인)
```

#### B 학생 작업 (동시 진행)

bash

```bash
# 1. Clone 및 브랜치 생성
git clone <repo-url>
cd team-page
git checkout -b feature/add-teamlead-b

# 2. 같은 위치 수정!
# team-page.html 편집:
<div class="team-member">
    <h2>Team Lead: 이영희</h2>
    <p>Role: Backend Developer</p>
    <p>Skills: Node.js, Python, MongoDB</p>
</div>

# 3. Commit & Push
git commit -am "Add team lead info - 이영희"
git push origin feature/add-teamlead-b

# 4. PR 생성
# → ⚠️ Conflict 발생 메시지 확인
```

#### B 학생 - Conflict 해결

bash

```bash
# 1. main 업데이트
git checkout main
git pull origin main

# 2. Feature 브랜치로 복귀
git checkout feature/add-teamlead-b

# 3. main Merge 시도
git merge main
# CONFLICT (content): Merge conflict in team-page.html
# Automatic merge failed; fix conflicts and then commit the result.

# 4. Conflict 확인
cat team-page.html
```

**출력:**

html

```html
<div class="team-member">
<<<<<<< HEAD
    <h2>Team Lead: 이영희</h2>
    <p>Role: Backend Developer</p>
    <p>Skills: Node.js, Python, MongoDB</p>
=======
    <h2>Team Lead: 김철수</h2>
    <p>Role: Frontend Developer</p>
    <p>Skills: React, TypeScript, CSS</p>
>>>>>>> main
</div>
```

**해결 방법 (두 명 모두 추가):**

html

```html
<div class="team-member">
    <h2>Team Lead: 김철수</h2>
    <p>Role: Frontend Developer</p>
    <p>Skills: React, TypeScript, CSS</p>
</div>
<div class="team-member">
    <h2>Team Lead: 이영희</h2>
    <p>Role: Backend Developer</p>
    <p>Skills: Node.js, Python, MongoDB</p>
</div>
```

**완료:**

bash

```bash
# 5. 해결 완료
git add team-page.html
git commit -m "Merge main: Add both team leads"
git push origin feature/add-teamlead-b

# 6. PR 확인 → Merge
```

---

### Part 4: 고급 Conflict 시나리오 (보너스)

#### 시나리오 1: 파일 삭제 vs 수정

**A 개발자:**

bash

```bash
git rm old-file.js
git commit -m "Remove deprecated file"
```

**B 개발자:**

bash

```bash
# old-file.js 수정
echo "Updated code" >> old-file.js
git commit -am "Update old file"
```

**Merge 시:**
```
CONFLICT (modify/delete): old-file.js deleted in main and modified in feature.
Version feature of old-file.js left in tree.

해결 방법:
1. 파일 삭제 유지: git rm old-file.js
2. 파일 수정 유지: git add old-file.js
```

#### 시나리오 2: 파일 이름 변경 Conflict

**A 개발자:**

bash

```bash
git mv config.js settings.js
git commit -m "Rename config to settings"
```

**B 개발자:**

bash

```bash
# config.js 내용 수정
echo "new config" >> config.js
git commit -am "Update config"
```

**Git의 자동 감지:**

bash

```bash
# Git이 rename을 감지하고 자동 처리
# settings.js에 B의 변경사항이 적용됨
# 대부분의 경우 자동 해결!
```

---

## 7.3 Feature Branch Workflow (60분)

### Part 1: Branch 보호 설정 (10분)

#### GitHub Repository Settings

**[GitHub Repository 설정 화면 공유]**

**경로:**
```
Repository → Settings → Branches → Add branch protection rule
```

**설정 항목:**
```
Branch name pattern: main

보호 규칙:
☑ Require a pull request before merging
  ☑ Require approvals: 1
  ☑ Dismiss stale pull request approvals when new commits are pushed
  ☑ Require review from Code Owners

☑ Require status checks to pass before merging
  ☑ Require branches to be up to date before merging

☑ Require conversation resolution before merging

☑ Include administrators (선택사항)

☑ Restrict who can push to matching branches
  (팀원만 선택)

[Create] / [Save changes]
```

**효과 확인:**

bash

```bash
# 터미널에서 직접 Push 시도
git checkout main
echo "Direct push test" >> README.md
git commit -am "Test direct push"
git push origin main

# 에러 발생:
# remote: error: GH006: Protected branch update failed for refs/heads/main.
# remote: error: Required status check "ci/test" is expected.
# remote: error: At least 1 approving review is required.
```

---

### Part 2: 4인 1조 시뮬레이션 시나리오 (40분)

#### 팀 구성
- Developer A: 로그인 기능
- Developer B: 회원가입 기능
- Developer C: 프로필 기능
- Developer D: 설정 기능

#### 프로젝트 구조
```
user-management/
├── src/
│   ├── auth/
│   │   ├── login.js
│   │   └── register.js
│   ├── user/
│   │   ├── profile.js
│   │   └── settings.js
│   └── utils/
│       └── validators.js
├── README.md
└── package.json
```

---

#### Phase 1: 브랜치 생성 및 작업 (15분)

**Developer A:**

bash

```bash
git clone <repo-url>
cd user-management
git checkout -b feature/login

# login.js 생성
mkdir -p src/auth
cat > src/auth/login.js << 'EOF'
export function login(username, password) {
  if (!username || !password) {
    throw new Error('Username and password required');
  }
  
  // TODO: API 호출
  console.log(`Logging in ${username}...`);
  return { success: true, user: username };
}
EOF

git add src/auth/login.js
git commit -m "feat(auth): Implement login function

- Add basic login validation
- Return user object on success
- Throw error for missing credentials"

git push origin feature/login
```

**Developer B:**

bash

```bash
git clone <repo-url>
cd user-management
git checkout -b feature/register

# register.js 생성
cat > src/auth/register.js << 'EOF'
export function register(username, email, password) {
  if (!username || !email || !password) {
    throw new Error('All fields are required');
  }
  
  if (password.length < 8) {
    throw new Error('Password must be at least 8 characters');
  }
  
  // TODO: API 호출
  console.log(`Registering ${username}...`);
  return { success: true, user: { username, email } };
}
EOF

git add src/auth/register.js
git commit -m "feat(auth): Implement registration function

- Add field validation
- Add password length check
- Return user object on success"

git push origin feature/register
```

**Developer C:**

bash

```bash
git clone <repo-url>
cd user-management
git checkout -b feature/profile

# profile.js 생성
mkdir -p src/user
cat > src/user/profile.js << 'EOF'
export function getProfile(userId) {
  if (!userId) {
    throw new Error('User ID required');
  }
  
  // TODO: 데이터베이스 조회
  return {
    id: userId,
    username: 'testuser',
    email: 'test@example.com',
    createdAt: new Date()
  };
}

export function updateProfile(userId, data) {
  if (!userId) {
    throw new Error('User ID required');
  }
  
  console.log(`Updating profile for ${userId}...`);
  return { success: true, updated: data };
}
EOF

git add src/user/profile.js
git commit -m "feat(user): Add profile management functions

- Implement getProfile
- Implement updateProfile
- Add basic validation"

git push origin feature/profile
```

**Developer D:**

bash

```bash
git clone <repo-url>
cd user-management
git checkout -b feature/settings

# settings.js 생성
cat > src/user/settings.js << 'EOF'
export function getSettings(userId) {
  // TODO: 설정 조회
  return {
    theme: 'light',
    language: 'ko',
    notifications: true
  };
}

export function updateSettings(userId, settings) {
  if (!userId) {
    throw new Error('User ID required');
  }
  
  console.log(`Updating settings for ${userId}...`);
  return { success: true, settings };
}
EOF

git add src/user/settings.js
git commit -m "feat(user): Add settings management

- Implement getSettings
- Implement updateSettings
- Return default settings"

git push origin feature/settings
```

---

#### Phase 2: Pull Request 생성 (5분)

**모든 개발자:**

1. GitHub에서 각자 PR 생성
2. PR 템플릿 작성:

markdown

```markdown
## Feature: [기능명]

### Changes
- [변경 내용 요약]

### Testing
- [ ] 로컬 테스트 완료
- [ ] 엣지 케이스 확인

### Dependencies
- Depends on: #[다른 PR 번호] (있다면)

### Reviewers
@devA @devB @devC @devD
```

**결과:**
```
Open Pull Requests:
- PR #10: feature/login (Developer A)
- PR #11: feature/register (Developer B)
- PR #12: feature/profile (Developer C)
- PR #13: feature/settings (Developer D)
```

---

#### Phase 3: 상호 코드 리뷰 (15분)

**리뷰 전략 (강사 지시):**
```
A → B의 PR 리뷰
B → C의 PR 리뷰
C → D의 PR 리뷰
D → A의 PR 리뷰
```

**Developer A가 B의 PR 리뷰:**

**[GitHub PR #11 화면]**

**긍정적 피드백:**
```
src/auth/register.js (Line 7-9)
💬 "비밀번호 길이 체크 좋습니다! 👍
추가 제안: 특수문자 포함 여부도 체크하면 보안이 더 강화될 것 같습니다."
```

**개선 제안:**
```
src/auth/register.js (Line 4-6)
💬 "제안: 이메일 형식 검증도 추가하면 좋을 것 같습니다.

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
if (!emailRegex.test(email)) {
  throw new Error('Invalid email format');
}

어떻게 생각하시나요?"
```

**버그 발견:**
```
src/auth/register.js (Line 14)
❌ "오타: 'user' → 'users' (일관성)
다른 함수에서는 복수형을 사용하는데 여기만 단수형이네요."
```

**Developer B가 C의 PR 리뷰:**
```
src/user/profile.js (Line 15)
💬 "좋은 구현입니다!

질문: updateProfile에서 어떤 필드들만 업데이트 가능한지
화이트리스트가 있으면 좋을 것 같은데, 어떻게 생각하시나요?

예:
const allowedFields = ['username', 'email', 'bio'];
const sanitizedData = Object.keys(data)
  .filter(key => allowedFields.includes(key))
  .reduce((obj, key) => ({ ...obj, [key]: data[key] }), {});
"
```

**Developer C가 D의 PR 리뷰:**
```
src/user/settings.js (Line 3-7)
💬 "기본 설정값이 좋습니다!

제안: 상수로 분리하면 재사용하기 좋을 것 같습니다.

const DEFAULT_SETTINGS = {
  theme: 'light',
  language: 'ko',
  notifications: true
};

export function getSettings(userId) {
  return { ...DEFAULT_SETTINGS };
}
"
```

**Developer D가 A의 PR 리뷰:**
```
src/auth/login.js (Line 8)
💬 "console.log는 프로덕션에서 제거되어야 합니다.

제안: 로깅 라이브러리 사용 또는 환경변수로 제어
if (process.env.NODE_ENV === 'development') {
  console.log(...);
}
"

Approve ✓
```

---

#### Phase 4: 순차 Merge 및 Conflict 경험 (5분)

**Merge 순서 (강사 결정):**
```
1순위: PR #10 (login) - Developer A
2순위: PR #11 (register) - Developer B
3순위: PR #12 (profile) - Developer C
4순위: PR #13 (settings) - Developer D
```

**Merge #1: login (충돌 없음)**

bash

```bash
# GitHub에서 Merge
✓ PR #10 merged successfully
Branch feature/login deleted

# Developer A 로컬 정리
git checkout main
git pull origin main
git branch -d feature/login
```

**Merge #2: register (충돌 발생!)**

**문제:** A와 B가 모두 `src/utils/validators.js`를 추가했다고 가정

**Developer B:**

bash

```bash
# main 업데이트
git checkout main
git pull origin main

# Feature 브랜치로 복귀
git checkout feature/register
git merge main

# CONFLICT in src/utils/validators.js
```

**해결:**

bash

```bash
# 두 검증 함수 병합
cat > src/utils/validators.js << 'EOF'
// From login feature
export function validateUsername(username) {
  return username && username.length >= 3;
}

// From register feature
export function validateEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

export function validatePassword(password) {
  return password && password.length >= 8;
}
EOF

git add src/utils/validators.js
git commit -m "Merge main: Combine validators from both features"
git push origin feature/register

# GitHub PR 업데이트 → Merge
```

**Merge #3 & #4: 나머지 (순조롭게 진행)**

---

### Part 3: 워크플로우 정리 및 베스트 프랙티스 (10분)

#### 완성된 워크플로우 다이어그램
```
[main 브랜치 보호 설정]
         ↓
[개발자들이 각자 feature 브랜치 생성]
         ↓
[독립적으로 작업 및 커밋]
         ↓
[origin에 Push]
         ↓
[Pull Request 생성]
         ↓
[팀원들 코드 리뷰]
    ↓         ↓
[Request   [Approve]
 Changes]      ↓
    ↓      [Merge to main]
[수정 반영]     ↓
    ↓      [브랜치 삭제]
    └─────────┘
         ↓
[다음 기능 개발...]
```

#### 실무 베스트 프랙티스

**1. 브랜치 네이밍 컨벤션**

bash

```bash
feature/기능명        # 새 기능
fix/버그명           # 버그 수정
hotfix/긴급버그      # 프로덕션 긴급 수정
refactor/리팩토링명  # 리팩토링
docs/문서명          # 문서 작업
test/테스트명        # 테스트 추가

# 예시:
feature/user-authentication
fix/login-validation-bug
hotfix/security-patch
refactor/auth-module
docs/api-documentation
test/auth-integration-tests
```

**2. 커밋 메시지 컨벤션**
```
<type>(<scope>): <subject>

<body>

<footer>

타입:
- feat: 새 기능
- fix: 버그 수정
- docs: 문서 변경
- style: 코드 포맷팅
- refactor: 리팩토링
- test: 테스트 추가
- chore: 빌드/설정 변경

예시:
feat(auth): Add JWT token validation

- Implement token verification middleware
- Add token expiration check
- Add refresh token logic

Closes #123
```

**3. PR 크기 관리**
```
✅ Good PR:
- 200-400 줄 변경
- 단일 기능/버그 수정
- 30분 내 리뷰 가능

❌ Bad PR:
- 1000+ 줄 변경
- 여러 기능 혼재
- 리뷰에 몇 시간 소요

전략: 큰 기능은 여러 작은 PR로 분할
```

**4. 코드 리뷰 원칙**
```
긍정적 피드백:
- 좋은 코드는 칭찬하기
- "이 부분 좋습니다!" 👍

건설적 제안:
- "제안:", "어떻게 생각하시나요?"
- 명령이 아닌 질문 형태

명확한 이슈:
- 버그/보안: 명확히 지적
- 예시 코드 제공

응답 시간:
- 24시간 내 최소 1차 리뷰
- Blocking 이슈는 즉시 응답
```

**5. Merge 전 체크리스트**

markdown

```markdown
- [ ] 모든 리뷰 코멘트 해결
- [ ] CI/CD 테스트 통과
- [ ] 최소 1명 Approve
- [ ] Conflict 해결
- [ ] main과 동기화 (최신 상태)
- [ ] 브랜치명/커밋 메시지 규칙 준수
```

---

### 마무리: 전체 흐름 복습

**개발자 관점:**

bash

```bash
# 1. 이슈 할당받음
# 2. 최신 main Pull
git checkout main
git pull origin main

# 3. Feature 브랜치 생성
git checkout -b feature/my-feature

# 4. 작업 및 커밋 (자주)
git add .
git commit -m "feat: ..."

# 5. Push
git push origin feature/my-feature

# 6. PR 생성
# (GitHub UI)

# 7. 리뷰 피드백 반영
git commit -m "fix: Address review comments"
git push origin feature/my-feature

# 8. Approve 받으면 Merge
# (GitHub UI 또는 관리자)

# 9. 로컬 정리
git checkout main
git pull origin main
git branch -d feature/my-feature
```

**팀 리드 관점:**
```
- Branch 보호 설정 유지
- PR 리뷰 프로세스 감독
- Merge 전 최종 확인
- Conflict 해결 가이드
- 팀 컨벤션 문서화
```

---

## 종합 Q&A

**Q1: "여러 명이 동시에 같은 파일 작업하면 어떻게 하나요?"**
```
A: 커뮤니케이션이 핵심입니다.

1. 파일/모듈 단위로 담당자 분리
2. 겹치는 부분은 먼저 하는 사람이 PR
3. 나중 사람은 Merge 후 Rebase
4. 팀 스탠드업에서 작업 범위 공유
```

**Q2: "main이 계속 업데이트되는데 제 브랜치는 언제 동기화하나요?"**

bash

```bash
# 전략 1: 작업 시작 시
git pull origin main

# 전략 2: PR 생성 직전
git checkout main
git pull origin main
git checkout feature/my-feature
git merge main

# 전략 3: 매일 아침
# 장기 브랜치라면 매일 main Merge

# 권장: PR 직전 + 중요 업데이트 시
```

**Q3: "리뷰어가 응답을 안 하면 어떻게 하나요?"**
```
실무 대응:

1일차: PR 생성, Slack 알림
2일차: 가벼운 리마인더
3일차: 매니저에게 에스컬레이션

회사 정책: SLA 설정
- P0 (긴급): 2시간 내
- P1 (높음): 당일
- P2 (보통): 48시간
```

**Q4: "Squash merge vs Merge commit 언제 쓰나요?"**
```
Squash merge:
- 커밋이 지저분할 때
- Feature 브랜치를 하나로
- 깔끔한 main 히스토리 원할 때

Merge commit:
- 모든 커밋 히스토리 보존
- 누가 언제 뭘 했는지 추적
- 법적/감사 요구사항

Rebase merge:
- 선형 히스토리
- Merge 커밋 싫을 때
- Conflict 해결 능력 필요

회사마다 정책 다름!
```
