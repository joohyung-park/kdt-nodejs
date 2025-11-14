# Git 버전관리 실습 - 2부: Branch - 평행 세계 만들기

> **학습 목표**: Branch를 이용해 독립적인 작업 공간을 만들고, 여러 작업을 병렬로 진행한 뒤 안전하게 통합하는 방법을 실습합니다.

---

## 2.1: Branch 생성과 이동 (50분)

### 개념: Branch란?

Branch는 **독립된 작업 공간**입니다. 마치 평행 세계처럼, 한 브랜치에서의 변경사항은 다른 브랜치에 영향을 주지 않습니다.

```
main:     A --- B --- C
                      \
feature:               D --- E
```

### 실습 1: 첫 번째 브랜치 만들기

```bash
# 새 프로젝트 시작
mkdir git-branch-practice
cd git-branch-practice
git init

# 초기 파일 생성
echo "# 쇼핑몰 프로젝트" > README.md
echo "version: 1.0.0" > version.txt
git add .
git commit -m "Initial commit: 프로젝트 시작"
```

```bash
# 현재 브랜치 확인
git branch
# * main (또는 master)

# 새 브랜치 생성
git branch feature/login
git branch feature/payment

# 브랜치 목록 확인
git branch
#   feature/login
#   feature/payment
# * main
```

**핵심**: `*` 표시는 현재 작업 중인 브랜치를 나타냅니다.

### 실습 2: 브랜치 이동하기

#### 방법 1: `git checkout` (전통적 방법)

```bash
# login 브랜치로 이동
git checkout feature/login

# 확인
git branch
# * feature/login
#   feature/payment
#   main
```

#### 방법 2: `git switch` (Git 2.23 이상, 권장)

```bash
# main으로 돌아가기
git switch main

# payment 브랜치로 이동
git switch feature/payment
```

**차이점**: `git switch`는 브랜치 전환 전용 명령어로, `checkout`보다 직관적입니다.

### 실습 3: 브랜치 생성과 동시에 이동

```bash
# main으로 돌아가기
git switch main

# 새 브랜치를 만들면서 바로 이동
git switch -c feature/cart
# 또는
git checkout -b feature/cart

# 확인
git branch
#   feature/cart
# * feature/login
#   feature/payment
#   main
```

### 실습 4: 브랜치 간 파일 상태 변화 관찰

```bash
# feature/login 브랜치로 이동
git switch feature/login

# 로그인 기능 파일 추가
cat > login.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>로그인</title></head>
<body>
    <h1>로그인 페이지</h1>
    <form>
        <input type="text" placeholder="아이디">
        <input type="password" placeholder="비밀번호">
        <button>로그인</button>
    </form>
</body>
</html>
EOF

# 커밋
git add login.html
git commit -m "feat: 로그인 페이지 추가"

# 현재 파일 목록 확인
ls
# README.md  login.html  version.txt
```

```bash
# main 브랜치로 이동
git switch main

# 파일 목록 확인 - login.html이 사라짐!
ls
# README.md  version.txt

# 다시 feature/login으로 이동
git switch feature/login

# login.html이 다시 나타남!
ls
# README.md  login.html  version.txt
```

**핵심 관찰**: 
- Branch를 전환하면 작업 디렉토리의 파일들이 해당 브랜치의 상태로 변경됩니다
- 각 브랜치는 완전히 독립된 작업 공간입니다

### 실습 5: 여러 브랜치에서 같은 파일 수정

```bash
# main 브랜치로 이동
git switch main

# version.txt 수정
echo "version: 1.0.0 - stable" > version.txt
cat version.txt
# version: 1.0.0 - stable

git add version.txt
git commit -m "docs: 버전 정보에 stable 표시"
```

```bash
# feature/login 브랜치로 이동
git switch feature/login

# version.txt 확인 - main의 변경사항이 없음!
cat version.txt
# version: 1.0.0

# 이 브랜치에서도 수정
echo "version: 1.0.0 - login feature" > version.txt
git add version.txt
git commit -m "docs: 로그인 기능 버전 표시"

cat version.txt
# version: 1.0.0 - login feature
```

```bash
# main으로 돌아가서 확인
git switch main
cat version.txt
# version: 1.0.0 - stable

# 다시 feature/login으로
git switch feature/login
cat version.txt
# version: 1.0.0 - login feature
```

**핵심 이해**: 같은 파일도 브랜치마다 다른 내용을 가질 수 있습니다!

### 연습 문제 (10분)

1. `feature/signup` 브랜치를 생성하고 이동하세요
2. `signup.html` 파일을 만들어 간단한 회원가입 폼을 작성하세요
3. 커밋한 후 main 브랜치로 돌아가 파일이 사라지는지 확인하세요
4. 다시 feature/signup으로 돌아가 파일이 있는지 확인하세요

<details>
<summary>정답 보기</summary>

```bash
git switch -c feature/signup

cat > signup.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>회원가입</title></head>
<body>
    <h1>회원가입</h1>
    <form>
        <input type="text" placeholder="아이디">
        <input type="password" placeholder="비밀번호">
        <input type="email" placeholder="이메일">
        <button>가입하기</button>
    </form>
</body>
</html>
EOF

git add signup.html
git commit -m "feat: 회원가입 페이지 추가"

git switch main
ls  # signup.html 없음

git switch feature/signup
ls  # signup.html 있음
```
</details>

---

## 2.2: 여러 브랜치 동시 작업 (70분)

### 개념: 병렬 개발

실제 프로젝트에서는 여러 기능을 동시에 개발합니다. Branch를 사용하면 각 기능을 독립적으로 작업할 수 있습니다.

### 실습 1: 프로젝트 재구성

```bash
# 깨끗하게 시작하기 위해 새 디렉토리
cd ..
mkdir ecommerce-project
cd ecommerce-project
git init

# 기본 프로젝트 구조
mkdir src
cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>쇼핑몰</title></head>
<body>
    <h1>Welcome to Our Shop</h1>
    <div id="products"></div>
</body>
</html>
EOF

cat > src/style.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
}
h1 {
    color: #333;
}
EOF

git add .
git commit -m "Initial commit: 기본 프로젝트 구조"
```

### 실습 2: 두 개의 기능 브랜치 생성

```bash
# 첫 번째 기능: 상품 목록
git switch -c feature/product-list

cat > src/products.js << 'EOF'
// 상품 데이터
const products = [
    { id: 1, name: "노트북", price: 1200000 },
    { id: 2, name: "마우스", price: 30000 },
    { id: 3, name: "키보드", price: 80000 }
];

function displayProducts() {
    const container = document.getElementById('products');
    products.forEach(product => {
        const div = document.createElement('div');
        div.className = 'product';
        div.innerHTML = `
            <h3>${product.name}</h3>
            <p>가격: ${product.price.toLocaleString()}원</p>
        `;
        container.appendChild(div);
    });
}
EOF

# index.html에 스크립트 추가
cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>쇼핑몰</title></head>
<body>
    <h1>Welcome to Our Shop</h1>
    <div id="products"></div>
    <script src="products.js"></script>
    <script>displayProducts();</script>
</body>
</html>
EOF

git add .
git commit -m "feat: 상품 목록 표시 기능 추가"
```

```bash
# main으로 돌아가기
git switch main

# 두 번째 기능: 장바구니
git switch -c feature/shopping-cart

cat > src/cart.js << 'EOF'
// 장바구니 기능
let cart = [];

function addToCart(productId, name, price) {
    cart.push({ productId, name, price });
    updateCartDisplay();
}

function updateCartDisplay() {
    const cartDiv = document.getElementById('cart');
    if (!cartDiv) return;
    
    const total = cart.reduce((sum, item) => sum + item.price, 0);
    cartDiv.innerHTML = `
        <h3>장바구니 (${cart.length}개)</h3>
        <p>총액: ${total.toLocaleString()}원</p>
    `;
}

function clearCart() {
    cart = [];
    updateCartDisplay();
}
EOF

# index.html에 장바구니 영역 추가
cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>쇼핑몰</title></head>
<body>
    <h1>Welcome to Our Shop</h1>
    <div id="cart"></div>
    <div id="products"></div>
    <script src="cart.js"></script>
</body>
</html>
EOF

git add .
git commit -m "feat: 장바구니 기능 추가"
```

### 실습 3: 각 브랜치에서 추가 작업

```bash
# product-list 브랜치에서 CSS 추가
git switch feature/product-list

cat >> src/style.css << 'EOF'

.product {
    border: 1px solid #ddd;
    padding: 15px;
    margin: 10px 0;
    border-radius: 5px;
}

.product h3 {
    margin: 0 0 10px 0;
    color: #007bff;
}
EOF

git add .
git commit -m "style: 상품 카드 스타일 추가"

# 상품에 이미지 URL 추가
cat > src/products.js << 'EOF'
// 상품 데이터
const products = [
    { id: 1, name: "노트북", price: 1200000, image: "laptop.jpg" },
    { id: 2, name: "마우스", price: 30000, image: "mouse.jpg" },
    { id: 3, name: "키보드", price: 80000, image: "keyboard.jpg" }
];

function displayProducts() {
    const container = document.getElementById('products');
    products.forEach(product => {
        const div = document.createElement('div');
        div.className = 'product';
        div.innerHTML = `
            <img src="${product.image}" alt="${product.name}" width="200">
            <h3>${product.name}</h3>
            <p>가격: ${product.price.toLocaleString()}원</p>
            <button onclick="addToCart(${product.id}, '${product.name}', ${product.price})">
                장바구니 추가
            </button>
        `;
        container.appendChild(div);
    });
}
EOF

git add .
git commit -m "feat: 상품 이미지 및 장바구니 추가 버튼"
```

```bash
# shopping-cart 브랜치에서 추가 기능
git switch feature/shopping-cart

cat > src/cart.js << 'EOF'
// 장바구니 기능
let cart = [];

function addToCart(productId, name, price) {
    const existingItem = cart.find(item => item.productId === productId);
    
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        cart.push({ productId, name, price, quantity: 1 });
    }
    updateCartDisplay();
}

function removeFromCart(productId) {
    cart = cart.filter(item => item.productId !== productId);
    updateCartDisplay();
}

function updateCartDisplay() {
    const cartDiv = document.getElementById('cart');
    if (!cartDiv) return;
    
    if (cart.length === 0) {
        cartDiv.innerHTML = '<h3>장바구니가 비어있습니다</h3>';
        return;
    }
    
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const itemsHTML = cart.map(item => `
        <div class="cart-item">
            ${item.name} x ${item.quantity} = ${(item.price * item.quantity).toLocaleString()}원
            <button onclick="removeFromCart(${item.productId})">삭제</button>
        </div>
    `).join('');
    
    cartDiv.innerHTML = `
        <h3>장바구니 (${cart.length}개 상품)</h3>
        ${itemsHTML}
        <p><strong>총액: ${total.toLocaleString()}원</strong></p>
        <button onclick="clearCart()">장바구니 비우기</button>
    `;
}

function clearCart() {
    cart = [];
    updateCartDisplay();
}
EOF

git add .
git commit -m "feat: 수량 관리 및 상품 삭제 기능"

# 장바구니 스타일 추가
cat >> src/style.css << 'EOF'

#cart {
    background-color: #f8f9fa;
    padding: 15px;
    border-radius: 5px;
    margin-bottom: 20px;
}

.cart-item {
    padding: 8px;
    border-bottom: 1px solid #dee2e6;
}

.cart-item:last-child {
    border-bottom: none;
}
EOF

git add .
git commit -m "style: 장바구니 스타일 추가"
```

### 실습 4: 브랜치 히스토리 시각화

```bash
# 모든 브랜치의 커밋 히스토리를 그래프로 표시
git log --all --graph --oneline --decorate

# 출력 예시:
# * a1b2c3d (HEAD -> feature/shopping-cart) style: 장바구니 스타일 추가
# * d4e5f6g feat: 수량 관리 및 상품 삭제 기능
# | * h7i8j9k (feature/product-list) feat: 상품 이미지 및 장바구니 추가 버튼
# | * l0m1n2o style: 상품 카드 스타일 추가
# |/
# * p3q4r5s (main) Initial commit: 기본 프로젝트 구조
```

**해석**:
- `|`: 브랜치가 분기됨을 표시
- `*`: 커밋 포인트
- `/`: 브랜치가 합쳐지는 지점 (아직 merge 전이라 없음)

### 실습 5: 브랜치 간 차이 확인

```bash
# main과 feature/product-list 브랜치 차이
git diff main..feature/product-list

# main과 feature/shopping-cart 브랜치 차이
git diff main..feature/shopping-cart

# 두 기능 브랜치 간 차이
git diff feature/product-list..feature/shopping-cart
```

```bash
# 각 브랜치에서 변경된 파일 목록만 보기
git diff --name-only main..feature/product-list
# src/index.html
# src/products.js
# src/style.css

git diff --name-only main..feature/shopping-cart
# src/cart.js
# src/index.html
# src/style.css
```

### 실습 6: 브랜치 전환하며 변화 관찰

```bash
# main 브랜치
git switch main
ls src/
# index.html  style.css

cat src/index.html
# (원본 index.html - products.js나 cart.js 스크립트 없음)
```

```bash
# product-list 브랜치
git switch feature/product-list
ls src/
# index.html  products.js  style.css

cat src/products.js
# (상품 목록 코드 있음)
```

```bash
# shopping-cart 브랜치
git switch feature/shopping-cart
ls src/
# cart.js  index.html  style.css

cat src/cart.js
# (장바구니 코드 있음)
```

**핵심 관찰**: 
- main에는 두 기능 모두 없음
- product-list에는 상품 목록만
- shopping-cart에는 장바구니만
- 각각 완전히 독립적으로 개발 중

### 연습 문제 (15분)

1. `feature/user-review` 브랜치를 생성하세요
2. `src/review.js` 파일을 만들어 상품 리뷰 작성 기능을 추가하세요
3. 최소 2개의 커밋을 만드세요 (기능 추가 → 스타일 추가)
4. `git log --all --graph --oneline`으로 전체 구조를 확인하세요

<details>
<summary>정답 예시</summary>

```bash
git switch main
git switch -c feature/user-review

cat > src/review.js << 'EOF'
// 리뷰 기능
let reviews = [];

function addReview(productId, rating, comment) {
    reviews.push({
        productId,
        rating,
        comment,
        date: new Date().toLocaleDateString()
    });
    displayReviews(productId);
}

function displayReviews(productId) {
    const productReviews = reviews.filter(r => r.productId === productId);
    // ... 리뷰 표시 로직
}
EOF

git add .
git commit -m "feat: 상품 리뷰 작성 기능 추가"

cat >> src/style.css << 'EOF'

.review {
    background-color: #fff;
    border: 1px solid #e0e0e0;
    padding: 10px;
    margin: 5px 0;
    border-radius: 3px;
}

.review .rating {
    color: #ffc107;
}
EOF

git add .
git commit -m "style: 리뷰 UI 스타일 추가"

git log --all --graph --oneline --decorate
```
</details>

---

## 2.3: Merge - 합치기 (60분)

### 개념: Merge의 두 가지 방식

1. **Fast-forward merge**: 단순히 포인터만 이동
2. **3-way merge**: 새로운 merge commit 생성

### 실습 1: Fast-forward Merge

```bash
# 새 프로젝트로 시작
cd ..
mkdir merge-practice
cd merge-practice
git init

# 초기 커밋
echo "# 블로그 프로젝트" > README.md
git add .
git commit -m "A: Initial commit"

echo "내용1" > file.txt
git add .
git commit -m "B: 파일 추가"
```

```bash
# 새 기능 브랜치
git switch -c feature/header

echo "<header>블로그 헤더</header>" > header.html
git add .
git commit -m "D: 헤더 추가"

echo "<nav>메뉴</nav>" >> header.html
git add .
git commit -m "E: 네비게이션 메뉴 추가"

# 로그 확인
git log --oneline
# abc123 (HEAD -> feature/header) E: 네비게이션 메뉴 추가
# def456 D: 헤더 추가
# ghi789 (main) B: 파일 추가
# jkl012 A: Initial commit
```

```bash
# main으로 돌아가서 merge
git switch main

# merge 전 상태 확인
ls
# README.md (header.html 없음)

# Fast-forward merge 실행
git merge feature/header
# Updating j7k8l9m..b1c2d3e
# Fast-forward
#  header.html | 2 ++
#  1 file changed, 2 insertions(+)

# merge 후 확인
ls
# README.md  header.html

git log --oneline --graph
# * b1c2d3e (HEAD -> main, feature/header) E: 네비게이션 메뉴 추가
# * f4g5h6i D: 헤더 추가
# * j7k8l9m B: 파일 추가
# * jkl012 A: Initial commit
```

**핵심 이해**: 
- Fast-forward는 단순히 main 브랜치 포인터를 앞으로 이동
- 별도의 merge commit이 생성되지 않음
- 일직선 히스토리 유지

### 실습 2: 3-way Merge (Non Fast-forward)

```bash
# feature/header에서 추가 작업
git switch feature/header

echo "color: blue;" > header.css
git add .
git commit -m "style: 헤더 스타일 추가"
```

```bash
# main에서도 작업 (다른 파일)
git switch main

echo "<footer>© 2024 블로그</footer>" > footer.html
git add .
git commit -m "feat: 푸터 추가"

# 현재 브랜치 구조
git log --all --graph --oneline
# * a1b2c3d (HEAD -> main) feat: 푸터 추가
# | * d4e5f6g (feature/header) style: 헤더 스타일 추가
# |/
# * b1c2d3e E: 네비게이션 메뉴 추가
# * f4g5h6i D: 헤더 추가
# * j7k8l9m B: 파일 추가
# * jkl012 A: Initial commit
```

```bash
# 3-way merge 실행
git merge feature/header

# Git이 자동으로 편집기를 열어 merge commit 메시지 입력 요청
# 기본 메시지: "Merge branch 'feature/header'"
# 저장하고 종료

# Merge branch 'feature/header'
# (merge commit 생성됨)

# 결과 확인
git log --all --graph --oneline
# *   h7i8j9k (HEAD -> main) Merge branch 'feature/header'
# |\
# | * d4e5f6g (feature/header) style: 헤더 스타일 추가
# * | a1b2c3d feat: 푸터 추가
# |/
# * b1c2d3e E: 네비게이션 메뉴 추가
# * f4g5h6i D: 헤더 추가
# * j7k8l9m B: 파일 추가
# * jkl012 A: Initial commit

# 파일 확인
ls
# README.md  footer.html  header.css  header.html
```

**핵심 이해**:
- 두 브랜치가 모두 진행된 경우 3-way merge 발생
- 새로운 merge commit이 생성됨 (두 부모를 가짐)
- 브랜치 히스토리가 보존됨

### 실습 3: Merge Commit의 구조 확인

```bash
# merge commit 상세 정보
git show h7i8j9k  # (실제 해시값 사용)

# commit h7i8j9k
# Merge: a1b2c3d d4e5f6g  ← 두 개의 부모!
# Author: ...
# Date: ...
#
#     Merge branch 'feature/header'

# merge commit의 부모 확인
git log --oneline h7i8j9k^1  # 첫 번째 부모 (main 쪽)
git log --oneline h7i8j9k^2  # 두 번째 부모 (feature/header 쪽)
```

### 실습 4: 충돌 없는 Merge 더 연습하기

```bash
# 새 기능 브랜치 두 개 생성
git switch -c feature/sidebar
echo "<aside>사이드바</aside>" > sidebar.html
git add .
git commit -m "feat: 사이드바 추가"

git switch main
git switch -c feature/article
echo "<article>첫 번째 글</article>" > article.html
git add .
git commit -m "feat: 기사 템플릿 추가"

# 각각 main에 merge
git switch main
git merge feature/sidebar
# Fast-forward

git merge feature/article
# Fast-forward

# 전체 구조 확인
git log --all --graph --oneline
```

### 실습 5: --no-ff 옵션으로 강제 Merge Commit 생성

```bash
# 새 브랜치
git switch -c feature/search

echo "검색 기능" > search.html
git add .
git commit -m "feat: 검색 기능 추가"

# main으로 돌아와서 --no-ff 옵션으로 merge
git switch main
git merge --no-ff feature/search

# 편집기가 열림, 메시지 입력:
# Merge branch 'feature/search'
# 
# 검색 기능을 메인에 통합

# 저장

# 결과 확인
git log --graph --oneline
# *   l0m1n2o (HEAD -> main) Merge branch 'feature/search'
# |\
# | * p3q4r5s (feature/search) feat: 검색 기능 추가
# |/
# * ...
```

**--no-ff의 용도**:
- Fast-forward 가능해도 merge commit을 생성
- 기능 단위로 히스토리를 명확하게 구분
- 협업 시 "어떤 커밋들이 하나의 기능인지" 파악 용이

### 실습 6: 실전 시나리오 - 쇼핑몰 프로젝트

```bash
cd ..
mkdir shop-merge-practice
cd shop-merge-practice
git init

# 기본 구조
echo "# 쇼핑몰 v1.0" > README.md
mkdir src
echo "console.log('app start');" > src/app.js
git add .
git commit -m "Initial commit: 프로젝트 시작"
```

```bash
# 결제 기능 개발
git switch -c feature/payment

cat > src/payment.js << 'EOF'
function processPayment(amount, method) {
    console.log(`Processing ${amount} via ${method}`);
    return { success: true, transactionId: Date.now() };
}
EOF

git add .
git commit -m "feat: 결제 처리 기본 로직"

cat >> src/payment.js << 'EOF'

function refundPayment(transactionId) {
    console.log(`Refunding transaction ${transactionId}`);
    return { success: true };
}
EOF

git add .
git commit -m "feat: 환불 기능 추가"
```

```bash
# 동시에 쿠폰 기능 개발
git switch main
git switch -c feature/coupon

cat > src/coupon.js << 'EOF'
function applyCoupon(code, total) {
    const coupons = {
        'WELCOME10': 0.1,
        'SAVE20': 0.2
    };
    
    const discount = coupons[code] || 0;
    return total * (1 - discount);
}
EOF

git add .
git commit -m "feat: 쿠폰 적용 기능"

echo "console.log('Coupon system loaded');" >> src/app.js
git add .
git commit -m "feat: 앱에 쿠폰 시스템 로드"
```

```bash
# main으로 돌아와서 두 기능 모두 merge
git switch main

# 먼저 결제 기능 merge
git merge feature/payment
# Fast-forward

# 쿠폰 기능 merge
git merge feature/coupon
# 3-way merge (merge commit 생성)

# 최종 결과
git log --all --graph --oneline --decorate
ls src/
# app.js  coupon.js  payment.js

# 모든 파일 확인
cat src/app.js
cat src/payment.js
cat src/coupon.js
```

### 연습 문제 (15분)

다음 시나리오를 실습하세요:

1. 새 프로젝트를 시작하고 `index.html`을 만들어 커밋
2. `feature/navbar` 브랜치를 만들어 네비게이션 바를 추가하고 커밋
3. main으로 돌아가 `footer.html`을 추가하고 커밋
4. `feature/navbar`를 main에 merge
5. `git log --graph`로 merge commit이 생성되었는지 확인

<details>
<summary>정답 보기</summary>

```bash
mkdir practice-merge
cd practice-merge
git init

echo "<html><body><h1>Home</h1></body></html>" > index.html
git add .
git commit -m "Initial: index.html 생성"

git switch -c feature/navbar
echo "<nav>Home | About | Contact</nav>" > navbar.html
git add .
git commit -m "feat: 네비게이션 바 추가"

git switch main
echo "<footer>© 2024</footer>" > footer.html
git add .
git commit -m "feat: 푸터 추가"

git merge feature/navbar

git log --graph --oneline --all
```
</details>

---

## 2.4: Branch 정리 - Rebase (30분)

### ⚠️ Rebase의 황금 규칙

> **절대 규칙: 이미 Push한 커밋은 Rebase 금지!**
>
> Rebase는 커밋 히스토리를 다시 쓰는 작업입니다. 다른 사람과 공유한 커밋을 rebase하면 큰 문제가 발생합니다.

### 개념: Merge vs Rebase

```
Merge:
main:     A --- B --- C ----------- M (merge commit)
                       \           /
feature:                D --- E ---

Rebase:
main:     A --- B --- C
                       \
feature (rebase):       D' --- E'
                        (새로운 커밋들)
```

### 실습 1: Rebase 기본

```bash
cd ..
mkdir rebase-practice
cd rebase-practice
git init

# 기본 파일
echo "# 프로젝트" > README.md
git add .
git commit -m "A: Initial commit"

echo "내용1" > file.txt
git add .
git commit -m "B: 파일 추가"
```

```bash
# 기능 브랜치에서 작업
git switch -c feature/ui

echo "UI 코드" > ui.html
git add .
git commit -m "D: UI 파일 생성"

echo "<style>color: red;</style>" >> ui.html
git add .
git commit -m "E: UI 스타일 추가"

# 로그 확인
git log --oneline
# abc123 (HEAD -> feature/ui) E: UI 스타일 추가
# def456 D: UI 파일 생성
# ghi789 (main) B: 파일 추가
# jkl012 A: Initial commit
```

```bash
# main에서도 진행
git switch main

echo "내용2" >> file.txt
git add .
git commit -m "C: 내용 업데이트"

# 현재 상태
git log --all --graph --oneline
# * mno345 (HEAD -> main) C: 내용 업데이트
# | * abc123 (feature/ui) E: UI 스타일 추가
# | * def456 D: UI 파일 생성
# |/
# * ghi789 B: 파일 추가
# * jkl012 A: Initial commit
```

```bash
# feature/ui 브랜치를 main 위로 rebase
git switch feature/ui
git rebase main

# Successfully rebased and updated refs/heads/feature/ui.

# 결과 확인
git log --all --graph --oneline
# * pqr678 (HEAD -> feature/ui) E: UI 스타일 추가
# * stu901 D: UI 파일 생성
# * mno345 (main) C: 내용 업데이트
# * ghi789 B: 파일 추가
# * jkl012 A: Initial commit
```

**핵심 관찰**:
- D, E 커밋의 해시값이 변경됨 (새로운 커밋!)
- feature/ui가 main의 최신 커밋 위에 놓임
- 일직선 히스토리 생성

### 실습 2: Rebase 후 Fast-forward Merge

```bash
# main을 feature/ui로 fast-forward
git switch main
git merge feature/ui

# Updating mno345..pqr678
# Fast-forward
#  ui.html | 2 ++
#  1 file changed, 2 insertions(+)

git log --graph --oneline
# * pqr678 (HEAD -> main, feature/ui) E: UI 스타일 추가
# * stu901 D: UI 파일 생성
# * mno345 C: 내용 업데이트
# * ghi789 B: 파일 추가
# * jkl012 A: Initial commit
```

**결과**: 깔끔한 일직선 히스토리!

### 실습 3: 여러 커밋을 Rebase하는 시나리오

```bash
# 새로운 기능 브랜치
git switch -c feature/database

echo "DB 연결 코드" > db.js
git add .
git commit -m "feat: 데이터베이스 연결"

echo "쿼리 함수" >> db.js
git add .
git commit -m "feat: 쿼리 함수 추가"

echo "// TODO: 최적화 필요" >> db.js
git add .
git commit -m "chore: TODO 주석"

echo "최적화 완료" >> db.js
git add .
git commit -m "feat: 쿼리 최적화"

# 4개의 커밋 생성됨
git log --oneline -4
```

```bash
# main에서 진행
git switch main
echo "README 업데이트" >> README.md
git add .
git commit -m "docs: README 업데이트"
```

```bash
# feature/database를 main 위로 rebase
git switch feature/database
git rebase main

# 성공!
git log --all --graph --oneline
# * ... feat: 쿼리 최적화
# * ... chore: TODO 주석
# * ... feat: 쿼리 함수 추가
# * ... feat: 데이터베이스 연결
# * ... (main) docs: README 업데이트
# ...
```

### 실습 4: Interactive Rebase로 커밋 정리

```bash
# 작업 전 커밋 상태 확인
git log --oneline feature/database ^main
# abc123 feat: 쿼리 최적화
# def456 chore: TODO 주석
# ghi789 feat: 쿼리 함수 추가
# jkl012 feat: 데이터베이스 연결

# Interactive rebase 실행
git rebase -i main

# 편집기가 열림:
# pick jkl012 feat: 데이터베이스 연결
# pick ghi789 feat: 쿼리 함수 추가
# pick def456 chore: TODO 주석
# pick abc123 feat: 쿼리 최적화
#
# Commands:
# p, pick = 커밋 사용
# r, reword = 커밋 메시지 수정
# e, edit = 커밋 편집
# s, squash = 이전 커밋과 합치기
# f, fixup = squash와 동일하나 메시지 버림
# d, drop = 커밋 제거

# 수정:
pick jkl012 feat: 데이터베이스 연결
squash ghi789 feat: 쿼리 함수 추가
drop def456 chore: TODO 주석
pick abc123 feat: 쿼리 최적화

# 저장하고 종료
```

```bash
# 새 커밋 메시지 입력 요청됨
# feat: 데이터베이스 연결 및 쿼리 함수
# 
# - DB 연결 설정
# - 기본 쿼리 함수 구현

# 저장

# 결과 확인
git log --oneline feature/database ^main
# mno345 feat: 쿼리 최적화
# pqr678 feat: 데이터베이스 연결 및 쿼리 함수
```

**결과**: 4개 커밋 → 2개의 깔끔한 커밋!

### 실습 5: ⚠️ Push 후 Rebase의 위험성 시뮬레이션

```bash
# 원격 저장소 시뮬레이션 (로컬에서 베어 저장소 생성)
cd ..
git init --bare remote-repo.git

cd rebase-practice
git remote add origin ../remote-repo.git
git push -u origin main

# 새 브랜치 작업 후 push
git switch -c feature/api
echo "API 코드" > api.js
git add .
git commit -m "feat: API 엔드포인트"
git push -u origin feature/api
```

```bash
# 다른 개발자가 이 브랜치를 받았다고 가정
cd ..
git clone remote-repo.git developer2
cd developer2
git switch feature/api
git log --oneline

# developer2가 이 브랜치에서 작업 시작
echo "추가 기능" >> api.js
git add .
git commit -m "feat: API 기능 확장"
```

```bash
# 원래 개발자가 rebase 후 force push (❌ 절대 하지 말 것!)
cd ../rebase-practice
git switch feature/api

# main에 새 커밋 추가
git switch main
echo "새 기능" > new-feature.txt
git add .
git commit -m "feat: 새 기능"

# feature/api를 rebase
git switch feature/api
git rebase main

# Force push (위험!)
git push -f origin feature/api
```

```bash
# developer2가 pull 시도
cd ../developer2
git pull

# 에러 발생!
# Your branch and 'origin/feature/api' have diverged
# 히스토리가 꼬여서 충돌 발생
```

**교훈**: 
- Push한 브랜치는 절대 rebase하지 않기
- 로컬 브랜치에서만 rebase 사용
- 공유 브랜치는 merge 사용

### 실습 6: 안전한 Rebase 워크플로우

```bash
cd ..
mkdir safe-rebase
cd safe-rebase
git init

# 초기 설정
echo "# 프로젝트" > README.md
git add .
git commit -m "Initial commit"
git branch -M main

# 로컬 작업 브랜치 (절대 push 안 함!)
git switch -c local/feature

# 여러 실험적 커밋
echo "실험1" > test1.txt
git add .
git commit -m "WIP: 실험1"

echo "실험2" > test2.txt
git add .
git commit -m "WIP: 실험2"

echo "실험3" > test3.txt
git add .
git commit -m "WIP: 실험3"

# 로그 확인
git log --oneline
# abc123 WIP: 실험3
# def456 WIP: 실험2
# ghi789 WIP: 실험1
# jkl012 (main) Initial commit
```

```bash
# main이 업데이트됨
git switch main
echo "main 업데이트" >> README.md
git add .
git commit -m "docs: README 업데이트"

# local/feature를 rebase하고 정리
git switch local/feature
git rebase main

# Interactive rebase로 커밋 정리
git rebase -i main

# 편집기에서:
# pick ghi789 WIP: 실험1
# squash def456 WIP: 실험2
# squash abc123 WIP: 실험3

# 새 메시지:
# feat: 새로운 기능 완성
# 
# 여러 실험을 거쳐 최종 구현 완료

# 결과
git log --oneline
# mno345 (HEAD -> local/feature) feat: 새로운 기능 완성
# pqr678 (main) docs: README 업데이트
# jkl012 Initial commit
```

```bash
# 이제 push할 준비가 된 깔끔한 커밋!
# (실제로는 origin에 push)
git switch main
git merge local/feature
# Fast-forward!

# 브랜치 삭제
git branch -d local/feature
```

### 요약: Rebase 사용 가이드

| 상황 | 사용 방법 | 안전성 |
|------|----------|--------|
| 로컬 브랜치 정리 | ✅ Rebase 사용 | 안전 |
| Push 전 커밋 정리 | ✅ Interactive Rebase | 안전 |
| Push 후 | ❌ Rebase 금지 | 위험 |
| 공유 브랜치 | ❌ Merge 사용 | 안전 |
| Feature 브랜치 (로컬 전용) | ✅ Rebase로 정리 | 안전 |

### 연습 문제 (10분)

1. 새 프로젝트를 만들고 3개의 커밋을 추가하세요
2. 기능 브랜치를 만들어 2개의 WIP 커밋을 만드세요
3. main에 1개의 커밋을 추가하세요
4. 기능 브랜치를 rebase하고 2개의 WIP 커밋을 1개로 squash하세요
5. main에 fast-forward merge하세요

<details>
<summary>정답 보기</summary>

```bash
mkdir rebase-exercise
cd rebase-exercise
git init

echo "v1" > version.txt
git add . && git commit -m "v1"

echo "v2" > version.txt
git add . && git commit -m "v2"

echo "v3" > version.txt
git add . && git commit -m "v3"

git switch -c feature/test
echo "test1" > test.txt
git add . && git commit -m "WIP: test1"

echo "test2" >> test.txt
git add . && git commit -m "WIP: test2"

git switch main
echo "main update" >> version.txt
git add . && git commit -m "main updated"

git switch feature/test
git rebase -i main
# pick 첫번째
# squash 두번째

# 새 메시지: "feat: 테스트 기능 완성"

git switch main
git merge feature/test

git log --oneline --graph
```
</details>

---

## 2부 마무리 퀴즈

1. **Fast-forward merge와 3-way merge의 차이는 무엇인가요?**
2. **Rebase를 사용하면 안 되는 상황은?**
3. **`git log --all --graph --oneline` 명령어의 각 옵션이 하는 일은?**
4. **Branch를 사용하는 가장 큰 이유는?**

<details>
<summary>정답 보기</summary>

1. Fast-forward는 포인터만 이동하고 merge commit이 없음. 3-way는 두 브랜치가 모두 진행되어 merge commit이 생성됨.

2. 이미 원격 저장소에 push한 커밋을 rebase하면 안 됨. 다른 사람과 공유 중인 브랜치도 rebase 금지.

3. `--all`: 모든 브랜치 표시, `--graph`: 그래프로 시각화, `--oneline`: 한 줄로 간단히 표시

4. 독립된 작업 공간을 만들어 메인 코드에 영향 없이 새 기능을 개발하기 위해
</details>

---

## 다음 파트 예고

**3부: 협업 - 함께 코드 만들기**에서는:
- 원격 저장소(GitHub) 사용법
- Push, Pull, Fetch의 차이
- Pull Request 워크플로우
- 충돌 해결 실전 연습

을 다룰 예정입니다!
