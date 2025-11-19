# Express 웹 서버 구축 (11시간)

## 세션 1: HTTP와 Express 기초 (2.5시간)

### 실습 1-1: Node.js로 직접 서버 만들기 (30분)

**목표**: HTTP 모듈의 불편함을 직접 경험하기

```javascript
// server-raw.js
const http = require("http");

const server = http.createServer((req, res) => {
  // URL 파싱을 직접 해야 함
  if (req.url === "/" && req.method === "GET") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("Hello World");
  } else if (req.url === "/api/users" && req.method === "GET") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ users: [] }));
  } else if (req.url === "/api/users" && req.method === "POST") {
    // body를 직접 파싱해야 함
    let body = "";
    req.on("data", (chunk) => {
      body += chunk.toString();
    });
    req.on("end", () => {
      // [수정됨] JSON 파싱 에러 방지 (안전성 강화)
      try {
        const data = JSON.parse(body);
        res.writeHead(201, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ message: "User created", data }));
      } catch (err) {
        res.writeHead(400, { "Content-Type": "text/plain" });
        res.end("Invalid JSON format");
      }
    });
  } else {
    res.writeHead(404);
    res.end("Not Found");
  }
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

**실습 과제**:

1. 서버를 실행하고 브라우저로 각 URL 접속해보기
2. HTTPie로 POST 요청 보내보기
3. 코드에서 불편한 점들 리스트업하기

**토론**:

- URL 파싱을 직접 해야 하는 불편함
- 메서드 체크를 if문으로 해야 하는 문제
- body 파싱의 복잡함
- 라우트가 많아지면 코드가 어떻게 될까?

### 실습 1-2: Express로 같은 서버 만들기 (45분)

**목표**: Express가 얼마나 간결한지 체감하기

```bash
mkdir express-tutorial
cd express-tutorial
npm init -y
npm install express
```

```javascript
// server.js
const express = require("express");
const app = express();

app.use(express.json()); // body-parser 역할

app.get("/", (req, res) => {
  res.send("Hello World");
});

app.get("/api/users", (req, res) => {
  res.json({ users: [] });
});

app.post("/api/users", (req, res) => {
  res.status(201).json({ message: "User created", data: req.body });
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

```json
// package.json scripts (Node v18.11+ 권장)
{
  "scripts": {
    "dev": "node --watch server.js", // nodemon 대신
    "start": "node server.js"
  }
}
```

**실습 과제**:

1. 두 코드 라인 수 비교하기
2. 각 Express 메서드가 무엇을 대체하는지 매핑하기
3. nodemon으로 자동 재시작 경험하기

### 실습 1-3: HTTP 상태 코드 실험 (45분)

**목표**: 적절한 상태 코드 사용의 중요성 이해하기

```javascript
// status-codes.js
const express = require("express");
const app = express();
app.use(express.json());

// 200 OK - 성공
app.get("/success", (req, res) => {
  res.status(200).json({ message: "Success" });
});

// 201 Created - 리소스 생성됨
app.post("/users", (req, res) => {
  res.status(201).json({ message: "User created" });
});

// 204 No Content - 성공했지만 반환할 내용 없음
app.delete("/users/1", (req, res) => {
  res.status(204).send();
});

// 400 Bad Request - 잘못된 요청
app.post("/validate", (req, res) => {
  if (!req.body.email) {
    return res.status(400).json({ error: "Email is required" });
  }
  res.json({ message: "Valid" });
});

// 404 Not Found - 리소스 없음
app.get("/users/999", (req, res) => {
  res.status(404).json({ error: "User not found" });
});

// 500 Internal Server Error - 서버 에러
app.get("/error", (req, res) => {
  res.status(500).json({ error: "Something went wrong" });
});

app.listen(3000);
```

**실습 과제**:

1. HTTPie로 각 엔드포인트 호출하고 상태 코드 확인
2. 브라우저 개발자 도구 Network 탭에서 상태 코드 보기
3. 잘못된 상태 코드 사용 예제 만들어보기 (예: 에러인데 200 반환)
4. 클라이언트 입장에서 왜 올바른 상태 코드가 중요한지 토론

### 실습 1-4: 요청/응답 사이클 이해하기 (30분)

**목표**: HTTP 헤더와 요청/응답 구조 파악

```javascript
// req-res.js
const express = require("express");
const app = express();
app.use(express.json());

app.get("/inspect", (req, res) => {
  console.log("=== Request Info ===");
  console.log("Method:", req.method);
  console.log("URL:", req.url);
  console.log("Headers:", req.headers);
  console.log("Query:", req.query);

  res.json({
    receivedHeaders: req.headers,
    receivedQuery: req.query,
    serverResponse: "Check your console!",
  });
});

app.post("/echo", (req, res) => {
  console.log("Body:", req.body);

  res.set("X-Custom-Header", "MyValue").status(200).json({
    echo: req.body,
    timestamp: new Date().toISOString(),
  });
});

app.listen(3000);
```

**실습 과제**:

1. 브라우저에서 `/inspect?name=john&age=25` 호출
2. HTTPie로 커스텀 헤더 추가해서 요청
3. POST 요청 보내고 콘솔과 응답 확인
4. 응답 헤더에서 `X-Custom-Header` 찾아보기

---

## 세션 2: 기본 라우팅 (2시간)

### 실습 2-1: 메모리 기반 TODO API (60분)

**목표**: CRUD 연산과 HTTP 메서드 매핑 이해

```javascript
// todo-api.js
const express = require("express");
const app = express();
app.use(express.json());

// 메모리에 저장 (서버 재시작하면 날아감)
let todos = [
  { id: 1, title: "Learn Express", completed: false },
  { id: 2, title: "Build API", completed: false },
];
let nextId = 3;

// READ - 전체 조회
app.get("/todos", (req, res) => {
  res.json(todos);
});

// READ - 단일 조회
app.get("/todos/:id", (req, res) => {
  const todo = todos.find((t) => t.id === parseInt(req.params.id));
  if (!todo) {
    return res.status(404).json({ error: "Todo not found" });
  }
  res.json(todo);
});

// CREATE
app.post("/todos", (req, res) => {
  const newTodo = {
    id: nextId++,
    title: req.body.title,
    completed: false,
  };
  todos.push(newTodo);
  res.status(201).json(newTodo);
});

// UPDATE
app.put("/todos/:id", (req, res) => {
  const todo = todos.find((t) => t.id === parseInt(req.params.id));
  if (!todo) {
    return res.status(404).json({ error: "Todo not found" });
  }

  todo.title = req.body.title || todo.title;
  todo.completed = req.body.completed ?? todo.completed;
  res.json(todo);
});

// DELETE
app.delete("/todos/:id", (req, res) => {
  const index = todos.findIndex((t) => t.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ error: "Todo not found" });
  }

  todos.splice(index, 1);
  res.status(204).send();
});

app.listen(3000, () => {
  console.log("TODO API running on port 3000");
});
```

**실습 과제**:

1. HTTPie로 CRUD 전체 테스트
2. 존재하지 않는 ID로 조회/수정/삭제 시도
3. POST에서 title 빼고 요청하면? (다음 실습에서 검증 추가)
4. 서버 재시작하면 데이터가 사라지는 것 확인

### 실습 2-2: 라우트 패턴과 쿼리스트링 (30분)

**목표**: 다양한 URL 패턴 다루기

```javascript
// route-patterns.js
const express = require("express");
const app = express();

let todos = [
  { id: 1, title: "Task 1", completed: false, priority: "high" },
  { id: 2, title: "Task 2", completed: true, priority: "low" },
  { id: 3, title: "Task 3", completed: false, priority: "high" },
];

// 쿼리스트링으로 필터링
// GET /todos?completed=true
// GET /todos?priority=high
// GET /todos?completed=false&priority=high
app.get("/todos", (req, res) => {
  let filtered = todos;

  if (req.query.completed !== undefined) {
    const isCompleted = req.query.completed === "true";
    filtered = filtered.filter((t) => t.completed === isCompleted);
  }

  if (req.query.priority) {
    filtered = filtered.filter((t) => t.priority === req.query.priority);
  }

  res.json(filtered);
});

// 정규식 패턴
// /files/report.pdf, /files/image.png 등
app.get(/^\/files\/(.+\.(pdf|png|jpg))$/, (req, res) => {
  const filename = req.params[0]; // 캡처된 전체 파일명
  res.json({
    message: "File matched",
    filename: filename,
  });
});

// 선택적 파라미터
// /posts, /posts/5 둘 다 매칭
app.get("/posts/:id?", (req, res) => {
  if (req.params.id) {
    res.json({ post: `Post ${req.params.id}` });
  } else {
    res.json({ posts: "All posts" });
  }
});

app.listen(3000);
```

**실습 과제**:

1. `/todos?completed=true` 호출
2. `/todos?priority=high&completed=false` 호출
3. `/files/report.pdf` 호출하고 `/files/report.txt` 호출해서 차이 보기
4. `/posts`와 `/posts/5` 호출

### 실습 2-3: 라우트 체이닝 (30분)

**목표**: 같은 경로에 여러 메서드 깔끔하게 처리

```javascript
// route-chaining.js
const express = require("express");
const app = express();
app.use(express.json());

let users = [
  { id: 1, name: "Alice", email: "alice@example.com" },
  { id: 2, name: "Bob", email: "bob@example.com" },
];
let nextId = 3;

// 체이닝 없이 (비교용)
// app.get('/users', (req, res) => { ... });
// app.post('/users', (req, res) => { ... });

// 체이닝 사용
app
  .route("/users")
  .get((req, res) => {
    res.json(users);
  })
  .post((req, res) => {
    const newUser = {
      id: nextId++,
      name: req.body.name,
      email: req.body.email,
    };
    users.push(newUser);
    res.status(201).json(newUser);
  });

app
  .route("/users/:id")
  .get((req, res) => {
    const user = users.find((u) => u.id === parseInt(req.params.id));
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  })
  .put((req, res) => {
    const user = users.find((u) => u.id === parseInt(req.params.id));
    if (!user) return res.status(404).json({ error: "User not found" });

    user.name = req.body.name || user.name;
    user.email = req.body.email || user.email;
    res.json(user);
  })
  .delete((req, res) => {
    const index = users.findIndex((u) => u.id === parseInt(req.params.id));
    if (index === -1) return res.status(404).json({ error: "User not found" });

    users.splice(index, 1);
    res.status(204).send();
  });

app.listen(3000);
```

**실습 과제**:

1. 코드 가독성 비교 (체이닝 vs 개별 정의)
2. CRUD 전체 테스트
3. 같은 경로에 대한 처리가 한 곳에 모여있는 장점 체감

---

## 세션 3: 동적 라우팅과 요청 데이터 (2.5시간)

### 실습 3-1: 경로 매개변수 심화 (45분)

**목표**: URL 파라미터로 계층 구조 표현

```javascript
// params-advanced.js
const express = require("express");
const app = express();
app.use(express.json());

// 블로그 게시글과 댓글 구조
const posts = [
  {
    id: 1,
    title: "First Post",
    comments: [
      { id: 1, text: "Great post!" },
      { id: 2, text: "Thanks for sharing" },
    ],
  },
  {
    id: 2,
    title: "Second Post",
    comments: [{ id: 3, text: "Interesting" }],
  },
];

// 특정 게시글의 모든 댓글
// GET /posts/1/comments
app.get("/posts/:postId/comments", (req, res) => {
  const postId = parseInt(req.params.postId);
  const post = posts.find((p) => p.id === postId);

  if (!post) {
    return res.status(404).json({ error: "Post not found" });
  }

  res.json(post.comments);
});

// 특정 게시글의 특정 댓글
// GET /posts/1/comments/2
app.get("/posts/:postId/comments/:commentId", (req, res) => {
  const postId = parseInt(req.params.postId);
  const commentId = parseInt(req.params.commentId);

  const post = posts.find((p) => p.id === postId);
  if (!post) {
    return res.status(404).json({ error: "Post not found" });
  }

  const comment = post.comments.find((c) => c.id === commentId);
  if (!comment) {
    return res.status(404).json({ error: "Comment not found" });
  }

  res.json(comment);
});

// 댓글 추가
// POST /posts/1/comments
app.post("/posts/:postId/comments", (req, res) => {
  const postId = parseInt(req.params.postId);
  const post = posts.find((p) => p.id === postId);

  if (!post) {
    return res.status(404).json({ error: "Post not found" });
  }

  const newComment = {
    id: Date.now(), // 간단한 ID 생성
    text: req.body.text,
  };

  post.comments.push(newComment);
  res.status(201).json(newComment);
});

// 여러 파라미터 한번에
// GET /users/123/posts/456/edit
app.get("/users/:userId/posts/:postId/edit", (req, res) => {
  res.json({
    action: "edit",
    userId: req.params.userId,
    postId: req.params.postId,
  });
});

app.listen(3000);
```

**실습 과제**:

1. `/posts/1/comments` 조회
2. `/posts/1/comments/2` 조회
3. 존재하지 않는 postId나 commentId로 시도
4. 새 댓글 추가하기
5. URL 구조가 리소스 관계를 어떻게 표현하는지 토론

### 실습 3-2: 쿼리스트링 활용 (45분)

**목표**: 검색, 정렬, 페이지네이션 구현

```javascript
// query-params.js
const express = require("express");
const app = express();

const products = [
  {
    id: 1,
    name: "Laptop",
    price: 1000,
    category: "electronics",
    inStock: true,
  },
  { id: 2, name: "Phone", price: 500, category: "electronics", inStock: true },
  { id: 3, name: "Desk", price: 300, category: "furniture", inStock: false },
  { id: 4, name: "Chair", price: 150, category: "furniture", inStock: true },
  {
    id: 5,
    name: "Monitor",
    price: 250,
    category: "electronics",
    inStock: true,
  },
  {
    id: 6,
    name: "Keyboard",
    price: 50,
    category: "electronics",
    inStock: true,
  },
  { id: 7, name: "Mouse", price: 25, category: "electronics", inStock: false },
  { id: 8, name: "Lamp", price: 40, category: "furniture", inStock: true },
];

// GET /products?category=electronics&inStock=true&sort=price&order=desc&page=1&limit=3
app.get("/products", (req, res) => {
  // [수정됨] 구조 분해 할당으로 깔끔하게 처리
  const {
    category,
    inStock,
    minPrice,
    maxPrice,
    search,
    sort,
    order,
    page = 1,
    limit = 10,
  } = req.query;

  // 1. 필터링 & 검색 (Chaining 활용)
  let result = products.filter((p) => {
    return (
      (!category || p.category === category) &&
      (inStock === undefined || p.inStock.toString() === inStock) &&
      (!minPrice || p.price >= Number(minPrice)) &&
      (!maxPrice || p.price <= Number(maxPrice)) &&
      (!search || p.name.toLowerCase().includes(search.toLowerCase()))
    );
  });

  // 2. 정렬
  if (sort) {
    const direction = order === "desc" ? -1 : 1;
    result.sort((a, b) => (a[sort] > b[sort] ? 1 : -1) * direction);
  }

  // 3. 페이지네이션
  const total = result.length;
  const paginatedData = result.slice((page - 1) * limit, page * limit);

  res.json({
    data: paginatedData,
    pagination: {
      total,
      page: Number(page),
      limit: Number(limit),
      totalPages: Math.ceil(total / limit),
    },
    filters: {
      category,
      inStock,
      minPrice,
      maxPrice,
      search,
    },
  });
});

app.listen(3000);
```

**실습 과제**:

1. 카테고리별 필터링: `/products?category=electronics`
2. 재고 있는 것만: `/products?inStock=true`
3. 가격 범위: `/products?minPrice=100&maxPrice=500`
4. 검색: `/products?search=key`
5. 정렬: `/products?sort=price&order=desc`
6. 페이지네이션: `/products?page=1&limit=3`
7. 모두 조합: `/products?category=electronics&inStock=true&sort=price&order=asc&page=1&limit=2`

### 실습 3-3: 요청 본문과 헤더 다루기 (60분)

**목표**: POST/PUT 요청 데이터와 헤더 활용

```javascript
// request-data.js
const express = require("express");
const app = express();
app.use(express.json());

// Content-Type 체크
app.post("/upload", (req, res) => {
  const contentType = req.get("Content-Type");

  if (!contentType || !contentType.includes("application/json")) {
    return res.status(415).json({
      error: "Unsupported Media Type",
      message: "Please send JSON data",
    });
  }

  res.json({ message: "Data received", data: req.body });
});

// 인증 헤더 시뮬레이션
app.get("/protected", (req, res) => {
  const authHeader = req.get("Authorization");

  if (!authHeader) {
    return res.status(401).json({ error: "No authorization header" });
  }

  // "Bearer token123" 형식 기대
  const [type, token] = authHeader.split(" ");

  if (type !== "Bearer" || token !== "secret-token") {
    return res.status(403).json({ error: "Invalid token" });
  }

  res.json({ message: "Access granted", user: "authenticated-user" });
});

// 요청 정보 전체 확인
app.all("/debug", (req, res) => {
  res.json({
    method: req.method,
    url: req.url,
    params: req.params,
    query: req.query,
    body: req.body,
    headers: req.headers,
    ip: req.ip,
  });
});

// JSON 유효성 검증
app.post("/users", (req, res) => {
  const { name, email, age } = req.body;

  // 필수 필드 체크
  if (!name || !email) {
    return res.status(400).json({
      error: "Validation failed",
      required: ["name", "email"],
    });
  }

  // 이메일 형식 체크 (간단한 버전)
  if (!email.includes("@")) {
    return res.status(400).json({
      error: "Invalid email format",
    });
  }

  // 타입 체크
  if (age && typeof age !== "number") {
    return res.status(400).json({
      error: "Age must be a number",
    });
  }

  res.status(201).json({
    message: "User created",
    user: { name, email, age },
  });
});

// 커스텀 헤더 읽기
app.get("/client-info", (req, res) => {
  res.json({
    userAgent: req.get("User-Agent"),
    language: req.get("Accept-Language"),
    customHeader: req.get("X-Custom-Header"),
  });
});

app.listen(3000);
```

**실습 과제**:

1. HTTPie로 `/upload`에 JSON 보내기
2. Content-Type을 text/plain으로 바꿔서 보내기
3. `/protected`에 올바른/잘못된 Authorization 헤더로 요청
4. `/debug`에 다양한 메서드로 요청하고 정보 확인
5. `/users`에 유효한/유효하지 않은 데이터 POST
6. `/client-info`에 커스텀 헤더 추가해서 요청

---

## 세션 4: 응답 처리와 라우터 모듈화 (2시간)

### 실습 4-1: 다양한 응답 형식 (30분)

**목표**: 상황에 맞는 응답 메서드 선택

```javascript
// response-types.js
const express = require("express");
const app = express();

// JSON 응답 (가장 일반적)
app.get("/api/data", (req, res) => {
  res.json({ message: "JSON response", data: [1, 2, 3] });
});

// 텍스트 응답
app.get("/text", (req, res) => {
  res.type("text/plain");
  res.send("Plain text response");
});

// HTML 응답
app.get("/html", (req, res) => {
  res.send(`
    
    
      Express Response
      
        Hello from Express
        This is an HTML response
      
    
  `);
});

// 상태 코드와 함께
app.get("/created", (req, res) => {
  res.status(201).json({ message: "Resource created" });
});

// 체이닝
app.get("/chain", (req, res) => {
  res
    .status(200)
    .set("X-Custom-Header", "MyValue")
    .json({ message: "Chained response" });
});

// 리다이렉트
app.get("/old-url", (req, res) => {
  res.redirect(301, "/new-url"); // 영구 이동
});

app.get("/new-url", (req, res) => {
  res.send("You have been redirected!");
});

// 조건부 응답
app.get("/format", (req, res) => {
  res.format({
    "text/plain": () => {
      res.send("Plain text");
    },
    "text/html": () => {
      res.send("HTML");
    },
    "application/json": () => {
      res.json({ message: "JSON" });
    },
    default: () => {
      res.status(406).send("Not Acceptable");
    },
  });
});

// 다운로드 트리거
app.get("/download", (req, res) => {
  const data = { users: ["Alice", "Bob", "Charlie"] };
  res
    .set("Content-Disposition", 'attachment; filename="users.json"')
    .json(data);
});

app.listen(3000);
```

**실습 과제**:

1. 각 엔드포인트를 브라우저와 HTTPie에서 호출
2. `/format`에 Accept 헤더를 바꿔가며 요청
3. 개발자 도구에서 응답 헤더 확인
4. `/download` 호출 시 브라우저 동작 확인

### 실습 4-2: 라우터 모듈화 시작 (45분)

**목표**: 라우트를 파일로 분리하는 이유와 방법

```javascript
// app.js (Before - 모놀리식)
const express = require("express");
const app = express();
app.use(express.json());

let users = [];
let posts = [];
let comments = [];

// Users routes
app.get("/users", (req, res) => {
  /* ... */
});
app.post("/users", (req, res) => {
  /* ... */
});
app.get("/users/:id", (req, res) => {
  /* ... */
});

// Posts routes
app.get("/posts", (req, res) => {
  /* ... */
});
app.post("/posts", (req, res) => {
  /* ... */
});
app.get("/posts/:id", (req, res) => {
  /* ... */
});

// Comments routes
app.get("/comments", (req, res) => {
  /* ... */
});
app.post("/comments", (req, res) => {
  /* ... */
});

// ... 100줄, 200줄 계속 늘어남...

app.listen(3000);
```

이제 분리해봅시다:

```
project/
├── app.js
├── routes/
│   ├── users.js
│   ├── posts.js
│   └── comments.js
└── package.json
```

```javascript
// routes/users.js
const express = require("express");
const router = express.Router();

let users = [
  { id: 1, name: "Alice", email: "alice@example.com" },
  { id: 2, name: "Bob", email: "bob@example.com" },
];
let nextId = 3;

// /users
router.get("/", (req, res) => {
  res.json(users);
});

router.post("/", (req, res) => {
  const newUser = {
    id: nextId++,
    name: req.body.name,
    email: req.body.email,
  };
  users.push(newUser);
  res.status(201).json(newUser);
});

// /users/:id
router.get("/:id", (req, res) => {
  const user = users.find((u) => u.id === parseInt(req.params.id));
  if (!user) return res.status(404).json({ error: "User not found" });
  res.json(user);
});

router.put("/:id", (req, res) => {
  const user = users.find((u) => u.id === parseInt(req.params.id));
  if (!user) return res.status(404).json({ error: "User not found" });

  user.name = req.body.name || user.name;
  user.email = req.body.email || user.email;
  res.json(user);
});

router.delete("/:id", (req, res) => {
  const index = users.findIndex((u) => u.id === parseInt(req.params.id));
  if (index === -1) return res.status(404).json({ error: "User not found" });

  users.splice(index, 1);
  res.status(204).send();
});

module.exports = router;
```

```javascript
// routes/posts.js
const express = require("express");
const router = express.Router();

let posts = [
  { id: 1, title: "First Post", content: "Hello World", userId: 1 },
  { id: 2, title: "Second Post", content: "Express is great", userId: 2 },
];
let nextId = 3;

router.get("/", (req, res) => {
  // 쿼리로 userId 필터링 가능
  let result = posts;
  if (req.query.userId) {
    result = result.filter((p) => p.userId === parseInt(req.query.userId));
  }
  res.json(result);
});

router.post("/", (req, res) => {
  const newPost = {
    id: nextId++,
    title: req.body.title,
    content: req.body.content,
    userId: req.body.userId,
  };
  posts.push(newPost);
  res.status(201).json(newPost);
});

router.get("/:id", (req, res) => {
  const post = posts.find((p) => p.id === parseInt(req.params.id));
  if (!post) return res.status(404).json({ error: "Post not found" });
  res.json(post);
});

module.exports = router;
```

```javascript
// app.js (After - 모듈화)
const express = require("express");
const app = express();

app.use(express.json());

// 라우터 import
const usersRouter = require("./routes/users");
const postsRouter = require("./routes/posts");

// 라우터 mount
app.use("/users", usersRouter);
app.use("/posts", postsRouter);

// 기본 라우트
app.get("/", (req, res) => {
  res.json({
    message: "API Server",
    endpoints: ["/users", "/posts"],
  });
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

**실습 과제**:

1. 위 구조대로 파일 생성
2. 각 라우터가 작동하는지 테스트
3. `comments.js` 라우터 추가해보기
4. app.js의 간결함과 각 라우터 파일의 집중도 비교

### 실습 4-3: 라우터 중첩과 구조화 (45분)

**목표**: 복잡한 라우트 계층 구조 만들기

```
project/
├── app.js
├── routes/
│   ├── index.js          # 라우터 진입점
│   ├── users.js
│   ├── posts.js
│   └── api/
│       ├── v1.js
│       └── v2.js
```

```javascript
// routes/api/v1.js
const express = require("express");
const router = express.Router();

router.get("/status", (req, res) => {
  res.json({ version: "1.0", status: "stable" });
});

router.get("/features", (req, res) => {
  res.json({ features: ["basic-crud", "authentication"] });
});

module.exports = router;
```

```javascript
// routes/api/v2.js
const express = require("express");
const router = express.Router();

router.get("/status", (req, res) => {
  res.json({ version: "2.0", status: "beta" });
});

router.get("/features", (req, res) => {
  res.json({
    features: ["basic-crud", "authentication", "real-time", "graphql"],
  });
});

module.exports = router;
```

```javascript
// routes/index.js
const express = require("express");
const router = express.Router();

const usersRouter = require("./users");
const postsRouter = require("./posts");
const v1Router = require("./api/v1");
const v2Router = require("./api/v2");

// Sub-routers
router.use("/users", usersRouter);
router.use("/posts", postsRouter);
router.use("/api/v1", v1Router);
router.use("/api/v2", v2Router);

// API 정보
router.get("/", (req, res) => {
  res.json({
    message: "Welcome to the API",
    versions: {
      v1: "/api/v1",
      v2: "/api/v2",
    },
    resources: {
      users: "/users",
      posts: "/posts",
    },
  });
});

module.exports = router;
```

```javascript
// app.js
const express = require("express");
const app = express();

app.use(express.json());

// 모든 라우트를 routes/index.js에서 관리
const routes = require("./routes");
app.use("/", routes);

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

**실습 과제**:

1. 버전별 API 엔드포인트 호출 (`/api/v1/status`, `/api/v2/status`)
2. 각 라우터의 경로가 어떻게 조합되는지 확인
3. 새로운 버전 v3 라우터 추가해보기
4. 라우터 구조가 URL 구조를 어떻게 반영하는지 토론

---

## 세션 5: 에러 핸들링과 RESTful API (2시간)

### 실습 5-1: 에러 처리 기본 (45분)

**목표**: 동기/비동기 에러를 안전하게 처리하기

```javascript
// error-handling.js
const express = require("express");
const app = express();
app.use(express.json());

// 동기 에러 - Express가 자동으로 catch
app.get("/sync-error", (req, res) => {
  throw new Error("This is a synchronous error!");
});

// 비동기 에러 - next()로 전달해야 함
app.get(
  "/async-error",
  asyncHandler((req, res, next) => {
    setTimeout(() => {
      throw new Error("This is an async error!");
    }, 100);
  })
);

// Promise rejection
app.get(
  "/promise-error",
  asyncHandler(async (req, res, next) => {
    // 비동기 작업 시뮬레이션
    await new Promise((resolve, reject) => {
      setTimeout(() => reject(new Error("Promise rejected!")), 100);
    });
  })
);

// 실제 사용 예: 데이터 조회
const users = [{ id: 1, name: "Alice" }];

app.get(
  "/users/:id",
  asyncHandler(async (req, res, next) => {
    const id = parseInt(req.params.id);

    // 유효성 검사
    if (isNaN(id)) {
      const error = new Error("Invalid user ID");
      error.status = 400;
      throw error;
    }

    // 시뮬레이션: DB 조회
    await new Promise((resolve) => setTimeout(resolve, 100));

    const user = users.find((u) => u.id === id);
    if (!user) {
      const error = new Error("User not found");
      error.status = 404;
      throw error;
    }

    res.json(user);
  })
);

const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// 404 핸들러 (모든 라우트 뒤에)
app.use((req, res, next) => {
  const error = new Error("Not Found");
  error.status = 404;
  next(error);
});

// 에러 핸들링 미들웨어 (4개 파라미터 필수!)
app.use((err, req, res, next) => {
  console.error("Error:", err.message);
  console.error("Stack:", err.stack);

  const status = err.status || 500;
  const message = err.message || "Internal Server Error";

  res.status(status).json({
    error: {
      message: message,
      status: status,
      // 개발 환경에서만 스택 노출
      ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
    },
  });
});

app.listen(3000);
```

**실습 과제**:

1. 각 에러 엔드포인트 호출하고 응답 확인
2. `/users/abc` (잘못된 ID)
3. `/users/999` (존재하지 않는 사용자)
4. `/nonexistent` (404)
5. 에러 핸들러가 없으면 어떻게 되는지 주석 처리하고 테스트
6. `NODE_ENV=development`로 실행해서 스택 트레이스 확인

### 실습 5-2: 커스텀 에러 클래스 (30분)

**목표**: 에러 타입별로 다르게 처리하기

```javascript
// errors/AppError.js
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true; // 예상 가능한 에러

    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = AppError;
```

```javascript
// errors/index.js
const AppError = require("./AppError");

class ValidationError extends AppError {
  constructor(message) {
    super(message, 400);
    this.name = "ValidationError";
  }
}

class NotFoundError extends AppError {
  constructor(resource) {
    super(`${resource} not found`, 404);
    this.name = "NotFoundError";
  }
}

class UnauthorizedError extends AppError {
  constructor(message = "Unauthorized") {
    super(message, 401);
    this.name = "UnauthorizedError";
  }
}

module.exports = {
  AppError,
  ValidationError,
  NotFoundError,
  UnauthorizedError,
};
```

```javascript
// app-with-custom-errors.js
const express = require("express");
const {
  ValidationError,
  NotFoundError,
  UnauthorizedError,
} = require("./errors");

const app = express();
app.use(express.json());

const users = [{ id: 1, name: "Alice", email: "alice@example.com" }];

app.post(
  "/users",
  asyncHandler((req, res, next) => {
    const { name, email } = req.body;

    if (!name || !email) {
      throw new ValidationError("Name and email are required");
    }

    if (!email.includes("@")) {
      throw new ValidationError("Invalid email format");
    }

    const newUser = { id: Date.now(), name, email };
    users.push(newUser);
    res.status(201).json(newUser);
  })
);

app.get(
  "/users/:id",
  asyncHandler((req, res, next) => {
    const user = users.find((u) => u.id === parseInt(req.params.id));

    if (!user) {
      throw new NotFoundError("User");
    }

    res.json(user);
  })
);

app.get(
  "/protected",
  asyncHandler((req, res, next) => {
    const token = req.headers.authorization;

    if (!token) {
      throw new UnauthorizedError("Token required");
    }

    res.json({ message: "Access granted" });
  })
);

// 404 핸들러
app.use((req, res, next) => {
  next(new NotFoundError("Route"));
});

// 에러 핸들러
app.use((err, req, res, next) => {
  // 운영 에러 (예상된 에러)
  if (err.isOperational) {
    return res.status(err.statusCode).json({
      error: {
        name: err.name,
        message: err.message,
        status: err.statusCode,
      },
    });
  }

  // 프로그래밍 에러 (예상 못한 에러)
  console.error("UNEXPECTED ERROR:", err);
  res.status(500).json({
    error: {
      message: "Something went wrong",
      status: 500,
    },
  });
});

app.listen(3000);
```

**실습 과제**:

1. 유효하지 않은 데이터로 POST 요청
2. 존재하지 않는 사용자 조회
3. Authorization 헤더 없이 `/protected` 접근
4. 각 에러의 응답 구조 비교
5. 일반 Error와 커스텀 에러의 차이점 토론

### 실습 5-3: RESTful API 설계 (45분)

**목표**: REST 원칙을 따르는 API 만들기

```javascript
// restful-api.js
const express = require("express");
const app = express();
app.use(express.json());

let books = [{ id: 1, title: "Express Guide", status: "draft" }];

// [핵심 1] 리소스 생성 후 위치 반환 (Location Header)
app.post("/books", (req, res) => {
  const newBook = { id: Date.now(), ...req.body };
  books.push(newBook);

  // 201 Created와 함께 생성된 리소스의 URI를 헤더에 포함
  res.status(201).location(`/books/${newBook.id}`).json(newBook);
});

// [핵심 2] 부분 수정 (PATCH) - 변경된 필드만 업데이트
app.patch("/books/:id", (req, res) => {
  const book = books.find((b) => b.id === parseInt(req.params.id));
  if (!book) return res.status(404).json({ error: "Not found" });

  // 요청 바디에 있는 키만 업데이트 (동적 할당)
  Object.keys(req.body).forEach((key) => {
    if (key !== "id") book[key] = req.body[key];
  });

  res.json(book);
});

// [핵심 3] 하위 리소스 (Sub-resource) URL 설계
// 책(Book)에 달린 리뷰(Reviews) 관리
const reviews = {}; // { bookId: [reviews] }

app.get("/books/:bookId/reviews", (req, res) => {
  const { bookId } = req.params;
  res.json(reviews[bookId] || []);
});

app.post("/books/:bookId/reviews", (req, res) => {
  const { bookId } = req.params;
  if (!reviews[bookId]) reviews[bookId] = [];

  const newReview = { id: Date.now(), ...req.body };
  reviews[bookId].push(newReview);

  res
    .status(201)
    .location(`/books/${bookId}/reviews/${newReview.id}`)
    .json(newReview);
});

app.listen(3000, () => console.log("Advanced REST API running"));
```

**REST 원칙 체크리스트**:

```markdown
✅ 리소스 기반 URL (명사 사용: /books, /reviews)
✅ HTTP 메서드로 동작 표현 (GET, POST, PUT, PATCH, DELETE)
✅ 적절한 상태 코드 사용
✅ Stateless (각 요청은 독립적)
✅ 계층 구조 (/books/:id/reviews)
✅ 필터링/정렬은 쿼리스트링으로
✅ Location 헤더로 생성된 리소스 위치 제공

❌ 나쁜 예시:

- /getBooks (동사 사용)
- /books/delete/1 (URL에 동작 표현)
- POST /books/search (GET으로 해야 함)
```

**실습 과제**:

1. HTTPie로 전체 CRUD 테스트
2. PUT vs PATCH 차이 경험 (전체 교체 vs 부분 수정)
3. 리뷰 추가 및 조회
4. 잘못된 RESTful 설계 예시를 만들어보고 고쳐보기
5. 새로운 리소스 (예: authors) 추가하고 관계 설정

---
