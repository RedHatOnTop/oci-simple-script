<div align="center">

# 🚀 OCI Discord Bot
### 완전 자동화 Always Free 인스턴스 생성기

<img src="https://img.shields.io/badge/OCI-Always_Free-orange?style=for-the-badge&logo=oracle" alt="OCI Always Free">
<img src="https://img.shields.io/badge/Discord-Bot-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord Bot">
<img src="https://img.shields.io/badge/Bash-Automation-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash Automation">
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License">

**Oracle Cloud Infrastructure의 Always Free 인스턴스를 Discord에서 간편하게 생성하세요!**

[🚀 빠른 시작](#🛠️-빠른-시작) • [📖 사용법](#🎮-사용법) • [🔧 고급 설정](#🎨-고급-설정) • [🤝 기여하기](#🤝-기여하기)

</div>

---

## 🎬 데모

<div align="center">

### 📱 Discord Bot 명령어 데모

```bash
# Discord 채널에서 사용 예시
/status                    # 봇 상태 및 인스턴스 현황 확인
/launch                    # Always Free 인스턴스 즉시 생성
/log count:5               # 최근 5회 실행 로그 조회
/config                    # 현재 설정 정보 확인
```

### 🧙‍♂️ 설정 마법사 실행 화면

```bash
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🧙‍♂️ OCI Always Free Discord Bot                          ║
║                              설정 마법사                                    ║
║         Oracle Cloud Infrastructure Always Free 인스턴스 자동 생성         ║
╚══════════════════════════════════════════════════════════════════════════════╝

ℹ️ [12:34:56] 🎯 Always Free 특화: E2.1.Micro (2개), A1.Flex (4 OCPU, 24GB)
ℹ️ [12:34:56] 🤖 Discord 통합: 슬래시 명령어, 실시간 모니터링
ℹ️ [12:34:56] 🔧 완전 자동화: 기존 설정 인식, 실시간 검증
```

### 📊 Always Free 사용량 모니터링

```bash
📊 Always Free 사용량:
  • Shape: VM.Standard.A1.Flex
  • 사양: 2 OCPU, 12GB RAM
  • A1 총 한도 대비: 2/4 OCPU, 12/24GB RAM
  • 남은 자원: 2 OCPU, 12GB RAM
  • 부트볼륨: 100/200GB (무료)
```

</div>

---

## ✨ 특징

<table>
<tr>
<td width="50%">

### 🎯 **Always Free 특화**
- ✅ **E2.1.Micro** (2개까지)
- ✅ **A1.Flex** (4 OCPU, 24GB RAM)
- ✅ 부트볼륨 200GB 무료
- ✅ 실시간 한도 체크

</td>
<td width="50%">

### 🤖 **Discord 통합**
- ✅ 슬래시 명령어 지원
- ✅ 실시간 상태 모니터링
- ✅ 로그 및 오류 알림
- ✅ PM2 서비스 관리

</td>
</tr>
<tr>
<td>

### � **완전 자동화**
- ✅ OCI CLI 자동 설치
- ✅ 기존 config 자동 인식
- ✅ 실시간 API 검증
- ✅ 원클릭 설정

</td>
<td>

### 🎨 **사용자 친화적**
- ✅ 컬러풀한 로그 출력
- ✅ 이모지 기반 UI
- ✅ 단계별 안내
- ✅ 오류 자동 진단

</td>
</tr>
</table>

---

## 🚀 핵심 기능

<details>
<summary><b>🎯 Always Free 최적화</b></summary>

- **Shape 자동 필터링**: E2.1.Micro, A1.Flex만 표시
- **한도 실시간 체크**: OCPU/RAM 사용량 자동 계산
- **과금 방지**: Always Free 범위 초과시 경고
- **사용량 대시보드**: 남은 자원 실시간 표시

</details>

<details>
<summary><b>🤖 Discord Bot 명령어</b></summary>

| 명령어 | 기능 | 예시 |
|:---:|:---|:---|
| `/status` | 봇 상태 및 인스턴스 현황 | 업타임, 성공률, 최근 활동 |
| `/launch` | 인스턴스 즉시 생성 | Always Free Shape 자동 선택 |
| `/log` | 최근 실행 로그 조회 | 성공/실패 내역, 오류 진단 |
| `/config` | 설정 정보 확인 | 현재 Shape, 지역, 사양 |
| `/help` | 전체 명령어 안내 | 사용법 및 팁 |

</details>

<details>
<summary><b>🔧 스마트 설정 마법사</b></summary>

- **자동 환경 감지**: 기존 OCI config 파일 자동 로드
- **실시간 API 검증**: 사용 가능한 Shape/Image 실시간 조회
- **사양 맞춤 설정**: OCPU/RAM 조합 자동 검증
- **한글 UI**: 직관적인 한국어 인터페이스

</details>  

---

## 🛠️ 빠른 시작

### 1️⃣ 사전 준비

<table>
<tr>
<td width="33%">

#### 🔑 **OCI 계정**
- Oracle Cloud 무료 계정
- Always Free 자격 확인
- 결제카드 등록 (무료)

</td>
<td width="33%">

#### 🤖 **Discord Bot**
- [Developer Portal](https://discord.com/developers/applications)
- Bot Token 발급
- 서버 초대 링크 생성

</td>
<td width="33%">

#### 🖥️ **서버 환경**
- Linux (Ubuntu/CentOS)
- Bash 4.0+
- curl, jq 설치

</td>
</tr>
</table>

### 2️⃣ OCI API 키 설정

```bash
# 🔐 API 키 쌍 생성
mkdir -p ~/.oci
openssl genrsa -out ~/.oci/oci_api_key.pem 2048
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
chmod 600 ~/.oci/oci_api_key.pem

# 📋 공개키 내용 복사 (OCI 콘솔에 등록용)
cat ~/.oci/oci_api_key_public.pem
```

> **🔗 OCI 콘솔 등록 경로**  
> `Identity & Security` → `Users` → `본인 계정` → `API Keys` → `Add API Key`

### 3️⃣ OCI CLI 설정

```bash
# 🚀 OCI CLI 설치 (자동)
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# 📝 대화형 설정 (추천)
oci setup config

# 🔍 설정 확인
oci iam region list --output table
```

### 4️⃣ 마법사 실행

```bash
# 📥 스크립트 다운로드
git clone https://github.com/RedHatOnTop/oci-simple-script.git
cd oci-simple-script

# 🧙‍♂️ 설정 마법사 실행
bash oci-config-wizard.sh
```

<div align="center">

**🎉 모든 설정이 완료되면 `config.json`이 자동 생성됩니다!**

</div>

### 5️⃣ Discord Bot 실행

```bash
# 🤖 봇 시작
bash oci-script-and-bot.sh

# 📊 상태 확인
pm2 status
pm2 logs oci-discord-bot
```

---

## 🎮 사용법

### Discord 명령어

<div align="center">

| 명령어 | 아이콘 | 설명 | 결과 |
|:---:|:---:|:---|:---|
| `/status` | 📊 | **봇 상태 확인** | 업타임, 성공률, 최근 활동 |
| `/launch` | 🚀 | **인스턴스 생성** | Always Free Shape 자동 선택 |
| `/log` | 📋 | **로그 조회** | 최근 N회 실행 내역 |
| `/config` | ⚙️ | **설정 확인** | 현재 Shape, 지역, 사양 |
| `/stop` | ⏹️ | **자동 생성 중지** | 봇 일시정지 |
| `/start` | ▶️ | **자동 생성 재시작** | 봇 재개 |
| `/help` | ❓ | **도움말** | 전체 명령어 안내 |

</div>

### Always Free 사용량 모니터링

```bash
# 🔍 현재 인스턴스 확인
oci compute instance list --compartment-id $COMPARTMENT_ID --output table

# 📊 A1.Flex 사용량 조회
oci limits resource-availability get --compartment-id $COMPARTMENT_ID \
    --service-name compute --limit-name vm-standard-a1-core-count
```

---

## 🎨 고급 설정

### 🎯 Always Free 최적화

<details>
<summary><b>💡 Shape 선택 가이드</b></summary>

| Shape | OCPU | RAM | 인스턴스 | 용도 | 비고 |
|:---:|:---:|:---:|:---:|:---|:---|
| **E2.1.Micro** | 1 | 1GB | 2개 | 경량 웹서버, 봇 | AMD 기반 |
| **A1.Flex** | 1-4 | 6-24GB | 1-4개 | 개발서버, 학습 | ARM 기반 |

**💰 비용 계산기:**
- E2.1.Micro: 무료 (2개까지)
- A1.Flex: 총 4 OCPU, 24GB RAM 무료
- 부트볼륨: 200GB 무료

</details>

<details>
<summary><b>🔧 커스텀 SSH 키</b></summary>

```bash
# 🔑 기존 SSH 키 사용
export CUSTOM_PRIVATE_KEY_PATH="/path/to/your/private_key"
export CUSTOM_PUBLIC_KEY_PATH="/path/to/your/public_key.pub"

# 🔐 새 SSH 키 생성
ssh-keygen -t rsa -b 2048 -f ~/.ssh/oci_key -N ""
export CUSTOM_PRIVATE_KEY_PATH="$HOME/.ssh/oci_key"
export CUSTOM_PUBLIC_KEY_PATH="$HOME/.ssh/oci_key.pub"
```

</details>

---

## � 트러블슈팅

<details>
<summary><b>🚨 자주 발생하는 문제</b></summary>

### ❌ OCI CLI 설치 오류

```bash
# 🔍 설치 확인
oci --version

# 🔧 PATH 설정 확인
echo $PATH | grep -o "$HOME/bin"

# 🔄 재설치
curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh | bash
```

### ❌ API 키 권한 오류

```bash
# 🔐 권한 확인 및 수정
ls -la ~/.oci/
chmod 600 ~/.oci/oci_api_key.pem
chmod 644 ~/.oci/oci_api_key_public.pem

# 🔍 키 유효성 검사
oci iam region list --auth api_key
```

### ❌ Discord Bot Token 오류

```bash
# 🔍 토큰 확인
grep -o "discord_token" config.json

# 🔧 토큰 재설정
bash oci-config-wizard.sh
# Discord 설정 부분만 재실행
```

### ❌ "Out of Capacity" 오류

- **🔄 다른 지역 시도**: `ap-tokyo-1`, `ap-mumbai-1`
- **⏰ 시간대 변경**: 새벽 시간대 추천
- **🎯 Shape 변경**: E2.1.Micro → A1.Flex

</details>

<details>
<summary><b>📊 상태 확인 명령어</b></summary>

```bash
# 🤖 봇 상태
pm2 status
pm2 logs oci-discord-bot --lines 50

# 📊 인스턴스 목록
oci compute instance list --compartment-id $COMPARTMENT_ID --output table

# 💰 Always Free 사용량
oci limits resource-availability get \
    --compartment-id $COMPARTMENT_ID \
    --service-name compute \
    --limit-name vm-standard-a1-core-count
```

</details>

<details>
<summary><b>🔧 설정 파일 확인</b></summary>

```bash
# 📄 OCI 설정
cat ~/.oci/config

# 📋 봇 설정
cat config.json | jq .

# 📝 로그 파일
tail -f oci_bot.log
```

</details>

---

## � 참고 자료

<div align="center">

### 🔗 유용한 링크

| 카테고리 | 링크 | 설명 |
|:---:|:---|:---|
| **🏛️ 공식** | [Oracle Cloud 콘솔](https://cloud.oracle.com) | OCI 관리 콘솔 |
| **📖 문서** | [OCI CLI 가이드](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) | 공식 설치 가이드 |
| **🤖 봇** | [Discord Developer](https://discord.com/developers/applications) | 봇 생성 및 관리 |
| **💡 팁** | [Out of Capacity 해결](https://hitrov.medium.com/resolving-oracle-cloud-out-of-capacity-issue-and-getting-free-vps-with-4-arm-cores-24gb-of-a3d7e6a027a8) | 용량 부족 해결법 |

</div>

### 🎓 추천 학습 자료

- **OCI 기초**: [Oracle Cloud Infrastructure 시작하기](https://docs.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
- **Discord.js**: [공식 가이드](https://discordjs.guide/)
- **PM2**: [프로세스 관리 가이드](https://pm2.keymetrics.io/docs/)

---

## 🤝 기여하기

<div align="center">

### 🙋‍♂️ 참여 방법

<table>
<tr>
<td width="33%" align="center">

**🐛 버그 리포트**  
발견한 문제를 알려주세요

[Issue 생성](https://github.com/RedHatOnTop/oci-simple-script/issues)

</td>
<td width="33%" align="center">

**💡 기능 제안**  
새로운 아이디어를 공유하세요

[Feature Request](https://github.com/RedHatOnTop/oci-simple-script/issues)

</td>
<td width="33%" align="center">

**🔧 코드 기여**  
직접 개선사항을 작성하세요

[Pull Request](https://github.com/RedHatOnTop/oci-simple-script/pulls)

</td>
</tr>
</table>

</div>

### 📋 기여 가이드라인

1. **🍴 Fork** 이 저장소를 본인 계정으로 포크
2. **🌿 Branch** 새로운 기능 브랜치 생성
3. **💻 Code** 개선사항 작성 및 테스트
4. **📝 Commit** 명확한 커밋 메시지 작성
5. **🚀 PR** Pull Request 생성

---

<div align="center">

## 📄 라이선스

**MIT License** - 자유롭게 사용, 수정, 배포하세요!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

<div align="center">

### 📊 성능 지표

| 지표 | Always Free 한도 | 설명 |
|:---:|:---:|:---|
| **E2.1.Micro** | 2개 인스턴스 | AMD EPYC, 1 OCPU, 1GB RAM |
| **A1.Flex** | 4 OCPU, 24GB | ARM Ampere, 유연한 사양 설정 |
| **부트볼륨** | 200GB | Block Volume, 고성능 SSD |
| **아웃바운드** | 10TB/월 | 데이터 전송 무료 |
| **업타임** | 744시간/월 | 24×31일 무제한 가동 |

### 🏆 추천 구성

<table>
<tr>
<td align="center">

**🚀 고성능 서버**
```bash
Shape: A1.Flex
OCPU: 4개
RAM: 24GB
스토리지: 200GB
```
*개발서버, AI/ML, 데이터베이스*

</td>
<td align="center">

**⚖️ 균형잡힌 구성**
```bash
Shape: A1.Flex  
OCPU: 2개
RAM: 12GB
스토리지: 100GB
```
*웹서버, API 서버, 미디어 서버*

</td>
<td align="center">

**💾 경량화 서버**
```bash
Shape: E2.1.Micro
OCPU: 1개  
RAM: 1GB
스토리지: 50GB
```
*봇, 모니터링, 프록시*

</td>
</tr>
</table>

</div>

---

## 📄 라이선스

**MIT License** - 자유롭게 사용, 수정, 배포하세요!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

### 🌟 이 프로젝트가 도움이 되었다면 Star를 눌러주세요!

**Made with ❤️ for the Oracle Cloud Always Free Community**

</div>
