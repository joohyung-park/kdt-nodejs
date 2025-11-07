# Node.js 네트워크 통신 실습 교안 

## 🕐 1교시 : 네트워크 통신의 이해와 첫 fetch

### 도입 

**실습 1-1: 브라우저에서 네트워크 확인하기**

1. 브라우저에서 아무 웹사이트나 접속 (예: 네이버)
2. F12 → Network 탭 열기
3. 새로고침 후 어떤 요청들이 일어나는지 관찰
4. 하나의 요청 클릭 → Headers, Response 확인

## 💡 HTTP 통신의 3가지 핵심 요소 

네트워크 통신에서 서버와 클라이언트가 대화하는 방식을 결정하는 **세 가지 핵심 약속**입니다.



### 1. Request Method (요청 방식)

클라이언트가 **서버에게 원하는 동작**을 알리는 **동사**입니다.

|**메소드**|**역할**|
|---|---|
|**GET**|데이터 **조회** (서버 데이터 변경 없음)|
|**POST**|새로운 데이터 **생성**|
|**PATCH/PUT**|기존 데이터 **수정**|
|**DELETE**|데이터 **삭제**|

> **배경:** 데이터 처리의 기본 동작인 **CRUD** (Create, Read, Update, Delete)를 웹에서 구현하기 위해 정의되었습니다.



### 2. Status Code (상태 코드)

요청 처리 후 **서버가 클라이언트에게 보내는 3자리 결과 보고서**입니다.

|**코드 범위**|**의미**|**주요 예시**|
|---|---|---|
|**2xx**|**성공**|**200 OK** (요청 성공)|
|**4xx**|**클라이언트 오류**|**404 Not Found** (주소 오류), **400 Bad Request** (요청 형식 오류)|
|**5xx**|**서버 오류**|**500 Internal Server Error** (서버 내부 문제)|

> **배경:** 프로그램이 통신 결과를 **규격화된 방식**으로 쉽게 판단하고 처리할 수 있도록 만들어졌습니다. **`fetch`는 4xx/5xx에서도 에러를 throw하지 않으므로 코드 확인이 필수**입니다.



### 3. Content-Type (콘텐츠 유형)

주고받는 **데이터의 형식**을 알려주는 '이름표'입니다.

|**유형**|**쓰임새**|
|---|---|
|`application/json`|데이터 통신의 **표준 형식** (API 통신)|
|`text/html`|웹 페이지|
|`image/jpeg`|JPEG 이미지|

> **배경:** 수신자가 데이터를 **정확히 해석**할 수 있도록 데이터 형식을 표준화(MIME 타입)했습니다. **POST/PATCH 요청 시, JSON 데이터를 보낼 때 이 헤더 설정이 필수**입니다.


### AJAX와 네트워크 통신의 역사 

**개념 설명**:

```
옛날(2000년대): 서버 ←→ 브라우저 (XML 형식)
              ↓
         XMLHttpRequest

오늘날: 서버 ←→ 브라우저 (JSON 형식)
         ↓
       fetch / axios
```

**AJAX = Asynchronous JavaScript And XML**

- 페이지 새로고침 없이 데이터를 주고받는 기술
- XML → JSON으로 변화
- XMLHttpRequest → fetch로 변화

### 첫 fetch 실습 

**실습 1-2: 가장 간단한 GET 요청**

프로젝트 폴더 만들기:

bash

```bash
mkdir network-practice
cd network-practice
npm init -y
```

`simple-fetch.js` 파일 생성:

javascript

```javascript
// 가장 간단한 fetch
async function getColorSurveys() {
  const response = await fetch('https://learn.codeit.kr/api/color-surveys');
  const data = await response.json();
  console.log(data);
}

getColorSurveys();
```

실행:

bash

```bash
node simple-fetch.js
```

**💡 설명 포인트**:

- `fetch()`는 Promise를 반환 → `await` 사용
- `response.json()`도 Promise → 한 번 더 `await`
- 결과는 객체 형태로 나옴

**실습 1-3: 응답 구조 이해하기**

`response-structure.js`:

javascript

```javascript
async function exploreResponse() {
  const response = await fetch('https://learn.codeit.kr/api/color-surveys');
  
  console.log('=== Response 객체 살펴보기 ===');
  console.log('상태 코드:', response.status);
  console.log('성공 여부:', response.ok);
  console.log('URL:', response.url);
  
  const data = await response.json();
  console.log('\n=== 실제 데이터 ===');
  console.log(data);
}

exploreResponse();
```

**함께 관찰하기**:

- 200번대 상태 코드 = 성공
- `response.ok` = true/false
- 실제 데이터는 `response.json()` 후에 얻음

---

## 🕑 2교시 : fetch로 다양한 요청 보내기

### 쿼리 파라미터 사용하기 

**실습 2-1: 문자열로 쿼리 파라미터 보내기**

`query-string.js`:

javascript

```javascript
async function getSurveysWithQuery() {
  // 10번째부터 5개만 가져오기
  const response = await fetch(
    'https://learn.codeit.kr/api/color-surveys?offset=10&limit=5'
  );
  const data = await response.json();
  
  console.log(`총 ${data.count}개 중 ${data.results.length}개 조회`);
  console.log(data.results);
}

getSurveysWithQuery();
```

**실습 2-2: URL 객체로 깔끔하게 만들기**

`query-object.js`:

javascript

```javascript
async function getSurveysWithURLObject() {
  const url = new URL('https://learn.codeit.kr/api/color-surveys');
  
  // 쿼리 파라미터 추가
  url.searchParams.append('offset', 10);
  url.searchParams.append('limit', 5);
  url.searchParams.append('mbti', 'ENFP');
  
  console.log('최종 URL:', url.toString());
  
  const response = await fetch(url);
  const data = await response.json();
  console.log(data);
}

getSurveysWithURLObject();
```

**💡 어떤 방법이 더 좋을까?**

- 쿼리가 1~2개: 문자열도 OK
- 쿼리가 동적이거나 많을 때: URL 객체 추천

### POST 요청과 JSON 보내기 

**실습 2-3: POST로 데이터 생성하기**

`create-survey.js`:

javascript

```javascript
async function createSurvey() {
  const newSurvey = {
    mbti: 'ENFP',
    colorCode: '#FF6B6B',
    password: '1234'
  };
  
  const response = await fetch('https://learn.codeit.kr/api/color-surveys', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',  // 필수!
    },
    body: JSON.stringify(newSurvey)  // 객체를 문자열로 변환
  });
  
  const data = await response.json();
  console.log('생성된 설문:', data);
}

createSurvey();
```

**💡 꼭 기억할 3가지**:

1. `method: 'POST'` 명시
2. `Content-Type: application/json` 헤더 설정
3. `JSON.stringify()`로 객체를 문자열로 변환

**실습 2-4: 직접 만들어보기 - PATCH 요청**

스스로 작성해보세요:

javascript

```javascript
// TODO: id가 1인 설문의 colorCode를 '#00FF00'으로 수정하는 함수 작성
// 힌트 1: URL은 https://learn.codeit.kr/api/color-surveys/1
// 힌트 2: method는 'PATCH'
// 힌트 3: body에는 { colorCode: '#00FF00', password: '1234' }

async function updateSurvey() {
  // 여기에 코드 작성
}

updateSurvey();
```

**정답 공유 및 설명**

---

## 🕒 3교시 : fetch 에러 처리와 실전 패턴

### 에러가 발생하는 상황들 (15분)

**실습 3-1: 에러 체험하기**

`errors.js`:

javascript

```javascript
// 1. 네트워크 오류
async function testNetworkError() {
  try {
    await fetch('https://wrong-domain-12345.com/api');
  } catch (error) {
    console.log('네트워크 오류:', error.message);
  }
}

// 2. 404 에러
async function test404Error() {
  const response = await fetch('https://learn.codeit.kr/api/wrong-path');
  console.log('응답 상태:', response.status);
  console.log('ok?', response.ok);
  // 놀랍게도 에러가 throw되지 않음!
}

// 3. JSON 파싱 에러
async function testParseError() {
  const response = await fetch('https://example.com');  // HTML 응답
  try {
    await response.json();  // JSON이 아닌데 파싱 시도
  } catch (error) {
    console.log('파싱 오류:', error.message);
  }
}

testNetworkError();
test404Error();
testParseError();
```

**💡 fetch의 특이한 점**:

- 404, 500 같은 HTTP 에러는 에러를 throw하지 않음!
- `response.ok`를 직접 확인해야 함

### 제대로 된 에러 처리 (45분)

**실습 3-2: 완벽한 에러 처리 함수**

`error-handling.js`:

javascript

```javascript
async function createSurveyWithErrorHandling(surveyData) {
  let response;
  
  // 1단계: 네트워크 전송
  try {
    response = await fetch('https://learn.codeit.kr/api/color-surveys', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(surveyData),
    });
  } catch (error) {
    console.error('네트워크 오류:', error);
    throw new Error('서버에 연결할 수 없습니다');
  }
  
  // 2단계: HTTP 상태 확인
  if (!response.ok) {
    throw new Error(`HTTP 오류! 상태: ${response.status}`);
  }
  
  // 3단계: JSON 파싱
  let data;
  try {
    data = await response.json();
  } catch (error) {
    console.error('JSON 파싱 오류:', error);
    throw new Error('서버 응답을 읽을 수 없습니다');
  }
  
  return data;
}

// 사용해보기
async function test() {
  try {
    const result = await createSurveyWithErrorHandling({
      mbti: 'ISFP',
      colorCode: '#FF0000',
      password: '1234'
    });
    console.log('성공:', result);
  } catch (error) {
    console.log('에러 발생:', error.message);
  }
}

test();
```

**실습 3-3: 재사용 가능한 API 함수 만들기**

`api.js`:

javascript

```javascript
// 공통 함수
async function request(url, options = {}) {
  let response;
  
  try {
    response = await fetch(url, options);
  } catch (error) {
    throw new Error('네트워크 전송 중 오류 발생');
  }
  
  if (!response.ok) {
    throw new Error(`HTTP 오류! 상태: ${response.status}`);
  }
  
  try {
    return await response.json();
  } catch (error) {
    throw new Error('JSON 파싱 중 오류 발생');
  }
}

// API 함수들
export async function getColorSurveys(queryParams = {}) {
  const url = new URL('https://learn.codeit.kr/api/color-surveys');
  Object.entries(queryParams).forEach(([key, value]) => {
    url.searchParams.append(key, value);
  });
  
  return request(url);
}

export async function createColorSurvey(surveyData) {
  return request('https://learn.codeit.kr/api/color-surveys', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(surveyData),
  });
}

export async function updateColorSurvey(id, surveyData) {
  return request(`https://learn.codeit.kr/api/color-surveys/${id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(surveyData),
  });
}
```

**함께 테스트하기**

---

## 🕓 4교시 : axios 시작하기

### axios 설치와 첫 사용 

**실습 4-1: axios 설치**

bash

```bash
npm install axios
```

**실습 4-2: fetch vs axios 비교**

`fetch-vs-axios.js`:

javascript

```javascript
import axios from 'axios';

// fetch 방식
async function withFetch() {
  const response = await fetch('https://learn.codeit.kr/api/color-surveys');
  const data = await response.json();
  console.log('fetch:', data);
}

// axios 방식
async function withAxios() {
  const response = await axios.get('https://learn.codeit.kr/api/color-surveys');
  console.log('axios:', response.data);
}

withFetch();
withAxios();
```

**💡 차이점 발견하기**:

- axios는 `.json()` 불필요 → 바로 `response.data`
- 코드가 더 간결함

### axios 인스턴스 만들기 

**실습 4-3: baseURL로 중복 제거**

`axios-instance.js`:

javascript

```javascript
import axios from 'axios';

// 인스턴스 생성
const api = axios.create({
  baseURL: 'https://learn.codeit.kr/api',
  timeout: 5000,  // 5초 안에 응답 없으면 에러
});

// 사용하기
async function getColorSurveys() {
  const response = await api.get('/color-surveys');  // 앞에 baseURL 자동 추가
  console.log(response.data);
}

async function getSurveyById(id) {
  const response = await api.get(`/color-surveys/${id}`);
  console.log(response.data);
}

getColorSurveys();
getSurveyById(1);
```

**실습 4-4: 완전한 API 모듈 만들기**

`colorSurveyApi.js`:

javascript

```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://learn.codeit.kr/api',
  timeout: 5000,
});

// 목록 조회
export async function getColorSurveys(queryParams = {}) {
  const response = await api.get('/color-surveys', {
    params: queryParams,  // 자동으로 쿼리 파라미터로 변환
  });
  return response.data;
}

// 단건 조회
export async function getColorSurvey(id) {
  const response = await api.get(`/color-surveys/${id}`);
  return response.data;
}

// 생성
export async function createColorSurvey(surveyData) {
  const response = await api.post('/color-surveys', surveyData);
  // JSON.stringify 불필요!
  // Content-Type 자동 설정!
  return response.data;
}

// 수정
export async function updateColorSurvey(id, surveyData) {
  const response = await api.patch(`/color-surveys/${id}`, surveyData);
  return response.data;
}

// 삭제
export async function deleteColorSurvey(id, password) {
  const response = await api.delete(`/color-surveys/${id}`, {
    data: { password }
  });
  return response.data;
}
```

**실습 4-5: API 모듈 사용하기**

`test-api.js`:

javascript

```javascript
import * as api from './colorSurveyApi.js';

async function testAPI() {
  // 생성
  const created = await api.createColorSurvey({
    mbti: 'INFJ',
    colorCode: '#9B59B6',
    password: '1234'
  });
  console.log('생성됨:', created);
  
  // 조회
  const surveys = await api.getColorSurveys({ limit: 3 });
  console.log('목록:', surveys);
  
  // 수정
  const updated = await api.updateColorSurvey(created.id, {
    colorCode: '#E74C3C',
    password: '1234'
  });
  console.log('수정됨:', updated);
}

testAPI();
```

---

## 🕔 5교시 : axios 에러 처리와 종합 실습

### axios 에러 처리 

**실습 5-1: axios 에러 구조 이해하기**

`axios-errors.js`:

javascript

```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://learn.codeit.kr/api',
});

async function testErrors() {
  try {
    // 존재하지 않는 리소스
    await api.get('/color-surveys/99999');
  } catch (error) {
    console.log('=== axios 에러 구조 ===');
    
    if (error.response) {
      // 서버가 응답했지만 2xx가 아닌 상태 코드
      console.log('상태 코드:', error.response.status);
      console.log('응답 데이터:', error.response.data);
      console.log('헤더:', error.response.headers);
    } else if (error.request) {
      // 요청은 보냈지만 응답이 없음
      console.log('응답 없음:', error.request);
    } else {
      // 요청 설정 중 에러
      console.log('기타 에러:', error.message);
    }
  }
}

testErrors();
```

**실습 5-2: 제대로 된 에러 처리**

`colorSurveyApi-with-error.js`:

javascript

```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://learn.codeit.kr/api',
  timeout: 5000,
});

export async function createColorSurvey(surveyData) {
  try {
    const response = await api.post('/color-surveys', surveyData);
    return response.data;
  } catch (error) {
    if (error.response) {
      // HTTP 에러
      const status = error.response.status;
      const data = error.response.data;
      
      if (status === 400) {
        throw new Error(`잘못된 요청: ${data.message || '입력값을 확인하세요'}`);
      } else if (status === 401) {
        throw new Error('인증이 필요합니다');
      } else if (status === 404) {
        throw new Error('리소스를 찾을 수 없습니다');
      } else {
        throw new Error(`서버 오류 (${status})`);
      }
    } else if (error.request) {
      throw new Error('서버 응답이 없습니다. 네트워크를 확인하세요');
    } else {
      throw new Error('요청 중 오류가 발생했습니다');
    }
  }
}

// 테스트
async function test() {
  try {
    // 일부러 잘못된 데이터 보내기
    await createColorSurvey({
      mbti: 'WRONG',  // 잘못된 MBTI
      colorCode: 'not-a-color',  // 잘못된 색상 코드
      password: '1234'
    });
  } catch (error) {
    console.log('에러 잡힘:', error.message);
  }
}

test();
```

### 종합 실습 프로젝트 

**실습 5-3: 완전한 CRUD 애플리케이션**

`survey-manager.js`:

javascript

```javascript
import * as api from './colorSurveyApi-with-error.js';

class SurveyManager {
  // 전체 목록 보기
  async list(options = {}) {
    try {
      const data = await api.getColorSurveys(options);
      console.log(`\n총 ${data.count}개의 설문`);
      data.results.forEach(survey => {
        console.log(`- [${survey.id}] ${survey.mbti}: ${survey.colorCode}`);
      });
    } catch (error) {
      console.error('조회 실패:', error.message);
    }
  }
  
  // 새 설문 만들기
  async create(mbti, colorCode, password) {
    try {
      const result = await api.createColorSurvey({ mbti, colorCode, password });
      console.log('\n✅ 설문 생성 성공!');
      console.log(`ID: ${result.id}`);
      console.log(`MBTI: ${result.mbti}`);
      console.log(`색상: ${result.colorCode}`);
      return result;
    } catch (error) {
      console.error('❌ 생성 실패:', error.message);
    }
  }
  
  // 설문 수정하기
  async update(id, colorCode, password) {
    try {
      const result = await api.updateColorSurvey(id, { colorCode, password });
      console.log('\n✅ 설문 수정 성공!');
      console.log(`새 색상: ${result.colorCode}`);
      return result;
    } catch (error) {
      console.error('❌ 수정 실패:', error.message);
    }
  }
  
  // 설문 삭제하기
  async delete(id, password) {
    try {
      await api.deleteColorSurvey(id, password);
      console.log('\n✅ 설문 삭제 성공!');
    } catch (error) {
      console.error('❌ 삭제 실패:', error.message);
    }
  }
}

// 사용 예시
async function demo() {
  const manager = new SurveyManager();
  
  console.log('=== 설문 관리 시스템 데모 ===');
  
  // 1. 현재 목록 보기
  console.log('\n1️⃣ 현재 설문 목록 (최근 5개)');
  await manager.list({ limit: 5 });
  
  // 2. 새 설문 만들기
  console.log('\n2️⃣ 새 설문 만들기');
  const created = await manager.create('ENFP', '#FF6B6B', '1234');
  
  // 3. 방금 만든 설문 수정하기
  if (created) {
    console.log('\n3️⃣ 색상 변경하기');
    await manager.update(created.id, '#4ECDC4', '1234');
  }
  
  // 4. 삭제하기
  if (created) {
    console.log('\n4️⃣ 설문 삭제하기');
    await manager.delete(created.id, '1234');
  }
  
  // 5. 최종 목록
  console.log('\n5️⃣ 최종 설문 목록');
  await manager.list({ limit: 5 });
}

demo();
```

**실행하고 결과 확인하기**

---

## 📝 마무리 과제 (수업 후 개인 학습)

### 과제 1: fetch로 TODO API 만들기

javascript

```javascript
// todos-api.js 파일을 만들고 다음 함수들을 구현하세요
// API: https://jsonplaceholder.typicode.com

// 1. 모든 TODO 가져오기
async function getTodos() {
  // 여기에 구현
}

// 2. 특정 TODO 가져오기
async function getTodo(id) {
  // 여기에 구현
}

// 3. 새 TODO 만들기
async function createTodo(todoData) {
  // 여기에 구현
  // todoData = { title: '제목', completed: false }
}

// 4. TODO 완료 처리
async function completeTodo(id) {
  // 여기에 구현 (PATCH 사용)
}
```

### 과제 2: axios로 영화 검색 앱 만들기

javascript

```javascript
// movie-search.js
// OMDb API 사용: http://www.omdbapi.com/
// API Key 발급 필요 (무료)

// 1. 영화 검색 기능
async function searchMovies(keyword) {
  // 여기에 구현
}

// 2. 영화 상세 정보 가져오기
async function getMovieDetail(imdbID) {
  // 여기에 구현
}

// 3. CLI로 사용할 수 있게 만들기
// node movie-search.js "Inception"
```

---

## 📚 핵심 정리

### fetch vs axios 비교표

|항목|fetch|axios|
|---|---|---|
|기본 제공|✅ 브라우저/Node.js 내장|❌ 설치 필요|
|JSON 변환|`.json()` 필요|자동|
|헤더 설정|수동|자동|
|에러 처리|`response.ok` 확인 필요|자동 throw|
|쿼리 파라미터|수동 변환|`params` 옵션|
|취소 기능|AbortController|CancelToken|
|진행률 추적|❌|✅|

### 언제 무엇을 써야 할까?

**fetch를 쓰면 좋을 때:**

- 간단한 요청
- 외부 라이브러리 설치를 피하고 싶을 때
- 번들 크기를 최소화하고 싶을 때

**axios를 쓰면 좋을 때:**

- 복잡한 API 통신
- 에러 처리가 중요할 때
- 인터셉터, 타임아웃 등 고급 기능이 필요할 때
- 여러 API 엔드포인트를 관리할 때

---

## ⏰ 시간 배분 요약

1. **1교시**: 네트워크 기초 + 첫 fetch 
2. **2교시**: fetch 다양한 요청 
3. **3교시**: fetch 에러 처리 
4. **4교시**: axios 시작 
5. **5교시**: axios 에러 처리 + 종합 실습 

각 실습마다 학생들이 직접 타이핑하고 실행해볼 시간을 충분히 주세요!****
