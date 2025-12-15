- Docker환경 준비
	- MacOS
		1. OrbStack설치
	- Windows
		1. WSL 설치
		2. Docker Desktop 설치
		3. 윈도우 검색창에서 선택적 기능 -> OpenSSH Server 설치
    <img width="2567" height="2005" alt="스크린샷 2025-12-12 231102" src="https://github.com/user-attachments/assets/a0711272-3975-4520-b199-5336d5e1d6fe" />

		4. 윈도우 검색창에서 서비스 -> OpenSSH Server 자동
    <img width="1179" height="1415" alt="스크린샷 2025-12-12 233352" src="https://github.com/user-attachments/assets/d05fadc4-3a79-4544-972f-3d926295640d" />

		5. winget install git.git
- Git SSH Key 등록
	- cat ~/.ssh/id*.pub 있는지 확인
		- 없으면 ssh-keygen 으로 password없이 생성
		- 새로 생성한 pub key 각자 github ->settings ->ssh key에 등록
	- ssh -T git@github.com  터미널에서 성공 확인
- Devpod 준비
	- 설치: [Install DevPod | DevPod docs | DevContainers everywhere](https://devpod.sh/docs/getting-started/install)
	- SSH Key 설정 및 credential forwarding
  <img width="2400" height="1657" alt="Pasted image 20251215132707" src="https://github.com/user-attachments/assets/c87e00ad-bcb3-4ff0-bfa6-18c99e1e133b" />

	- 강사가 준비한 공통 환경(devcontainer.json)을 fork한 project로 devpod 생성
