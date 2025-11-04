# JavaScript 모듈 시스템
##  모듈 시스템의 필요성

### 시작: 모든 코드가 한 파일에

javascript

```javascript
// app.js - 모든 코드가 여기 있음

// 배열 유틸리티 함수들
function myMap(array, callback) {
  const result = [];
  for (let i = 0; i < array.length; i++) {
    result.push(callback(array[i], i, array));
  }
  return result;
}

function myFilter(array, callback) {
  const result = [];
  for (let i = 0; i < array.length; i++) {
    if (callback(array[i], i, array)) {
      result.push(array[i]);
    }
  }
  return result;
}

function myReduce(array, callback, initialValue) {
  let accumulator = initialValue;
  for (let i = 0; i < array.length; i++) {
    accumulator = callback(accumulator, array[i], i, array);
  }
  return accumulator;
}

// 실제 사용하는 코드
const numbers = [1, 2, 3, 4, 5];

const doubled = myMap(numbers, n => n * 2);
console.log('Doubled:', doubled);

const evens = myFilter(numbers, n => n % 2 === 0);
console.log('Evens:', evens);

const sum = myReduce(numbers, (acc, n) => acc + n, 0);
console.log('Sum:', sum);
```

### 문제점 인식

- 유틸리티 함수와 비즈니스 로직이 섞여 있음
- 다른 파일에서도 이 함수들이 필요하면? → 복사/붙여넣기? 😱

### 실습: 파일 분리하기

**Step 1: 유틸리티 함수를 별도 파일로**

javascript

```javascript
// arrayUtils.js
function myMap(array, callback) {
  const result = [];
  for (let i = 0; i < array.length; i++) {
    result.push(callback(array[i], i, array));
  }
  return result;
}

function myFilter(array, callback) {
  const result = [];
  for (let i = 0; i < array.length; i++) {
    if (callback(array[i], i, array)) {
      result.push(array[i]);
    }
  }
  return result;
}

function myReduce(array, callback, initialValue) {
  let accumulator = initialValue;
  for (let i = 0; i < array.length; i++) {
    accumulator = callback(accumulator, array[i], i, array);
  }
  return accumulator;
}

// 어떻게 내보낼까? 🤔
```

javascript

```javascript
// app.js
// 어떻게 가져올까? 🤔

const numbers = [1, 2, 3, 4, 5];

const doubled = myMap(numbers, n => n * 2);
console.log('Doubled:', doubled);

const evens = myFilter(numbers, n => n % 2 === 0);
console.log('Evens:', evens);

const sum = myReduce(numbers, (acc, n) => acc + n, 0);
console.log('Sum:', sum);
```

### 핵심 메시지: 왜 모듈이 필요한가?

**시나리오:** 다른 파일에서도 같은 유틸리티가 필요하다면?

javascript

```javascript
// userService.js
// 여기서도 myMap, myFilter가 필요함!

const users = [
  { name: 'Alice', age: 25 },
  { name: 'Bob', age: 30 },
  { name: 'Charlie', age: 35 }
];

// myMap, myFilter를 다시 구현? ❌
// 복사/붙여넣기? ❌
```

javascript

```javascript
// productService.js
// 여기서도 myMap, myReduce가 필요함!

const products = [
  { name: 'Laptop', price: 1000 },
  { name: 'Phone', price: 500 },
  { name: 'Tablet', price: 300 }
];

// 또 복사/붙여넣기? ❌
```

**문제점:**

1. 같은 코드를 3군데에 복사/붙여넣기
2. `myMap`에 버그 발견 → 3군데 다 고쳐야 함
3. 성능 개선? → 3군데 다 수정
4. 로직이 미묘하게 달라질 수 있음 (누군가 실수로 수정)

**해결책: 역할 별로 모아서 코드 공유 -> 모듈!**

- 유틸리티 함수를 한 곳에만 작성
- 필요한 곳에서 가져다 쓰기
- 수정은 한 곳에서만
- 모든 곳에 자동으로 반영
- 모듈: 코드를 공유, 즉 구현하고 가져오는 최소 단위

---

## 모듈 가져오기와 경로

### CommonJS로 모듈 만들기

javascript

```javascript
// arrayUtils.js
function myMap(array, callback) {
  const result = [];
  for (let i = 0; i < array.length; i++) {
    result.push(callback(array[i], i, array));
  }
  return result;
}

function myFilter(array, callback) {
  const result = [];
  for (let i = 0; i < array.length; i++) {
    if (callback(array[i], i, array)) {
      result.push(array[i]);
    }
  }
  return result;
}

function myReduce(array, callback, initialValue) {
  let accumulator = initialValue;
  for (let i = 0; i < array.length; i++) {
    accumulator = callback(accumulator, array[i], i, array);
  }
  return accumulator;
}

// 내보내기!
module.exports = {
  myMap,
  myFilter,
  myReduce
};

// Node.js가 모든 파일에 자동으로 만들어줌 (보이진 않지만) 
// const module = { 
//  exports: {} // 빈 객체로 시작 
// };
```

javascript

```javascript
// app.js
const arrayUtils = require('./arrayUtils'); // module.exports가 이곳에.

const numbers = [1, 2, 3, 4, 5];

const doubled = arrayUtils.myMap(numbers, n => n * 2);
console.log('Doubled:', doubled);

const evens = arrayUtils.myFilter(numbers, n => n % 2 === 0);
console.log('Evens:', evens);

const sum = arrayUtils.myReduce(numbers, (acc, n) => acc + n, 0);
console.log('Sum:', sum);
```

javascript

```javascript
// userService.js
const { myMap, myFilter } = require('./arrayUtils');

const users = [
  { name: 'Alice', age: 25 },
  { name: 'Bob', age: 30 },
  { name: 'Charlie', age: 35 }
];

const names = myMap(users, user => user.name);
console.log('Names:', names);

const adults = myFilter(users, user => user.age >= 30);
console.log('Adults:', adults);
```

javascript

```javascript
// productService.js
const { myMap, myReduce } = require('./arrayUtils');

const products = [
  { name: 'Laptop', price: 1000 },
  { name: 'Phone', price: 500 },
  { name: 'Tablet', price: 300 }
];

const prices = myMap(products, p => p.price);
console.log('Prices:', prices);

const total = myReduce(prices, (sum, price) => sum + price, 0);
console.log('Total:', total);
```

### 상대경로 vs 절대경로

**절대경로 시도:**

javascript

```javascript
// ❌ 이렇게 하면 안됨!
const arrayUtils = require('/Users/myname/project/arrayUtils');
```

**문제점:**

- 내 컴퓨터: `/Users/myname/project/arrayUtils`
- 팀원 컴퓨터: `/Users/teammate/workspace/project/arrayUtils`
- 서버: `/var/www/app/arrayUtils`
- 모두 경로가 다름! → 코드가 안 돌아감 💥

**상대경로 사용:**

javascript

````javascript
// ✅ 현재 파일 위치 기준
const arrayUtils = require('./arrayUtils');
```

**왜 상대경로?**
- 프로젝트 구조만 같으면 어디서든 동작
- 팀원 PC, 서버, 어디든 OK
- 프로젝트 폴더를 통째로 옮겨도 동작

### 폴더 구조 예시
```
project/
├── app.js              → require('./arrayUtils')
├── arrayUtils.js
├── services/
│   ├── userService.js  → require('../arrayUtils')
│   └── productService.js → require('../arrayUtils')
└── utils/
    └── stringUtils.js
````

**상대경로 예시:**

javascript

```javascript
// services/userService.js
const arrayUtils = require('../arrayUtils'); // 상위 폴더

// app.js
const arrayUtils = require('./arrayUtils'); // 같은 폴더
const userService = require('./services/userService'); // 하위 폴더
```

### 내 모듈 vs 외부 모듈

javascript

```javascript
// 내가 만든 모듈 - 상대경로 필요
const arrayUtils = require('./arrayUtils');
const userService = require('./services/userService');

// 외부 모듈 - 경로 없음! 
const express = require('express');
const lodash = require('lodash');
```

**왜 경로가 없을까?**

- `node_modules` 폴더에서 자동으로 찾음
- npm으로 설치해볼 예정!

---

## npm - 패키지 매니저

### npm이란?

- **N**ode **P**ackage **M**anager
- 외부 라이브러리(패키지)를 관리하는 도구
- **주의:** JavaScript의 모듈 시스템(CommonJS/ESM)이 아님! **패키지** 의존성 관리 도구

### 우리가 만든 arrayUtils vs 남이 만든 lodash

javascript

```javascript
// 우리가 만든 유틸리티
const arrayUtils = require('./arrayUtils');

// 프로 개발자들이 만든 유틸리티 (더 많은 기능, 더 최적화)
// 어떻게 가져올까? 🤔
```

### 프로젝트 초기화

bash

```bash
# 폴더 생성
mkdir my-project
cd my-project

# npm 프로젝트 초기화
npm init -y
```

**결과:** `package.json` 파일 생성

json

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

### 외부 패키지 설치: lodash

**lodash란?** 우리가 만든 arrayUtils보다 훨씬 강력한 유틸리티 라이브러리

bash

```bash
npm install lodash
```

**무슨 일이 일어났나?**

1. `node_modules/` 폴더 생성 (처음 설치 시)
2. `node_modules/lodash/` 폴더에 코드 다운로드
3. `package.json`에 기록:

json

```json
{
  "dependencies": {
    "lodash": "^4.17.21"
  }
}
```

4. `package-lock.json` 파일 생성 (정확한 버전 기록)

### lodash 사용하기

javascript

```javascript
// app.js
const _ = require('lodash'); // 경로 없음! node_modules에서 찾음

const numbers = [1, 2, 3, 4, 5];

// lodash의 강력한 기능들
const doubled = _.map(numbers, n => n * 2);
console.log('Doubled:', doubled);

const evens = _.filter(numbers, n => n % 2 === 0);
console.log('Evens:', evens);

const sum = _.sum(numbers);
console.log('Sum:', sum);

// 우리가 구현 안 한 기능들도!
const chunks = _.chunk(numbers, 2); // [1,2], [3,4], [5]
console.log('Chunks:', chunks);

const shuffled = _.shuffle(numbers);
console.log('Shuffled:', shuffled);
```

### npm install은 "사전 준비"

**중요한 개념:**

javascript

```javascript
const lodash = require('lodash');
```

- `require()`는 **이미 다운로드된** 파일을 로드만 함
- `npm install` 없이 실행하면?

bash

```bash
node app.js
# Error: Cannot find module 'lodash'
# 💥 즉시 에러!
```

**올바른 순서:**

bash

```bash
# 1. 저장소 클론
git clone <repo>

# 2. 의존성 설치 (필수!)
npm install

# 3. 실행
node app.js
```

### 실습: date-fns 사용하기

bash

```bash
npm install date-fns
```

javascript

```javascript
// dateExample.js
const { format, addDays, differenceInDays } = require('date-fns');

const today = new Date();
console.log('Today:', format(today, 'yyyy-MM-dd'));

const nextWeek = addDays(today, 7);
console.log('Next week:', format(nextWeek, 'yyyy-MM-dd'));

const christmas = new Date(2025, 11, 25);
const daysUntil = differenceInDays(christmas, today);
console.log(`Days until Christmas: ${daysUntil}`);
```

### npm 명령어 정리

bash

```bash
# 패키지 설치
npm install lodash
npm i lodash              # 축약형

# 개발용 패키지 설치 (테스트, 빌드 도구 등)
npm install --save-dev jest
npm i -D jest             # 축약형

# 전역 설치 (시스템 전체에서 사용)
npm install --global nodemon
npm i -g nodemon          # 축약형

# 패키지 제거
npm uninstall lodash

# 설치된 패키지 목록
npm list
npm ls                    # 축약형
```


---

## package.json 완전 정복

### package.json 전체 구조

json

```json
{
  "name": "my-awesome-project",
  "version": "1.0.0",
  "description": "배열 유틸리티를 사용하는 프로젝트",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "test": "jest"
  },
  "keywords": ["utils", "array"],
  "author": "Your Name",
  "license": "MIT",
  "dependencies": {
    "lodash": "^4.17.21",
    "date-fns": "^2.30.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.7.0"
  }
}
```

### dependencies vs devDependencies

**dependencies:** 프로그램 실행에 필요한 패키지

json

```json
"dependencies": {
  "lodash": "^4.17.21",
  "express": "^4.18.2",
  "date-fns": "^2.30.0"
}
```

javascript

```javascript
// 실제 앱 코드에서 사용
const _ = require('lodash');
const express = require('express');
```

**devDependencies:** 개발할 때만 필요한 패키지

json

```json
"devDependencies": {
  "nodemon": "^3.0.1",  // 개발 중 자동 재시작
  "jest": "^29.7.0"      // 테스트 도구
}
```

**설치 방법:**

bash

```bash
npm install lodash          # dependencies에 추가
npm install -D nodemon      # devDependencies에 추가
```

### scripts: 명령어 단축키

json

```json
"scripts": {
  "start": "node app.js",
  "dev": "nodemon app.js",
  "test": "jest",
  "lint": "eslint .",
  "build": "webpack"
}
```

**사용법:**

bash

```bash
npm start           # node app.js 실행
npm run dev         # nodemon app.js 실행
npm test            # jest 실행
npm run lint        # eslint . 실행
npm run build       # webpack 실행
```

**실습:**

json

```json
{
  "scripts": {
    "start": "node app.js",
    "user": "node userService.js",
    "product": "node productService.js",
    "date": "node dateExample.js"
  }
}
```

bash

```bash
npm start          # app.js 실행
npm run user       # userService.js 실행
npm run product    # productService.js 실행
npm run date       # dateExample.js 실행
```

### 버전 표기법 (SemVer, Semantic Versioning)

**형식:** `MAJOR.MINOR.PATCH` (예: `4.17.21`)

- **MAJOR (4):** 하위 호환 안 되는 변경 (breaking change)
- **MINOR (17):** 새 기능 추가 (하위 호환 됨)
- **PATCH (21):** 버그 수정

**특수 기호:**

json

```json
{
  "dependencies": {
    "lodash": "4.17.21",    // 정확히 이 버전만
    "express": "^4.18.2",   // 4.18.2 이상, 5.0.0 미만 (추천)
    "date-fns": "~2.30.0"   // 2.30.0 이상, 2.31.0 미만
  }
}
```

**`^` (캐럿) - 가장 많이 사용:**

- `^4.18.2` → `4.18.2` 이상 `5.0.0` 미만
- MINOR, PATCH 업데이트는 허용
- MAJOR 업데이트는 불허 (breaking change 방지)

**`~` (틸드):**

- `~2.30.0` → `2.30.0` 이상 `2.31.0` 미만
- PATCH 업데이트만 허용

### package-lock.json의 역할

**package.json:**

json

```json
{
  "dependencies": {
    "lodash": "^4.17.21"  // 범위 허용
  }
}
```

**package-lock.json:**

json

```json
{
  "dependencies": {
    "lodash": {
      "version": "4.17.21",  // 정확한 버전 고정!
      "resolved": "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz",
      "integrity": "sha512-..."
    }
  }
}
```

**왜 필요한가?**

**시나리오 1: 팀 협업**

bash

```bash
# 개발자 A
npm install  # lodash 4.17.21 설치됨

# 1주일 후, lodash 4.17.22 출시

# 개발자 B
npm install  # lodash 4.17.22 설치됨 (^4.17.21이니까)

# 결과: 같은 코드인데 다른 버전! 버그 발생 가능 😱
```

**package-lock.json이 있으면:**

bash

```bash
# 개발자 A, B 모두
npm install  # lock 파일 보고 정확히 4.17.21 설치

# 결과: 모두 같은 버전 사용 ✅
```

**결론:**

- `package.json`: "이 범위의 버전 괜찮아"
- `package-lock.json`: "정확히 이 버전 써"
- **둘 다 Git에 커밋해야 함!**

### "type": "module" 필드 

json

```json
{
  "type": "module",
  "scripts": {
    "start": "node app.js"
  }
}
```

**이게 뭘까?**

---

## CommonJS vs ES Modules - 심화

### 역사: 왜 두 가지 방식이 있나?

**옛날 옛적에...**

- JavaScript는 브라우저를 위한 언어
- 모듈 시스템이 없었음
- Node.js 등장 → 서버에서 JS 사용
- 모듈이 필요해짐 → **CommonJS 탄생** (커뮤니티 표준)

**그 후...**

- JavaScript 표준(ECMAScript)에 모듈 추가
- **ES Modules 탄생** (공식 표준)
- 하지만 기존 CommonJS 코드가 너무 많음
- 둘 다 지원하게 됨

### 기본 문법 비교

**CommonJS:**

javascript

```javascript
// arrayUtils.js
function myMap(array, callback) {
  // ...
}

function myFilter(array, callback) {
  // ...
}

// 내보내기
module.exports = {
  myMap,
  myFilter
};
```

javascript

```javascript
// app.js
// 가져오기
const arrayUtils = require('./arrayUtils');
const { myMap, myFilter } = require('./arrayUtils');

// 사용
const result = myMap([1, 2, 3], n => n * 2);
```

**ES Modules:**

javascript

```javascript
// arrayUtils.mjs (또는 .js with "type": "module")
// 내보내기
export function myMap(array, callback) {
  // ...
}

export function myFilter(array, callback) {
  // ...
}
```

javascript

```javascript
// app.mjs
// 가져오기
import { myMap, myFilter } from './arrayUtils.mjs';

// 사용
const result = myMap([1, 2, 3], n => n * 2);
```

### require는 함수, import는 문법!

**require는 진짜 함수다:**

javascript

```javascript
// ✅ 변수 사용 가능
const moduleName = 'lodash';
const _ = require(moduleName);

// ✅ 조건문 안에서 사용 가능
if (process.env.NODE_ENV === 'development') {
  const devTool = require('./devTool');
} else {
  const prodTool = require('./prodTool');
}

// ✅ 함수 안에서 사용 가능
function loadModule(name) {
  return require(`./${name}`);
}
const utils = loadModule('arrayUtils');

// ✅ 계산된 경로
const version = '2';
const lib = require(`./lib-v${version}`);
```

**import는 문법이다 (함수 아님):**

javascript

```javascript
// ❌ 변수 사용 불가
const moduleName = 'lodash';
import _ from moduleName; // SyntaxError!

// ❌ 조건문 안에서 불가
if (condition) {
  import something from './module'; // SyntaxError!
}

// ❌ 함수 안에서 불가
function loadModule() {
  import utils from './utils'; // SyntaxError!
}

// ✅ 파일 최상단에만 가능
import { myMap, myFilter } from './arrayUtils.mjs';
```

### 로딩 방식: 동기 vs 비동기

**CommonJS: 동기적**이고 **동적** 로딩/실행.

javascript

````javascript
console.log('1. 시작');

const utils = require('./arrayUtils'); // 여기서 멈춤! 파일 다 읽을 때까지
console.log('2. 로드 완료');

const result = utils.myMap([1, 2, 3], n => n * 2);
console.log('3. 실행 완료');
```

**실행 순서:**
```
1. 시작
(파일 읽는 중... blocking)
2. 로드 완료
3. 실행 완료
````

**ES Modules: **정적**이고 **비동기적으로 로딩 가능**하며, 실행은 **순차적**.**

javascript

```javascript
// 파일 최상단에서 모든 import를 먼저 분석
import { myMap } from './arrayUtils.mjs';
import { format } from 'date-fns';
import express from 'express';

// 여러 파일을 병렬로 로드 가능!

console.log('시작');
const result = myMap([1, 2, 3], n => n * 2);
```

### Static vs Dynamic의 실전 의미

**Static (ES Modules):**

javascript

```javascript
// ✅ 빌드 타임에 분석 가능
import { myMap, myFilter } from './arrayUtils.mjs';
// → "아, 이 파일은 arrayUtils의 myMap, myFilter만 쓰네"
// → myReduce는 안 쓰니까 번들에서 제외 (Tree Shaking!)
```

javascript

```javascript
// ✅ IDE가 자동완성 더 잘함
import { my } from './arrayUtils.mjs';
//         ^^ 자동완성: myMap, myFilter, myReduce
```

**Dynamic (CommonJS):**

javascript

```javascript
// ❌ 실행해봐야 알 수 있음
const moduleName = getUserInput(); // 런타임에 결정
const module = require(`./${moduleName}`);
// → 어떤 모듈을 쓸지 실행 전엔 모름
// → Tree Shaking 불가
```

### Top-level await

**ES Modules만 가능:**

javascript

```javascript
// data.mjs
const response = await fetch('https://api.example.com/data');
const data = await response.json();

export default data;
```

javascript

```javascript
// app.mjs
import data from './data.mjs';
console.log(data); // 이미 로드됨!
```

**CommonJS는 불가능:**

javascript

```javascript
// ❌ 에러!
const data = await fetchData(); // SyntaxError!

// ✅ async 함수 안에서만
(async () => {
  const data = await fetchData();
  console.log(data);
})();
```

### 동적 import() - ES Modules의 유연성

**문제:** ES Modules는 조건부 로딩이 안 됨 **해결:** 동적 `import()` 함수

javascript

```javascript
// 조건부 로딩
if (process.env.NODE_ENV === 'development') {
  const devTool = await import('./devTool.mjs');
  devTool.init();
}

// 계산된 경로
const locale = getUserLocale(); // 'ko', 'en', 'ja'
const messages = await import(`./locales/${locale}.mjs`);

// 지연 로딩 (필요할 때만)
button.addEventListener('click', async () => {
  const module = await import('./heavy-feature.mjs');
  module.run();
});
```

**특징:**

- Promise를 반환
- Top-level await와 함께 사용
- 코드 분할(Code Splitting)에 유용

### Export 패턴

**Named Export:**

javascript

```javascript
// arrayUtils.mjs
export function myMap(array, callback) { /* ... */ }
export function myFilter(array, callback) { /* ... */ }
export const VERSION = '1.0.0';
```

javascript

```javascript
// 사용
import { myMap, myFilter, VERSION } from './arrayUtils.mjs';
import { myMap as map } from './arrayUtils.mjs'; // 별칭
import * as utils from './arrayUtils.mjs'; // 전체
// utils.myMap, utils.myFilter, utils.VERSION
```

**Default Export:**

javascript

```javascript
// calculator.mjs
const calculator = {
  add: (a, b) => a + b,
  subtract: (a, b) => a - b
};

export default calculator;
```

javascript

```javascript
// 사용
import calculator from './calculator.mjs';
import calc from './calculator.mjs'; // 이름 자유롭게
```

**혼용:**

javascript

```javascript
// utils.mjs
export function helper1() { /* ... */ }
export function helper2() { /* ... */ }

const mainUtil = { /* ... */ };
export default mainUtil;
```

javascript

```javascript
// 사용
import mainUtil, { helper1, helper2 } from './utils.mjs';
```

**언제 뭘 쓸까?**

- Named Export: 여러 개 내보낼 때, 이름이 중요할 때
- Default Export: 하나만 내보낼 때, 모듈의 "메인" 기능

### .mjs vs .js

**방법 1: .mjs 확장자 사용**

javascript

```javascript
// arrayUtils.mjs - 무조건 ES Module
export function myMap() { /* ... */ }
```

javascript

```javascript
// app.mjs
import { myMap } from './arrayUtils.mjs';
```

**방법 2: package.json 설정**

json

```json
{
  "type": "module"
}
```

javascript

```javascript
// arrayUtils.js - 이제 ES Module로 동작!
export function myMap() { /* ... */ }
```

javascript

```javascript
// app.js
import { myMap } from './arrayUtils.js';
```

**CommonJS 사용하려면?**

json

```json
{
  "type": "module" // 기본은 ES Module
}
```

javascript

```javascript
// legacy.cjs - CommonJS 사용
module.exports = { /* ... */ };
```

---

## 순환 참조 문제와 해결

### 순환 참조란?

**예시 상황:** 사용자와 게시글

javascript

```javascript
// user.js
const { getPostsByUser } = require('./post');

function getUser(id) {
  const user = { id, name: 'Alice' };
  user.posts = getPostsByUser(id); // 게시글 목록 가져오기
  return user;
}

module.exports = { getUser };
```

javascript

```javascript
// post.js
const { getUser } = require('./user'); // 순환 참조!

function getPost(id) {
  const post = { id, title: 'Hello' };
  post.author = getUser(1); // 작성자 정보 가져오기
  return post;
}

function getPostsByUser(userId) {
  return [{ id: 1, title: 'Post 1' }];
}

module.exports = { getPost, getPostsByUser };
```

javascript

````javascript
// app.js
const { getUser } = require('./user');

const user = getUser(1);
console.log(user);
```

**실행하면?** 💥

### CommonJS에서의 순환 참조

**실행 순서 추적:**
```
1. app.js: require('./user')
2. user.js 실행 시작
3. user.js: require('./post')
4. post.js 실행 시작
5. post.js: require('./user') ← 다시 user.js!
6. 하지만 user.js는 아직 실행 중...
7. Node.js: "user.js는 아직 완료 안됐지만, 지금까지 export한 것만 줄게"
8. 이 시점에서 module.exports = {} (빈 객체! `user.js`**가 아직 실행 중이어서 `module.exports`에 최종 값이 할당되지 않았기 때문**)
9. post.js: getUser = undefined
10. 나중에 getUser() 호출하면... 💥 TypeError!
````

**실습: 문제 재현**

javascript

```javascript
// user.js
console.log('user.js 시작');
const post = require('./post');
console.log('user.js: post =', post);

function getUser(id) {
  console.log('getUser 호출');
  return { id, name: 'Alice' };
}

console.log('user.js: getUser 내보내기');
module.exports = { getUser };
console.log('user.js 완료');
```

javascript

```javascript
// post.js
console.log('post.js 시작');
const user = require('./user');
console.log('post.js: user =', user); // {} (빈 객체!)

function getPost(id) {
  console.log('getPost 호출');
  // 이 시점에 user는 여전히 {} 이므로 에러 발생
  const author = user.getUser(1); // TypeError: user.getUser is not a function
  return { id, title: 'Hello', author };
}

console.log('post.js 완료');
module.exports = { getPost };
```

javascript

````javascript
// app.js
console.log('app.js 시작');
const { getUser } = require('./user');
console.log('getUser 가져옴');
const result = getUser(1);
console.log(result);
```

**출력:**
```
app.js 시작
user.js 시작
post.js 시작
post.js: user = {}           ← 빈 객체!
post.js 완료
user.js: post = { getPost: [Function: getPost] }
user.js: getUser 내보내기
user.js 완료
getUser 가져옴
getUser 호출
````

### ES Modules에서의 순환 참조

**ES Modules는 더 안전:**

javascript

```javascript
// user.mjs
console.log('user.mjs 시작');
import { getPostsByUser } from './post.mjs';
console.log('user.mjs: import 완료');

export function getUser(id) {
  console.log('getUser 호출');
  const user = { id, name: 'Alice' };
  user.posts = getPostsByUser(id);
  return user;
}

console.log('user.mjs 완료');
```

javascript

```javascript
// post.mjs
console.log('post.mjs 시작');
import { getUser } from './user.mjs';
console.log('post.mjs: import 완료');

export function getPost(id) {
  console.log('getPost 호출');
  const post = { id, title: 'Hello' };
  post.author = getUser(1);
  return post;
}

export function getPostsByUser(userId) {
  return [{ id: 1, title: 'Post 1' }];
}

console.log('post.mjs 완료');
```

javascript

````javascript
// app.mjs
import { getUser } from './user.mjs';
const user = getUser(1);
console.log(user);
```

**출력:**
```
user.mjs 시작
post.mjs 시작
post.mjs: import 완료
post.mjs 완료
user.mjs: import 완료
user.mjs 완료
getUser 호출
getPost 호출
(무한 루프!) 💥
````

**왜 조금 더 나은가?**

- ESM은 `export`된 함수와 클래스는 호이스팅됩니다. 따라서 `post.mjs`에서 `getUser(1)`을 호출할 때 `getUser`는 `undefined`가 아닌 **함수 그 자체**입니다.
- CommonJS처럼 undefined는 안 되지만...
- 문제는 함수가 호출되면서 **모듈 로딩이 중단되지 않고 재귀적으로 실행**되어 무한 루프에 빠지는 것입니다. (CommonJS는 실행 중간에 빈 객체를 넘겨주지만, ESM은 바인딩을 제공합니다.)

### 근본적인 해결 방법

**1. 의존성 방향 정리**

javascript

```javascript
// ❌ 순환 참조
// user → post
// post → user

// ✅ 단방향
// user → post
// post ✗ user
```

**실제 해결:**

javascript

```javascript
// user.js
function getUser(id) {
  return { id, name: 'Alice' };
}

module.exports = { getUser };
```

javascript

```javascript
// post.js
function getPost(id) {
  return { id, title: 'Hello', authorId: 1 }; // ID만 저장
}

function getPostsByUser(userId) {
  return [{ id: 1, title: 'Post 1' }];
}

module.exports = { getPost, getPostsByUser };
```

javascript

```javascript
// app.js - 여기서 조합
const { getUser } = require('./user');
const { getPost, getPostsByUser } = require('./post');

const user = getUser(1);
user.posts = getPostsByUser(user.id);
console.log(user);
```

**2. 중간 모듈 분리**

javascript

```javascript
// models.js - 데이터 구조만
module.exports = {
  User: class User {
    constructor(id, name) {
      this.id = id;
      this.name = name;
    }
  },
  Post: class Post {
    constructor(id, title) {
      this.id = id;
      this.title = title;
    }
  }
};
```

javascript

```javascript
// userService.js
const { User } = require('./models');

function getUser(id) {
  return new User(id, 'Alice');
}

module.exports = { getUser };
```

javascript

```javascript
// postService.js
const { Post } = require('./models');

function getPost(id) {
  return new Post(id, 'Hello');
}

module.exports = { getPost };
```

**3. 지연 로딩 (CommonJS 한정)**

javascript

```javascript
// user.js
function getUser(id) {
  // 함수 안에서 require (실행 시점에 로딩)
  const { getPostsByUser } = require('./post');
  const user = { id, name: 'Alice' };
  user.posts = getPostsByUser(id);
  return user;
}

module.exports = { getUser };
```

**왜 작동하나?**

- 파일 파싱 단계에선 require 안 함
- 함수 호출 시점엔 이미 모든 모듈 로딩 완료

### 왜 ES Modules를 쓰는가?

**장점:**

1. **표준:** ECMAScript 공식 표준
2. **정적 분석:** 빌드 타임에 오류 감지
3. **Tree Shaking:** 사용 안 하는 코드 제거
4. **브라우저 지원:** 별도 변환 없이 브라우저에서 동작
5. **비동기:** 병렬 로딩으로 더 빠름
6. **Top-level await:** 비동기 코드 더 쉽게

**단점:**

1. 동적 로딩 제한 (→ `import()` 로 해결)
2. Node.js 구버전 미지원
3. 기존 CommonJS 생태계가 큼

**현실:**

- 새 프로젝트: ES Modules 추천
- 레거시: CommonJS 여전히 많음
- 라이브러리: 둘 다 지원하는 경우 많음

**결론:**

- ES Modules가 미래
- 하지만 CommonJS도 당분간 공존
- 둘 다 이해하는 것이 중요!
