function step1() {
  return "step1";
}

function step2() {
  return "step2";
}

const callback1 = (
  step1Result // Promise{"step1"}
) =>
  step2().then((step2Result) => ({
    // "step2"
    step1: step1Result,
    step2: step2Result,
  }));

//ambient context 척하면 척 개떡같이 말해도 찰떡같이 알아들어
// 여러 함수들이 연대해서 한 맥락, 목적을 달성한다.
// 동기적으로 값을 기다리고 있다.
// 부모 자식 함수 사이에 다른 일을 수행할 수가 없어
// 부모는 자식을 기다리고 끝날떄 까지 cpu를 안놔줘.
function root() {
  const step1Result = step1();
  const step2Result = step2();
  console.log(step1Result + step2Result);
}

// 맥락 없음
// 다 따로 놈 이벤트 기반임
// 이벤트 일어나야 콜백 수행함
// 이벤트 일어나도 즉시 수행하는 것도 아님
// 이벤트 일어나면 즉시 번호표를 뽑아줌 콜백(할일)을 queue에 넣어줌
// 비동기 성. 다른일 할 수 있음.
// queue에 다른 일 끼워넣으면 다른거 먼저하 ㄹ수도 있고.
new Promise()
  .then(step1) // 앞에 거 끝나면 나 이거 해줘
  .then((step1Result) => ({
    step1: step1Result,
    step2: step2(),
  }))
  .then(({ step1, step2 }) => console.log(step1 + step2));


  // 결론
  // 오늘날에 Promise를 resolve, then으로 직접 조작 하는일은 많지 않다.
  // async function안에서 await을 호출하는 스타일로
  // Promise를 값으로 바꿔서 저장하고 scope에 변수로 저장하는 것 처럼 코딩
  // 함수 처럼 편리한 사용성 + 비동기
async function asyncFn() {
  const step1Result = await step1();  // 기다리지 않는다.
  const step2Result = await step2();
  console.log(step1Result + step2Result);
}


let scope = {};
step1()
  .then((s1) => {
    scope.step1Result = s1;
    return step2();
  })
  .then((s2) => {
    scope.step2Result = s2;
    console.log(scope.step1Result + scope.step2Result);
  });
