# ORM과 DB 연동 (18시간)

## 1. SQL의 탄생과 목적 (2시간)

### 1.1 데이터 관리의 진화 (40분)

**당시의 문제 상황**

```text
// 1970년대 데이터 접근 방식
// 프로그래머가 직접 파일 구조를 다뤄야 했음

// 의사 코드 (Pseudo-code)
파일_열기("employees.txt")
레코드_찾기(위치_계산(10)) // 프로그래머가 물리적 위치를 직접 계산해야 함
데이터_읽기()
파일_닫기()
```

**문제점:**

- 파일 구조가 바뀌면 모든 프로그램 수정 필요
- Index, Join, 동시성 제어 등을 직접 구현해야 함
- 간단한 데이터 조회에도 비즈니스 분석가가 프로그래머에게 매번 요청
- '연봉 5천 이상' 같은 조건 검색 시 파일 전체 스캔 필요
- 동시 접속 시 파일 깨짐 발생

### 1.2 SQL의 혁명적 아이디어 (30분)

**Edgar Codd의 관계형 모델 (1970)**

핵심 아이디어:

> "비즈니스 사람들이 프로그래밍 없이 직접 데이터를 조회할 수 있게 하자"

**SQL의 설계 철학:**

sql

```sql
-- HOW(어떻게)가 아닌 WHAT(무엇을)만 선언

SELECT name, salary
FROM employees
WHERE department = 'Engineering'
  AND salary > 100000
  AND years_of_service > 5;

-- 결과:
-- - 3일 걸리던 작업이 즉시 완료
-- - 비프로그래머도 사용 가능
-- - 요구사항 변경 시 쿼리만 수정
```

**SQL의 설계 목표:**

- **Imperative(명령형):** "파일을 열고, 10번째 줄로 가서, 읽어와라" (HOW)
- **Declarative(선언형):** "연봉 5천 이상인 사람을 줘" (WHAT) -> **SQL**
- 사용자: '비즈니스 분석가, 비프로그래머'
- 목적: '데이터 조회 및 간단한 변경'
- 철학: '선언적 - 무엇을 원하는지만 명시'
- 목표가 아닌 것들
  - '복잡한 비즈니스 로직 구현',
  - '워크플로우 제어',
  - '범용 계산',
  - 'Turing completeness'

### 1.3 선언적 vs 명령형 (30분)

**실습: 같은 작업, 다른 접근**

```javascript
// 문제: "부서별 평균 연봉을 구하고, 평균보다 높은 직원 찾기"

// ===== SQL 방식 (선언적) =====
// SELECT e.name, e.salary, d.avg_salary
// FROM employees e
// JOIN (
//   SELECT department, AVG(salary) as avg_salary
//   FROM employees
//   GROUP BY department
// ) d ON e.department = d.department
// WHERE e.salary > d.avg_salary;

// 특징:
// ✅ 비프로그래머도 읽을 수 있음 (영어에 가까움)
// ✅ 어떻게 계산할지 명시하지 않음 (DB가 최적화)
// ❌ 복잡한 로직 추가 어려움
// ❌ 재사용, 합성 제한적

// ===== JavaScript 방식 (명령형) =====
function getAboveAverageEmployees(employees) {
  // 1단계: 부서별 평균 계산
  const avgByDept = {};

  for (const emp of employees) {
    if (!avgByDept[emp.department]) {
      avgByDept[emp.department] = { sum: 0, count: 0 };
    }
    avgByDept[emp.department].sum += emp.salary;
    avgByDept[emp.department].count += 1;
  }

  for (const dept in avgByDept) {
    avgByDept[dept] = avgByDept[dept].sum / avgByDept[dept].count;
  }

  // 2단계: 평균보다 높은 직원 필터
  return employees.filter((emp) => emp.salary > avgByDept[emp.department]);
}

// 특징:
// ✅ 정확히 어떻게 계산되는지 명시
// ✅ 복잡한 로직 추가 쉬움
// ✅ 재사용, 테스트, 합성 가능
// ❌ 최적화는 직접 구현해야 함
```

**토론 주제:**

- 각 방식의 장단점은?
- 어떤 상황에서 어떤 방식이 적합한가?
- SQL이 "프로그래밍 언어"인가?

### 1.4 왜 다른 언어가 필요했나 (30분)

**초기 시대 (1970-80년대): SQL로 충분했음**

```sql
-- 단순한 애플리케이션
-- Terminal에서 직접 SQL 실행

> SELECT * FROM orders WHERE customer_id = 123;
> UPDATE orders SET status = 'shipped' WHERE id = 456;

-- "조회하고 출력"이 전부
-- 복잡한 로직 없음
```

**애플리케이션이 복잡해지면서 (1990년대~)**

```javascript
// 예: "주문 처리" 비즈니스 로직

// SQL로 시도하면?
// -- 1. 재고 확인
// SELECT stock FROM products WHERE id = ?;

// -- 2. 재고가 충분하면 주문 생성
// --    문제: "충분하면"이라는 조건을 어떻게 표현?
// --    SQL에는 IF문이 없음!

// -- 3. 재고 감소
// UPDATE products SET stock = stock - ? WHERE id = ?;

// -- 4. 주문 생성
// INSERT INTO orders ...;

// -- 5. 결제 처리 (외부 API)
// --    문제: SQL에서 HTTP 호출 불가능!

// -- 6. 이메일 발송
// --    문제: SQL에서 SMTP 불가능!

// -- 7. 에러 발생 시 롤백?
// --    문제: 일부는 DB, 일부는 외부 시스템
```

**해결책: 범용 언어로 로직 작성**

```javascript
async function processOrder(orderId, userId) {
  // 복잡한 제어 흐름 표현 가능
  const order = await getOrder(orderId);
  const user = await getUser(userId);

  // 조건 분기
  if (!user.hasPaymentMethod) {
    return { error: "No payment method" };
  }

  if (user.isPremium) {
    order.discount = 0.1;
  }

  // 재고 확인
  const hasStock = await checkStock(order.items);
  if (!hasStock) {
    return { error: "Out of stock" };
  }

  // 외부 API 호출
  const paymentResult = await stripe.charge(order.total);
  if (!paymentResult.success) {
    throw new Error("Payment failed");
  }

  // 여러 DB 작업을 하나의 워크플로우로
  await updateStock(order.items);
  await createShipment(order);
  await sendEmail(user.email, "Order confirmed");
  await logEvent("order_processed", { orderId, userId });

  return { success: true, order };
}
```

**SQL로는 불가능한 것들:**

- 외부 API 호출 (결제, 이메일 등)
- 복잡한 조건 분기와 제어 흐름
- 에러 처리 및 복구 로직
- 비동기 워크플로우
- 상태 관리 및 컨텍스트 유지

---

## 2. SQL 기초와 관계형 DB 개념 (3시간)

### 2.1 실습 환경 설정 (30분)

**SQLite 설정**

```bash
# SQLite 설치 (이미 설치되어 있을 가능성 높음)
sqlite3 --version

# 실습용 DB 생성
sqlite3 blog.db
```

**Node.js에서 SQLite 사용**

```bash
npm install sqlite3
```

```javascript
// db.js
const sqlite3 = require("sqlite3").verbose();
const db = new sqlite3.Database("./blog.db");

// 테이블 생성
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT,
      author_id INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (author_id) REFERENCES users(id)
    )
  `);
});

module.exports = db;
```

### 2.2 기본 CRUD 연산 (1시간)

**CREATE (삽입)**

```javascript
// SQL 직접 작성
const db = require("./db");

// 사용자 생성
function createUser(name, email) {
  return new Promise((resolve, reject) => {
    db.run(
      "INSERT INTO users (name, email) VALUES (?, ?)",
      [name, email],
      function (err) {
        if (err) reject(err);
        else resolve({ id: this.lastID });
      }
    );
  });
}

// 사용 예시
createUser("홍길동", "hong@example.com")
  .then((result) => console.log("Created user:", result))
  .catch((err) => console.error("Error:", err));
```

**READ (조회)**

```javascript
// 단일 조회
function getUser(id) {
  return new Promise((resolve, reject) => {
    db.get("SELECT * FROM users WHERE id = ?", [id], (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
}

// 목록 조회
function getAllUsers() {
  return new Promise((resolve, reject) => {
    db.all("SELECT * FROM users ORDER BY created_at DESC", [], (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
}

// 조건부 조회
function searchUsers(keyword) {
  return new Promise((resolve, reject) => {
    db.all(
      "SELECT * FROM users WHERE name LIKE ? OR email LIKE ?",
      [`%${keyword}%`, `%${keyword}%`],
      (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      }
    );
  });
}
```

**UPDATE (수정)**

```javascript
function updateUser(id, name, email) {
  return new Promise((resolve, reject) => {
    db.run(
      "UPDATE users SET name = ?, email = ? WHERE id = ?",
      [name, email, id],
      function (err) {
        if (err) reject(err);
        else resolve({ changes: this.changes });
      }
    );
  });
}
```

**DELETE (삭제)**

```javascript
function deleteUser(id) {
  return new Promise((resolve, reject) => {
    db.run("DELETE FROM users WHERE id = ?", [id], function (err) {
      if (err) reject(err);
      else resolve({ changes: this.changes });
    });
  });
}
```

**실습 과제 1: 블로그 API 만들기**

```javascript
// 학생들이 구현할 함수들
// posts 테이블에 대한 CRUD

async function createPost(title, content, authorId) {
  // TODO: 게시글 생성
}

async function getPost(id) {
  // TODO: 게시글 조회
  // 작성자 정보도 함께 (JOIN 사용)
}

async function updatePost(id, title, content) {
  // TODO: 게시글 수정
}

async function deletePost(id) {
  // TODO: 게시글 삭제
}
```

### 2.3 JOIN과 관계 (1시간)

**문제 상황**

```javascript
// 게시글과 작성자 정보를 함께 조회하고 싶다

// 방법 1: 두 번의 쿼리 (비효율적)
const post = await getPost(1);
const author = await getUser(post.author_id);

console.log({
  title: post.title,
  content: post.content,
  authorName: author.name,
  authorEmail: author.email,
});

// 방법 2: JOIN 사용 (효율적)
```

**JOIN의 종류**

```sql
-- INNER JOIN: 양쪽 모두 매칭되는 것만
SELECT p.*, u.name as author_name, u.email as author_email
FROM posts p
INNER JOIN users u ON p.author_id = u.id;

-- LEFT JOIN: 왼쪽은 전부, 오른쪽은 매칭되는 것만
SELECT p.*, u.name as author_name
FROM posts p
LEFT JOIN users u ON p.author_id = u.id;
-- 작성자가 없는(삭제된) 게시글도 포함
```

**JavaScript에서 JOIN 결과 처리**

```javascript
function getPostWithAuthor(postId) {
  return new Promise((resolve, reject) => {
    db.get(
      `SELECT 
        p.id, p.title, p.content, p.created_at,
        u.id as author_id, u.name as author_name, u.email as author_email
       FROM posts p
       LEFT JOIN users u ON p.author_id = u.id
       WHERE p.id = ?`,
      [postId],
      (err, row) => {
        if (err) {
          reject(err);
        } else if (!row) {
          resolve(null);
        } else {
          // 결과를 구조화
          resolve({
            id: row.id,
            title: row.title,
            content: row.content,
            createdAt: row.created_at,
            author: row.author_id
              ? {
                  id: row.author_id,
                  name: row.author_name,
                  email: row.author_email,
                }
              : null,
          });
        }
      }
    );
  });
}
```

SQL을 직접 작성하면 겪는 고통

- SQL 문자열 작성의 번거로움
- JOIN 결과를 객체로 변환하는 수고
- 중복 코드 (에러 처리, Promise 래핑 등)
- 컬럼명 충돌 (id, name 등)

**"더 나은 방법은 없을까?"**

### 2.4 실습: SQL 지옥 체험 (30분)

**과제: 댓글 기능 추가**

```javascript
// 1. 댓글 테이블 생성
db.run(`
  CREATE TABLE comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    post_id INTEGER,
    author_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (author_id) REFERENCES users(id)
  )
`);

// 2. 게시글 + 작성자 + 댓글 목록 + 각 댓글 작성자
// 이걸 어떻게 조회할까?

async function getPostFull(postId) {
  // 방법 1: 여러 번의 쿼리 (N+1 문제)
  const post = await getPostWithAuthor(postId);
  const comments = await new Promise((resolve, reject) => {
    db.all(
      "SELECT * FROM comments WHERE post_id = ?",
      [postId],
      (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      }
    );
  });

  for (const comment of comments) {
    comment.author = await getUser(comment.author_id);
    // 댓글이 100개면 100번의 추가 쿼리!
  }

  post.comments = comments;
  return post;

  // 방법 2: 복잡한 JOIN (결과 처리가 복잡)
  // LEFT JOIN comments + LEFT JOIN users (for comment authors)
  // 결과가 flat하게 나와서 직접 구조화해야 함
}
```

SQL을 직접 작성하면 겪는 고통

- Callback hell / Promise 지옥
- SQL 문자열 관리의 어려움
- N+1 문제 (성능 이슈)
- 결과를 객체로 변환하는 번거로움
- 에러 처리 중복
- 테스트의 어려움

> "여러분이 지금 겪고 있는 불편함, 이게 바로 ORM이 해결하려는 문제입니다."

---

## 3. Impedance Mismatch의 이해 (3시간)

- 코드는 **객체(Object)**, DB는 **테이블(Table)**
- 이 간극을 메우기 위해 개발자가 고통받음 (SQL 문자열 작성, 타입 변환 등)

### 3.1 두 세계의 충돌 (1시간)

**문제 제기**

```javascript
// 코드에서 생각하는 방식
class Post {
  constructor(title, content, author) {
    this.title = title;
    this.content = content;
    this.author = author; // User 객체
    this.comments = []; // Comment 배열
  }

  addComment(comment) {
    this.comments.push(comment);
  }
}

// vs

// DB에서 저장하는 방식
// posts 테이블:
// | id | title | content | author_id |

// comments 테이블:
// | id | content | post_id | author_id |
```

**핵심 질문:**

- 코드의 `author` (객체)와 DB의 `author_id` (숫자)는 어떻게 연결되나?
- 코드의 `comments` (배열)는 DB에 어떻게 표현되나?
- 이 "틈(mismatch)"을 누가 메우나?

**시각적 표현**

```
[코드 세계]              [DB 세계]
Post 객체                posts 테이블
  ├─ title                ├─ id
  ├─ content              ├─ title
  └─ author: User         ├─ content
       ├─ name            └─ author_id (FK)
       └─ email                 ↓
  └─ comments: []         users 테이블
       └─ Comment[]            ├─ id
            ├─ content         ├─ name
            └─ author          └─ email

                          comments 테이블
                          ├─ id
                          ├─ content
                          ├─ post_id (FK)
                          └─ author_id (FK)

"이 틈을 어떻게 메울까?"
```

### 3.2 표현력의 차이 (1시간)

**왜 SQL은 JavaScript보다 표현력이 떨어질까?**

**1. Turing Incomplete**

```javascript
// JS: 피보나치 수열 (자연스러움)
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

// SQL: 피보나치 수열 (부자연스러움)
// WITH RECURSIVE fib(n, curr, next) AS (
//   SELECT 1, 0, 1
//   UNION ALL
//   SELECT n+1, next, curr+next
//   FROM fib
//   WHERE n < 10
// )
// SELECT * FROM fib;

// 이게 "조회 언어"의 목적인가?
```

**2. 제어 흐름의 제약**

```javascript
// JS: 복잡한 할인 로직
function calculateDiscount(user, order) {
  if (!user.isPremium) {
    return 0;
  }

  if (order.amount > 1000) {
    return order.amount * 0.2; // 20% 할인
  } else if (order.amount > 500) {
    return order.amount * 0.1; // 10% 할인
  } else {
    return 0;
  }
}

// SQL: CASE 지옥
// SELECT
//   order_id,
//   amount,
//   CASE
//     WHEN users.is_premium = 0 THEN 0
//     WHEN amount > 1000 THEN amount * 0.2
//     WHEN amount > 500 THEN amount * 0.1
//     ELSE 0
//   END as discount
// FROM orders
// JOIN users ON orders.user_id = users.id;

// 문제:
// 1. 읽기 어려움
// 2. 재사용 불가능
// 3. 테스트 어려움
```

**3. 합성(Composition) 불가능**

```javascript
// JS: 함수 합성
const isActive = (user) => user.status === "active";
const isPremium = (user) => user.plan === "premium";
const hasEmail = (user) => user.email != null;

// 조합 가능
const eligibleUsers = users.filter(isActive).filter(isPremium).filter(hasEmail);

// 각 조건을 독립적으로 테스트하고 재사용

// SQL: 합성 불가능
// SELECT * FROM users
// WHERE status = 'active'
//   AND plan = 'premium'
//   AND email IS NOT NULL;

// 조건을 분리해서 재사용? 불가능
// 매번 전체 WHERE절을 다시 작성
```

**4. 상태 관리 불가**

```javascript
// JS: 상태를 유지하며 처리
class OrderProcessor {
  constructor() {
    this.processed = new Set();
  }

  process(order) {
    if (this.processed.has(order.id)) {
      console.log("Already processed");
      return;
    }

    // 처리 로직
    this.processed.add(order.id);
  }
}

// SQL: 상태 개념 없음
// 매번 독립적인 쿼리
// 워크플로우를 표현할 방법이 없음
```

**정리: 언어의 능력 스펙트럼**

```javascript
// Turing Complete (범용)
// JavaScript, Python, Java, Go...
const 명령형_언어 = {
  패러다임: "어떻게(HOW)",
  합성: "가능",
  추상화: "계층적",
  상태: "있음",
  제어흐름: "자유로움",
};

// Turing Incomplete (특수 목적)
// SQL, GraphQL, HTML, CSS...
const 선언형_SQL = {
  패러다임: "무엇을(WHAT)",
  합성: "제한적",
  추상화: "거의 없음",
  상태: "없음",
  제어흐름: "CASE문 정도",
};
```

SQL은 **"데이터 조회"**라는 특정 목적에 최적화됐어요. 그 목적에는 완벽하죠. 하지만:

- 복잡한 비즈니스 로직
- 워크플로우
- 재사용 가능한 추상화
- 테스트 가능한 모듈

이런 건 애초에 SQL의 설계 목표가 아니었던 거죠.

그래서 **"저장/조회는 SQL, 로직은 Application"**으로 분리하게 된 거고, 이게 바로 impedance mismatch의 근본 원인이에요.

### 3.3 계층별 목적의 차이 (1시간)

**세 계층의 서로 다른 관점**

```javascript
// 문제: "사용자의 최근 주문 목록"

// ===== Persistence Layer (DB 관점) =====
// 목적: 효율적 저장과 조회
// users 테이블:
//   - 정규화: 중복 제거
//   - Index: 빠른 조회
//   - FK: 무결성 보장

// orders 테이블:
//   - user_id로 관계 표현
//   - created_at에 index

// ===== Domain Layer (비즈니스 로직 관점) =====
class User {
  // 도메인 전문가의 멘탈 모델
  constructor(name, email) {
    this.name = name;
    this.email = email;
    this.orders = [];
  }

  // 비즈니스 규칙
  placeOrder(order) {
    if (this.hasUnpaidOrders()) {
      throw new Error("미결제 주문이 있습니다");
    }
    this.orders.push(order);
  }

  hasUnpaidOrders() {
    return this.orders.some((o) => !o.isPaid);
  }
}

// ===== API Layer (Frontend 편의 관점) =====
// 목적: 화면 그리기 편한 모양
const response = {
  userId: 1,
  userName: "홍길동",
  recentOrders: [
    {
      orderId: 101,
      date: "2024-01-15",
      itemCount: 3, // 계산된 값
      totalAmount: 50000,
      status: "배송중", // 여러 상태의 조합
      estimatedDelivery: "1월 17일", // 계산된 값
    },
  ],
  orderSummary: {
    // 완전히 다른 aggregate
    totalOrders: 15,
    totalSpent: 500000,
  },
};
```

**각 계층에서 발생하는 Mismatch**

**1. Domain ↔ Persistence Mismatch**

```javascript
// Domain: 객체와 행동
class Order {
  constructor(items) {
    this.items = items;
    this.status = "pending";
  }

  calculateTotal() {
    return this.items.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0
    );
  }

  ship() {
    if (this.status !== "paid") {
      throw new Error("결제되지 않은 주문");
    }
    this.status = "shipped";
  }
}

// Persistence: 테이블과 관계
// orders: { id, user_id, status, created_at }
// order_items: { id, order_id, product_id, quantity, price }

// 문제:
// 1. calculateTotal()은 어디 저장? (nowhere, 메서드니까)
// 2. ship()의 검증 로직은? (DB trigger로? 아니면 app에서?)
// 3. items 배열은? (별도 테이블로 분리됨)
```

**2. API ↔ Domain Mismatch**

```javascript
// Frontend 요청 (GraphQL 스타일)
const request = {
  dashboard: {
    recentOrders: {}, // Order aggregate
    popularProducts: {}, // Product aggregate
    userActivity: {}, // Activity aggregate
    notifications: {}, // Notification aggregate
  },
};

// 문제: domain에 "Dashboard"라는 엔티티를 만들어야 하나?
// 이건 순수하게 view를 위한 조합인데...

// Domain 모델
class Order {}
class Product {}
class Activity {}
class Notification {}

// 하지만 "Dashboard"는 domain 개념이 아님
// 그냥 여러 개념을 한 화면에 보여주는 것뿐
```

**실습: Mismatch 경험하기**

```javascript
// 과제: 블로그 "대시보드" 구현

// Frontend가 원하는 형태
const dashboard = {
  // 여러 aggregate를 조합
  myRecentPosts: [], // Post들
  popularPosts: [], // 다른 기준의 Post들
  myComments: [], // Comment들
  notifications: [], // 전혀 다른 개념
  statistics: {
    // 계산된 값들
    totalPosts: 10,
    totalComments: 50,
    totalLikes: 200,
  },
};

// 학생 질문:
// 1. 이걸 하나의 SQL 쿼리로?
// 2. Domain에 Dashboard 클래스 만들어야 하나?
// 3. 각각 따로 조회 후 조합?

// 정답: "상황에 따라 다름"
// 이게 바로 mismatch의 본질
```

**핵심 메시지**

원인: '계층별로 목적이 다르기 때문',

계층별\_목적: {
persistence: '효율적 저장/조회',
domain: '비즈니스 로직, 도메인 규칙',
api: 'Frontend 편의'
},

결과: '경계마다 불일치 발생',

해결: [
'DTO/Mapper로 변환',
'Repository로 persistence 격리',
'API Layer 별도 구성',
'하지만 완벽한 해결은 불가능'
]

---

## 4. ORM의 개념과 장단점 (2시간)

### 4.1 ORM의 등장 (30분)

**문제 상황 재확인**

지금까지 우리가 겪은 고통

'SQL 문자열 반복 작성',
'JOIN 결과를 객체로 변환하는 수고',
'N+1 쿼리 문제',
'Callback hell',
'중복된 에러 처리',
'테스트의 어려움',
'Impedance mismatch'

**ORM의 약속**

```javascript
// "이상적인" 코드를 꿈꾼다

// SQL 대신 객체로
const user = { name: "홍길동", email: "hong@example.com" };
await prisma.user.create({ data: user });

// JOIN 대신 관계 탐색
const userWithPosts = await prisma.user.findUnique({
  where: { id: 1 },
  include: { posts: true },
});

console.log(userWithPosts.posts[0].title);

// 마치 메모리의 객체처럼 다루고 싶다!
```

**ORM (Object-Relational Mapping)이란?**

```
객체(Object) ←→ 관계형 DB(Relational)

        ORM이 중간에서
        자동으로 변환
```

**주요 ORM 라이브러리**

- JavaScript: Prisma, TypeORM, Sequelize
- Python: SQLAlchemy, Django ORM
- Java: Hibernate
- Ruby: ActiveRecord
- Go: GORM

### 4.2 Prisma 시작하기 (30분)

**Prisma란?**

- 차세대 Node.js ORM
- 타입 안전 (JavaScript에서도 자동완성 지원)
- 직관적인 API
- 강력한 마이그레이션 도구

**설치**

```bash
npm install prisma --save-dev
npm install @prisma/client
npx prisma init --datasource-provider sqlite
```

**Prisma Schema 정의 (schema.prisma)**

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "sqlite"
  url      = "file:./blog.db"
}

model User {
  id        Int      @id @default(autoincrement())
  name      String
  email     String   @unique
  createdAt DateTime @default(now())
  posts     Post[]
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  authorId  Int
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
}
```

**마이그레이션 실행**

```bash
# DB 스키마 생성
npx prisma migrate dev --name init

# Prisma Client 생성
npx prisma generate
```

**Prisma Client 사용**

```javascript
// prisma.js
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

module.exports = prisma;
```

**사용 예시**

```javascript
// main.js
const prisma = require("./prisma");

async function main() {
  // 사용자 생성
  const user = await prisma.user.create({
    data: {
      name: "홍길동",
      email: "hong@example.com",
    },
  });
  console.log("Created user:", user);

  // 게시글 생성
  const post = await prisma.post.create({
    data: {
      title: "첫 게시글",
      content: "안녕하세요",
      authorId: user.id,
    },
  });
  console.log("Created post:", post);

  // 사용자와 게시글 함께 조회
  const userWithPosts = await prisma.user.findUnique({
    where: { id: user.id },
    include: { posts: true },
  });
  console.log("User with posts:", userWithPosts);
}

main()
  .catch((e) => console.error(e))
  .finally(async () => {
    await prisma.$disconnect();
  });
```

**학생들의 첫 반응**

> "와... SQL 안 쓰네요?" "자동완성도 되네요!" "이거 편한데요?"

### 4.3 ORM의 근본적 딜레마 (30분)

**ORM의 약속 vs 현실**

```javascript
// 약속: "도메인 객체 중심으로 생각하세요"

// 하지만 Prisma Schema는?
model Student {
  id      Int      @id @default(autoincrement())
  name    String
  courses Course[]  // ← 이게 도메인 개념인가, DB 관계인가?
}

model Course {
  id       Int       @id @default(autoincrement())
  title    String
  students Student[]
}

// 중간 테이블이 자동으로 생성됨
// 이건 명백히 DB persistence 개념
```

**문제 1: Persistence 개념의 노출**

```javascript
// 순수한 도메인 모델이라면
class Course {
  constructor() {
    this.students = [];
  }

  enroll(student) {
    if (this.isFull()) {
      throw new Error("정원 초과");
    }
    // 도메인 로직...
  }

  isFull() {
    return this.students.length >= this.maxStudents;
  }
}

// Prisma로 조회하면?
const course = await prisma.course.findUnique({
  where: { id: 1 },
  include: { students: true },
});

// course.students는 단순 배열
// isFull(), enroll() 같은 도메인 메서드는?
// 직접 구현해야 함
```

**문제 2: 양방향 참조**

```javascript
// Prisma Schema
model Order {
  id    Int         @id @default(autoincrement())
  items OrderItem[]  // 순방향
}

model OrderItem {
  id      Int   @id @default(autoincrement())
  orderId Int
  order   Order @relation(fields: [orderId], references: [id])  // 역방향
}

// 질문: OrderItem이 Order를 알아야 할 도메인 이유가 있나?
// 답: 없다. 이건 ORM이 관계를 추적하기 위한 것
```

**문제 3: 도메인 불변식 보장 어려움**

```javascript
// 불변식: balance는 항상 transactions의 합이어야 함

model Account {
  id           Int           @id @default(autoincrement())
  balance      Float
  transactions Transaction[]
}

model Transaction {
  id        Int     @id @default(autoincrement())
  amount    Float
  accountId Int
  account   Account @relation(fields: [accountId], references: [id])
}

// 문제: balance와 transactions를 독립적으로 수정 가능
const account = await prisma.account.update({
  where: { id: 1 },
  data: { balance: 1000 }  // 이렇게 직접 수정하면 불변식 깨짐
})

// 도메인 로직으로 보호해야 함
async function deposit(accountId, amount) {
  // Transaction에서 처리
  await prisma.$transaction(async (tx) => {
    await tx.transaction.create({
      data: { accountId, amount }
    })
    await tx.account.update({
      where: { id: accountId },
      data: { balance: { increment: amount } }
    })
  })
}
```

**실습: ORM의 함정 경험하기**

```javascript
// 겉보기에 간단한 코드
const users = await prisma.user.findMany();

for (const user of users) {
  console.log(user.name, user.posts.length); // Error! posts가 없음
}

// include를 빼먹으면 관계가 로드되지 않음
const usersWithPosts = await prisma.user.findMany({
  include: { posts: true },
});

// 그런데 이것도 N+1 문제가 생길 수 있음
for (const user of usersWithPosts) {
  for (const post of user.posts) {
    console.log(post.comments.length); // Error! comments 안 가져옴
  }
}

// 중첩 include 필요
const usersComplete = await prisma.user.findMany({
  include: {
    posts: {
      include: {
        comments: true,
      },
    },
  },
});
```

### 4.4 ORM의 장단점 정리 (30분)

**장점**

```javascript
// 1. 생산성 향상
// SQL 직접 작성
db.query(
  "INSERT INTO users (name, email) VALUES (?, ?)",
  [name, email],
  (err, result) => {
    /* ... */
  }
);

// Prisma 사용
const user = await prisma.user.create({
  data: { name, email },
});

// 2. 타입 안전성 (자동완성)
const user = await prisma.user.findUnique({ where: { id: 1 } });
user.name; // 자동 완성
user.unknown; // Error: Property 'unknown' does not exist

// 3. 관계 처리 간편
const userWithPosts = await prisma.user.findUnique({
  where: { id: 1 },
  include: { posts: true },
});

// 4. DB 종류에 독립적 (이론상)
// schema.prisma의 provider만 바꾸면 됨

// 5. 기본적인 보안 (SQL Injection 방지)
// Parameterized query 자동 사용
```

**단점**

```javascript
// 1. 성능 최적화 어려움
// 복잡한 쿼리는 결국 Raw SQL 필요
await prisma.$queryRaw`
  SELECT ...
  FROM ...
  WHERE ...
`;

// 2. 학습 곡선
// SQL + Prisma Schema + Prisma API
// 모두 알아야 함

// 3. 추상화의 누수 (Leaky Abstraction)
// Prisma가 SQL을 감추지만,
// 결국 SQL을 알아야 제대로 쓸 수 있음

// 4. 유연성 제한
// 복잡한 쿼리나 특수한 최적화는 어려움

// 5. 마법 같은 동작
// 뒤에서 무슨 일이 일어나는지 모르면 위험
```

**언제 Prisma를 쓸까? 언제 쓰지 말까?**

```javascript
// Prisma 사용 권장
const 적합한_경우 = {
  상황: [
    "간단한 CRUD",
    "프로토타이핑",
    "Admin 페이지",
    "복잡하지 않은 관계",
    "타입 안전성이 중요한 프로젝트",
  ],
  이유: "생산성 > 성능 최적화",
};

// Raw SQL 사용 권장
const 부적합한_경우 = {
  상황: [
    "복잡한 통계 쿼리",
    "대용량 배치 처리",
    "고도의 성능 최적화 필요",
    "복잡한 조인 및 집계",
  ],
  이유: "Prisma로는 표현 제한적",
};
```

**핵심 메시지**

```javascript
const prisma_진실 = {
  약속: "객체처럼 쓸 수 있다",
  현실: "SQL을 생성하는 도구일 뿐",

  권고: [
    "Prisma는 편리하지만 완벽하지 않다",
    "SQL을 몰라도 되는 게 아니라, 잘 알아야 Prisma를 잘 쓴다",
    "Prisma는 trade-off다",
    "도메인 모델 ≠ Prisma Model (혼동하지 말 것)",
  ],
};
```

---

## 5. 모델 정의와 마이그레이션 (2시간)

### 5.0 환경 설정과 보안 (30분)

**하드코딩의 위험성**

- DB URL, 비밀번호 등을 코드에 직접 적으면(Hardcoding) GitHub 해킹 시 DB가 털림.
- **해결책:** 환경 변수(`.env`) 사용.

**.env 파일 설정**

```env
# .env 파일 생성 (git에 커밋하지 않음!)
DATABASE_URL="file:./dev.db"
```

**Prisma Schema 수정**

```prisma
datasource db {
  provider = "sqlite"
  // url      = "file:./dev.db"  <-- (X) 위험!
  url      = env("DATABASE_URL") // <-- (O) 안전
}
```

**.gitignore 설정**

```gitignore
node_modules
.env  <-- 필수 추가
*.db
```

### 5.1 Prisma Schema 정의 (1시간)

**기본 Model**

```prisma
// schema.prisma

model User {
  id        Int      @id @default(autoincrement())
  name      String
  email     String   @unique
  bio       String?  // nullable
  phone     String?
  status    String   @default("active")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

**다양한 필드 타입**

```prisma
model Product {
  id          Int      @id @default(autoincrement())
  name        String
  description String?

  // 숫자
  price       Float
  stock       Int

  // Boolean
  isAvailable Boolean  @default(true)

  // JSON
  metadata    Json?

  // Enum
  status      Status   @default(DRAFT)

  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}

enum Status {
  DRAFT
  PUBLISHED
  ARCHIVED
}
```

**Index와 제약조건**

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  status    String
  createdAt DateTime @default(now())

  // 복합 인덱스
  @@index([status, createdAt])
  // 복합 유니크
  @@unique([email, name])
}
```

**실습: Prisma Schema 정의하기**

```prisma
// 과제: 블로그 시스템의 Model 정의

// 1. User
// - id, name, email, password
// - bio (nullable)
// - role (ADMIN, USER) enum
// - createdAt

// 2. Post
// - id, title, content
// - status (DRAFT, PUBLISHED) enum
// - viewCount (기본값 0)
// - publishedAt (nullable)
// - createdAt, updatedAt

// 3. Comment
// - id, content
// - createdAt

// 4. Tag
// - id, name (unique)
// - createdAt

// TODO: 학생들이 직접 작성
```

### 5.2 마이그레이션 (1시간)

**왜 마이그레이션이 필요한가?**

```prisma
// 초기 User 모델
model User {
  id   Int    @id @default(autoincrement())
  name String
}

// 나중에 email 필드 추가
model User {
  id    Int    @id @default(autoincrement())
  name  String
  email String  // ← 기존 DB에는 이 컬럼이 없음!
}

// 문제:
// 1. 기존 데이터는?
// 2. 팀원들 DB는?
// 3. 프로덕션 DB는?

// 해결책: 마이그레이션
```

**마이그레이션 생성 및 실행**

```bash
# 마이그레이션 생성 (schema 변경 감지)
npx prisma migrate dev --name add_email_to_user

# 생성되는 파일: prisma/migrations/20240101000000_add_email_to_user/migration.sql
```

**생성된 마이그레이션 파일**

```sql
-- prisma/migrations/20240101000000_add_email_to_user/migration.sql

-- AlterTable
ALTER TABLE "User" ADD COLUMN "email" TEXT;
```

**마이그레이션 명령어**

```bash
# 개발 환경: 마이그레이션 생성 및 적용
npx prisma migrate dev --name migration_name

# 프로덕션 환경: 마이그레이션만 적용
npx prisma migrate deploy

# 마이그레이션 상태 확인
npx prisma migrate status

# 마이그레이션 리셋 (개발 시에만!)
npx prisma migrate reset
```

**실습: 마이그레이션 작성**

```prisma
// 시나리오: Post 모델에 slug 필드 추가

// 1. Schema 수정
model Post {
  id      Int    @id @default(autoincrement())
  title   String
  content String?
  slug    String @unique  // 추가
}

// 2. 마이그레이션 생성
// npx prisma migrate dev --name add_slug_to_post

// 3. 생성된 migration.sql 확인
```

**복잡한 마이그레이션 처리**

```sql
-- 기존 데이터가 있을 때 NOT NULL 컬럼 추가

-- Step 1: Nullable로 추가
ALTER TABLE "Post" ADD COLUMN "slug" TEXT;

-- Step 2: 기존 데이터에 값 설정
UPDATE "Post" SET "slug" = LOWER(REPLACE("title", ' ', '-')) || '-' || "id";

-- Step 3: NOT NULL 제약 추가
ALTER TABLE "Post" ALTER COLUMN "slug" SET NOT NULL;

-- Step 4: UNIQUE 제약 추가
CREATE UNIQUE INDEX "Post_slug_key" ON "Post"("slug");
```

**마이그레이션 베스트 프랙티스**

```javascript
// 1. 작은 단위로 나누기
// ✅ 좋은 예: 각 변경사항마다 별도 마이그레이션
// npx prisma migrate dev --name add_email
// npx prisma migrate dev --name add_role
// npx prisma migrate dev --name add_indexes

// ❌ 나쁜 예: 한 번에 여러 테이블 변경
// 문제 생기면 어디서 문제인지 파악 어려움

// 2. 기존 데이터 고려
// NOT NULL 추가 시 기본값 설정
// UNIQUE 추가 전 중복 데이터 정리

// 3. 롤백 불가능
// Prisma 마이그레이션은 기본적으로 롤백 미지원
// 새로운 마이그레이션으로 되돌리기

// 4. 프로덕션 적용 전 테스트
// 개발 환경에서 충분히 테스트 후 배포
```

**Prisma Studio로 데이터 확인**

```bash
# GUI로 DB 데이터 확인 및 수정
npx prisma studio
```

### 5.3 데이터 시딩 (Seeding) (30분)

**더미 데이터의 필요성**

- 개발할 때마다 `INSERT` 쿼리를 치거나 API를 호출하는 것은 비효율적.
- 초기 데이터를 자동으로 넣어주는 스크립트 필요.

**Seed 스크립트 작성**

```javascript
// prisma/seed.js
// prisma/seed.js
import { prisma } from "./prisma.js";

async function main() {
  // 기존 데이터 삭제 (초기화)
  console.log("Delete previous data");
  await prisma.article.deleteMany();

  // 더미 데이터 생성
  console.log("Seed dummies");
  const payload = await prisma.article.createMany({
    data: [
      {
        title: "title1",
        content: "content1",
      },
      {
        title: "title2",
        content: "content2",
      },
      {
        title: "title3",
        content: "content3",
      },
    ],
  });

  console.log(payload.count, " dummies seeded");
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
```

**설정 및 실행**

```ts
// prisma.config.ts
import "dotenv/config";
import { defineConfig, env } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
    seed: "node prisma/seed.js",
  },
  datasource: {
    url: env("DATABASE_URL"),
  },
});
```

```bash
# 시딩 실행
npx prisma db seed
```

---

## 6. CRUD 연산 (2시간)

### 6.1 Create (생성) (30분)

**기본 생성**

```javascript
const prisma = require("./prisma");

// 단일 생성
const user = await prisma.user.create({
  data: {
    name: "홍길동",
    email: "hong@example.com",
  },
});
console.log("Created user:", user);

// 여러 개 생성
const users = await prisma.user.createMany({
  data: [
    { name: "김철수", email: "kim@example.com" },
    { name: "이영희", email: "lee@example.com" },
    { name: "박민수", email: "park@example.com" },
  ],
});
console.log(`Created ${users.count} users`);

// createMany는 생성된 객체를 반환하지 않음
// 생성 개수만 반환
```

**관계와 함께 생성**

```javascript
// 기존 User 참조해서 Post 생성
const post = await prisma.post.create({
  data: {
    title: "첫 게시글",
    content: "안녕하세요",
    authorId: 1, // 기존 User의 ID
  },
});

// User와 Post를 동시에 생성 (Nested Create)
const userWithPost = await prisma.user.create({
  data: {
    name: "새 사용자",
    email: "new@example.com",
    posts: {
      create: [
        { title: "게시글 1", content: "내용 1" },
        { title: "게시글 2", content: "내용 2" },
      ],
    },
  },
  include: {
    posts: true, // 생성된 posts도 함께 반환
  },
});
console.log(userWithPost);
```

**조건부 생성 (Upsert)**

```javascript
// 있으면 업데이트, 없으면 생성
const user = await prisma.user.upsert({
  where: { email: "hong@example.com" },
  update: { name: "홍길동(수정)" },
  create: { name: "홍길동", email: "hong@example.com" },
});
```

### 6.2 Read (조회) (30분)

**기본 조회**

```javascript
// 전체 조회
const users = await prisma.user.findMany();

// 조건 조회
const activeUsers = await prisma.user.findMany({
  where: { status: "active" },
});

// 단일 조회
const user = await prisma.user.findUnique({
  where: { id: 1 },
});

// 또는 이메일로
const userByEmail = await prisma.user.findUnique({
  where: { email: "hong@example.com" },
});

// 첫 번째 결과만
const firstUser = await prisma.user.findFirst({
  where: { status: "active" },
  orderBy: { createdAt: "desc" },
});
```

**여러 조건**

```javascript
// AND 조건 (기본)
const users = await prisma.user.findMany({
  where: {
    status: "active",
    email: { contains: "@example.com" },
  },
});

// OR 조건
const users = await prisma.user.findMany({
  where: {
    OR: [{ status: "active" }, { status: "pending" }],
  },
});

// NOT 조건
const users = await prisma.user.findMany({
  where: {
    NOT: { status: "banned" },
  },
});

// 복합 조건
const users = await prisma.user.findMany({
  where: {
    AND: [
      { status: "active" },
      {
        OR: [
          { email: { contains: "@gmail.com" } },
          { email: { contains: "@naver.com" } },
        ],
      },
    ],
  },
});
```

**필터 연산자**

```javascript
// 문자열 검색
const users = await prisma.user.findMany({
  where: {
    name: {
      contains: "길동", // LIKE '%길동%'
      startsWith: "홍", // LIKE '홍%'
      endsWith: "동", // LIKE '%동'
    },
  },
});

// 숫자 비교
const posts = await prisma.post.findMany({
  where: {
    viewCount: {
      gt: 100, // greater than
      gte: 100, // greater than or equal
      lt: 1000, // less than
      lte: 1000, // less than or equal
    },
  },
});

// 배열 검색
const users = await prisma.user.findMany({
  where: {
    id: { in: [1, 2, 3, 4, 5] },
  },
});
```

**정렬, 페이지네이션**

```javascript
// 정렬
const users = await prisma.user.findMany({
  orderBy: {
    createdAt: "desc",
  },
});

// 여러 필드로 정렬
const users = await prisma.user.findMany({
  orderBy: [{ status: "asc" }, { createdAt: "desc" }],
});

// 페이지네이션
const users = await prisma.user.findMany({
  skip: 20, // OFFSET
  take: 10, // LIMIT
});

// 페이지네이션 + 전체 개수
const [users, total] = await prisma.$transaction([
  prisma.user.findMany({
    skip: 20,
    take: 10,
  }),
  prisma.user.count(),
]);
console.log(`${users.length} / ${total}`);
```

**특정 필드만 조회**

```javascript
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
    // password 같은 민감한 정보 제외
  },
});
```

**관계 포함 조회**

```javascript
// 관계 자동 로드
const users = await prisma.user.findMany({
  include: {
    posts: true,
  },
});
// users[0].posts 접근 가능

// 선택적으로 필드 지정
const users = await prisma.user.findMany({
  include: {
    posts: {
      select: {
        id: true,
        title: true,
      },
    },
  },
});

// 중첩된 관계
const posts = await prisma.post.findMany({
  include: {
    author: true,
    comments: {
      include: {
        author: true,
      },
    },
  },
});
```

### 6.3 Update (수정) (30분)

**기본 수정**

```javascript
// 단일 수정
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    name: "새 이름",
    email: "new@example.com",
  },
});

// 여러 개 수정
const result = await prisma.user.updateMany({
  where: { status: "pending" },
  data: { status: "active" },
});
console.log(`Updated ${result.count} users`);
```

**부분 수정**

```javascript
// 일부 필드만 수정
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    name: "새 이름",
    // 다른 필드는 그대로 유지
  },
});
```

**증가/감소**

```javascript
// 조회수 증가
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    viewCount: { increment: 1 },
  },
});

// 재고 감소
const product = await prisma.product.update({
  where: { id: 5 },
  data: {
    stock: { decrement: 3 },
  },
});

// 곱하기, 나누기도 가능
const product = await prisma.product.update({
  where: { id: 5 },
  data: {
    price: { multiply: 1.1 }, // 10% 인상
  },
});
```

**관계 업데이트**

```javascript
// Post의 author 변경
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    authorId: 2, // 새 작성자 ID
  },
});

// 또는
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    author: {
      connect: { id: 2 },
    },
  },
});
```

### 6.4 Delete (삭제) (30분)

**기본 삭제**

```javascript
// 단일 삭제
const user = await prisma.user.delete({
  where: { id: 1 },
});
console.log("Deleted user:", user);

// 여러 개 삭제
const result = await prisma.user.deleteMany({
  where: { status: "inactive" },
});
console.log(`Deleted ${result.count} users`);

// 전체 삭제
const result = await prisma.user.deleteMany();
```

**조건부 삭제**

```javascript
// 특정 조건의 사용자만 삭제
const result = await prisma.user.deleteMany({
  where: {
    AND: [
      { status: "inactive" },
      { createdAt: { lt: new Date("2023-01-01") } },
    ],
  },
});
```

### 심화: 데이터를 진짜 지워도 될까? (Soft Delete)

**Hard Delete vs Soft Delete**

- **Hard Delete:** DB에서 `DELETE` (영구 삭제). 복구 불가능.
- **Soft Delete:** `deletedAt` 필드에 날짜 기록. 데이터는 남겨둠.

**Schema 변경**

```prisma
model Post {
  id        Int       @id @default(autoincrement())
  // ... 기존 필드들
  deletedAt DateTime? // null이면 존재, 값이 있으면 삭제됨
}
```

**삭제 구현 (Update 사용)**

```js
// 삭제 (사실은 수정)
const deletedPost = await prisma.post.update({
  where: { id: 1 },
  data: {
    deletedAt: new Date(), // 현재 시간 기록
  },
});
```

**조회 구현 (필터링)**

```js
// 삭제되지 않은 글만 조회
const activePosts = await prisma.post.findMany({
  where: {
    deletedAt: null,
  },
});
```

### 실습: CRUD API 만들기

```javascript
// 과제: Express + Prisma로 RESTful API 구현
const express = require("express");
const prisma = require("./prisma");
const app = express();

app.use(express.json());

// GET /users - 전체 사용자 목록
app.get("/users", async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const [users, total] = await prisma.$transaction([
      prisma.user.findMany({
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      prisma.user.count(),
    ]);

    res.json({
      users,
      total,
      page,
      totalPages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /users/:id - 특정 사용자 조회
app.get("/users/:id", async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: parseInt(req.params.id) },
      include: { posts: true },
    });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /users - 사용자 생성
app.post("/users", async (req, res) => {
  try {
    const user = await prisma.user.create({
      data: req.body,
    });
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// PATCH /users/:id - 사용자 수정
app.patch("/users/:id", async (req, res) => {
  try {
    const user = await prisma.user.update({
      where: { id: parseInt(req.params.id) },
      data: req.body,
    });
    res.json(user);
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "User not found" });
    }
    res.status(400).json({ error: error.message });
  }
});

// DELETE /users/:id - 사용자 삭제
app.delete("/users/:id", async (req, res) => {
  try {
    await prisma.user.delete({
      where: { id: parseInt(req.params.id) },
    });
    res.status(204).send();
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "User not found" });
    }
    res.status(400).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

---

## 7. 관계 설정 (1:N, N:M) (2시간)

### 7.1 One-to-Many / Many-to-One (1시간)

**개념**

```
User (1) ←→ (N) Post
한 명의 사용자는 여러 게시글을 작성할 수 있다
각 게시글은 한 명의 작성자를 가진다
```

**Schema 정의**

```prisma
// schema.prisma

model User {
  id    Int    @id @default(autoincrement())
  name  String
  email String @unique
  posts Post[]  // 1:N 관계
}

model Post {
  id       Int    @id @default(autoincrement())
  title    String
  content  String?
  authorId Int
  author   User   @relation(fields: [authorId], references: [id])
}
```

**생성**

```javascript
// 방법 1: 기존 User 참조
const post = await prisma.post.create({
  data: {
    title: "새 게시글",
    content: "내용",
    authorId: 1,
  },
});

// 방법 2: connect 사용
const post = await prisma.post.create({
  data: {
    title: "새 게시글",
    content: "내용",
    author: {
      connect: { id: 1 },
    },
  },
});

// 방법 3: User와 함께 생성 (Nested Create)
const user = await prisma.user.create({
  data: {
    name: "홍길동",
    email: "hong@example.com",
    posts: {
      create: [
        { title: "게시글 1", content: "내용 1" },
        { title: "게시글 2", content: "내용 2" },
      ],
    },
  },
  include: { posts: true },
});
```

**조회**

```javascript
// User의 posts 조회
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: { posts: true },
});
console.log(user.posts); // Post[]

// Post의 author 조회
const post = await prisma.post.findUnique({
  where: { id: 1 },
  include: { author: true },
});
console.log(post.author); // User

// 조건부 include
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: {
    posts: {
      where: { status: "PUBLISHED" },
      orderBy: { createdAt: "desc" },
      take: 5,
    },
  },
});
```

**Cascade 동작**

```prisma
model User {
  id    Int    @id @default(autoincrement())
  posts Post[]
}

model Post {
  id       Int  @id @default(autoincrement())
  authorId Int
  author   User @relation(fields: [authorId], references: [id], onDelete: Cascade)
  // onDelete: Cascade - User 삭제 시 Post도 삭제
  // onDelete: SetNull - User 삭제 시 authorId를 NULL로
  // onDelete: Restrict - User에 Post가 있으면 삭제 불가 (기본값)
}
```

**실습: 댓글 기능 추가**

```prisma
// 과제: Comment 모델 정의
// Post (1) ←→ (N) Comment
// User (1) ←→ (N) Comment

model Comment {
  id        Int      @id @default(autoincrement())
  content   String
  postId    Int
  authorId  Int
  createdAt DateTime @default(now())

  // TODO: Post와의 관계 정의
  // TODO: User(작성자)와의 관계 정의
}

// TODO: Post와 User 모델에 comments 필드 추가
```

```javascript
// API 구현
// POST /posts/:postId/comments - 댓글 작성
app.post("/posts/:postId/comments", async (req, res) => {
  // TODO: 구현
});

// GET /posts/:postId/comments - 댓글 목록
app.get("/posts/:postId/comments", async (req, res) => {
  // TODO: 구현
});

// DELETE /comments/:id - 댓글 삭제
app.delete("/comments/:id", async (req, res) => {
  // TODO: 구현
});
```

### 7.2 Many-to-Many (1시간)

**개념**

```
Post (N) ←→ (M) Tag
하나의 게시글은 여러 태그를 가질 수 있다
하나의 태그는 여러 게시글에 사용될 수 있다

실제 DB 구조:
posts 테이블
tags 테이블
_PostToTag 테이블 (중간 테이블, Prisma가 자동 생성)
  - A (Post ID)
  - B (Tag ID)
```

**Schema 정의**

```prisma
// schema.prisma

model Post {
  id      Int    @id @default(autoincrement())
  title   String
  content String?
  tags    Tag[]   // Many-to-Many
}

model Tag {
  id    Int    @id @default(autoincrement())
  name  String @unique
  posts Post[]  // Many-to-Many
}

// Prisma가 자동으로 _PostToTag 테이블 생성
```

**명시적 중간 테이블 (Extra Columns가 필요한 경우)**

```prisma
model Post {
  id       Int        @id @default(autoincrement())
  title    String
  postTags PostTag[]
}

model Tag {
  id       Int        @id @default(autoincrement())
  name     String     @unique
  postTags PostTag[]
}

model PostTag {
  id        Int      @id @default(autoincrement())
  postId    Int
  tagId     Int
  addedAt   DateTime @default(now())  // 추가 컬럼
  addedBy   Int?                       // 추가 컬럼

  post      Post     @relation(fields: [postId], references: [id])
  tag       Tag      @relation(fields: [tagId], references: [id])

  @@unique([postId, tagId])
}
```

**생성 및 연결**

```javascript
// 방법 1: 기존 Tag 연결
const post = await prisma.post.create({
  data: {
    title: "새 게시글",
    content: "내용",
    tags: {
      connect: [
        { id: 1 }, // 기존 Tag
        { id: 2 },
      ],
    },
  },
});

// 방법 2: Tag 이름으로 연결
const post = await prisma.post.create({
  data: {
    title: "새 게시글",
    content: "내용",
    tags: {
      connect: [{ name: "JavaScript" }, { name: "Node.js" }],
    },
  },
});

// 방법 3: 없으면 생성, 있으면 연결 (connectOrCreate)
const post = await prisma.post.create({
  data: {
    title: "새 게시글",
    content: "내용",
    tags: {
      connectOrCreate: [
        {
          where: { name: "JavaScript" },
          create: { name: "JavaScript" },
        },
        {
          where: { name: "Prisma" },
          create: { name: "Prisma" },
        },
      ],
    },
  },
  include: { tags: true },
});
```

**조회**

```javascript
// Post의 tags 조회
const post = await prisma.post.findUnique({
  where: { id: 1 },
  include: { tags: true },
});
console.log(post.tags);

// Tag의 posts 조회
const tag = await prisma.tag.findUnique({
  where: { name: "JavaScript" },
  include: { posts: true },
});
console.log(tag.posts);

// 특정 태그를 가진 게시글 검색
const posts = await prisma.post.findMany({
  where: {
    tags: {
      some: {
        name: "JavaScript",
      },
    },
  },
  include: { tags: true },
});

// 여러 태그를 모두 가진 게시글 (AND)
const posts = await prisma.post.findMany({
  where: {
    AND: [
      { tags: { some: { name: "JavaScript" } } },
      { tags: { some: { name: "TypeScript" } } },
    ],
  },
});
```

**추가 및 제거**

```javascript
// 태그 추가
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    tags: {
      connect: { name: "React" },
    },
  },
  include: { tags: true },
});

// 태그 제거
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    tags: {
      disconnect: { name: "React" },
    },
  },
  include: { tags: true },
});

// 전체 교체
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    tags: {
      set: [{ id: 1 }, { id: 2 }, { id: 3 }],
    },
  },
});

// 전부 제거
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    tags: {
      set: [],
    },
  },
});
```

**실습: 태그 시스템 구현**

// 과제: 블로그 태그 기능

// 1. Tag 모델 정의 (위에서 정의함)
// 2. Post와 Many-to-Many 관계 설정

```javascript
// 3. API 구현
const express = require("express");
const prisma = require("./prisma");
const app = express();

app.use(express.json());

// POST /tags - 태그 생성
app.post("/tags", async (req, res) => {
  // TODO: 구현
});

// GET /tags - 태그 목록
app.get("/tags", async (req, res) => {
  try {
    const tags = await prisma.tag.findMany({
      include: {
        _count: {
          select: { posts: true },
        },
      },
    });
    res.json(tags);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /tags/:name/posts - 해당 태그의 게시글 목록
app.get("/tags/:name/posts", async (req, res) => {
  // TODO: 구현
});

// POST /posts/:id/tags - 게시글에 태그 추가
app.post("/posts/:id/tags", async (req, res) => {
  // req.body = { tagNames: ['JavaScript', 'Node.js'] }
  try {
    const post = await prisma.post.update({
      where: { id: parseInt(req.params.id) },
      data: {
        tags: {
          connectOrCreate: req.body.tagNames.map((name) => ({
            where: { name },
            create: { name },
          })),
        },
      },
      include: { tags: true },
    });
    res.json(post);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// DELETE /posts/:id/tags/:tagName - 게시글에서 태그 제거
app.delete("/posts/:id/tags/:tagName", async (req, res) => {
  // TODO: 구현
});
```

### 7.3 자기 참조 관계 (Self-Relations) (30분)

**개념: 댓글의 대댓글**

- 댓글(Comment)은 또 다른 댓글(Comment)을 부모로 가질 수 있음.
- 같은 테이블 내에서 관계를 맺음.

**Schema 정의**

```prisma
model Comment {
  id        Int      @id @default(autoincrement())
  content   String

  // 부모 댓글 ID (없으면 최상위 댓글)
  parentId  Int?

  // 부모와의 관계 (자식 입장에서 부모를 봄)
  parent    Comment?  @relation("CommentHistory", fields: [parentId], references: [id])

  // 자식들과의 관계 (부모 입장에서 자식들을 봄)
  children  Comment[] @relation("CommentHistory")
}
```

**사용 예시**

```js
// 대댓글 달기
await prisma.comment.create({
  data: {
    content: "저도 동감합니다!",
    parentId: 1, // 원본 댓글 ID
  },
});

// 댓글과 그 대댓글들 조회
const commentWithReplies = await prisma.comment.findUnique({
  where: { id: 1 },
  include: {
    children: true, // 대댓글 목록 가져오기
  },
});
```

---

## 8. 쿼리 최적화 기초 (2시간)

### 8.1 N+1 문제 (1시간)

**문제 발견**

```javascript
// 겉보기에 간단한 코드
const users = await prisma.user.findMany();

for (const user of users) {
  console.log(user.name, user.posts.length);
  // Error: Cannot read property 'length' of undefined
}

// 왜? include를 안 했으니까

// include 추가
const users = await prisma.user.findMany({
  include: { posts: true },
});

for (const user of users) {
  console.log(user.name, user.posts.length); // 이제 동작
}

// 실행되는 쿼리:
// SELECT ... FROM User ...
// SELECT ... FROM Post WHERE authorId IN (1, 2, 3, ...)
// Prisma는 똑똑하게 IN 절로 최적화!

// 하지만 중첩된 관계에서는?
const users = await prisma.user.findMany({
  include: {
    posts: true,
  },
});

for (const user of users) {
  for (const post of user.posts) {
    console.log(post.comments.length); // Error! comments 안 가져옴
  }
}
```

**N+1 문제란?**

- N개의 레코드를 조회하면서 각각에 대해 추가 쿼리 발생
- Prisma는 기본적으로 IN절을 사용해 최적화하지만
- 중첩된 관계나 복잡한 경우 여전히 발생 가능

**해결 방법: Nested Include**

```javascript
// 중첩 include
const users = await prisma.user.findMany({
  include: {
    posts: {
      include: {
        comments: {
          include: {
            author: true,
          },
        },
      },
    },
  },
});

// 이제 모든 데이터 접근 가능
for (const user of users) {
  console.log(user.name);
  for (const post of user.posts) {
    console.log("  -", post.title);
    for (const comment of post.comments) {
      console.log("    *", comment.author.name, ":", comment.content);
    }
  }
}
```

**Select로 필요한 것만**

```javascript
// include 대신 select 사용
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    posts: {
      select: {
        id: true,
        title: true,
        _count: {
          select: { comments: true },
        },
      },
    },
  },
});

// 각 게시글의 댓글 "수"만 가져옴 (댓글 내용은 안 가져옴)
```

**실습: N+1 문제 찾고 해결하기**

```javascript
// 과제: 다음 코드의 문제점 찾기

// 1. 사용자 목록과 각 사용자의 게시글 수
async function getUsersWithPostCount() {
  const users = await prisma.user.findMany();

  const result = [];
  for (const user of users) {
    const postCount = await prisma.post.count({
      where: { authorId: user.id },
    }); // N+1 문제!
    result.push({
      id: user.id,
      name: user.name,
      postCount,
    });
  }
  return result;
}

// 해결: _count 사용
async function getUsersWithPostCountFixed() {
  const users = await prisma.user.findMany({
    select: {
      id: true,
      name: true,
      _count: {
        select: { posts: true },
      },
    },
  });

  return users.map((user) => ({
    id: user.id,
    name: user.name,
    postCount: user._count.posts,
  }));
}

// 2. 게시글 목록과 댓글 수, 좋아요 수
// TODO: 학생들이 직접 최적화
```

### 8.2 Select와 Index (30분)

**필요한 필드만 조회**

```javascript
// ❌ 나쁜 예: 모든 필드 조회
const users = await prisma.user.findMany();
// SELECT * FROM User
// password, bio 등 불필요한 데이터까지 전송

// ✅ 좋은 예: 필요한 필드만
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
  },
});
// SELECT id, name, email FROM User
```

**Index 생성**

```prisma
// schema.prisma

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique        // 자동으로 index
  name      String
  status    String
  createdAt DateTime @default(now())

  // 단일 컬럼 index
  @@index([status])

  // 복합 index
  @@index([status, createdAt])
}

// 효과:
// - WHERE status = ? → 빠름
// - WHERE status = ? AND createdAt > ? → 빠름
// - ORDER BY status, createdAt → 빠름
```

**Index 확인**

```bash
# Prisma Studio에서 확인
npx prisma studio

# 또는 직접 SQL로
npx prisma db execute --stdin <<< "
SELECT * FROM sqlite_master WHERE type='index';
"
```

**Index 사용 시 주의사항**

```javascript
// ✅ Index가 도움이 되는 경우
// - WHERE 절에 자주 사용되는 컬럼
// - ORDER BY에 사용되는 컬럼
// - 관계의 FK
// - Unique 제약이 필요한 컬럼

// ❌ Index를 피해야 하는 경우
// - 데이터가 적은 테이블 (100건 미만)
// - 자주 UPDATE/INSERT 되는 컬럼
// - Boolean 같은 cardinality 낮은 컬럼
```

### 8.3 Raw Query와 Transaction (30분)

**복잡한 쿼리는 Raw SQL**

```javascript
// Prisma로 표현하기 어려운 복잡한 통계 쿼리

// 예: 월별 게시글 수와 평균 조회수
const stats = await prisma.$queryRaw`
  SELECT 
    strftime('%Y-%m', created_at) as month,
    COUNT(*) as post_count,
    AVG(view_count) as avg_views
  FROM Post
  WHERE created_at >= date('now', '-6 months')
  GROUP BY strftime('%Y-%m', created_at)
  ORDER BY month
`;

console.log(stats);
// [
//   { month: '2024-01', post_count: 15n, avg_views: 123.5 },
//   { month: '2024-02', post_count: 20n, avg_views: 145.2 },
//   ...
// ]

// 주의: COUNT는 BigInt로 반환됨
```

**Parameterized Query (SQL Injection 방지)**

```javascript
// ❌ 위험: SQL Injection 가능
const email = req.query.email;
const users = await prisma.$queryRawUnsafe(
  `SELECT * FROM User WHERE email = '${email}'`
);
// 만약 email = "' OR '1'='1" 이면?

// ✅ 안전: Parameterized query
const users = await prisma.$queryRaw`
  SELECT * FROM User WHERE email = ${email}
`;
// Prisma가 자동으로 escape
```

**Transaction 사용**

```javascript
// 여러 작업을 하나의 트랜잭션으로
async function transferMoney(fromId, toId, amount) {
  // ❌ 나쁜 예: 중간에 실패하면?
  const from = await prisma.account.update({
    where: { id: fromId },
    data: { balance: { decrement: amount } },
  });
  // 여기서 에러 발생하면? from의 돈만 빠져나감!
  const to = await prisma.account.update({
    where: { id: toId },
    data: { balance: { increment: amount } },
  });

  // ✅ 좋은 예: Transaction 사용
  await prisma.$transaction([
    prisma.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } },
    }),
    prisma.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } },
    }),
  ]);
  // 하나라도 실패하면 전체 rollback
}

// 복잡한 로직이 필요한 경우
await prisma.$transaction(async (tx) => {
  // tx를 사용해서 쿼리 실행
  const from = await tx.account.findUnique({ where: { id: fromId } });

  if (from.balance < amount) {
    throw new Error("잔액 부족");
  }

  await tx.account.update({
    where: { id: fromId },
    data: { balance: { decrement: amount } },
  });

  await tx.account.update({
    where: { id: toId },
    data: { balance: { increment: amount } },
  });

  await tx.transactionLog.create({
    data: { fromId, toId, amount },
  });
});
```

**Batch 처리**

```javascript
// ❌ 나쁜 예: 하나씩 INSERT
for (const user of users) {
  await prisma.user.create({ data: user });
}
// 1000개면 1000번의 쿼리

// ✅ 좋은 예: Bulk INSERT
await prisma.user.createMany({
  data: users,
});
// 1번의 쿼리로 처리
```

**실습: 성능 최적화**

```javascript
// 과제: 다음 기능을 최적화하기

// 1. 대시보드 데이터
async function getDashboard(userId) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  const posts = await prisma.post.findMany({ where: { authorId: userId } });
  const comments = await prisma.comment.findMany({
    where: { authorId: userId },
  });

  let totalViews = 0;
  for (const post of posts) {
    totalViews += post.viewCount;
  }

  return {
    user,
    totalPosts: posts.length,
    totalComments: comments.length,
    totalViews,
    recentPosts: posts.slice(0, 5),
  };
}

// TODO: 쿼리 수를 최소화하기 (hint: 1-2개로 가능)

// 최적화된 버전
async function getDashboardOptimized(userId) {
  const [user, stats] = await prisma.$transaction([
    // 1. 사용자 정보와 최근 게시글
    prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        _count: {
          select: {
            posts: true,
            comments: true,
          },
        },
        posts: {
          select: {
            id: true,
            title: true,
            viewCount: true,
            createdAt: true,
          },
          orderBy: { createdAt: "desc" },
          take: 5,
        },
      },
    }),

    // 2. 총 조회수 (Raw SQL로)
    prisma.$queryRaw`
      SELECT SUM(view_count) as total_views
      FROM Post
      WHERE author_id = ${userId}
    `,
  ]);

  return {
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
    },
    totalPosts: user._count.posts,
    totalComments: user._count.comments,
    totalViews: Number(stats[0].total_views) || 0,
    recentPosts: user.posts,
  };
}

// 2. 인기 태그 조회
async function getPopularTags() {
  // ❌ 나쁜 예
  const tags = await prisma.tag.findMany({
    include: {
      posts: true,
    },
  });

  return tags
    .map((tag) => ({
      name: tag.name,
      postCount: tag.posts.length,
    }))
    .sort((a, b) => b.postCount - a.postCount)
    .slice(0, 10);
}

// ✅ 좋은 예: Raw SQL로 최적화
async function getPopularTagsOptimized() {
  const tags = await prisma.$queryRaw`
    SELECT 
      t.id,
      t.name,
      COUNT(pt.A) as post_count
    FROM Tag t
    LEFT JOIN _PostToTag pt ON t.id = pt.B
    GROUP BY t.id, t.name
    ORDER BY post_count DESC
    LIMIT 10
  `;

  return tags.map((tag) => ({
    id: tag.id,
    name: tag.name,
    postCount: Number(tag.post_count),
  }));
}

// 또는 Prisma의 groupBy 사용 (제한적)
async function getPopularTagsWithPrisma() {
  const tags = await prisma.tag.findMany({
    select: {
      id: true,
      name: true,
      _count: {
        select: { posts: true },
      },
    },
    orderBy: {
      posts: {
        _count: "desc",
      },
    },
    take: 10,
  });

  return tags.map((tag) => ({
    id: tag.id,
    name: tag.name,
    postCount: tag._count.posts,
  }));
}
```

---

## 부록: 자주 하는 실수와 해결

### 실수 1: include 없이 관계 접근

```javascript
// ❌ 나쁜 예
const user = await prisma.user.findUnique({ where: { id: 1 } });
console.log(user.posts.length); // Error: Cannot read property 'length' of undefined

// ✅ 좋은 예
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: { posts: true },
});
console.log(user.posts.length); // OK
```

### 실수 2: 비밀번호를 평문으로 저장

```javascript
// ❌ 절대 안 됨
const user = await prisma.user.create({
  data: {
    email: "user@example.com",
    password: "1234", // 평문 저장
  },
});

// ✅ 해싱 사용
const bcrypt = require("bcrypt");

const hashedPassword = await bcrypt.hash("1234", 10);
const user = await prisma.user.create({
  data: {
    email: "user@example.com",
    password: hashedPassword,
  },
});
```

### 실수 3: Transaction 없이 여러 작업

```javascript
// ❌ 중간에 실패하면?
const order = await prisma.order.create({ data: orderData });
await prisma.product.update({
  where: { id: productId },
  data: { stock: { decrement: quantity } },
});
// 여기서 에러 발생하면? 주문은 생성됐는데 재고는 그대로

// ✅ Transaction 사용
await prisma.$transaction([
  prisma.order.create({ data: orderData }),
  prisma.product.update({
    where: { id: productId },
    data: { stock: { decrement: quantity } },
  }),
]);
```

### 실수 4: Unique 제약 위반 처리 안 함

```javascript
// ❌ 에러 처리 없음
const user = await prisma.user.create({
  data: { email: "existing@example.com", name: "Test" },
});
// 이미 존재하는 이메일이면 에러 발생

// ✅ 에러 처리
try {
  const user = await prisma.user.create({
    data: { email: "existing@example.com", name: "Test" },
  });
} catch (error) {
  if (error.code === "P2002") {
    // Unique constraint violation
    return res.status(400).json({ error: "Email already exists" });
  }
  throw error;
}
```

### 실수 5: BigInt 처리 안 함

```javascript
// COUNT, SUM 등은 BigInt 반환
const result = await prisma.$queryRaw`
  SELECT COUNT(*) as count FROM User
`;

console.log(result[0].count); // 10n (BigInt)

// ❌ 나쁜 예
const count = result[0].count; // BigInt 그대로 사용

// ✅ 좋은 예
const count = Number(result[0].count); // Number로 변환
```

### 실수 6: Prisma Client 연결 해제 안 함

```javascript
// ❌ 나쁜 예
async function main() {
  const users = await prisma.user.findMany();
  console.log(users);
  // 연결이 계속 유지됨
}

main();

// ✅ 좋은 예
async function main() {
  const users = await prisma.user.findMany();
  console.log(users);
}

main()
  .catch((e) => console.error(e))
  .finally(async () => {
    await prisma.$disconnect();
  });
```

### 실수 7: Migration 충돌

```bash
# 여러 사람이 동시에 schema 변경 시

# A: schema 변경 후
npx prisma migrate dev --name add_field_a

# B: 동시에 schema 변경 후
npx prisma migrate dev --name add_field_b
# 충돌 발생!

# 해결:
# 1. git pull로 최신 migration 가져오기
# 2. schema 다시 수정
# 3. 새 migration 생성
```

---

## 참고 자료

### 공식 문서

- [Prisma 공식 문서](https://www.prisma.io/docs)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [Prisma Client API](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference)

### Prisma 특화 자료

- [Prisma Examples](https://github.com/prisma/prisma-examples)
- [Prisma Data Guide](https://www.prisma.io/dataguide)
- [Prisma Blog](https://www.prisma.io/blog)

### 추천 읽을거리

- "Database Design for Mere Mortals" - Michael J. Hernandez
- "SQL Performance Explained" - Markus Winand
- "Domain-Driven Design" - Eric Evans (고급)

### 유용한 도구

- [Prisma Studio](https://www.prisma.io/studio) - GUI 데이터베이스 클라이언트
- [DB Browser for SQLite](https://sqlitebrowser.org/)
- [Postman](https://www.postman.com/) - API 테스트
- [Prisma VS Code Extension](https://marketplace.visualstudio.com/items?itemName=Prisma.prisma)

---

## 다음 단계

이 과정을 마친 후 학습할 주제들:

### 1. 고급 쿼리 최적화

- Query Plan 분석
- Index 전략
- Caching (Redis)
- Connection Pooling

### 2. 트랜잭션과 동시성

- ACID 속성
- Isolation Level
- Optimistic Locking
- Deadlock 해결

### 3. 스키마 설계 심화

- 정규화/비정규화
- Data Modeling
- Event Sourcing
- CQRS 패턴

### 4. Prisma 고급 기능

- Middleware
- Query Extensions
- Custom Generators
- Multi-schema
- Read Replicas

### 5. NoSQL과의 비교

- MongoDB (Prisma는 MongoDB도 지원!)
- Redis
- 언제 RDBMS를, 언제 NoSQL을?
- Polyglot Persistence

---

## 마무리

### 핵심 요약

**1. SQL의 본질**

- 조회에 특화된 선언적 언어
- Turing incomplete
- 비즈니스 로직 표현에는 부적합

**2. Impedance Mismatch**

- 코드(객체) ↔ DB(테이블)의 근본적 차이
- 계층별로 목적이 다름 (Domain, Persistence, API)
- 완벽한 해결은 불가능

**3. Prisma의 역할**

- 두 세계를 연결하는 차세대 도구
- 타입 안전, 직관적 API
- 생산성 향상, 하지만 완벽하지 않음
- SQL을 몰라도 되는 게 아니라, 잘 알아야 Prisma를 잘 씀

**4. 최적화의 중요성**

- N+1 문제 주의 (include 전략)
- 필요한 데이터만 조회 (select)
- 복잡한 쿼리는 Raw SQL
- 항상 실행되는 쿼리 확인

**5. 실무 권고사항**

const 실무\_지혜 = {
kick_off: 'Prisma로 빠르게 시작',

주의사항: [
'Lock-in 인식 (나중에 바꾸기 어려움)',
'도메인 로직은 Application에',
'Schema는 신중하게 설계',
'Migration 전략 수립'
],

최적화: [
'문제가 생기기 전까지는 단순하게',
'측정 후 최적화',
'Premature optimization is evil',
'하지만 N+1은 미리 방지'
],

성장\_경로: [
'SQL 마스터하기',
'Prisma Schema 깊이 이해',
'Transaction과 동시성',
'MongoDB로 확장 (Prisma 지원)',
'Polyglot Persistence'
]
}

### Prisma의 장점 재확인

타입*안전: '자동완성과 타입 체크 (JS에서도!)',
직관적\_API: '배우기 쉬운 API',
마이그레이션: '강력한 마이그레이션 도구',
다중\_DB: 'PostgreSQL, MySQL, SQLite, SQL Server, MongoDB 지원',
개발*경험: 'Prisma Studio로 GUI 제공'
