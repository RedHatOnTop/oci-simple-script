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

```json
{
  "A": "ap-SEOUL-1",
  "C": "ocid1.compartment.oc1..xxx",
  "S": "ocid1.subnet.oc1..xxx",
  "I": "ocid1.image.oc1..xxx",
  "availabilityConfig": { ... },
  "instanceOptions": { ... },
  "shapeConfig": { ... }
}
```

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

## 🤝 기여/문의

- 개선 제안, 버그 신고, 추가 기능 요청은 **이슈**로 남겨주세요.
- Pull Request 환영합니다!

---

## 🏷️ 라이선스

MIT License
