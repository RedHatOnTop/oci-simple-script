# 🚀 OCI Discord Bot 자동화 셋업

OCI 인스턴스 자동 생성, Discord 봇 슬래시 명령어, pm2 서비스 관리, SSH 키 옵션까지 한 번에 자동화하는 솔루션입니다.

---

## 📝 주요 기능

- **통합 config.json 기반 설정**  
  모든 OCI/디스코드 관련 값을 한 곳에서 관리  
- **값 자동 분리/선택 저장**  
  스크립트가 shape, subnet, image를 OCI CLI로 실제 가능한 목록을 보여주고 번호 선택  
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

### 1. config.json 생성

아래 스크립트를 실행하세요:

```bash
bash oci_config_wizard.sh
```

- 스크립트가 필요한 정보를 하나씩 입력받고,
- shape, subnet, image는 oci 명령어로 조회 후 번호로 선택하게 합니다.
- 모든 값이 하나의 config.json에 저장됩니다.

#### 각 값 구하는 방법

- **A (Availability Domain)/SHAPE/SUBNET/IMAGE**
  - 스크립트에서 자동으로 OCI CLI로 목록을 조회 후, 번호로 선택
  - 직접 OCI 콘솔 또는 아래 명령어로도 확인 가능  
    - Shape: `oci compute shape list --compartment-id <compartment_ocid>`
    - Subnet: `oci network subnet list --compartment-id <compartment_ocid>`
    - Image: `oci compute image list --compartment-id <compartment_ocid>`

- **계정 정보 등 기타 값**
  - OCI 콘솔에서 복사  
  - Discord 개발자 페이지에서 토큰 및 ID 복사

### 2. 봇/자동화 스크립트 실행

봇 및 인스턴스 자동화 스크립트는 config.json만을 참조하도록 개선되어 있습니다.

### 3. OCI 콘솔에 퍼블릭키 등록

스크립트 안내에 따라 퍼블릭키를 OCI 콘솔에 등록합니다.

### 4. 디스코드에서 슬래시 명령어 사용

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
