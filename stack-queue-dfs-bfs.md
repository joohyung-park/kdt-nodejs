# 🚀 JavaScript로 배우는 자료구조와 알고리즘: Stack, Queue, DFS, BFS

## 💡 섹션 1: 기본 자료구조의 이해 

이 섹션에서는 **Stack(스택)**과 **Queue(큐)**의 개념을 배우고, **JavaScript 배열**을 이용해 이 두 자료구조를 간단히 구현해 봅니다.

### 1. Stack (스택)

#### 📝 개념: LIFO (Last-In, First-Out)

스택은 **가장 나중에 들어온 요소가 가장 먼저 나가는** 구조입니다. 마치 접시를 쌓아 올리는 것처럼, 맨 위에 쌓인 접시를 먼저 꺼내야만 그 아래 접시를 꺼낼 수 있습니다.

|**용어**|**의미**|**JS 배열 함수**|
|---|---|---|
|**Push (푸시)**|스택에 요소를 **추가**합니다.|`array.push()`|
|**Pop (팝)**|스택의 **가장 위** 요소를 **제거**하고 반환합니다.|`array.pop()`|
|**Peek (피크)**|스택의 가장 위 요소를 **확인**만 합니다.|`array[array.length - 1]`|

#### 🏢 일상생활 비유: 접시 쌓기

설거지를 마친 접시를 차곡차곡 쌓아 올린다고 상상해 보세요.

1. 새 접시는 **맨 위**에 놓입니다. (`Push`)
    
2. 사용할 접시를 꺼낼 때는 **맨 위**의 접시부터 꺼냅니다. (`Pop`)
    
3. 맨 아래에 있는 접시는 맨 나중에야 꺼낼 수 있습니다. (**Last-In, First-Out**)
    

#### 💻 JS를 이용한 Stack 구현 (데모)

JS에서 배열은 Stack처럼 동작할 수 있습니다.

```javascript
const stack = [];

// Push (요소 추가)
stack.push("A"); // [ 'A' ]
stack.push("B"); // [ 'A', 'B' ]
stack.push("C"); // [ 'A', 'B', 'C' ]

// Pop (가장 나중(위)에 들어온 'C'가 먼저 나감)
const item1 = stack.pop(); // item1: 'C', stack: [ 'A', 'B' ]
const item2 = stack.pop(); // item2: 'B', stack: [ 'A' ]

console.log(item1); // 출력: C
console.log(stack); // 출력: [ 'A' ]
```

---

### 2. Queue (큐)

#### 📝 개념: FIFO (First-In, First-Out)

큐는 **가장 먼저 들어온 요소가 가장 먼저 나가는** 구조입니다. 마치 영화관에서 줄을 서는 것처럼, 먼저 도착한 사람이 먼저 입장합니다.

|**용어**|**의미**|**JS 배열 함수**|
|---|---|---|
|**Enqueue (인큐)**|큐의 **뒤쪽**에 요소를 **추가**합니다.|`array.push()`|
|**Dequeue (디큐)**|큐의 **앞쪽** 요소를 **제거**하고 반환합니다.|`array.shift()`|

#### 🏢 일상생활 비유: 줄 서기

은행이나 영화관 앞에서 줄을 선다고 상상해 보세요.

1. 새로운 손님은 **줄의 맨 뒤**에 섭니다. (`Enqueue`)
    
2. 서비스를 받을 때는 **줄의 맨 앞**에 있는 사람부터 받습니다. (`Dequeue`)
    
3. 먼저 줄을 선 사람이 먼저 서비스를 받고 나갑니다. (**First-In, First-Out**)
    

#### 💻 JS를 이용한 Queue 구현 (데모)

JS에서 배열은 `push`와 `shift`를 함께 사용하면 Queue처럼 동작합니다. 다만, `shift()`는 배열 앞쪽 요소를 제거할 때 다른 요소들을 모두 한 칸씩 당겨야 하므로 **성능상 비효율적**일 수 있음을 언급합니다.

```javascript
const queue = [];

// Enqueue (뒤쪽에 추가)
queue.push("철수");   // [ '철수' ]
queue.push("영희");   // [ '철수', '영희' ]
queue.push("민수");   // [ '철수', '영희', '민수' ]

// Dequeue (가장 먼저 들어온 '철수'가 먼저 나감)
const next1 = queue.shift(); // next1: '철수', queue: [ '영희', '민수' ]
const next2 = queue.shift(); // next2: '영희', queue: [ '민수' ]

console.log(next1); // 출력: 철수
console.log(queue); // 출력: [ '민수' ]
```

---

## 🧭 섹션 2: 그래프 탐색 - DFS 

이 섹션에서는 **그래프**의 기본 개념을 소개하고, Stack의 특성을 활용하는 **깊이 우선 탐색 (DFS)**을 자세히 배웁니다.

### 1. 그래프의 기본 이해

#### 🗺️ 그래프란 무엇인가?

**그래프(Graph)**는 **정점(Vertex, 노드)**과 그 정점들을 잇는 **간선(Edge)**으로 이루어진 구조입니다. 우리 주변의 지도, 지하철 노선도, 소셜 미디어의 친구 관계 등이 모두 그래프로 표현될 수 있습니다.


## 🌲 트리 (Tree)는 그래프의 특수한 형태입니다

우리가 앞서 살펴본 그래프 외에도, 일상에서 흔히 접하는 또 다른 중요한 구조가 있습니다. 바로 **트리(Tree)**입니다.

### 1. 트리의 정의와 특징 🌳

트리는 그래프의 한 종류이지만, 다음과 같은 **매우 중요한 제약 조건**을 가지고 있습니다.

|**특징**|**그래프 (Graph)**|**트리 (Tree)**|
|---|---|---|
|**순환 (Cycle)**|순환이 가능합니다. (A → B → A)|**절대로 순환이 불가능**합니다.|
|**연결성**|모든 노드가 연결되어 있지 않아도 됩니다.|모든 노드가 연결되어 있으며, **하나의 경로**만 존재합니다.|
|**계층 구조**|보통 계층이 없습니다.|**부모/자식 관계**가 명확한 계층 구조입니다.|

> 💡 **비유:** 트리는 **뿌리(Root)**에서 시작해 가지를 뻗어나가는 나무와 같습니다. 자식 노드는 부모 노드로 되돌아갈 수 없으며, 가지가 엉켜 순환 고리를 만들지 않습니다.


```javascript
const treeGraph = {
    'A': ['B', 'C'], 
    'B': ['D', 'E'], 
    'C': ['F'],
    'D': [],
    'E': ['G'],
    'F': [],
    'G': []
};
```

### 2. DFS (Depth-First Search) - 깊이 우선 탐색

#### 📜 개념: 깊이 우선 탐색

**DFS**는 하나의 정점에서 시작해 **갈 수 있는 한 최대한 깊숙이** 내려가서 탐색을 마친 후, 더 이상 갈 곳이 없으면 되돌아와(Backtrack) 다른 경로를 탐색합니다.

DFS는 **Stack**의 원리(LIFO)와 일치합니다. 가장 최근에 확인한 경로를 따라 계속 내려가기 때문입니다.

#### 🧗‍♂️ 비유: 미로 찾기

미로에서 출구를 찾는다고 상상해 보세요.

1. 갈림길이 나오면, 일단 **한쪽 길을 선택**해 끝까지 가봅니다.
    
2. **막다른 길**에 도달하면, 마지막 갈림길로 **되돌아와** (Pop/Backtrack) 다른 길을 선택합니다.
    

#### 💻 JS 구현: Stack을 활용한 DFS (반복문)

**Stack**을 이용해 방문할 노드의 순서를 관리하며 깊이를 우선하여 탐색합니다.

```javascript
function dfs(graph, startNode) {
    const stack = [startNode];
    const visited = new Set();
    visited.add(startNode); // 시작 노드는 바로 방문 처리

    console.log("DFS 시작 노드:", startNode);

    while (stack.length > 0) {
        const node = stack.pop(); 
        
        console.log("DFS 방문:", node); 

        // 현재 노드에서 갈 수 있는 이웃 노드들을 탐색
        // 순서를 반대로 Push해야 Stack 특성상 원하는 순서로 탐색될 수 있음
        const neighbors = graph[node].slice().reverse(); 
        
        for (const neighbor of neighbors) {
            if (!visited.has(neighbor)) {
                visited.add(neighbor); // 방문 예정 노드도 미리 방문 처리
                stack.push(neighbor);
            }
        }
    }
}

// 예시 실행 순서 (A -> B -> D -> C 또는 A -> C -> B -> D)
// DFS는 깊이 우선이므로, 'A'에서 시작해 'B'로, 'B'에서 'D'로 깊게 내려간 후,
// 되돌아와 'C'를 탐색하는 순서가 될 가능성이 높습니다.
dfs(treeGraph, 'A');
```

**예시 순서:** `A`가 Stack에서 Pop되면, 이웃인 `B`, `C`가 Stack에 순서대로 Push됩니다. Stack의 LIFO 특성 때문에 `C`가 먼저 Pop되어 탐색이 **깊게** 이루어집니다.

---

## 🌊 섹션 3: 그래프 탐색 - BFS

이 섹션에서는 Queue의 특성을 활용하는 **너비 우선 탐색 (BFS)**을 자세히 배우고, DFS와 BFS를 비교해 봅니다.

### 1. BFS (Breadth-First Search) - 너비 우선 탐색

#### 📜 개념: 너비 우선 탐색

**BFS**는 하나의 정점에서 시작해, 현재 정점과 **가까운 정점들을 모두 탐색**한 후, 한 단계 더 떨어진 정점들을 탐색하는 방식입니다. 즉, 수평으로 넓게 확장하며 탐색합니다.

BFS는 **Queue**의 원리(FIFO)와 일치합니다. 먼저 도착한 노드(가까운 노드)부터 먼저 처리(탐색)하기 때문입니다.

#### 🗣️ 비유: 물결 퍼지기

호수에 돌을 던졌을 때 물결이 퍼져나가는 것을 상상해 보세요.

1. 돌이 떨어진 지점(시작점)에서 **가장 가까운 곳**부터 동그랗게 물결이 퍼집니다.
    
2. 가까운 곳의 물결이 모두 퍼지고 난 후에야 **다음 단계**의 물결이 퍼져나갑니다.
    

#### 💻 JS 구현: Queue를 활용한 BFS

**Queue**를 이용해 방문할 노드의 순서를 관리하며 너비를 우선하여 탐색합니다.

```javascript
function bfs(graph, startNode) {
    const queue = [startNode];
    const visited = new Set();
    visited.add(startNode); // 시작 노드는 바로 방문 처리

    console.log("BFS 시작 노드:", startNode);

    while (queue.length > 0) {
        const node = queue.shift(); 
        
        console.log("BFS 방문:", node); 

        // 현재 노드에서 갈 수 있는 이웃 노드들을 순서대로 Queue에 추가
        for (const neighbor of graph[node]) {
            if (!visited.has(neighbor)) {
                visited.add(neighbor);
                queue.push(neighbor);
            }
        }
    }
}

// 예시 실행 순서 (A -> B, C (레벨 1) -> D (레벨 2))
// BFS는 너비 우선이므로, 'A'와 가까운 노드들(B, C)을 먼저 탐색하고,
// 그 다음 가까운 노드(D)를 탐색합니다.
bfs(treeGraph, 'A');
```

**예시 순서:** `A`가 Queue에서 Dequeue되면, 이웃인 `B`, `C`가 Queue의 뒤쪽에 Enqueue됩니다. Queue의 FIFO 특성 때문에 `B`가 먼저 Dequeue되고, `C`가 Dequeue된 후에야 `D`가 탐색됩니다. (**너비 우선**)

### 2. DFS와 BFS 비교

|**구분**|**DFS (깊이 우선 탐색)**|**BFS (너비 우선 탐색)**|
|---|---|---|
|**핵심 자료구조**|**Stack (스택)**|**Queue (큐)**|
|**탐색 방식**|최대한 깊숙이 파고들어 탐색 (수직적)|가까운 노드부터 넓게 확장하며 탐색 (수평적)|
|**적합한 상황**|모든 경로를 탐색해야 할 때 (예: 미로 찾기, 모든 연결 요소 찾기)|**최단 경로**를 찾을 때 (각 단계가 거리를 의미, 예: 길 찾기, 레벨 탐색)|
|**비유**|미로에서 길 하나를 끝까지 가보는 방식|호수에 돌을 던져 물결이 퍼져나가는 방식|

## ✅ Q&A 및 마무리 (10분)
