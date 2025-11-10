# Linux 기초 명령어 실습 강의 교안

## 강의 목표

- Linux 터미널 환경에 익숙해지기
- Docker 컨테이너를 활용한 SSH 원격 접속 실습
- 파이프를 활용한 강력한 명령어 조합
- 실무에서 바로 활용 가능한 실용적 패턴 학습

---

## 사전 준비 (강의 전 확인사항)

**필수 설치:**

- Docker Desktop 또는 OrbStack
- 터미널 (Mac: Terminal/iTerm2, Windows: WSL2)

**환경 확인:**

bash

```bash
docker --version
docker ps
```

---

## 1부: 기본 탐색과 파일 관리

### 1.1 현재 위치 파악과 이동

**명령어 소개:**

bash

```bash
pwd       # Print Working Directory
whoami    # 현재 사용자
ls        # 목록 보기
ls -la    # 상세 정보 + 숨김 파일
cd        # 디렉토리 이동
```

**실습 1:**

bash

```bash
pwd
whoami
ls -la
cd /tmp
pwd
cd ~
cd -      # 이전 디렉토리로
```

### 1.2 파일과 디렉토리 관리

**실습 2:**

bash

```bash
cd ~
mkdir -p practice/project/{src,docs,tests}
cd practice
touch README.md project/src/main.py

# 복사와 이동
cp README.md project/
mv README.md README.txt
cp -r project backup

# 확인
ls -R

# 정리
rm -rf backup
```

### 1.3 파일 내용 확인

**실습 3:**

bash

```bash
# 샘플 파일 생성
cat > test.txt << EOF
Line 1
Line 2
Line 3
Line 4
Line 5
EOF

cat test.txt
head -n 2 test.txt
tail -n 2 test.txt
less test.txt  # q로 종료
```

---

## 2부: 파이프와 텍스트 처리

### 2.1 파이프의 개념과 기본 사용

**개념 소개:** 파이프(`|`)는 한 명령어의 출력을 다음 명령어의 입력으로 연결합니다. Linux의 가장 강력한 기능입니다!

**기본 명령어:**

bash

```bash
wc -l     # 줄 수 세기
sort      # 정렬
uniq      # 중복 제거
grep      # 패턴 검색
cut       # 열 추출
```

**실습 4:**

bash

```bash
# 기본 파이프
ls -la | wc -l                    # 파일 개수
ls -la | grep "txt"               # txt 파일만
history | grep "cd"               # cd 명령 히스토리

# 여러 파이프 연결
cat test.txt | sort | uniq        # 정렬 후 중복 제거
ls -la | grep "txt" | wc -l       # txt 파일 개수
```

### 2.2 실전 파이프 패턴

**실습 5: 로그 분석**

bash

```bash
cd ~/practice

# 샘플 로그 생성
cat > server.log << EOF
2024-11-10 10:15:23 INFO User login: john
2024-11-10 10:16:45 ERROR Database connection failed
2024-11-10 10:17:12 INFO User login: alice
2024-11-10 10:18:33 ERROR Timeout: API request
2024-11-10 10:19:54 INFO User login: bob
2024-11-10 10:20:15 ERROR File not found
2024-11-10 10:21:36 INFO User login: alice
2024-11-10 10:22:47 INFO User logout: john
EOF

# 파이프로 분석하기
echo "=== 전체 로그 줄 수 ==="
cat server.log | wc -l

echo "=== 에러 로그만 보기 ==="
cat server.log | grep "ERROR"

echo "=== 에러 개수 세기 ==="
cat server.log | grep "ERROR" | wc -l

echo "=== 로그인한 사용자 목록 (중복 제거) ==="
cat server.log | grep "User login" | cut -d: -f2 | sort | uniq

echo "=== 사용자별 로그인 횟수 ==="
cat server.log | grep "User login" | cut -d: -f2 | sort | uniq -c | sort -rn
```

**실습 6: 시스템 정보 분석**

bash

```bash
# 현재 실행 중인 프로세스 분석
ps aux | head -10
ps aux | grep "bash"
ps aux | sort -k4 -rn | head -6        # 메모리 사용률 TOP 5

# 디스크 사용량 분석
du -sh * | sort -h                     # 크기순 정렬
```

**실습 7: 리다이렉션과 파이프 조합**

bash

```bash
# 출력을 파일로 저장
cat server.log | grep "ERROR" > errors.log
cat errors.log

# 추가 저장
cat server.log | grep "INFO" >> all_filtered.log
cat server.log | grep "ERROR" >> all_filtered.log
wc -l all_filtered.log
```

---

## 3부: Docker 컨테이너로 SSH 실습 환경 구축

### 3.1 SSH 개념과 Docker 환경 준비

**SSH란?**

- Secure Shell: 원격 서버에 안전하게 접속하는 프로토콜
- 실무에서 서버 관리의 필수 도구
- 오늘은 Docker 컨테이너를 원격 서버처럼 사용!

**실습 8: SSH 서버 컨테이너 생성**

bash

```bash
# 1. Ubuntu 컨테이너를 SSH 서버로 실행
docker run -d \
  --name ssh-server \
  -p 2222:22 \
  ubuntu:22.04 \
  sleep infinity

# 2. 컨테이너 확인
docker ps

# 3. 컨테이너 안에 SSH 서버 설치
docker exec -it ssh-server bash

# (컨테이너 안에서 실행)
apt-get update
apt-get install -y openssh-server sudo
mkdir -p /run/sshd

# 사용자 생성
useradd -m -s /bin/bash student
echo "student:password123" | chpasswd
echo "student ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH 설정 수정
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# SSH 서버 시작
/usr/sbin/sshd -D &

# 테스트용 파일 생성
su - student
echo "Hello from container" > ~/welcome.txt
exit
exit

# 4. SSH 서버가 잘 실행되었는지 확인
docker exec ssh-server ps aux | grep sshd
```

**빠른 설정 스크립트 (한 번에 실행):**

bash

```bash
# 호스트에서 실행
docker run -d --name ssh-server -p 2222:22 ubuntu:22.04 sleep infinity

docker exec ssh-server bash -c '
apt-get update && apt-get install -y openssh-server sudo vim && \
mkdir -p /run/sshd && \
useradd -m -s /bin/bash student && \
echo "student:password123" | chpasswd && \
echo "student ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
/usr/sbin/sshd -D &
'

echo "SSH 서버 준비 완료!"
```

### 3.2 SSH로 컨테이너 접속하기

**실습 9: SSH 접속**

bash

```bash
# 로컬 터미널에서 실행
ssh student@localhost -p 2222
# 비밀번호: password123

# 접속 후 확인
pwd
whoami
ls -la
cat welcome.txt

# 아직 종료하지 마세요!
```

**다른 터미널 창 열기:**

bash

```bash
# 새 터미널 창을 열어서
ssh student@localhost -p 2222

# 이제 2개의 SSH 세션이 동시에 연결됨!
# 한쪽에서는 파일을 만들고, 다른쪽에서 확인해보세요

# 터미널1에서:
echo "Created from terminal 1" > test.txt

# 터미널2에서:
ls -la
cat test.txt

# 양쪽 다 exit로 종료
exit
```

### 3.3 SSH 키 기반 인증

**실습 10: SSH 키 생성 및 등록**

bash

```bash
# 로컬에서 SSH 키 생성
cd ~/.ssh
ssh-keygen -t rsa -b 2048 -f docker_key -N ""

# 생성된 키 확인
ls -la docker_key*
cat docker_key.pub

# 공개키를 컨테이너에 복사
cat ~/.ssh/docker_key.pub | ssh student@localhost -p 2222 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh'
# 비밀번호: password123

# 이제 키로 접속 (비밀번호 없이!)
ssh -i ~/.ssh/docker_key student@localhost -p 2222

whoami
exit
```

**SSH Config 설정:**

bash

````bash
# 편하게 접속하기 위한 설정
nano ~/.ssh/config
```

다음 내용 추가:
```
Host mycontainer
    HostName localhost
    Port 2222
    User student
    IdentityFile ~/.ssh/docker_key
````

bash

```bash
# 이제 간단하게 접속!
ssh mycontainer
exit
```

### 3.4 SSH를 활용한 원격 작업

**실습 11: 원격 명령 실행**

bash

```bash
# 로컬에서 원격 명령 실행 (접속 안 하고)
ssh mycontainer 'pwd'
ssh mycontainer 'ls -la'
ssh mycontainer 'df -h'

# 원격 결과를 로컬 파일로 저장
ssh mycontainer 'ls -la' > container_files.txt
cat container_files.txt

# 파이프와 함께 사용
ssh mycontainer 'ps aux' | grep student
ssh mycontainer 'cat /etc/os-release' | grep VERSION
```

**실습 12: 파일 전송 (SCP)**

bash

```bash
# 로컬 파일을 컨테이너로 전송
cd ~/practice
echo "Local data" > local_file.txt
scp -P 2222 local_file.txt student@localhost:~/
ssh mycontainer 'cat ~/local_file.txt'

# 컨테이너 파일을 로컬로 가져오기
ssh mycontainer 'echo "Container data" > container_file.txt'
scp -P 2222 student@localhost:~/container_file.txt ./
cat container_file.txt

# config 설정했으면 더 간단하게
scp local_file.txt mycontainer:~/
scp mycontainer:~/container_file.txt ./
```

**실습 13: SSH + 파이프 고급 활용**

bash

```bash
# 먼저 컨테이너에 로그 파일 생성
ssh mycontainer 'cat > app.log << EOF
2024-11-10 10:15:23 INFO Application started
2024-11-10 10:16:45 ERROR Connection failed
2024-11-10 10:17:12 INFO Request processed
2024-11-10 10:18:33 ERROR Timeout
2024-11-10 10:19:54 INFO Request processed
EOF'

# 원격 로그를 로컬에서 파이프로 분석
ssh mycontainer 'cat app.log' | grep ERROR
ssh mycontainer 'cat app.log' | grep ERROR | wc -l
ssh mycontainer 'cat app.log' | cut -d' ' -f4 | sort | uniq -c

# 원격에서 파이프 실행 후 결과만 가져오기
ssh mycontainer 'cat app.log | grep ERROR | wc -l'

# 원격 디렉토리를 tar로 압축해서 로컬로 가져오기
ssh mycontainer 'tar czf - /home/student' | tar xzf - -C ./
ls -la home/student/
```

---

## 4부: 종합 실습 프로젝트

### 실전 시나리오: 원격 서버 모니터링 및 로그 분석

**시나리오:** 컨테이너에서 실행 중인 애플리케이션의 로그를 실시간으로 모니터링하고 분석합니다.

**실습 14: 종합 프로젝트**

bash

```bash
# 1. 컨테이너에 모니터링 환경 구축
ssh mycontainer << 'ENDSSH'
# 애플리케이션 로그 시뮬레이션 스크립트 생성
cat > /home/student/generate_logs.sh << 'EOF'
#!/bin/bash
while true; do
    RANDOM_NUM=$((RANDOM % 100))
    if [ $RANDOM_NUM -lt 70 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') INFO Request processed successfully"
    elif [ $RANDOM_NUM -lt 90 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') WARNING High memory usage"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR Connection timeout"
    fi
    sleep 2
done
EOF

chmod +x /home/student/generate_logs.sh

# 백그라운드로 로그 생성 시작
nohup /home/student/generate_logs.sh > /home/student/app.log 2>&1 &
echo "Log generator started"
exit
ENDSSH

# 2. 로컬에서 실시간 모니터링
echo "=== 실시간 로그 모니터링 (Ctrl+C로 종료) ==="
ssh mycontainer 'tail -f /home/student/app.log'

# (Ctrl+C로 종료 후)

# 3. 로그 분석
echo "=== 로그 통계 분석 ==="

echo "총 로그 수:"
ssh mycontainer 'wc -l /home/student/app.log'

echo "로그 레벨별 집계:"
ssh mycontainer 'cat /home/student/app.log' | cut -d' ' -f3 | sort | uniq -c

echo "에러 로그만 추출:"
ssh mycontainer 'cat /home/student/app.log | grep ERROR' > remote_errors.log
cat remote_errors.log

echo "최근 10개 에러:"
ssh mycontainer 'cat /home/student/app.log | grep ERROR | tail -10'

# 4. 분석 보고서 생성
cat > analysis_report.txt << EOF
=== 원격 서버 로그 분석 보고서 ===
생성 시간: $(date)

1. 전체 통계
EOF

echo "   총 로그 수: $(ssh mycontainer 'wc -l < /home/student/app.log')" >> analysis_report.txt
echo "   에러 수: $(ssh mycontainer 'grep -c ERROR /home/student/app.log')" >> analysis_report.txt
echo "   경고 수: $(ssh mycontainer 'grep -c WARNING /home/student/app.log')" >> analysis_report.txt
echo "" >> analysis_report.txt

echo "2. 레벨별 비율" >> analysis_report.txt
ssh mycontainer 'cat /home/student/app.log' | cut -d' ' -f3 | sort | uniq -c >> analysis_report.txt

cat analysis_report.txt

# 5. 보고서를 컨테이너로 다시 전송
scp analysis_report.txt mycontainer:~/
ssh mycontainer 'ls -la analysis_report.txt'

# 6. 로그 생성 프로세스 종료
ssh mycontainer 'pkill -f generate_logs.sh'
```

**실습 15: 여러 컨테이너 동시 관리 (보너스)**

bash

```bash
# 두 번째 컨테이너 생성
docker run -d --name ssh-server2 -p 2223:22 ubuntu:22.04 sleep infinity

# 같은 방식으로 SSH 설정
docker exec ssh-server2 bash -c '
apt-get update && apt-get install -y openssh-server sudo && \
mkdir -p /run/sshd && \
useradd -m -s /bin/bash student && \
echo "student:password123" | chpasswd && \
/usr/sbin/sshd -D &
'

# SSH config에 추가
cat >> ~/.ssh/config << EOF

Host container2
    HostName localhost
    Port 2223
    User student
    IdentityFile ~/.ssh/docker_key
EOF

# 공개키 복사
ssh-copy-id -p 2223 student@localhost

# 여러 컨테이너 동시 확인
for container in mycontainer container2; do
    echo "=== $container ==="
    ssh $container 'hostname && df -h | head -2'
    echo ""
done
```

---

## 마무리: 치트시트

### 파이프 패턴 모음

bash

```bash
# 로그 분석
cat log | grep "pattern" | wc -l              # 패턴 개수
cat log | cut -d' ' -f1 | sort | uniq -c      # 필드별 집계
cat log | grep "ERROR" | tail -20             # 최근 에러 20개

# 시스템 모니터링
ps aux | sort -k3 -rn | head -5               # CPU 사용률 TOP 5
du -sh * | sort -h | tail -5                  # 가장 큰 파일 5개

# 파일 검색
find . -name "*.log" -type f | wc -l          # 로그 파일 개수
ls -la | grep "^d" | wc -l                    # 디렉토리 개수
```

### SSH 명령어 모음

bash

```bash
# 접속
ssh user@host -p PORT
ssh -i keyfile user@host

# 파일 전송
scp -P PORT file user@host:/path/
scp -P PORT user@host:/path/file ./
scp -r -P PORT dir user@host:/path/

# 원격 명령
ssh user@host 'command'
ssh user@host 'cmd1 && cmd2 | cmd3'

# SSH + 파이프
ssh user@host 'cat log' | grep ERROR
ssh user@host 'tar czf - dir' | tar xzf -
```

### 단축키

bash

```bash
Ctrl + C        # 프로세스 중단
Ctrl + D        # 로그아웃/EOF
Ctrl + Z        # 프로세스 일시정지
Ctrl + L        # 화면 클리어
Ctrl + R        # 명령어 히스토리 검색
Tab             # 자동완성
```

### 실습 환경 정리

bash

```bash
# 컨테이너 중지 및 삭제
docker stop ssh-server ssh-server2
docker rm ssh-server ssh-server2

# 나중에 다시 사용하려면 stop만 하고 rm 생략
# docker start ssh-server 로 재시작 가능
```

---

## 과제 (선택)

1. 3개의 컨테이너를 만들고 각각 다른 로그를 생성하여 모든 컨테이너의 에러 로그를 한 파일로 수집하기
2. SSH + 파이프를 활용한 원격 백업 스크립트 작성하기
3. 원격 서버의 디스크 사용량을 모니터링하고 80% 이상이면 알림 출력하는 스크립트 만들기
