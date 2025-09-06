<div align="center">

# 🚀 OCI Discord Bot
### 완전 자동화 Always Free 인스턴스 생성기

<img src="https://img.shields.io/badge/OCI-Always_Free-orange?style=for-the-badge&logo=oracle" alt="OCI Always Free">
<img src="https://img.shields.io/badge/Discord-Bot-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord Bot">
<img src="https://img.shields.io/badge/Bash-Automation-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash Automation">
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License">

**Oracle Cloud Infrastructure의 Always Free 인스턴스를 Discord에서 간편하게 생성하세요!**

> 시작 시 언어 선택 프롬프트가 제공됩니다. 기본은 영어이며 한국어도 지원합니다. 선택한 언어는 `config.json`의 `LANGUAGE`에 저장되어 다음 실행부터 자동 적용됩니다.

[🚀 빠른 시작](#🛠️-빠른-시작) • [📖 사용법](#🎮-사용법) • [🔧 고급 설정](#🎨-고급-설정) • [🤝 기여하기](#🤝-기여하기)

[English](README.md) | **한국어**

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

## 💎 Oracle Cloud Always Free란 무엇인가요?

<div align="center">

**Oracle Cloud Always Free**는 강력한 클라우드 인프라를 영구적으로 무료로 제공합니다 - 개발자, 학생, 소규모 프로젝트에 완벽해요!

</div>

### 🎁 Oracle Always Free가 제공하는 것들

<table>
<tr>
<td width="50%">

#### 🖥️ **컴퓨트 인스턴스**
- **2개 E2.1.Micro** (AMD EPYC)
  - 각각 1 OCPU, 1GB RAM
  - 용도: 웹서버, API, 봇
- **4 OCPU A1.Flex** (ARM Ampere)
  - 총 4 OCPU, 24GB RAM
  - 설정 가능: 1-4개 인스턴스

</td>
<td width="50%">

#### 💾 **스토리지 & 네트워크**
- **200GB 블록 스토리지**
- **10GB 오브젝트 스토리지**
- **로드 밸런서** (10 Mbps)
- **VCN & 보안 목록**
- **Autonomous Database** (20GB)

</td>
</tr>
</table>

### 🎮 인기 사용 사례 & 예시

<details>
<summary><b>🎯 A1.Flex (ARM) - 고성능 애플리케이션</b></summary>

#### 🎮 **게임 서버**
```bash
# 마인크래프트 서버 (권장: 2 OCPU, 8GB)
Shape: VM.Standard.A1.Flex
설정: 2 OCPU, 8GB RAM
플레이어: ~10-20명 동시 접속
성능: 모드 서버에도 우수한 성능
```

#### 🌐 **개발 환경**
```bash
# 풀스택 개발 환경
Shape: VM.Standard.A1.Flex  
설정: 4 OCPU, 24GB RAM
스택: Docker, Kubernetes, CI/CD
용도: 팀 개발, 마이크로서비스
```

#### 🤖 **AI/ML 워크로드**
```bash
# 머신러닝 학습
설정: 4 OCPU, 24GB RAM
프레임워크: TensorFlow, PyTorch
용도: 모델 학습, 데이터 처리
```

</details>

<details>
<summary><b>⚡ E2.1.Micro (AMD) - 경량 서비스</b></summary>

#### 🌐 **웹 애플리케이션**
- 개인 웹사이트 & 블로그
- REST API & 마이크로서비스
- Discord/Telegram 봇
- 모니터링 서비스

#### 📊 **데이터베이스 & 캐싱**
- 소규모 데이터베이스 (PostgreSQL, MySQL)
- Redis 캐시 서버
- 메시지 큐
- 로그 수집기

</details>

### 💰 Always Free vs 유료 플랜 비교

| 기능 | Always Free | 유료 플랜 |
|:---:|:---:|:---:|
| **비용** | 월 $0 영구 무료 | 사용량 기반 과금 |
| **성능** | 프로덕션 가능 | 확장 가능 |
| **기간** | 시간 제한 없음 | 유연함 |
| **지원** | 커뮤니티 | 전문 지원 |

> **💡 프로 팁**: Always Free는 학습, 개발, 소규모 프로덕션 워크로드에 완벽합니다. 더 많은 리소스가 필요할 때 유료 플랜으로 확장하세요!

---

## ✨ 특징

<table>
<tr>
<td width="50%">

### 🎯 **Always Free 특화**
- ✅ **E2.1.Micro** (2개까지)
- ✅ **A1.Flex** (4 OCPU, 24GB RAM)
- ✅ 부트볼륨 무료(기본 100GB로 생성, 설정으로 변경 가능)
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

### 🔧 **완전 자동화**
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
| `/schedule` | 생성 간격 설정 | 3-60분 (기본값: 5분) |
| `/stats` | 상세 통계 분석 | 성공률, 기간별 분석 |
| `/instances` | 인스턴스 목록 | 실행/중지 인스턴스 현황 |
| `/resources` | 자원 사용량 | Always Free 한도 및 사용량 |
| `/alert` | 알림 설정 | 알림 구성 |
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
git clone https://github.com/CorelLinux/oci-simple-script.git
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

> 참고: 봇 경로(oci-script-and-bot.sh)로 인스턴스를 생성할 때도 `config.json`의 `bootVolumeConfig.sizeInGBs` 값이 자동 적용되어 `--source-boot-volume-size-in-gbs` 플래그로 전달됩니다(기본 100GB).

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
| `/schedule` | ⏰ | **생성 간격 설정** | 3-60분 (기본값: 5분) |
| `/stats` | 📊 | **상세 통계** | 성공률, 기간별 분석 |
| `/instances` | 🖥️ | **인스턴스 목록** | 실행/중지 인스턴스 현황 |
| `/resources` | 💰 | **자원 사용량** | Always Free 한도 및 사용량 |
| `/alert` | 🔔 | **알림 설정** | 알림 구성 |
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

### ⚡ v2.0 새로운 기능

<div align="center">

| 기능 | 설명 | 장점 |
|:---|:---|:---|
| **🎯 스마트 간격** | 기본 5분 시도 | 더 빠른 인스턴스 확보 |
| **⚙️ 유연한 타이밍** | `/schedule`로 3-60분 범위 | 수요에 따른 맞춤 설정 |
| **🌐 다국어 지원** | 영어/한국어 지원 | 더 나은 접근성 |
| **🔧 오류 복구** | 명령어 오류 처리 개선 | 더 안정적인 동작 |
| **📊 강화된 통계** | 상세 성공률 분석 | 더 나은 모니터링 |

</div>

> **💡 프로 팁**: 수요가 높은 시간대엔 `/schedule 3`, 수요가 낮은 시간대엔 `/schedule 30`을 사용하여 성공률을 최적화하세요.

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

<details>
<summary><b>🌐 언어 설정</b></summary>

봇은 영어와 한국어 인터페이스를 모두 지원합니다. `config.json`에서 설정하세요:

```json
{
  "LANGUAGE": "ko",  // "en": 영어, "ko": 한국어
  // ... 기타 설정 옵션
}
```

**언어 기능:**
- 🎯 선택한 언어로 Discord 명령어 설명
- 📝 선택한 언어로 봇 응답 메시지
- 🔧 오류 메시지 및 도움말 텍스트 현지화
- 🚀 매끄러운 전환 - config 편집 후 재시작만으로 변경

**언어 변경:**
```bash
# config.json 편집
nano config.json
# "LANGUAGE": "ko"를 "LANGUAGE": "en"으로 변경

# 봇 재시작
pm2 restart oci-discord-bot
```

</details>

---

## 🔧 트러블슈팅

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

### ❌ sudo에서 OCI CLI 사용 불가 문제

사용자 경로에 symlink로 설치된 OCI CLI는 sudo에서 접근할 수 없는 경우가 있습니다.

```bash
# 🔍 OCI CLI 설치 위치 확인
which oci
# 결과: /home/user/bin/oci

# 🔧 시스템 경로에 symlink 생성
sudo ln -s $(which oci) /usr/local/bin/oci

# ✅ sudo에서 사용 가능 확인
sudo oci --version
```

**자동 해결 방법:**
```bash
# 스크립트가 자동으로 symlink를 시도하지만, 수동 처리도 가능합니다
if command -v oci >/dev/null 2>&1; then
  sudo ln -sf "$(which oci)" /usr/local/bin/oci
  sudo oci --version
fi
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

## 📚 참고 자료

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

[Issue 생성](https://github.com/CorelLinux/oci-simple-script/issues)

</td>
<td width="33%" align="center">

**💡 기능 제안**  
새로운 아이디어를 공유하세요

[Feature Request](https://github.com/CorelLinux/oci-simple-script/issues)

</td>
<td width="33%" align="center">

**🔧 코드 기여**  
직접 개선사항을 작성하세요

[Pull Request](https://github.com/CorelLinux/oci-simple-script/pulls)

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

### 🌟 이 프로젝트가 도움이 되었다면 Star를 눌러주세요!

**Made with ❤️ for the Oracle Cloud Always Free Community**

</div>