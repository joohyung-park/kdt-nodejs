# Git 버전관리 실습 - 1부: Git의 핵심 - Commit 이해하기 (3시간)

## 🎯 학습 목표

- Git 저장소를 초기화하고 첫 커밋을 만들 수 있다
- Stage 영역의 역할을 이해하고 의미 단위로 커밋을 나눌 수 있다
- Amend를 사용하여 커밋을 수정할 수 있다
- Git의 내부 구조를 이해하고 커밋이 스냅샷임을 설명할 수 있다

---

## 1.1: Git 저장소와 첫 커밋 (40분)

### 핵심 개념

> **Stage는 준비, Commit은 사진 찍기**
> 
> Git은 3단계 프로세스로 작동합니다:
> 
> 1. **작업 디렉토리 (Working Directory)**: 파일을 편집하는 공간
> 2. **스테이지 영역 (Staging Area)**: 커밋할 파일을 준비하는 공간
> 3. **저장소 (Repository)**: 커밋이 영구 저장되는 공간

### 실습 1-1: 프로젝트 시작하기

bash

````bash
# 1. 새 프로젝트 폴더 생성
mkdir my-first-git
cd my-first-git

# 2. Git 저장소 초기화
git init
```

**출력 결과:**
```
Initialized empty Git repository in /Users/yourname/my-first-git/.git/
````

**해설:** `.git` 폴더가 생성되며, 이 폴더가 Git의 모든 이력을 저장합니다.

bash

```bash
# 3. 숨김 파일 포함하여 확인
ls -la
```

### 실습 1-2: 첫 번째 파일 생성과 상태 확인

bash

````bash
# 1. README 파일 생성
echo "# My First Git Project" > README.md

# 2. Git 상태 확인
git status
```

**출력 결과:**
```
On branch main

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	README.md

nothing added to commit but untracked files present (use "git add" to track)
````

**해설:** `Untracked files` = Git이 아직 추적하지 않는 새 파일

### 실습 1-3: Stage에 파일 올리기

bash

````bash
# 1. 파일을 Stage에 추가
git add README.md

# 2. 상태 변화 관찰
git status
```

**출력 결과:**
```
On branch main

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   README.md
````

**해설:**

- `Changes to be committed` = 커밋 준비 완료
- 아직 사진을 찍지 않았지만, 카메라 앞에 세워둔 상태

### 실습 1-4: 첫 커밋 만들기

bash

````bash
# 1. 커밋 생성 (스냅샷 찍기)
git commit -m "docs: README 파일 추가"

# 2. 결과 확인
git status
```

**출력 결과:**
```
[main (root-commit) a1b2c3d] docs: README 파일 추가
 1 file changed, 1 insertion(+)
 create mode 100644 README.md
```
```
On branch main
nothing to commit, working tree clean
````

**해설:**

- `root-commit` = 프로젝트의 첫 커밋
- `a1b2c3d` = 커밋 해시의 앞 7자리 (고유 ID)
- `working tree clean` = 모든 변경사항이 커밋됨

### 실습 1-5: 여러 파일 추가하며 프로세스 반복

bash

````bash
# 1. index.html 생성
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My First Git Project</title>
</head>
<body>
    <h1>Hello Git!</h1>
</body>
</html>
EOF

# 2. 상태 확인
git status
```

**출력:**
```
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	index.html

nothing added to commit but untracked files present (use "git add" to track)
````

bash

````bash
# 3. Stage → Commit 과정
git add index.html
git status
git commit -m "feat: 기본 HTML 페이지 추가"

# 4. 로그 확인
git log
```

**출력:**
```
commit b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2
Author: Your Name <your.email@example.com>
Date:   Mon Nov 10 10:00:00 2025 +0900

    feat: 기본 HTML 페이지 추가

commit a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0
Author: Your Name <your.email@example.com>
Date:   Mon Nov 10 09:55:00 2025 +0900

    docs: README 파일 추가
```

### 💡 핵심 정리
```
[작업 디렉토리]  →  [Stage 영역]  →  [저장소]
    파일 수정      git add         git commit
                  (준비하기)       (사진 찍기)
````

---

## 1.2: Stage 영역의 의미 (40분)

### 핵심 개념

> **"의미 단위로 커밋 나누기"**
> 
> 좋은 커밋은 하나의 논리적 변경사항만 포함합니다. Stage 영역을 사용하면 여러 파일을 수정하더라도 관련된 변경사항만 선택하여 커밋할 수 있습니다.

### 실습 2-1: 여러 파일 동시 수정

bash

````bash
# 1. CSS 파일 생성
cat > style.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
    background-color: #f0f0f0;
}

h1 {
    color: #333;
}
EOF

# 2. JavaScript 파일 생성
cat > script.js << 'EOF'
console.log('Git is awesome!');

function greet() {
    alert('Hello from Git!');
}
EOF

# 3. index.html 수정 (CSS, JS 연결)
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My First Git Project</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Hello Git!</h1>
    <button onclick="greet()">Click Me</button>
    <script src="script.js"></script>
</body>
</html>
EOF

# 4. 상태 확인
git status
```

**출력:**
```
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   index.html

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	script.js
	style.css

no changes added to commit (use "git add" and/or "git commit -a")
````

### 실습 2-2: 선택적 Stage - 스타일링만 먼저 커밋

bash

````bash
# 1. 스타일 관련 파일만 Stage에 추가
git add style.css
git add index.html

# 2. Stage 상태 확인
git status
```

**출력:**
```
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   index.html
	new file:   style.css

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	script.js
````

**해설:** `script.js`는 아직 Stage에 없음 → 이번 커밋에 포함되지 않음

bash

````bash
# 3. 스타일링 커밋
git commit -m "style: CSS 스타일 추가 및 HTML에 연결"

# 4. 상태 확인
git status
```

**출력:**
```
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	script.js

nothing added to commit but untracked files present (use "git add" to track)
````

### 실습 2-3: 나머지 기능 커밋

bash

````bash
# 1. JavaScript 파일 커밋
git add script.js
git commit -m "feat: 인사 버튼 기능 추가"

# 2. 로그 확인
git log --oneline
```

**출력:**
```
c5d6e7f feat: 인사 버튼 기능 추가
b3c4d5e style: CSS 스타일 추가 및 HTML에 연결
a1b2c3d feat: 기본 HTML 페이지 추가
9a8b7c6 docs: README 파일 추가
````

### 실습 2-4: git diff로 변경사항 비교

bash

```bash
# 1. README에 설명 추가
cat >> README.md << 'EOF'

## 프로젝트 설명
간단한 웹 페이지로 Git을 학습합니다.

## 파일 구조
- index.html: 메인 페이지
- style.css: 스타일시트
- script.js: 인터랙션
EOF

# 2. style.css도 수정
echo "" >> style.css
echo "button { padding: 10px 20px; }" >> style.css

# 3. 작업 디렉토리의 변경사항 확인
git diff
```

**출력:**

diff

```diff
diff --git a/README.md b/README.md
index 8b13789..9876543 100644
--- a/README.md
+++ b/README.md
@@ -1 +1,9 @@
 # My First Git Project
+
+## 프로젝트 설명
+간단한 웹 페이지로 Git을 학습합니다.
+
+## 파일 구조
+- index.html: 메인 페이지
+- style.css: 스타일시트
+- script.js: 인터랙션
```

**해설:** `+`로 시작하는 줄 = 추가된 내용

bash

```bash
# 4. README만 Stage에 추가
git add README.md

# 5. Stage 영역의 변경사항 확인
git diff --staged
```

**출력:** README.md의 diff만 표시됨

bash

```bash
# 6. 작업 디렉토리에 남은 변경사항 확인
git diff
```

**출력:**

diff

```diff
diff --git a/style.css b/style.css
index abc1234..def5678 100644
--- a/style.css
+++ b/style.css
@@ -7,3 +7,4 @@ body {
 h1 {
     color: #333;
 }
+button { padding: 10px 20px; }
```

### 실습 2-5: 의미별로 나누어 커밋

bash

````bash
# 1. README 변경사항만 커밋
git commit -m "docs: README에 프로젝트 설명 추가"

# 2. 나머지 스타일 변경사항 커밋
git add style.css
git commit -m "style: 버튼 스타일 추가"

# 3. 깔끔한 히스토리 확인
git log --oneline
```

**출력:**
```
f6e7d8c style: 버튼 스타일 추가
e5d6c7b docs: README에 프로젝트 설명 추가
c5d6e7f feat: 인사 버튼 기능 추가
b3c4d5e style: CSS 스타일 추가 및 HTML에 연결
a1b2c3d feat: 기본 HTML 페이지 추가
9a8b7c6 docs: README 파일 추가
```

### 💡 핵심 정리

**나쁜 커밋:**
```
git add .
git commit -m "여러 가지 수정"
```
→ 무엇을 바꿨는지 나중에 알 수 없음

**좋은 커밋:**
```
git add README.md
git commit -m "docs: 프로젝트 설명 추가"

git add style.css
git commit -m "style: 버튼 스타일 개선"
````

→ 각 커밋이 명확한 목적을 가짐

---

## 1.3: Amend로 커밋 수정 (40분)

### 핵심 개념

> **아직 서버에 올리지 않은 커밋은 수정 가능**
> 
> `git commit --amend`는 직전 커밋을 덮어씁니다. 커밋 메시지를 수정하거나, 빠뜨린 파일을 추가할 때 유용합니다.

### 실습 3-1: 커밋 메시지 오타 수정

bash

````bash
# 1. 새 파일 생성 (오타가 있는 커밋)
echo "# 할 일 목록" > todo.txt
git add todo.txt
# '할일' → '할 일' 띄어쓰기 실수
git commit -m "feat: 할일 목록 추가"  

# 2. 로그 확인
git log --oneline -1
```

**출력:**
```
g7h8i9j feat: 할일 목록 추가
````

bash

````bash
# 3. 커밋 메시지 수정
git commit --amend -m "feat: 할 일 목록 추가"

# 4. 결과 확인
git log --oneline -1
```

**출력:**
```
h8i9j0k feat: 할 일 목록 추가
````

**해설:** 커밋 해시가 바뀜 (`g7h8i9j` → `h8i9j0k`) = 새로운 커밋으로 대체됨

### 실습 3-2: 빠뜨린 파일 추가하기

bash

````bash
# 1. 기능 추가 커밋 (하지만 파일 하나를 깜빡함)
cat > config.js << 'EOF'
const CONFIG = {
    appName: 'My Git Project',
    version: '1.0.0'
};
EOF

git add config.js
git commit -m "feat: 설정 파일 추가"

# 2. 앗! .gitignore를 같이 커밋하려고 했는데 깜빡함
cat > .gitignore << 'EOF'
node_modules/
.DS_Store
*.log
EOF

# 3. 상태 확인
git status
```

**출력:**
```
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.gitignore

nothing added to commit but untracked files present (use "git add" to track)
````

bash

```bash
# 4. 새로운 커밋을 만들지 않고, 직전 커밋에 추가
git add .gitignore
git commit --amend --no-edit
```

**해설:** `--no-edit` = 커밋 메시지를 그대로 유지

bash

````bash
# 5. 커밋 내용 확인
git show --name-only
```

**출력:**
```
commit i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8
Author: Your Name <your.email@example.com>
Date:   Mon Nov 10 11:00:00 2025 +0900

    feat: 설정 파일 추가

.gitignore
config.js
````

**해설:** 두 파일이 모두 같은 커밋에 포함됨

### 실습 3-3: 커밋 내용과 메시지 모두 수정

bash

````bash
# 1. 파일 생성 및 커밋
cat > about.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>About</title>
</head>
<body>
    <h1>About This Projct</h1>
</body>
</html>
EOF

git add about.html
git commit -m "feat: About 페이지 추가"

# 2. 오타 발견! (Projct → Project)
cat > about.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>About</title>
</head>
<body>
    <h1>About This Project</h1>
</body>
</html>
EOF

# 3. 수정 사항을 Stage에 추가
git add about.html

# 4. 커밋 메시지도 더 자세하게 수정
git commit --amend -m "feat: About 페이지 추가

프로젝트 소개 페이지를 추가합니다.
향후 팀 정보를 추가할 예정입니다."

# 5. 수정된 커밋 확인
git show
```

**출력:**
```
commit j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9
Author: Your Name <your.email@example.com>
Date:   Mon Nov 10 11:10:00 2025 +0900

    feat: About 페이지 추가
    
    프로젝트 소개 페이지를 추가합니다.
    향후 팀 정보를 추가할 예정입니다.

diff --git a/about.html b/about.html
new file mode 100644
index 0000000..abc1234
--- /dev/null
+++ b/about.html
@@ -0,0 +1,9 @@
+<!DOCTYPE html>
+<html>
+<head>
+    <title>About</title>
+</head>
+<body>
+    <h1>About This Project</h1>
+</body>
+</html>
````

### 실습 3-4: Amend의 위험성 이해하기

bash

````bash
# 현재 히스토리 확인
git log --oneline
```

**출력:**
```
j0k1l2m About 페이지 추가
i9j0k1l 설정 파일 추가
h8i9j0k 할 일 목록 추가
f6e7d8c 버튼 스타일 추가
e5d6c7b README에 프로젝트 설명 추가
...
````

**중요한 질문:** "이 커밋들을 팀원과 이미 공유했다면?"

bash

```bash
# ❌ 절대 하면 안 되는 경우:
# git push (서버에 올린 후)
# git commit --amend (커밋 수정)
# git push --force (강제로 덮어쓰기)

# 이렇게 하면 팀원의 히스토리와 충돌이 발생합니다!
```

### 💡 핵심 정리

**Amend 사용 규칙:**

✅ **사용해도 되는 경우:**

- 아직 `git push`하지 않은 로컬 커밋
- 혼자 작업하는 브랜치
- 커밋 메시지 오타 수정
- 빠뜨린 파일 추가

❌ **사용하면 안 되는 경우:**

- 이미 서버에 올린 커밋
- 다른 사람이 base로 사용 중인 커밋
- 공용 브랜치(main, develop 등)의 커밋

**명령어 정리:**

bash

```bash
# 커밋 메시지만 수정
git commit --amend -m "새로운 메시지"

# 커밋 메시지 그대로, 파일만 추가
git add forgotten-file.txt
git commit --amend --no-edit

# 커밋 메시지와 내용 모두 수정
git add modified-file.txt
git commit --amend
```

---

## 1.4: 커밋 히스토리 시각화 & Git 내부 구조 (60분)

### 핵심 개념

> **커밋 = 포인터 + 전체 프로젝트 스냅샷**
> 
> Git은 변경사항(diff)을 저장하는 것이 아니라, 매 커밋마다 전체 프로젝트의 스냅샷을 저장합니다. 내부적으로는 "커밋 → 트리 → 블롭" 구조로 데이터를 관리합니다.

### 실습 4-1: 더 많은 커밋 쌓기

bash

```bash
# 1. footer 추가
cat >> index.html << 'EOF'
    <footer>
        <p>&copy; 2025 My Git Project</p>
    </footer>
EOF

git add index.html
git commit -m "feat: 푸터 추가"

# 2. footer 스타일 추가
cat >> style.css << 'EOF'

footer {
    margin-top: 50px;
    padding: 20px;
    background-color: #333;
    color: white;
    text-align: center;
}
EOF

git add style.css
git commit -m "style: 푸터 스타일링"

# 3. 할 일 항목 추가
cat >> todo.txt << 'EOF'

## 완료
- [x] 기본 페이지 구조
- [x] 스타일 적용

## 진행 중
- [ ] 네비게이션 바
- [ ] 반응형 디자인
EOF

git add todo.txt
git commit -m "docs: 할 일 목록 업데이트"

# 4. 로그인 페이지 추가
cat > login.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Login</h1>
    <form>
        <input type="text" placeholder="Username">
        <input type="password" placeholder="Password">
        <button type="submit">Login</button>
    </form>
</body>
</html>
EOF

git add login.html
git commit -m "feat: 로그인 페이지 추가"
```

### 실습 4-2: 히스토리 시각화

bash

```bash
# 1. 기본 로그
git log
```

**문제점:** 너무 길고 읽기 어려움

bash

````bash
# 2. 한 줄로 요약
git log --oneline
```

**출력:**
```
m3n4o5p feat: 로그인 페이지 추가
l2m3n4o docs: 할 일 목록 업데이트
k1l2m3n style: 푸터 스타일링
j0k1l2m feat: 푸터 추가
i9j0k1l feat: About 페이지 추가
h8i9j0k feat: 설정 파일 추가
g7h8i9j feat: 할 일 목록 추가
f6e7d8c style: 버튼 스타일 추가
e5d6c7b docs: README에 프로젝트 설명 추가
c5d6e7f feat: 인사 버튼 기능 추가
b3c4d5e style: CSS 스타일 추가 및 HTML에 연결
a1b2c3d feat: 기본 HTML 페이지 추가
9a8b7c6 docs: README 파일 추가
````

bash

````bash
# 3. 그래프로 시각화
git log --oneline --graph --all
```

**출력:**
```
* m3n4o5p (HEAD -> main) feat: 로그인 페이지 추가
* l2m3n4o docs: 할 일 목록 업데이트
* k1l2m3n style: 푸터 스타일링
* j0k1l2m feat: 푸터 추가
* i9j0k1l feat: About 페이지 추가
* h8i9j0k feat: 설정 파일 추가
* g7h8i9j feat: 할 일 목록 추가
* f6e7d8c style: 버튼 스타일 추가
* e5d6c7b docs: README에 프로젝트 설명 추가
* c5d6e7f feat: 인사 버튼 기능 추가
* b3c4d5e style: CSS 스타일 추가 및 HTML에 연결
* a1b2c3d feat: 기본 HTML 페이지 추가
* 9a8b7c6 docs: README 파일 추가
````

**해설:**

- `HEAD` = 현재 내가 보고 있는 위치
- `main` = 브랜치 이름
- `*` = 커밋 지점

bash

```bash
# 4. 더 예쁘게 (데코레이션 추가)
git log --oneline --graph --all --decorate
```

### 실습 4-3: 특정 커밋의 스냅샷 보기

bash

````bash
# 1. 가장 최근 커밋의 상세 정보
git show HEAD
```

**출력:**
```
commit m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2
Author: Your Name <your.email@example.com>
Date:   Mon Nov 10 11:30:00 2025 +0900

    feat: 로그인 페이지 추가

diff --git a/login.html b/login.html
new file mode 100644
index 0000000..abc1234
--- /dev/null
+++ b/login.html
@@ -0,0 +1,14 @@
+<!DOCTYPE html>
+<html>
+<head>
+    <title>Login</title>
+    <link rel="stylesheet" href="style.css">
+</head>
+<body>
+    <h1>Login</h1>
+    <form>
+        <input type="text" placeholder="Username">
+        <input type="password" placeholder="Password">
+        <button type="submit">Login</button>
+    </form>
+</body>
+</html>
````

bash

```bash
# 2. 두 커밋 전의 변경사항
git show HEAD~2
```

**해설:** `HEAD~2` = HEAD에서 2단계 이전 커밋

bash

```bash
# 3. 특정 커밋 해시로 조회
git show k1l2m3n
```

bash

````bash
# 4. 파일 이름만 보기
git show HEAD --name-only
```

**출력:**
```
commit m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2
Author: Your Name <your.email@example.com>
Date:   Mon Nov 10 11:30:00 2025 +0900

    feat: 로그인 페이지 추가

login.html
````

### 실습 4-4: Git 내부 구조 들여다보기 - 객체 탐험

bash

````bash
# 1. .git 폴더 구조 확인
ls -la .git/
```

**출력:**
```
drwxr-xr-x  13 user  staff   416 Nov 10 11:30 .
drwxr-xr-x  15 user  staff   480 Nov 10 11:30 ..
-rw-r--r--   1 user  staff    23 Nov 10 09:55 HEAD
drwxr-xr-x   2 user  staff    64 Nov 10 09:55 branches
-rw-r--r--   1 user  staff   137 Nov 10 11:00 config
drwxr-xr-x   3 user  staff    96 Nov 10 09:55 hooks
-rw-r--r--   1 user  staff   217 Nov 10 11:30 index
drwxr-xr-x   3 user  staff    96 Nov 10 09:55 info
drwxr-xr-x   4 user  staff   128 Nov 10 09:56 logs
drwxr-xr-x  40 user  staff  1280 Nov 10 11:30 objects
drwxr-xr-x   4 user  staff   128 Nov 10 09:55 refs
````

**핵심 폴더:**

- `objects/` = 모든 Git 데이터가 저장되는 곳
- `refs/` = 브랜치, 태그 등의 참조
- `HEAD` = 현재 체크아웃된 커밋을 가리킴

bash

````bash
# 2. objects 폴더 들여다보기
ls .git/objects/
```

**출력:**
```
9a  a1  b3  c5  e5  f6  g7  h8  i9  j0  k1  l2  m3
info  pack
````

**해설:** 각 폴더는 해시의 첫 2자리, 폴더 안에 실제 객체 파일이 있음

bash

````bash
# 3. 최신 커밋의 내부 구조 보기
git cat-file -t HEAD
```

**출력:**
```
commit
````

bash

````bash
# 4. 커밋 객체의 내용 보기
git cat-file -p HEAD
```

**출력:**
```
tree a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6
parent l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0
author Your Name <your.email@example.com> 1699585800 +0900
committer Your Name <your.email@example.com> 1699585800 +0900

feat: 로그인 페이지 추가
````

**해설:**

- `tree` = 이 커밋의 프로젝트 스냅샷
- `parent` = 이전 커밋 (부모)
- `author` = 작성자
- `committer` = 커밋한 사람

bash

````bash
# 5. 트리 객체 들여다보기
git cat-file -p HEAD^{tree}
```

**출력:**
```
100644 blob xyz1234... .gitignore
100644 blob abc5678... README.md
100644 blob def9012... about.html
100644 blob ghi3456... config.js
100644 blob jkl7890... index.html
100644 blob mno1234... login.html
100644 blob pqr5678... script.js
100644 blob stu9012... style.css
100644 blob vwx3456... todo.txt
````

**해설:** `tree` = 디렉토리처럼 파일 목록을 담고 있음

bash

````bash
# 6. 특정 파일의 blob 내용 보기 (login.html)
# 먼저 login.html의 blob 해시 찾기
BLOB_HASH=$(git cat-file -p HEAD^{tree} | grep login.html | awk '{print $3}')
echo "login.html의 blob 해시: $BLOB_HASH"

# blob 내용 확인
git cat-file -p $BLOB_HASH
```

**출력:**
```
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Login</h1>
    <form>
        <input type="text" placeholder="Username">
        <input type="password" placeholder="Password">
        <button type="submit">Login</button>
    </form>
</body>
</html>
````

### 실습 4-5: 커밋 체인 따라가기

bash

````bash
# 1. 현재 커밋에서 출발
git log --oneline -1
```

**출력:**
```
m3n4o5p (HEAD -> main) feat: 로그인 페이지 추가
````

bash

````bash
# 2. 부모 커밋 확인
git cat-file -p HEAD | grep parent
```

**출력:**
```
parent l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0
````

bash

````bash
# 3. 부모 커밋의 내용 보기
git cat-file -p HEAD~1
```

**출력:**
```
tree b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7
parent k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8
author Your Name <your.email@example.com> 1699585700 +0900
committer Your Name <your.email@example.com> 1699585700 +0900

docs: 할 일 목록 업데이트
````

bash

````bash
# 4. 부모의 부모 (조부모) 확인
git log --oneline HEAD~2 -1
```

**출력:**
```
k1l2m3n style: 푸터 스타일링
```

### 📊 화이트보드 세션: Git 객체 구조도

**강사가 화이트보드에 그릴 내용:**
```
┌─────────────────────────────────────────────────────┐
│ Commit m3n4o5p                                      │
│ "feat: 로그인 페이지 추가"                             │
│                                                     │
│  tree: a7b8c9d0                                     │
│  parent: l2m3n4o5 ───────────┐                     │
│  author: Your Name            │                     │
└───────────────────────────────┼─────────────────────┘
                                │
                                ▼
                ┌───────────────────────────┐
                │ Commit l2m3n4o5           │
                │ "docs: 할 일 목록 업데이트" │
                │                           │
                │  tree: b8c9d0e1           │
                │  parent: k1l2m3n ─────┐   │
                └───────────────────────┼───┘
                                        │
                                        ▼
                        ┌───────────────────────┐
                        │ Commit k1l2m3n        │
                        │ "style: 푸터 스타일링" │
                        └───────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Tree a7b8c9d0 (커밋 m3n4o5p의 스냅샷)                │
├─────────────────────────────────────────────────────┤
│  .gitignore    → blob xyz1234                       │
│  README.md     → blob abc5678                       │
│  about.html    → blob def9012                       │
│  config.js     → blob ghi3456                       │
│  index.html    → blob jkl7890                       │
│  login.html    → blob mno1234 ◄── 새로 추가!        │
│  script.js     → blob pqr5678                       │
│  style.css     → blob stu9012                       │
│  todo.txt      → blob vwx3456                       │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ Blob mno1234                  │
        │ (login.html의 실제 내용)       │
        ├───────────────────────────────┤
        │ <!DOCTYPE html>               │
        │ <html>                        │
        │ <head>                        │
        │   <title>Login</title>        │
        │   ...                         │
        └───────────────────────────────┘
````

**설명할 핵심 포인트:**

1. **Commit**: 메타데이터 + Tree 포인터
2. **Tree**: 파일/폴더 구조 (스냅샷)
3. **Blob**: 실제 파일 내용
4. **Parent**: 커밋 체인으로 히스토리 형성

### 실습 4-6: 스냅샷의 의미 - 실험

bash

````bash
# 1. 현재 상태 저장
git log --oneline -1
```

**출력:**
```
m3n4o5p (HEAD -> main) feat: 로그인 페이지 추가
````

bash

````bash
# 2. 파일 수정 (하지만 커밋하지 않음)
echo "<!-- 임시 수정 -->" >> login.html

# 3. 작업 디렉토리 확인
cat login.html | tail -3
```

**출력:**
```
    </form>
</body>
</html>
<!-- 임시 수정 -->
````

bash

````bash
# 4. Git 저장소의 login.html은? (HEAD 커밋의 버전)
git show HEAD:login.html | tail -3
```

**출력:**
```
    </form>
</body>
</html>
````

**해설:** Git은 완전한 스냅샷을 저장하므로, 언제든 과거 버전으로 돌아갈 수 있음

bash

````bash
# 5. 작업 디렉토리 원상 복구
git restore login.html
```

### 💡 최종 핵심 정리

**Git의 3가지 객체:**
```
Commit  →  Tree  →  Blob
(커밋)    (폴더)   (파일)
```

**커밋은 차이가 아닌 스냅샷:**
```
❌ 잘못된 이해: "커밋 = 이전 커밋과의 차이점"
✅ 올바른 이해: "커밋 = 그 시점의 전체 프로젝트 사진"
````

**유용한 명령어 정리:**

bash

```bash
# 히스토리 보기
git log --oneline --graph --all

# 특정 커밋 내용 보기
git show <commit-hash>
git show HEAD~3

# Git 내부 객체 보기
git cat-file -t <hash>  # 객체 타입 확인
git cat-file -p <hash>  # 객체 내용 보기
git cat-file -p HEAD^{tree}  # 현재 커밋의 트리
```

---

## 🎓 1부 종합 실습 과제

### 과제: 개인 블로그 프로젝트 시작하기

**요구사항:**

1. `my-blog` 폴더 생성 및 Git 저장소 초기화
2. 다음 파일들을 **의미 있는 단위로 나누어** 최소 8개 이상의 커밋으로 만들기:
    - `index.html` (블로그 메인 페이지)
    - `posts.html` (글 목록)
    - `style.css` (스타일)
    - `README.md` (프로젝트 설명)
    - `.gitignore` (무시할 파일 설정)
3. 최소 1번 이상 `git commit --amend` 사용하기
4. `git log --oneline --graph` 결과 스크린샷 제출
5. 마지막 커밋의 Tree 구조 캡처: `git cat-file -p HEAD^{tree}`

**평가 기준:**

- 각 커밋이 하나의 명확한 목적을 가지는가?
- 커밋 메시지가 의미 있게 작성되었는가?
- Git 내부 구조를 이해하고 있는가?

**제출물:**

bash

```bash
# 히스토리 출력
git log --oneline --graph > git-history.txt

# 마지막 커밋의 트리 구조
git cat-file -p HEAD^{tree} > git-tree.txt

# 제출
zip my-blog-submission.zip git-history.txt git-tree.txt
```

---

## 📚 참고 자료

### 추가 학습 자료

- [Git 공식 문서](https://git-scm.com/doc)
- [Pro Git 책 (무료)](https://git-scm.com/book/ko/v2)
- [Git Internals](https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain)

### 다음 시간 예고: 2부 - Branch와 Merge

- 브랜치의 개념과 활용
- 병합 전략 (Fast-forward vs 3-way merge)
- 충돌 해결 방법
- 실무 브랜치 전략 (Git Flow, GitHub Flow)
