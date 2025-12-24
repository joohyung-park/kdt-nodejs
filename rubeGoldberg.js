let startRubeGoldberg;

const rubeGoldberg = new Promise((resolve) => {
  startRubeGoldberg = resolve;
})
  .then((ball) => {
    console.log("step1:", ball);
    return ball;
  })
  .then((ball) => {
    console.log("step2:", ball);
    return ball;
  })
  .then((ball) => {
    console.log("step3:", ball);
    return ball;
  });

setTimeout(() => {
  startRubeGoldberg("🏀");
}, 3000);
