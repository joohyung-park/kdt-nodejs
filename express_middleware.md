# Express 미들웨어와 파일 관리

## 1. 미들웨어 기본 (2시간)

> **💡 핵심 개념정리: 미들웨어(Middleware)란?**
>
> - **정의**: 클라이언트의 요청(Request)이 서버에 들어와 응답(Response)으로 나갈 때까지 거쳐가는 **'관문'**들의 체인입니다.
> - **목적**: "모든 요청에 로그를 남긴다", "로그인 여부를 검사한다"와 같이 공통적인 처리를 반복하지 않고 효율적으로 관리하기 위함입니다.
> - **구조**: 양파 껍질(Onion Model)과 같습니다. 요청이 겹겹이 쌓인 미들웨어를 뚫고 들어가서, 다시 응답이 되어 뚫고 나옵니다.

### 1.1 미들웨어 개념과 실행 순서 체감 (1시간)

**목표**: `next()`의 의미와 미들웨어 흐름 직접 제어하기

**실습 1: 첫 번째 미들웨어 만들기**

```javascript
// app.js
const express = require("express");
const app = express();

// 가장 단순한 미들웨어
app.use((req, res, next) => {
  console.log("미들웨어 1번 실행됨");
  next(); // 다음 미들웨어로 넘기기
});

app.use((req, res, next) => {
  console.log("미들웨어 2번 실행됨");
  next();
});

app.get("/", (req, res) => {
  console.log("라우트 핸들러 실행됨");
  res.send("Hello World");
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

**과제**: 브라우저에서 `http://localhost:3000`에 접속하고 콘솔 출력 순서 확인하기

**실습 2: 실행 시간 측정 미들웨어**

```javascript
// middleware/timer.js
function requestTimer(req, res, next) {
  const start = Date.now();
  console.log("1. 요청 시작");

  // res.on('finish') : 응답이 전송 완료된 후 실행되는 이벤트
  res.on("finish", () => {
    const duration = Date.now() - start;
    console.log(`3. 응답 완료: ${req.method} ${req.url} - ${duration}ms`);
  });

  next(); // 다음 단계로 이동 (2. 라우트 핸들러 실행됨)
}

module.exports = requestTimer;
```

```javascript
// app.js
const requestTimer = require("./middleware/timer");

app.use(requestTimer);

app.get("/fast", (req, res) => {
  res.send("빠른 응답");
});

app.get("/slow", (req, res) => {
  setTimeout(() => {
    res.send("느린 응답");
  }, 2000);
});
```

**실습 3: next()의 다양한 사용법**

```javascript
// next() - 다음 미들웨어로 이동
app.use((req, res, next) => {
  console.log("A");
  next();
});

// next('route') - (같은 경로의) 다음 라우트 핸들러로 건너뛰기
app.get(
  "/user/:id",
  (req, res, next) => {
    if (req.params.id === "0") {
      next("route"); // 아래 두 번째 핸들러로 건너뜀
    } else {
      next(); // 바로 다음 핸들러로
    }
  },
  (req, res) => {
    res.send(`User ${req.params.id}`);
  }
);

app.get("/user/:id", (req, res) => {
  res.send("Special user 0");
});

// next(error) - 바로 에러 핸들러로 점프
app.use((req, res, next) => {
  if (!req.headers.authorization) {
    next(new Error("인증 필요"));
  } else {
    next();
  }
});
```

**토론 포인트**:

- `next()`를 호출하지 않으면 어떻게 될까?
- `res.send()` 후에 `next()`를 호출하면?

### 1.2 로깅 미들웨어로 흐름 추적하기 (0.5시간)

**실습 4: morgan 설치와 기본 사용**

```bash
npm install morgan
```

```javascript
const morgan = require("morgan");

// 개발 환경용 - 컬러풀한 출력
app.use(morgan("dev"));

// 다양한 포맷 실험
// app.use(morgan('combined')); // Apache 스타일
// app.use(morgan('common'));
// app.use(morgan('short'));
// app.use(morgan('tiny'));
```

**실습 5: 커스텀 로그 포맷**

```javascript
// 커스텀 토큰 정의
morgan.token("body", (req) => JSON.stringify(req.body));
morgan.token("user-id", (req) => req.user?.id || "anonymous");

// 커스텀 포맷 사용
app.use(morgan(":method :url :status :response-time ms - :body"));
```

### 1.3 커스텀 미들웨어 만들기 (0.5시간)

**실습 6: 요청 ID 추가 미들웨어**

```javascript
// middleware/requestId.js
const { randomUUID } = require("crypto");

function addRequestId(req, res, next) {
  req.id = randomUUID();
  res.setHeader("X-Request-ID", req.id);
  next();
}

module.exports = addRequestId;
```

**실습 7: 인증 체크 미들웨어**

```javascript
// middleware/auth.js
function requireAuth(req, res, next) {
  const token = req.headers.authorization;

  if (!token) {
    return res.status(401).json({ error: "인증 토큰이 필요합니다" });
  }

  // 실제로는 토큰 검증 로직
  if (token === "Bearer secret-token") {
    req.user = { id: 1, name: "John" };
    next();
  } else {
    res.status(403).json({ error: "유효하지 않은 토큰" });
  }
}

module.exports = requireAuth;
```

```javascript
// 특정 라우트에만 적용
const requireAuth = require("./middleware/auth");

app.get("/public", (req, res) => {
  res.send("누구나 접근 가능");
});

app.get("/private", requireAuth, (req, res) => {
  res.json({ message: "인증된 사용자만", user: req.user });
});
```

**도전 과제**:

- IP 기반 요청 제한 미들웨어 만들기 (1분에 10회)
- API 키 검증 미들웨어 만들기

---

## 2. 내장/서드파티 미들웨어 (2시간)

> **💡 핵심 개념정리: 왜 라이브러리를 쓸까?**
>
> - **보안 & 효율**: HTTP 요청은 복잡합니다. 직접 파싱하면 버그나 보안 취약점(DoS 등)이 생기기 쉽습니다. 검증된 미들웨어가 이를 인프라 레벨에서 처리해줍니다.

### 2.1 Body Parser (0.5시간)

**실습 8: JSON과 URL-encoded 데이터 처리**

```javascript
// Express 4.16+ 에서는 내장
// JSON 파싱 (용량 제한 설정으로 DoS 공격 방지)
app.use(
  express.json({
    limit: "10kb", // 10kb 이상의 본문은 거부 (413 Payload Too Large)
  })
);

// Form 데이터 파싱
app.use(express.urlencoded({ extended: true }));

// JSON 형식이 깨졌을 때의 에러 처리
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
    return res.status(400).json({ error: "JSON 형식이 잘못되었습니다" });
  }
  next(err);
});

app.post("/json", (req, res) => {
  console.log("받은 JSON:", req.body);
  res.json({ received: req.body });
});

app.post("/form", (req, res) => {
  console.log("받은 Form 데이터:", req.body);
  res.json({ received: req.body });
});
```

**Postman 테스트**:

1. POST `/json` - Body > raw > JSON 선택

```json
{
  "name": "John",
  "age": 30
}
```

2. POST `/form` - Body > x-www-form-urlencoded 선택

```
   name: John
   age: 30
```

**실습 9: 크기 제한과 에러 처리**

```javascript
app.use(
  express.json({
    limit: "10kb", // 10kb 제한
    strict: true, // 배열/객체만 허용
  })
);

// JSON 파싱 에러 처리
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
    return res.status(400).json({ error: "JSON 형식이 잘못되었습니다" });
  }
  next(err);
});
```

### 2.2 정적 파일 서빙 (0.5시간)

**실습 10: express.static 기본 사용**

```javascript
// public 폴더 생성 후 파일 배치
// public/
//   ├── index.html
//   ├── style.css
//   └── images/
//       └── logo.png

app.use(express.static("public"));

// 이제 http://localhost:3000/index.html 접근 가능
// http://localhost:3000/images/logo.png 도 가능
```

**실습 11: 가상 경로와 여러 디렉토리**

```javascript
// /static 경로에 마운트
app.use("/static", express.static("public"));
// 이제 http://localhost:3000/static/index.html

// 여러 디렉토리 서빙 (순서대로 검색)
app.use(express.static("public"));
app.use(express.static("uploads"));

// 캐시 설정
app.use(
  express.static("public", {
    maxAge: "1d", // 1일 캐시
    etag: true,
    lastModified: true,
  })
);
```

**실습 12: index.html 자동 서빙**

```html
<!-- public/index.html -->

Express Static Test 정적 파일 서빙 테스트
```

### 2.3 CORS (0.5시간)

- **참고**: CORS는 서버 보안이 아니라 **브라우저의 보안 정책**입니다. 서버는 브라우저에게 "나는 이 출처(Origin)를 허용해"라고 헤더로 알려주는 역할만 합니다.

**실습 13: CORS 기본 설정**

```bash
npm install cors
```

```javascript
const cors = require("cors");

// 모든 origin 허용 (개발용만!)
app.use(cors());

// 특정 origin만 허용
app.use(
  cors({
    origin: "http://localhost:3001",
  })
);

// 여러 origin 허용
app.use(
  cors({
    origin: ["http://localhost:3001", "http://localhost:3002"],
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true, // 쿠키 포함 요청 허용
  })
);
```

**실습 14: 동적 origin 검증**

```javascript
const allowedOrigins = ["http://localhost:3001", "http://example.com"];

app.use(
  cors({
    origin: function (origin, callback) {
      // origin이 undefined면 same-origin 요청
      if (!origin) return callback(null, true);

      if (allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
  })
);
```

**실습 15: 특정 라우트에만 CORS 적용**

```javascript
// 전체는 CORS 제한
app.get("/private", (req, res) => {
  res.json({ data: "private" });
});

// 특정 라우트만 CORS 허용
app.get("/public", cors(), (req, res) => {
  res.json({ data: "public" });
});
```

### 2.4 보안 미들웨어 (0.5시간)

**실습 16: helmet으로 보안 헤더 설정**

```bash
npm install helmet
```

```javascript
const helmet = require("helmet");

// 기본 설정 (권장)
app.use(helmet());

// 커스텀 설정
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'", "https://cdn.example.com"],
      },
    },
    hsts: {
      maxAge: 31536000, // 1년
      includeSubDomains: true,
      preload: true,
    },
  })
);
```

**실습 17: compression으로 응답 압축**

```bash
npm install compression
```

```javascript
const compression = require("compression");

app.use(
  compression({
    level: 6, // 압축 레벨 (0-9)
    threshold: 1024, // 1KB 이상만 압축
    filter: (req, res) => {
      if (req.headers["x-no-compression"]) {
        return false;
      }
      return compression.filter(req, res);
    },
  })
);

// 큰 JSON 응답 테스트
app.get("/big-data", (req, res) => {
  const data = Array.from({ length: 10000 }, (_, i) => ({
    id: i,
    name: `User ${i}`,
    email: `user${i}@example.com`,
  }));
  res.json(data);
});
```

**실습 17.5: Cookie Parser (인증 기초)**

```bash
npm install cookie-parser
```

```js
const cookieParser = require("cookie-parser");
app.use(cookieParser());

app.get("/cookie-test", (req, res) => {
  console.log("Cookies: ", req.cookies);
  res.send("Cookie check");
});
```

**도전 과제**:

- `cookie-parser` 설치하고 쿠키 읽기/쓰기 구현
- `express-rate-limit`으로 API 요청 제한하기

---

## 3. 에러 핸들링 (1.5시간)

> **💡 핵심 개념정리: 중앙 집중식 에러 처리**
>
> - **Why**: 모든 라우터마다 `try-catch`를 써서 에러 응답을 보내는 건 중복 코드가 너무 많습니다.
> - **Goal**: 에러가 발생하면 `next(err)`로 던지고, **딱 한 곳(Global Error Handler)**에서 받아서 로그도 찍고 응답도 보냅니다.

### 3.1 에러 미들웨어 구조 (0.5시간)

**실습 18: 기본 에러 핸들러**

```javascript
// 에러 미들웨어는 항상 4개 인자를 받음
app.use((err, req, res, next) => {
  console.error("에러 발생:", err);
  res.status(500).json({
    error: "서버 에러가 발생했습니다",
    message: err.message,
  });
});
```

**실습 19: 에러 타입별 처리**

```javascript
// errors/AppError.js
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true; // 예상된 에러
    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = AppError;
```

```javascript
const AppError = require("./errors/AppError");

app.get("/user/:id", (req, res, next) => {
  const { id } = req.params;

  if (isNaN(id)) {
    return next(new AppError("ID는 숫자여야 합니다", 400));
  }

  // 사용자를 찾지 못한 경우
  if (!user) {
    return next(new AppError("사용자를 찾을 수 없습니다", 404));
  }

  res.json({ user });
});

// 통합 에러 핸들러
app.use((err, req, res, next) => {
  if (err.isOperational) {
    // 예상된 에러 - 클라이언트에게 안전하게 전달
    return res.status(err.statusCode).json({
      status: "error",
      message: err.message,
    });
  }

  // 예상치 못한 에러 - 자세한 정보 숨김
  console.error("예상치 못한 에러:", err);
  res.status(500).json({
    status: "error",
    message: "서버 에러가 발생했습니다",
  });
});
```

### 3.2 동기/비동기 에러 처리 (0.5시간)

**실습 20: 동기 함수의 에러**

```javascript
// try-catch 필요 없음 - Express가 자동으로 잡음
app.get("/sync-error", (req, res) => {
  throw new Error("동기 에러 발생!");
  // 에러 미들웨어로 전달됨
});
```

**실습 21: 비동기 함수의 에러 (문제 상황)**

```javascript
// ❌ 이렇게 하면 에러를 잡지 못함
app.get("/async-error", (req, res) => {
  setTimeout(() => {
    throw new Error("비동기 에러 발생!");
  }, 100);
  // 애플리케이션 크래시!
});

// ❌ Promise rejection도 마찬가지
app.get("/promise-error", (req, res) => {
  Promise.reject(new Error("Promise 에러"));
  // 처리되지 않은 rejection
});
```

**실습 22: 비동기 에러 올바른 처리**

```javascript
// ✅ next()로 에러 전달
app.get("/async-error-fixed", (req, res, next) => {
  setTimeout(() => {
    try {
      throw new Error("비동기 에러 발생!");
    } catch (err) {
      next(err);
    }
  }, 100);
});

// ✅ Promise는 catch에서 next 호출
app.get("/promise-error-fixed", (req, res, next) => {
  someAsyncFunction()
    .then((data) => res.json(data))
    .catch(next); // catch(err => next(err))와 동일
});

// ✅ async/await는 try-catch
app.get("/async-await", async (req, res, next) => {
  try {
    const data = await someAsyncFunction();
    res.json(data);
  } catch (err) {
    next(err);
  }
});
```

```js
// app.js
// ✅ 비동기 에러를 잡기 위한 라이브러리 (Express 4.x 필수)
require("express-async-errors");

app.get("/users/:id", async (req, res) => {
  const user = await findUser(req.params.id);
  if (!user) {
    // throw하면 자동으로 아래 에러 핸들러로 전달됨 (express-async-errors 덕분)
    throw new AppError("사용자를 찾을 수 없습니다", 404);
  }
  res.json(user);
});

// ❌ 잘못된 예: 여기서 try-catch 없이 비동기 에러가 나면 서버가 죽음 (라이브러리 없을 시)
```

### 3.3 에러 로깅과 응답 전략 (0.5시간)

**실습 23: 환경별 에러 응답**

```javascript
// utils/errorHandler.js
// 반드시 인자가 4개여야 함 (err, req, res, next)
function errorHandler(err, req, res, next) {
  const statusCode = err.statusCode || 500;

  // 개발 환경 - 자세한 에러 정보
  if (process.env.NODE_ENV === "development") {
    return res.status(statusCode).json({
      status: "error",
      message: err.message,
      stack: err.stack,
      error: err,
    });
  }

  // 프로덕션 - 최소한의 정보만
  // 배포 환경: 내부 정보 숨김 (보안)
  res.status(statusCode).json({
    status: "error",
    message: err.isOperational ? err.message : "서버 에러가 발생했습니다",
  });
}

module.exports = errorHandler;
```

**실습 24: 에러 로깅 시스템**

```javascript
// middleware/errorLogger.js
const fs = require("fs");
const path = require("path");

function errorLogger(err, req, res, next) {
  const logEntry = {
    timestamp: new Date().toISOString(),
    method: req.method,
    url: req.url,
    statusCode: err.statusCode || 500,
    message: err.message,
    stack: err.stack,
    user: req.user?.id || "anonymous",
    requestId: req.id,
  };

  // 파일에 로그 기록
  const logFile = path.join(__dirname, "../logs/errors.log");
  fs.appendFileSync(logFile, JSON.stringify(logEntry) + "\n");

  // 심각한 에러는 알림 발송 (예: Slack, Email)
  if (err.statusCode === 500) {
    // sendAlertToSlack(logEntry);
  }

  next(err);
}

module.exports = errorLogger;
```

```javascript
// app.js
const errorLogger = require("./middleware/errorLogger");
const errorHandler = require("./utils/errorHandler");

// 라우트들...

// 404 핸들러
app.use((req, res, next) => {
  next(new AppError("요청한 리소스를 찾을 수 없습니다", 404));
});

// 에러 로깅 -> 에러 응답 순서
app.use(errorLogger);
app.use(errorHandler);
```

**실습 25: express-async-errors 사용**

```bash
npm install express-async-errors
```

```javascript
// app.js 맨 위에 require만 하면 됨
require("express-async-errors");

// 이제 async 함수에서 try-catch 불필요
app.get("/users/:id", async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) {
    throw new AppError("사용자를 찾을 수 없습니다", 404);
  }
  res.json(user);
});
```

**도전 과제**:

- 에러 발생 시 Slack으로 알림 보내기
- 에러 로그를 데이터베이스에 저장하기

---

## 4. 파일 업로드 (3시간)

> **💡 핵심 개념정리: Multipart와 Stream**
>
> - **문제**: 일반 JSON과 달리 파일은 크기가 큽니다. 한 번에 메모리에 올리면 서버가 터집니다.
> - **해결**: `multipart/form-data` 형식으로 쪼개서 보내고, 서버는 이를 **스트림(Stream)** 방식으로 받아서 디스크에 바로 씁니다. `Multer`가 이 복잡한 과정을 처리합니다.

### 4.1 Multipart 이해와 Multer 설정 (1시간)

**개념 설명**:

- `Content-Type: multipart/form-data`가 필요한 이유
- Boundary와 파트 구분
- 메모리 vs 디스크 스토리지

**실습 26: 기본 파일 업로드**

```bash
npm install multer
```

```javascript
// uploads/ 폴더 생성
const multer = require("multer");
const upload = multer({ dest: "uploads/" });

app.post("/upload", upload.single("file"), (req, res) => {
  console.log("업로드된 파일:", req.file);
  console.log("기타 폼 데이터:", req.body);

  res.json({
    message: "파일 업로드 성공",
    file: req.file,
  });
});
```

**Postman 테스트**:

- POST `/upload`
- Body > form-data 선택
- Key: `file` (Type: File 선택), Value: 파일 선택
- Key: `description` (Type: Text), Value: "테스트 파일"

**실습 27: 디스크 스토리지 커스터마이징**

```javascript
// config/multer.js
const multer = require("multer");
const path = require("path");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // 업로드 폴더 지정
    cb(null, "uploads/");
  },
  filename: function (req, file, cb) {
    // 파일명 충돌 방지: timestamp + 원본 확장자
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + "-" + uniqueSuffix + ext);
  },
});

const upload = multer({ storage: storage });

module.exports = upload;
```

**실습 28: 메모리 스토리지 (임시 처리용)**

```javascript
const memoryStorage = multer.memoryStorage();
const memoryUpload = multer({ storage: memoryStorage });

app.post("/upload-memory", memoryUpload.single("file"), (req, res) => {
  console.log("파일 버퍼:", req.file.buffer);
  console.log("파일 크기:", req.file.size);

  // 버퍼를 그대로 사용 (예: S3 업로드, 이미지 처리 등)
  res.json({
    message: "메모리 업로드 성공",
    size: req.file.size,
  });
});
```

### 4.2 프로필 이미지 업로드 실습 (1시간)

**실습 29: 완전한 프로필 이미지 업로드 시스템**

```javascript
// routes/profile.js
const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const fs = require("fs").promises;

// 사용자별 폴더 생성
const storage = multer.diskStorage({
  destination: async function (req, file, cb) {
    const userId = req.user?.id || "anonymous";
    const uploadPath = path.join("uploads", "profiles", userId.toString());

    // 폴더가 없으면 생성
    await fs.mkdir(uploadPath, { recursive: true });
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    // 프로필 사진은 하나만: profile + 타임스탬프 + 확장자
    const ext = path.extname(file.originalname);
    cb(null, `profile-${Date.now()}${ext}`);
  },
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
  fileFilter: function (req, file, cb) {
    // 이미지 파일만 허용
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(
      path.extname(file.originalname).toLowerCase()
    );
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(
        new Error("이미지 파일만 업로드 가능합니다 (jpeg, jpg, png, gif, webp)")
      );
    }
  },
});

// 프로필 이미지 업로드
router.post(
  "/upload",
  upload.single("profileImage"),
  async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "파일이 업로드되지 않았습니다" });
      }

      // 이전 프로필 이미지 삭제 (있다면)
      const userId = req.user?.id || "anonymous";
      const uploadDir = path.join("uploads", "profiles", userId.toString());
      const files = await fs.readdir(uploadDir);

      for (const file of files) {
        if (file !== path.basename(req.file.path)) {
          await fs.unlink(path.join(uploadDir, file));
        }
      }

      res.json({
        message: "프로필 이미지 업로드 성공",
        file: {
          filename: req.file.filename,
          path: req.file.path,
          size: req.file.size,
          url: `/uploads/profiles/${userId}/${req.file.filename}`,
        },
      });
    } catch (err) {
      next(err);
    }
  }
);

// 프로필 이미지 조회
router.get("/:userId", async (req, res, next) => {
  try {
    const { userId } = req.params;
    const uploadDir = path.join("uploads", "profiles", userId);

    const files = await fs.readdir(uploadDir);
    const profileImage = files.find((file) => file.startsWith("profile-"));

    if (!profileImage) {
      return res
        .status(404)
        .json({ error: "프로필 이미지를 찾을 수 없습니다" });
    }

    res.json({
      url: `/uploads/profiles/${userId}/${profileImage}`,
    });
  } catch (err) {
    if (err.code === "ENOENT") {
      return res
        .status(404)
        .json({ error: "프로필 이미지를 찾을 수 없습니다" });
    }
    next(err);
  }
});

module.exports = router;
```

```javascript
// app.js
app.use("/api/profile", require("./routes/profile"));
app.use("/uploads", express.static("uploads"));
```

### 4.3 파일 검증, 크기 제한, 보안 (0.5시간)

**실습 30: 파일 MIME 타입 검증**

```bash
npm install file-type
```

```javascript
const FileType = require("file-type");

async function validateFileType(req, res, next) {
  try {
    if (!req.file) return next();

    // 실제 파일 내용으로 타입 확인 (확장자 속일 수 없음)
    const fileTypeResult = await FileType.fromFile(req.file.path);

    const allowedMimes = ["image/jpeg", "image/png", "image/gif", "image/webp"];

    if (!fileTypeResult || !allowedMimes.includes(fileTypeResult.mime)) {
      // 잘못된 파일 삭제
      await fs.unlink(req.file.path);
      return res.status(400).json({
        error: "허용되지 않은 파일 형식입니다",
        detected: fileTypeResult?.mime,
      });
    }

    next();
  } catch (err) {
    next(err);
  }
}

app.post("/upload", upload.single("file"), validateFileType, (req, res) => {
  res.json({ message: "검증된 파일 업로드 성공" });
});
```

**실습 31: Path Traversal 공격 방어**

```javascript
const path = require("path");

function sanitizeFilename(filename) {
  // 위험한 문자 제거
  return filename
    .replace(/[^a-zA-Z0-9._-]/g, "_") // 안전한 문자만
    .replace(/\.{2,}/g, ".") // 연속된 점 제거 (../ 방지)
    .slice(0, 255); // 파일명 길이 제한
}

const storage = multer.diskStorage({
  filename: function (req, file, cb) {
    const safeName = sanitizeFilename(file.originalname);
    const uniqueName = `${Date.now()}-${safeName}`;
    cb(null, uniqueName);
  },
});
```

**실습 32: 업로드 에러 처리**

```javascript
app.post(
  "/upload",
  (req, res, next) => {
    upload.single("file")(req, res, (err) => {
      if (err instanceof multer.MulterError) {
        // Multer 에러
        if (err.code === "LIMIT_FILE_SIZE") {
          return res.status(400).json({
            error: "파일 크기는 5MB를 초과할 수 없습니다",
          });
        }
        if (err.code === "LIMIT_UNEXPECTED_FILE") {
          return res.status(400).json({
            error: "예상치 못한 필드명입니다",
          });
        }
        return res.status(400).json({ error: err.message });
      } else if (err) {
        // 기타 에러
        return res.status(500).json({ error: err.message });
      }

      // 성공
      next();
    });
  },
  (req, res) => {
    res.json({ message: "업로드 성공", file: req.file });
  }
);
```

**실습 32.5: 안전한 파일 처리를 위한 유틸리티 (Cleanup)** 업로드 중 에러가 발생했을 때, 찌꺼기 파일(Orphaned Files)이 남지 않도록 삭제하는 기능이 필수입니다.

```js
// utils/fileCleanup.js
const fs = require("fs").promises;

const cleanupFile = async (file) => {
  try {
    if (file && file.path) {
      await fs.unlink(file.path);
      console.log(`🗑️ 임시 파일 삭제됨: ${file.path}`);
    }
  } catch (err) {
    console.error(`❌ 파일 삭제 실패: ${file.path}`, err);
  }
};
module.exports = cleanupFile;
```

```js
// app.js
const cleanupFile = require("./utils/fileCleanup");

app.post("/upload", upload.single("profile"), async (req, res, next) => {
  try {
    if (!req.file) throw new AppError("파일이 없습니다", 400);

    // 예: DB 저장 시도
    // await db.saveUserImage(req.file.filename);

    // 인위적 에러 발생 (테스트용)
    if (req.body.triggerError) throw new Error("DB 저장 실패!");

    res.json({ message: "성공", file: req.file });
  } catch (err) {
    next(err); // 에러 핸들러로 전달
  }
});

// 수정된 전역 에러 핸들러 (Cleanup 포함)
app.use(async (err, req, res, next) => {
  // 💡 요청 객체에 파일 정보가 남아있다면 삭제 시도 (롤백)
  if (req.file) await cleanupFile(req.file);
  if (req.files) {
    if (Array.isArray(req.files)) await Promise.all(req.files.map(cleanupFile));
    else
      for (let key in req.files)
        await Promise.all(req.files[key].map(cleanupFile));
  }

  // ... 기존 에러 응답 로직
  res.status(err.statusCode || 500).json({ error: err.message });
});
```

### 4.2 프로필 이미지 업로드 구현

### 4.4 이미지 리사이징 (0.5시간)

**실습 33: sharp로 이미지 처리**

```bash
npm install sharp
```

```javascript
const sharp = require("sharp");

app.post(
  "/upload-thumbnail",
  upload.single("image"),
  async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "파일이 없습니다" });
      }

      const originalPath = req.file.path;
      const thumbnailPath = originalPath.replace(/(\.\w+)$/, "-thumb$1");

      // 썸네일 생성 (300x300, 비율 유지, 크롭)
      await sharp(originalPath)
        .resize(300, 300, {
          fit: "cover",
          position: "center",
        })
        .jpeg({ quality: 80 })
        .toFile(thumbnailPath);

      res.json({
        message: "이미지 업로드 및 썸네일 생성 완료",
        original: originalPath,
        thumbnail: thumbnailPath,
      });
    } catch (err) {
      next(err);
    }
  }
);
```

**실습 34: 여러 크기의 이미지 생성**

```javascript
app.post(
  "/upload-responsive",
  upload.single("image"),
  async (req, res, next) => {
    try {
      const sizes = [
        { name: "small", width: 320 },
        { name: "medium", width: 640 },
        { name: "large", width: 1024 },
      ];

      const results = await Promise.all(
        sizes.map(async (size) => {
          const outputPath = req.file.path.replace(
            /(\.\w+)$/,
            `-${size.name}$1`
          );

          await sharp(req.file.path)
            .resize(size.width)
            .jpeg({ quality: 80 })
            .toFile(outputPath);

          return { size: size.name, path: outputPath };
        })
      );

      res.json({
        message: "반응형 이미지 생성 완료",
        original: req.file.path,
        variants: results,
      });
    } catch (err) {
      next(err);
    }
  }
);
```

**도전 과제**:

- 여러 파일 동시 업로드 (upload.array())
- 다중 필드 업로드 (upload.fields())
- 이미지 워터마크 추가하기

---

## 5. 파일 다운로드 (2시간)

> **💡 핵심 개념정리: Buffering vs Streaming**
>
> - **Buffering**: 파일을 컵에 다 채운 뒤 주는 것. (메모리 부족 위험)
> - **Streaming**: 호스로 물을 계속 흘려보내는 것. (대용량 처리에 필수)

### 5.1 sendFile vs download (0.5시간)

**실습 35: res.sendFile() 기본 사용**

```javascript
const path = require("path");

app.get("/file/:filename", (req, res, next) => {
  const { filename } = req.params;
  const filepath = path.join(__dirname, "uploads", filename);

  // 절대 경로 필요
  res.sendFile(filepath, (err) => {
    if (err) {
      if (err.status === 404) {
        return res.status(404).json({ error: "파일을 찾을 수 없습니다" });
      }
      next(err);
    }
  });
});
```

**실습 36: res.download() - 다운로드 강제**

```javascript
app.get("/download/:filename", (req, res, next) => {
  const { filename } = req.params;
  const filepath = path.join(__dirname, "uploads", filename);

  // 브라우저가 다운로드 대화상자 표시
  res.download(filepath, filename, (err) => {
    if (err) {
      if (err.status === 404) {
        return res.status(404).json({ error: "파일을 찾을 수 없습니다" });
      }
      next(err);
    }
  });
});

// 다운로드 파일명 변경
app.get("/download-as/:filename", (req, res) => {
  const { filename } = req.params;
  const filepath = path.join(__dirname, "uploads", filename);
  const downloadName = "my-file.pdf";

  res.download(filepath, downloadName);
});
```

**실습 37: Content-Disposition 헤더 직접 설정**

```javascript
app.get("/inline/:filename", (req, res) => {
  const { filename } = req.params;
  const filepath = path.join(__dirname, "uploads", filename);

  // 브라우저에서 바로 열기 (이미지, PDF 등)
  res.setHeader("Content-Disposition", "inline");
  res.sendFile(filepath);
});

app.get("/attachment/:filename", (req, res) => {
  const { filename } = req.params;
  const filepath = path.join(__dirname, "uploads", filename);

  // 다운로드 강제
  res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);
  res.sendFile(filepath);
});
```

### 5.2 스트림 기반 파일 전송 (0.5시간)

**실습 38: 기본 스트림 다운로드**

```javascript
const fs = require("fs");

app.get("/stream/:filename", (req, res, next) => {
  const { filename } = req.params;
  const filepath = path.join(__dirname, "uploads", filename);

  // 파일 존재 확인
  fs.access(filepath, fs.constants.F_OK, (err) => {
    if (err) {
      return res.status(404).json({ error: "파일을 찾을 수 없습니다" });
    }

    // 스트림 생성
    const fileStream = fs.createReadStream(filepath);

    // 에러 처리
    fileStream.on("error", (error) => {
      next(error);
    });

    // MIME 타입 설정 (선택사항)
    const mimeType = "application/octet-stream";
    res.setHeader("Content-Type", mimeType);
    res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);

    // 스트림 파이프
    fileStream.pipe(res);
  });
});
```

**실습 39: Content-Length와 Range 지원**

```javascript
app.get("/stream-optimized/:filename", async (req, res, next) => {
  try {
    const { filename } = req.params;
    const filepath = path.join(__dirname, "uploads", filename);

    // 파일 정보 가져오기
    const stat = await fs.promises.stat(filepath);
    const fileSize = stat.size;

    // Range 요청 처리 (비디오 스트리밍 등)
    const range = req.headers.range;

    if (range) {
      // Range 헤더 파싱 (예: "bytes=0-1023")
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunkSize = end - start + 1;

      // 부분 응답 헤더
      res.status(206); // Partial Content
      res.setHeader("Content-Range", `bytes ${start}-${end}/${fileSize}`);
      res.setHeader("Accept-Ranges", "bytes");
      res.setHeader("Content-Length", chunkSize);
      res.setHeader("Content-Type", "application/octet-stream");

      // 부분 스트림
      const stream = fs.createReadStream(filepath, { start, end });
      stream.pipe(res);
    } else {
      // 전체 파일
      res.setHeader("Content-Length", fileSize);
      res.setHeader("Content-Type", "application/octet-stream");
      res.setHeader(
        "Content-Disposition",
        `attachment; filename="${filename}"`
      );

      const stream = fs.createReadStream(filepath);
      stream.pipe(res);
    }
  } catch (err) {
    if (err.code === "ENOENT") {
      return res.status(404).json({ error: "파일을 찾을 수 없습니다" });
    }
    next(err);
  }
});
```

**실습 39.5: pipeline을 이용한 대용량 파일 전송** 기존 `pipe()`만 사용하면 에러 발생 시 메모리 누수가 생길 수 있습니다. Node.js 10+의 `pipeline`을 사용하세요.

```js
const { pipeline } = require("stream");
const fs = require("fs");

app.get("/download-stream/:filename", (req, res) => {
  const filepath = path.join(__dirname, "uploads", req.params.filename);

  // 파일 존재 확인 (비동기)
  fs.access(filepath, fs.constants.F_OK, (err) => {
    if (err) return res.status(404).send("파일 없음");

    const fileStream = fs.createReadStream(filepath);

    res.setHeader("Content-Type", "application/octet-stream");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename="${req.params.filename}"`
    );

    // ✅ 안전한 파이핑 (Pipeline)
    // 스트림 완료나 에러 시 자동으로 리소스를 정리합니다.
    pipeline(fileStream, res, (err) => {
      if (err) {
        console.error("전송 실패:", err);
        // 주의: 헤더가 이미 전송되었다면 상태 코드를 바꿀 수 없음
        if (!res.headersSent) res.status(500).end();
      }
    });
  });
});
```

### 5.3 대용량 파일 처리 (0.5시간)

**실습 40: 청크 단위 다운로드**

```javascript
app.get("/download-large/:filename", async (req, res, next) => {
  try {
    const { filename } = req.params;
    const filepath = path.join(__dirname, "uploads", filename);

    const stat = await fs.promises.stat(filepath);
    const fileSize = stat.size;
    const chunkSize = 1024 * 1024; // 1MB 청크

    res.setHeader("Content-Type", "application/octet-stream");
    res.setHeader("Content-Length", fileSize);
    res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);

    // 스트림으로 청크 단위 전송
    const stream = fs.createReadStream(filepath, {
      highWaterMark: chunkSize,
    });

    stream.on("data", (chunk) => {
      console.log(`전송 중: ${chunk.length} bytes`);
    });

    stream.on("end", () => {
      console.log("전송 완료");
    });

    stream.pipe(res);
  } catch (err) {
    next(err);
  }
});
```

**실습 41: 다운로드 진행률 표시 (Server-Sent Events)**

```javascript
app.get("/download-progress/:filename", async (req, res, next) => {
  try {
    const { filename } = req.params;
    const filepath = path.join(__dirname, "uploads", filename);

    const stat = await fs.promises.stat(filepath);
    const fileSize = stat.size;
    let downloaded = 0;

    res.setHeader("Content-Type", "application/octet-stream");
    res.setHeader("Content-Length", fileSize);
    res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);

    const stream = fs.createReadStream(filepath);

    stream.on("data", (chunk) => {
      downloaded += chunk.length;
      const progress = ((downloaded / fileSize) * 100).toFixed(2);
      console.log(`다운로드 진행률: ${progress}%`);
      // 실제로는 WebSocket이나 SSE로 클라이언트에 전달
    });

    stream.pipe(res);
  } catch (err) {
    next(err);
  }
});
```

### 5.4 파일 접근 권한 체크 (0.5시간)

**실습 42: 인증된 사용자만 다운로드**

```javascript
// middleware/requireAuth.js (이전에 만든 것 재사용)

app.get("/secure-download/:filename", requireAuth, async (req, res, next) => {
  try {
    const { filename } = req.params;
    const userId = req.user.id;

    // 사용자의 파일인지 확인
    const filepath = path.join(
      __dirname,
      "uploads",
      userId.toString(),
      filename
    );

    await fs.promises.access(filepath, fs.constants.F_OK);

    res.download(filepath, filename);
  } catch (err) {
    if (err.code === "ENOENT") {
      return res
        .status(404)
        .json({ error: "파일을 찾을 수 없거나 권한이 없습니다" });
    }
    next(err);
  }
});
```

**실습 43: 임시 다운로드 링크 생성**

```javascript
const crypto = require("crypto");

// 토큰 저장소 (실제로는 Redis 등 사용)
const downloadTokens = new Map();

// 다운로드 토큰 생성
app.post("/generate-download-link", requireAuth, (req, res) => {
  const { filename } = req.body;
  const userId = req.user.id;

  // 임시 토큰 생성
  const token = crypto.randomBytes(32).toString("hex");

  // 10분간 유효
  const expiresAt = Date.now() + 10 * 60 * 1000;

  downloadTokens.set(token, {
    filename,
    userId,
    expiresAt,
  });

  // 토큰 자동 만료
  setTimeout(() => {
    downloadTokens.delete(token);
  }, 10 * 60 * 1000);

  res.json({
    downloadUrl: `/download-with-token/${token}`,
    expiresAt: new Date(expiresAt).toISOString(),
  });
});

// 토큰으로 다운로드
app.get("/download-with-token/:token", async (req, res, next) => {
  try {
    const { token } = req.params;
    const tokenData = downloadTokens.get(token);

    if (!tokenData) {
      return res
        .status(403)
        .json({ error: "유효하지 않은 다운로드 링크입니다" });
    }

    if (Date.now() > tokenData.expiresAt) {
      downloadTokens.delete(token);
      return res.status(403).json({ error: "만료된 다운로드 링크입니다" });
    }

    const filepath = path.join(
      __dirname,
      "uploads",
      tokenData.userId.toString(),
      tokenData.filename
    );

    // 일회용 토큰은 사용 후 삭제
    downloadTokens.delete(token);

    res.download(filepath, tokenData.filename);
  } catch (err) {
    next(err);
  }
});
```

**도전 과제**:

- ZIP 파일로 여러 파일 압축 다운로드
- 다운로드 속도 제한 (throttling)
- 다운로드 이력 추적

---

## 6. 로깅 전략 (0.5시간)

> **💡 핵심 개념정리: 가시성(Observability)과 보안**
>
> - **가시성**: 서버는 블랙박스입니다. 로그가 없으면 문제가 생겼을 때 원인을 찾을 수 없습니다.
> - **보안**: 비밀번호, 주민번호 등 개인정보(PII)는 절대 로그에 남기면 안 됩니다.

### 6.1 프로덕션 로깅 설정

**실습 44: Winston으로 구조화된 로깅**

```bash
npm install winston winston-daily-rotate-file
```

```javascript
// config/logger.js
const winston = require("winston");
const DailyRotateFile = require("winston-daily-rotate-file");

const logLevels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

const logColors = {
  error: "red",
  warn: "yellow",
  info: "green",
  http: "magenta",
  debug: "blue",
};

winston.addColors(logColors);

const format = winston.format.combine(
  winston.format.timestamp({ format: "YYYY-MM-DD HH:mm:ss" }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// 콘솔 포맷 (개발용)
const consoleFormat = winston.format.combine(
  winston.format.colorize({ all: true }),
  winston.format.printf((info) => {
    return `${info.timestamp} [${info.level}]: ${info.message}`;
  })
);

const transports = [
  // 콘솔 출력
  new winston.transports.Console({
    format: consoleFormat,
  }),

  // 일별 로테이션 파일 (에러)
  new DailyRotateFile({
    filename: "logs/error-%DATE%.log",
    datePattern: "YYYY-MM-DD",
    level: "error",
    maxFiles: "14d",
    maxSize: "20m",
  }),

  // 일별 로테이션 파일 (전체)
  new DailyRotateFile({
    filename: "logs/combined-%DATE%.log",
    datePattern: "YYYY-MM-DD",
    maxFiles: "14d",
    maxSize: "20m",
  }),
];

const logger = winston.createLogger({
  level: process.env.NODE_ENV === "production" ? "info" : "debug",
  levels: logLevels,
  format,
  transports,
});

module.exports = logger;
```

**실습 44.5: Winston 설정과 민감 정보 마스킹**

```js
const winston = require("winston");

// 민감 정보 가리기 (Masking)
const maskSensitive = winston.format((info) => {
  if (info.password) info.password = "********";
  if (info.body && info.body.password) info.body.password = "********";
  return info;
});

const logger = winston.createLogger({
  format: winston.format.combine(
    maskSensitive(), // 마스킹 먼저 적용
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: "error.log", level: "error" }),
  ],
});

// 사용
logger.info("로그인 시도", { body: req.body }); // password가 마스킹되어 기록됨
```

**실습 45: Morgan과 Winston 통합**

- Morgan의 HTTP 로그 스트림을 Winston으로 연결하여 파일로 저장합니다.

```javascript
// middleware/morganMiddleware.js
const morgan = require("morgan");
const logger = require("../config/logger");

// Morgan 출력을 Winston으로 리디렉션
const stream = {
  write: (message) => {
    logger.http(message.trim());
  },
};

const morganMiddleware = morgan(
  ":method :url :status :res[content-length] - :response-time ms",
  { stream }
);

module.exports = morganMiddleware;
```

```javascript
// app.js
const logger = require("./config/logger");
const morganMiddleware = require("./middleware/morganMiddleware");

app.use(morganMiddleware);

// 로거 사용
app.get("/test", (req, res) => {
  logger.info("테스트 엔드포인트 호출됨", {
    userId: req.user?.id,
    ip: req.ip,
  });
  res.send("OK");
});

// 에러 로깅
app.use((err, req, res, next) => {
  logger.error("에러 발생", {
    error: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
  });

  res.status(500).json({ error: "서버 에러" });
});
```

### 6.2 환경별 로그 레벨

**실습 46: 환경 변수로 로그 레벨 제어**

```javascript
// .env
NODE_ENV = development;
LOG_LEVEL = debug;

// .env.production
NODE_ENV = production;
LOG_LEVEL = info;
```

```javascript
// config/logger.js
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  // ...
});

// 사용
logger.debug("디버그 정보"); // 개발 환경에만 출력
logger.info("일반 정보"); // 항상 출력
logger.error("에러 발생"); // 항상 출력
```

---

## 참고 자료

- [Express 공식 문서](https://expressjs.com/)
- [Multer 문서](https://github.com/expressjs/multer)
- [Sharp 문서](https://sharp.pixelplumbing.com/)
- [Winston 문서](https://github.com/winstonjs/winston)
- [Node.js Stream 가이드](https://nodejs.org/api/stream.html)

---

## 부록: 자주 하는 실수와 해결법

1. **파일 업로드 후 req.body가 undefined**

   - 해결: `multer`가 `body-parser`를 대체하므로 폼 필드는 자동으로 파싱됨

2. **대용량 파일 업로드 시 메모리 부족**

   - 해결: 디스크 스토리지 사용, 스트림 처리

3. **파일명에 한글이나 특수문자**

   - 해결: `sanitizeFilename()` 함수로 안전하게 변환

4. **업로드 중단 시 임시 파일 남음**

   - 해결: 에러 핸들러에서 `fs.unlink()`로 정리

5. **CORS 에러**

   - 해결: `cors` 미들웨어 설정 확인, credentials 옵션

6. **비동기 에러가 잡히지 않음**
   - 해결: `express-async-errors` 사용 또는 명시적 `try-catch`

```

```
