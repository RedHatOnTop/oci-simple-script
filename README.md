# 🚀 OCI Discord Bot 자동화 셋업

OCI 인스턴스 자동 생성, Discord 봇 슬래시 명령어, pm2 서비스 관리, SSH 키 옵션까지 한 번에 자동화하는 솔루션입니다.

---

## 📝 주요 기능

- **config.json 기반 설정**  
  모든 OCI/디스코드 관련 값을 한 곳에서 관리
- **값 자동 분리 저장**  
  스크립트가 config.json에서 각 인자값(A, C, S, I 등)과 JSON 옵션을 파일로 자동 저장
- **OCI CLI 설치/설정 자동화**  
  키 생성/사용, config 자동 생성
- **사용자 SSH 키 선택 지원**  
  Termius/ssh-keygen 등 외부 생성 키 사용 가능
- **디스코드 봇 슬래시 명령어 지원**  
  `/status`, `/launch`, `/log`, `/stop`, `/start`, `/help`
- **pm2 프로세스 관리**  
  봇을 서버 서비스로 관리
- **컬러&이모지 로그**  
  bash/pm2/봇에서 가독성 높은 로그 출력
- **오류 자동 검출 및 안내**  
  누락, 권한, 설치, 키 등록 등 단계별 안내
- **스크립트/봇 로그 파일 관리**  
  `oci_bot.log`에 활동 기록

---

## ⚡️ 빠른 시작

### 1. `config.json` 파일 작성

아래 예시처럼 작성합니다.

```json
{
  "A": "ap-seoul-1",
  "C": "ocid1.compartment.oc1..exampleuniqueID1234",
  "S": "ocid1.subnet.oc1..exampleuniqueID5678",
  "I": "ocid1.image.oc1..exampleuniqueID9101",
  "availabilityConfig": {
    "isLiveMigrationPreferred": true,
    "recoveryAction": "RESTORE_INSTANCE"
  },
  "instanceOptions": {
    "areLegacyImdsEndpointsDisabled": false
  },
  "shapeConfig": {
    "ocpus": 1,
    "memoryInGBs": 6
  }
}
```

#### 각 값 구하는 방법

- **A (Availability Domain)**  
  - OCI 콘솔 → Compute → 인스턴스 생성 화면에서 "가용 도메인" 확인  
  - CLI: `oci iam availability-domain list --compartment-id <tenancy_ocid>`
- **C (Compartment OCID)**  
  - OCI 콘솔 → 좌측 메뉴 "Compartments"에서 대상 compartment 클릭  
  - 상세정보에서 OCID 복사  
  - CLI: `oci iam compartment list --compartment-id <tenancy_ocid>`
- **S (Subnet OCID)**  
  - OCI 콘솔 → 네트워킹 → Subnets에서 대상 subnet 클릭  
  - 상세정보에서 OCID 복사  
  - CLI: `oci network subnet list --compartment-id <compartment_ocid>`
- **I (Image OCID)**  
  - OCI 콘솔 → Compute → 이미지 → 대상 OS 이미지 선택  
  - 상세정보에서 OCID 복사  
  - CLI: `oci compute image list --compartment-id <compartment_ocid>`
- **availabilityConfig / instanceOptions / shapeConfig**  
  - [OCI 공식 CLI 문서](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitroubleshooting.htm) 및  
    [OCI 인스턴스 launch 옵션 문서](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/requests/LaunchInstanceRequest) 참고  
  - 예제 값은 위 config.json 참고

### 2. `.env` 파일 작성

```env
TENANCY_OCID=ocid1.tenancy.oc1..xxxx
USER_OCID=ocid1.user.oc1..xxxx
COMPARTMENT_OCID=ocid1.compartment.oc1..xxxx
FINGERPRINT=xx:xx:xx:xx:xx:xx
REGION=ap-seoul-1
DISCORD_TOKEN=your_discord_bot_token
DISCORD_CLIENT_ID=bot_client_id
DISCORD_GUILD_ID=server_guild_id
DISCORD_CHANNEL_ID=channel_id
CUSTOM_PUBLIC_KEY_PATH=/home/ubuntu/.ssh/id_rsa.pub   # (선택)
CUSTOM_PRIVATE_KEY_PATH=/home/ubuntu/.ssh/id_rsa      # (선택)
```

### 3. 스크립트 실행

```shell
bash oci_setup_and_bot.sh
```

### 4. OCI 콘솔에 퍼블릭키 등록

스크립트 안내에 따라 퍼블릭키를 OCI 콘솔에 등록합니다.

### 5. 디스코드에서 슬래시 명령어 사용

채널에서 아래 명령어를 사용할 수 있습니다:

| 명령어         | 설명                        |
|:--------------:|:---------------------------|
| `/status`      | 봇 상태, 업타임, 최근 결과 |
| `/launch`      | 인스턴스 즉시 생성         |
| `/log count:n` | 최근 n회 실행 로그         |
| `/stop`        | 자동 생성 중지             |
| `/start`       | 자동 생성 재시작           |
| `/help`        | 명령어 안내                |

---

## 📚 참고 사항

- Node.js **18+**, discord.js **14+**, pm2 **최신 버전** 권장
- 오류 발생시 로그 및 안내 메시지 확인
- 인스턴스 생성 명령어/옵션은 [OCI 공식 문서](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) 참고
- **보안 주의:** 키 파일의 권한은 반드시 `600`으로 설정하세요.
- 봇 로그는 `oci_bot.log`에 저장됩니다.

---

## 📰 참고한 글

- [Resolving Oracle Cloud Out of Capacity Issue and Getting Free VPS with 4 ARM Cores, 24GB of RAM (Medium)](https://hitrov.medium.com/resolving-oracle-cloud-out-of-capacity-issue-and-getting-free-vps-with-4-arm-cores-24gb-of-a3d7e6a027a8)
- [OCI 공식 CLI 및 API 문서](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitroubleshooting.htm)

---

## 🤝 기여/문의

- 개선 제안, 버그 신고, 추가 기능 요청은 **이슈**로 남겨주세요.
- Pull Request 환영합니다!

---

## 🏷️ 라이선스

MIT License
