#!/bin/bash

# ===================================================================  echo -e "${CYAN}│${RESET} ☐ Discord Bot 생성 및 토큰 보유                            ${CYAN}│${RESET}"
  echo -e "${CYAN}│${RESET} ☐ 서버에 봇 초대 및 권한 설정                              ${CYAN}│${RESET}"
  echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${RESET}"
  echo ""
  
  log info "💡 OCI CLI 미설정 시:"
  echo -e "   ${CYAN}oci setup config${RESET}"
  echo ""
  log info "💡 Discord Bot 생성:"
  echo -e "   ${CYAN}https://discord.com/developers/applications${RESET}"
  echo """💡 OCI CLI 미설정 시:"
  echo -e "   ${CYAN}oci setup config${RESET}"
  echo ""
  log info "💡 Discord Bot 생성:"
  echo -e "   ${CYAN}https://discord.com/developers/applications${RESET}"
  echo ""====
# 🧙‍♂️ OCI Always Free Discord Bot 설정 마법사
# =============================================================================
# Oracle Cloud Infrastructure Always Free 인스턴스 자동 생성 봇을 위한
# 완전 자동화된 설정 마법사입니다.
# 
# 특징:
# • 🎯 Always Free Shape만 선별 (E2.1.Micro, A1.Flex)
# • 🔧 기존 OCI config 자동 인식
# • ⚡ 실시간 API 검증
# • 🎨 한국어 UI 지원
# =============================================================================

set -euo pipefail

# 🔒 Root/Sudo 실행 방지
if [[ $EUID -eq 0 ]]; then
  echo -e "\033[1;31m❌ 오류: 이 스크립트는 root 또는 sudo로 실행할 수 없습니다.\033[0m"
  echo ""
  echo -e "\033[1;33m⚠️ 이유:\033[0m"
  echo "• OCI CLI 설치 스크립트가 root 실행을 차단합니다"
  echo "• 사용자 홈 디렉토리에 설치되어야 합니다"
  echo ""
  echo -e "\033[0;36mℹ️ 해결방법:\033[0m"
  echo "일반 사용자로 실행하세요:"
  echo -e "\033[1;32mbash oci-config-wizard.sh\033[0m"
  echo ""
  exit 1
fi

# 🎨 컬러 및 이모지 정의
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# 📝 로그 함수들
log() {
  local type="$1"
  local msg="$2"
  local timestamp=$(date '+%H:%M:%S')
  
  case "$type" in
    success) echo -e "${GREEN}✅ [${timestamp}]${RESET} ${msg}" ;;
    error)   echo -e "${RED}❌ [${timestamp}]${RESET} ${msg}" ;;
    warn)    echo -e "${YELLOW}⚠️ [${timestamp}]${RESET} ${msg}" ;;
    info)    echo -e "${CYAN}ℹ️ [${timestamp}]${RESET} ${msg}" ;;
    wizard)  echo -e "${MAGENTA}🧙‍♂️ [${timestamp}]${RESET} ${BOLD}${msg}${RESET}" ;;
    input)   echo -e "${BLUE}📝 [${timestamp}]${RESET} ${msg}" ;;
    fail)    echo -e "${RED}❌ [${timestamp}]${RESET} ${msg}" ;;
    *)       echo -e "${WHITE}${msg}${RESET}" ;;
  esac
}

print_header() {
  clear
  echo -e "${CYAN}${BOLD}"
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║                                                                              ║"
  echo "║                    🧙‍♂️ OCI Always Free Discord Bot                           ║"
  echo "║                              설정 마법사                                     ║"
  echo "║                                                                              ║"
  echo "║         Oracle Cloud Infrastructure Always Free 인스턴스 자동 생성            ║"
  echo "║                                                                              ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
  echo ""
  log info "🎯 Always Free 특화: E2.1.Micro (2개), A1.Flex (4 OCPU, 24GB)"
  log info "🤖 Discord 통합: 슬래시 명령어, 실시간 모니터링"
  log info "🔧 완전 자동화: 기존 설정 인식, 실시간 검증"
  echo ""
}

CONFIG_FILE="config.json"
OCI_CONFIG_FILE="$HOME/.oci/config"

# 메인 시작
print_header

log wizard "OCI/Discord Bot 완전 자동화 설정 마법사를 시작합니다!"
echo ""
log info "💡 문제가 발생하면 다음과 같이 실행하세요:"
echo -e "   ${CYAN}DEBUG=1 bash oci-config-wizard.sh${RESET}        # 디버깅 모드"
echo -e "   ${CYAN}SHOW_HELP=1 bash oci-config-wizard.sh${RESET}    # OCI 설치 도움말"
echo ""

print_requirements() {
  echo -e "${YELLOW}${BOLD}📋 사전 요구사항 체크리스트${RESET}"
  echo -e "${CYAN}┌────────────────────────────────────────────────────────────────┐${RESET}"
  echo -e "${CYAN}│${RESET} ☐ OCI CLI 설치 완료                                        ${CYAN}│${RESET}"
  echo -e "${CYAN}│${RESET} ☐ OCI config 파일 설정 (~/.oci/config)                    ${CYAN}│${RESET}"
  echo -e "${CYAN}│${RESET} ☐ Discord Bot 생성 및 토큰 보유                            ${CYAN}│${RESET}"
  echo -e "${CYAN}│${RESET} ☐ 서버에 봇 초대 및 권한 설정                              ${CYAN}│${RESET}"
  echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${RESET}"
  echo ""
  
  log info "� OCI CLI 미설정 시:"
  echo "   ${CYAN}oci setup config${RESET}"
  echo ""
  log info "💡 Discord Bot 생성:"
  echo "   ${CYAN}https://discord.com/developers/applications${RESET}"
  echo ""
  
  read -p "모든 요구사항이 준비되었으면 Enter를 눌러 계속하세요..." -n 1
  echo ""
}

print_requirements

# 필수 도구 확인
check_dependencies() {
  log wizard "1단계: 필수 도구 확인 중..."
  echo ""
  
  local deps_ok=true
  
  # jq 확인 및 자동 설치
  if command -v jq >/dev/null 2>&1; then
    log success "jq 설치 확인됨 $(jq --version)"
  else
    log warn "jq가 설치되지 않았습니다. 자동 설치를 시도합니다..."
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y jq
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y jq
    elif command -v brew >/dev/null 2>&1; then
      brew install jq
    else
      log error "jq 자동 설치 실패. 수동 설치 필요:"
      echo "  ${CYAN}Ubuntu/Debian:${RESET} sudo apt install jq"
      echo "  ${CYAN}CentOS/RHEL:${RESET} sudo yum install jq"
      echo "  ${CYAN}macOS:${RESET} brew install jq"
      deps_ok=false
    fi
    
    if command -v jq >/dev/null 2>&1; then
      log success "jq 설치 완료 $(jq --version)"
    fi
  fi
  
  # OCI CLI 확인 (단순화된 명령어 출력 검증)
  log info "🔍 OCI CLI 확인 중..."
  
  if oci --version >/dev/null 2>&1; then
    local oci_version=$(oci --version 2>/dev/null | head -1)
    log success "OCI CLI 설치 확인됨: ${oci_version}"
  else
    log warn "OCI CLI가 설치되지 않았거나 PATH에 없습니다."
    echo ""
    read -p "지금 설치하시겠습니까? (y/N): " install_oci
    if [[ "$install_oci" =~ ^[Yy]$ ]]; then
      log info "OCI CLI 설치 중..."
      bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
      
      log success "✅ OCI CLI 설치 완료! 터미널을 재시작하거나 'export PATH=\"\$HOME/bin:\$PATH\"'를 실행하세요."
      echo ""
      log info "설치 후 스크립트를 다시 실행하세요."
      exit 0
    else
      log error "OCI CLI가 필요합니다. 다음 명령어로 설치하세요:"
      echo -e "  ${CYAN}bash -c \"\$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)\"${RESET}"
      deps_ok=false
    fi
  fi
  
  # OCI config 파일 확인 및 검증
  if [[ -f "$OCI_CONFIG_FILE" ]]; then
    log success "OCI config 파일 발견: $OCI_CONFIG_FILE"
    
    # config 파일 유효성 검사
    local required_fields=("user" "tenancy" "region" "key_file" "fingerprint")
    local missing_fields=()
    
    for field in "${required_fields[@]}"; do
      if ! grep -q "^${field}=" "$OCI_CONFIG_FILE"; then
        missing_fields+=("$field")
      fi
    done
    
    if [[ ${#missing_fields[@]} -eq 0 ]]; then
      log success "OCI config 파일 형식 검증 완료"
      
      # API 키 파일 존재 확인
      local key_file=$(grep "^key_file=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ' | sed 's|^~|'"$HOME"'|')
      if [[ -f "$key_file" ]]; then
        log success "API 키 파일 확인됨: $key_file"
      else
        log warn "API 키 파일을 찾을 수 없습니다: $key_file"
        echo -e "  ${YELLOW}키 파일 경로를 확인하거나 다시 생성하세요.${RESET}"
      fi
    else
      log warn "OCI config 파일에 다음 필드가 누락되었습니다:"
      for field in "${missing_fields[@]}"; do
        echo -e "  • ${RED}$field${RESET}"
      done
      echo -e "  ${CYAN}재설정 명령어:${RESET} oci setup config"
    fi
  else
    log error "OCI config 파일이 없습니다: $OCI_CONFIG_FILE"
    echo -e "  ${CYAN}설정 명령어:${RESET} oci setup config"
    deps_ok=false
  fi
  
  if [[ "$deps_ok" == "false" ]]; then
    echo ""
    log error "필수 요구사항이 충족되지 않았습니다. 위 안내에 따라 설정 후 다시 실행하세요."
    exit 1
  fi
  
  echo ""
  log success "🎉 모든 필수 도구 확인 완료!"
  echo ""
}

# 🆕 진행률 표시 함수
print_progress() {
  local step="$1"
  local message="$2"
  echo ""
  log wizard "[$step/5] $message"
  echo ""
}

# 🆕 디버깅 정보 출력 함수
print_debug_info() {
  if [[ "${DEBUG:-}" == "1" ]]; then
    echo ""
    log info "🔍 디버깅 정보:"
    echo -e "  • Shell: $SHELL"
    echo -e "  • PATH: ${PATH:0:150}..."
    echo -e "  • HOME: $HOME"
    echo -e "  • PWD: $PWD"
    echo -e "  • USER: ${USER:-$(whoami)}"
    echo ""
  fi
}

check_dependencies
print_debug_info

# 🆕 OCI CLI 설치 도움말 함수
show_oci_install_help() {
  if [[ "${SHOW_HELP:-}" == "1" ]]; then
    echo ""
    log info "💡 OCI CLI 수동 설치 가이드:"
    echo -e "  ${CYAN}1. 공식 설치 스크립트:${RESET}"
    echo -e "     bash -c \"\$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)\""
    echo ""
    echo -e "  ${CYAN}2. 설치 후 PATH 설정:${RESET}"
    echo -e "     export PATH=\"\$HOME/bin:\$PATH\""
    echo -e "     echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc"
    echo ""
    echo -e "  ${CYAN}3. 설치 확인:${RESET}"
    echo -e "     oci --version"
    echo ""
    echo -e "  ${YELLOW}일반적인 설치 경로:${RESET}"
    echo -e "  • Ubuntu/Debian: ~/.local/bin/oci"
    echo -e "  • CentOS/RHEL: ~/bin/oci"
    echo -e "  • 수동 설치: ~/lib/oracle-cli/bin/oci"
    echo ""
  fi
}

show_oci_install_help

# 기존 config.json 로드
if [ -f "$CONFIG_FILE" ]; then
  EXISTING=$(cat "$CONFIG_FILE")
  log info "기존 config.json 파일을 발견했습니다."
else
  EXISTING="{}"
  log info "새로운 config.json 파일을 생성합니다."
fi

# jq helper: 기존 값 있으면 그 값 반환
get_current() {
  local key="$1"
  echo "$EXISTING" | jq -r --arg k "$key" '.[$k] // empty'
}

# 값을 입력받고 즉시 저장 (Discord 설정용)
prompt_and_save() {
  local key="$1"
  local msg="$2"
  local current
  current=$(get_current "$key")
  local prompt="$msg"
  if [ -n "$current" ]; then
    prompt="$msg [현재: $current] (Enter키로 유지): "
  else
    prompt="$msg: "
  fi
  read -p "$prompt" val
  if [ -z "$val" ] && [ -n "$current" ]; then
    val="$current"
  fi
  EXISTING=$(echo "$EXISTING" | jq --arg k "$key" --arg v "$val" '.[$k]=$v')
  echo "$EXISTING" > "$CONFIG_FILE"
}

# OCI config 파일에서 자동 추출
if [ -f "$OCI_CONFIG_FILE" ]; then
  log success "기존 OCI config 파일 발견: $OCI_CONFIG_FILE"
  
  # OCI config 파일에서 값 추출
  user_ocid=$(grep "^user=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
  tenancy_ocid=$(grep "^tenancy=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
  fingerprint=$(grep "^fingerprint=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
  region=$(grep "^region=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
  key_file=$(grep "^key_file=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
  
  # 물결표시 경로 확장
  key_file="${key_file/#\~/$HOME}"
  
  if [ -n "$user_ocid" ]; then
    EXISTING=$(echo "$EXISTING" | jq --arg v "$user_ocid" '.USER_OCID=$v')
    log info "USER_OCID 자동 설정: $user_ocid"
  fi
  
  if [ -n "$tenancy_ocid" ]; then
    EXISTING=$(echo "$EXISTING" | jq --arg v "$tenancy_ocid" '.TENANCY_OCID=$v')
    log info "TENANCY_OCID 자동 설정: $tenancy_ocid"
  fi
  
  if [ -n "$fingerprint" ]; then
    EXISTING=$(echo "$EXISTING" | jq --arg v "$fingerprint" '.FINGERPRINT=$v')
    log info "FINGERPRINT 자동 설정: $fingerprint"
  fi
  
  if [ -n "$region" ]; then
    EXISTING=$(echo "$EXISTING" | jq --arg v "$region" '.REGION=$v')
    log info "REGION 자동 설정: $region"
  fi
  
  if [ -n "$key_file" ]; then
    EXISTING=$(echo "$EXISTING" | jq --arg v "$key_file" '.KEY_FILE=$v')
    log info "KEY_FILE 자동 설정: $key_file"
  fi
  
  echo "$EXISTING" > "$CONFIG_FILE"
  log success "OCI config에서 환경변수 자동 추출 완료!"
else
  log warn "OCI config 파일이 없습니다. 수동으로 입력해야 합니다."
  log info "다음 명령어로 OCI CLI 설정을 먼저 해주세요: oci setup config"
fi

echo ""
log wizard "=== 1단계: OCI 환경변수 자동 추출 ==="

# OCI config 파일 필수 확인
if [ ! -f "$OCI_CONFIG_FILE" ]; then
  log fail "OCI config 파일이 없습니다: $OCI_CONFIG_FILE"
  echo ""
  log info "🔧 OCI CLI 설정이 필요합니다. 다음 중 하나를 실행하세요:"
  echo "  1. 대화형 설정: oci setup config"
  echo "  2. 수동 설정: oci setup keys"
  echo ""
  log info "설정 완료 후 다시 실행해주세요."
  exit 1
fi

# OCI config 파일에서 자동 추출
log success "기존 OCI config 파일 발견: $OCI_CONFIG_FILE"

# OCI config 파일에서 값 추출
user_ocid=$(grep "^user=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
tenancy_ocid=$(grep "^tenancy=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
fingerprint=$(grep "^fingerprint=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
region=$(grep "^region=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')
key_file=$(grep "^key_file=" "$OCI_CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')

# 물결표시 경로 확장
key_file="${key_file/#\~/$HOME}"

# 필수 값 검증
required_fields=("user_ocid:USER_OCID" "tenancy_ocid:TENANCY_OCID" "fingerprint:FINGERPRINT" "region:REGION" "key_file:KEY_FILE")
missing_fields=()

for field_pair in "${required_fields[@]}"; do
  local_var="${field_pair%:*}"
  config_key="${field_pair#*:}"
  
  if [ -z "${!local_var}" ]; then
    missing_fields+=("$config_key")
  fi
done

if [ ${#missing_fields[@]} -gt 0 ]; then
  log fail "OCI config 파일에 필수 값이 누락되었습니다:"
  for field in "${missing_fields[@]}"; do
    echo "  ❌ $field"
  done
  echo ""
  log info "다음 명령어로 OCI CLI를 다시 설정하세요:"
  echo "  oci setup config"
  exit 1
fi

# 키 파일 존재 확인
if [ ! -f "$key_file" ]; then
  log fail "API 키 파일을 찾을 수 없습니다: $key_file"
  echo ""
  log info "키 파일 경로를 확인하거나 다음 명령어로 다시 설정하세요:"
  echo "  oci setup config"
  exit 1
fi

# config.json에 저장
EXISTING=$(echo "$EXISTING" | jq --arg v "$user_ocid" '.USER_OCID=$v')
EXISTING=$(echo "$EXISTING" | jq --arg v "$tenancy_ocid" '.TENANCY_OCID=$v')
EXISTING=$(echo "$EXISTING" | jq --arg v "$fingerprint" '.FINGERPRINT=$v')
EXISTING=$(echo "$EXISTING" | jq --arg v "$region" '.REGION=$v')
EXISTING=$(echo "$EXISTING" | jq --arg v "$key_file" '.KEY_FILE=$v')

# Compartment는 기본적으로 Tenancy와 동일하게 설정
EXISTING=$(echo "$EXISTING" | jq --arg v "$tenancy_ocid" '.COMPARTMENT_OCID=$v')

echo "$EXISTING" > "$CONFIG_FILE"

log success "OCI config에서 환경변수 자동 추출 완료!"
log info "추출된 값:"
echo "  • USER_OCID: $user_ocid"
echo "  • TENANCY_OCID: $tenancy_ocid"
echo "  • COMPARTMENT_OCID: $tenancy_ocid (Tenancy와 동일)"
echo "  • FINGERPRINT: $fingerprint"
echo "  • REGION: $region"
echo "  • KEY_FILE: $key_file"

echo ""
log info "🔍 OCI CLI 연결 테스트 중..."
if oci iam region list >/dev/null 2>&1; then
  log success "OCI CLI 연결 성공!"
else
  log fail "OCI CLI 연결 실패. 설정을 확인해주세요."
  echo ""
  log info "다음 명령어로 OCI CLI 설정을 다시 해주세요:"
  echo "  oci setup config"
  exit 1
fi

echo ""
log wizard "=== 2단계: Discord Bot 설정 ==="

prompt_and_save DISCORD_TOKEN "Discord Bot Token"
prompt_and_save DISCORD_CLIENT_ID "Discord Client ID"
prompt_and_save DISCORD_GUILD_ID "Discord Guild ID (서버 ID)"
prompt_and_save DISCORD_CHANNEL_ID "Discord Channel ID"

# Discord Bot 초대 링크 자동 생성
generate_discord_invite_link() {
  local client_id=$(get_current DISCORD_CLIENT_ID)
  if [[ -n "$client_id" ]]; then
    local permissions="274878024704"  # 필요한 권한들의 비트마스크
    local invite_url="https://discord.com/oauth2/authorize?client_id=${client_id}&scope=bot&permissions=${permissions}"
    
    echo ""
    log success "🔗 Discord Bot 초대 링크가 자동 생성되었습니다!"
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET}                     ${BOLD}Discord Bot 초대 링크${RESET}                     ${CYAN}│${RESET}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${CYAN}│${RESET} ${GREEN}${invite_url}${RESET} ${CYAN}│${RESET}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "${YELLOW}💡 이 링크를 사용하여 봇을 Discord 서버에 초대하세요:${RESET}"
    echo "1. 위 링크를 브라우저에서 열기"
    echo "2. Discord 서버 선택"
    echo "3. 권한 확인 후 '승인' 클릭"
    echo ""
    
    # 클립보드 복사 시도 (선택적)
    if command -v xclip >/dev/null 2>&1; then
      echo "$invite_url" | xclip -selection clipboard
      log info "📋 링크가 클립보드에 복사되었습니다!"
    elif command -v pbcopy >/dev/null 2>&1; then
      echo "$invite_url" | pbcopy
      log info "📋 링크가 클립보드에 복사되었습니다!"
    fi
  fi
}

# Discord Bot 초대 링크 생성 실행
generate_discord_invite_link

# OCI API 호출을 위한 필수값 검증
COMPARTMENT_OCID=$(get_current COMPARTMENT_OCID)
if [ -z "$COMPARTMENT_OCID" ]; then
  log fail "COMPARTMENT_OCID가 설정되지 않았습니다."
  exit 1
fi

echo ""
log wizard "=== 3단계: OCI 리소스 선택 (실시간 API 조회) ==="

# Availability Domain 선택
echo ""
log info "🌐 사용 가능한 Availability Domain 조회 중..."
if ! ADS_RAW=$(oci iam availability-domain list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null); then
  log fail "Availability Domain 조회 실패. OCI CLI 설정을 확인하세요."
  log info "다음 명령어로 OCI CLI 테스트: oci iam region list"
  exit 1
fi

ads=($(echo "$ADS_RAW" | jq -r '.data[]? | select(.name != null) | .name'))
current_ad=$(get_current AVAILABILITY_DOMAIN)

log success "사용 가능한 Availability Domain:"
for i in "${!ads[@]}"; do
  echo "  $i) ${ads[$i]}"
done

if [ -n "$current_ad" ]; then
  echo "현재 설정: $current_ad"
fi
read -p "Availability Domain 번호 선택 (Enter키로 현재값 유지): " ad_idx
if [ -z "$ad_idx" ] && [ -n "$current_ad" ]; then
  AVAILABILITY_DOMAIN="$current_ad"
else
  AVAILABILITY_DOMAIN="${ads[$ad_idx]}"
fi
EXISTING=$(echo "$EXISTING" | jq --arg v "$AVAILABILITY_DOMAIN" '.AVAILABILITY_DOMAIN=$v')
echo "$EXISTING" > "$CONFIG_FILE"
log success "Availability Domain 설정: $AVAILABILITY_DOMAIN"

# Shape 선택 (실제 OCI API 기반)
echo ""
log info "🔧 사용 가능한 Compute Shape 조회 중..."
if ! SHAPES_RAW=$(oci compute shape list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null); then
  log fail "Shape 조회 실패. 권한을 확인하세요."
  exit 1
fi

# Always Free Eligible Shape 필터링 및 모든 Shape 포함
shapes=()
shape_descriptions=()
min_ocpus=()
max_ocpus=()
min_memory=()
max_memory=()
is_always_free=()

# E2.1.Micro (Always Free)
e2_data=$(echo "$SHAPES_RAW" | jq -r '.data[] | select(.shape == "VM.Standard.E2.1.Micro")')
if [ -n "$e2_data" ]; then
  shapes+=("VM.Standard.E2.1.Micro")
  shape_descriptions+=("AMD x86 (Always Free - 2개까지)")
  min_ocpus+=("1")
  max_ocpus+=("1")
  min_memory+=("1")
  max_memory+=("1")
  is_always_free+=("true")
fi

# A1.Flex (Always Free)
a1_data=$(echo "$SHAPES_RAW" | jq -r '.data[] | select(.shape | contains("A1.Flex"))')
if [ -n "$a1_data" ]; then
  shapes+=("VM.Standard.A1.Flex")
  shape_descriptions+=("ARM Ampere (Always Free - 총 4 OCPU, 24GB)")
  min_ocpus+=("1")
  max_ocpus+=("4")
  min_memory+=("1")
  max_memory+=("24")
  is_always_free+=("true")
fi

# 기타 주요 Shape들 (유료)
other_shapes=$(echo "$SHAPES_RAW" | jq -r '.data[] | select(.shape | test("VM.Standard.[E34]|VM.DenseIO|VM.GPU")) | .shape' | sort -u | head -10)
while IFS= read -r shape; do
  if [[ "$shape" != "VM.Standard.E2.1.Micro" ]] && [[ ! "$shape" =~ A1\.Flex ]]; then
    shape_info=$(echo "$SHAPES_RAW" | jq -r ".data[] | select(.shape == \"$shape\") | [.ocpus, .memory_in_gbs] | @tsv" | head -1)
    if [ -n "$shape_info" ]; then
      ocpu_info=$(echo "$shape_info" | cut -f1)
      memory_info=$(echo "$shape_info" | cut -f2)
      
      shapes+=("$shape")
      shape_descriptions+=("유료 인스턴스")
      min_ocpus+=("$ocpu_info")
      max_ocpus+=("$ocpu_info")
      min_memory+=("$memory_info")
      max_memory+=("$memory_info")
      is_always_free+=("false")
    fi
  fi
done <<< "$other_shapes"

if [ ${#shapes[@]} -eq 0 ]; then
  log fail "사용 가능한 Shape을 찾을 수 없습니다."
  exit 1
fi

current_shape=$(get_current SHAPE)
log success "🖥️ 사용 가능한 Compute Shape:"
for i in "${!shapes[@]}"; do
  free_badge=""
  if [[ "${is_always_free[$i]}" == "true" ]]; then
    free_badge=" 🆓"
  fi
  echo "  $i) ${shapes[$i]} (${shape_descriptions[$i]})${free_badge}"
  echo "     └─ OCPU: ${min_ocpus[$i]}-${max_ocpus[$i]}, RAM: ${min_memory[$i]}-${max_memory[$i]}GB"
done

echo ""
log info "💡 Shape 선택 가이드:"
echo "  🆓 Always Free: E2.1.Micro, A1.Flex (비용 없음)"
echo "  💰 유료 인스턴스: 사용량에 따라 과금"
echo "  📊 A1.Flex: 여러 인스턴스로 분할 가능 (총 4 OCPU, 24GB 한도)"

if [ -n "$current_shape" ]; then
  echo ""
  echo "현재 Shape: $current_shape"
fi

while true; do
  read -p "Shape 번호 선택 (Enter키로 현재값 유지): " shape_idx
  
  if [ -z "$shape_idx" ] && [ -n "$current_shape" ]; then
    SHAPE="$current_shape"
    # 기존 설정에서 인덱스 찾기
    for i in "${!shapes[@]}"; do
      if [[ "${shapes[$i]}" == "$current_shape" ]]; then
        SELECTED_SHAPE_IDX="$i"
        break
      fi
    done
    break
  elif [[ "$shape_idx" =~ ^[0-9]+$ ]] && [ "$shape_idx" -ge 0 ] && [ "$shape_idx" -lt "${#shapes[@]}" ]; then
    SHAPE="${shapes[$shape_idx]}"
    SELECTED_SHAPE_IDX="$shape_idx"
    break
  else
    log warn "올바른 번호를 입력해주세요 (0-$((${#shapes[@]}-1)))"
  fi
done

EXISTING=$(echo "$EXISTING" | jq --arg v "$SHAPE" '.SHAPE=$v')
echo "$EXISTING" > "$CONFIG_FILE"
log success "Shape 설정: $SHAPE (${shape_descriptions[$SELECTED_SHAPE_IDX]})"

# Subnet 선택
echo ""
log info "🌐 사용 가능한 Subnet 조회 중..."
if ! SUBNETS_RAW=$(oci network subnet list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null); then
  log fail "Subnet 조회 실패. VCN이 생성되어 있는지 확인하세요."
  exit 1
fi

subnet_names=($(echo "$SUBNETS_RAW" | jq -r '.data[]? | select(."display-name" != null) | ."display-name"'))
subnet_ids=($(echo "$SUBNETS_RAW" | jq -r '.data[]? | select(.id != null) | .id'))
subnet_cidrs=($(echo "$SUBNETS_RAW" | jq -r '.data[]? | select(."cidr-block" != null) | ."cidr-block"'))

if [ ${#subnet_ids[@]} -eq 0 ]; then
  log fail "사용 가능한 Subnet이 없습니다. OCI 콘솔에서 VCN과 Subnet을 먼저 생성하세요."
  exit 1
fi

current_subnet=$(get_current SUBNET_ID)
log success "사용 가능한 Subnet:"
for i in "${!subnet_ids[@]}"; do
  echo "  $i) ${subnet_names[$i]} (${subnet_cidrs[$i]})"
done

if [ -n "$current_subnet" ]; then
  echo "현재 Subnet: $current_subnet"
fi
read -p "Subnet 번호 선택 (Enter키로 현재값 유지): " subnet_idx
if [ -z "$subnet_idx" ] && [ -n "$current_subnet" ]; then
  SUBNET_ID="$current_subnet"
else
  SUBNET_ID="${subnet_ids[$subnet_idx]}"
fi
EXISTING=$(echo "$EXISTING" | jq --arg v "$SUBNET_ID" '.SUBNET_ID=$v')
echo "$EXISTING" > "$CONFIG_FILE"
log success "Subnet 설정: ${subnet_names[$subnet_idx]}"
# Image 선택 (선택한 Shape에 맞는 이미지 조회)
echo ""
log info "🖼️ 사용 가능한 OS Image 조회 중..."

# 선택된 Shape 가져오기
current_shape=$(get_current SHAPE)
if [ -z "$current_shape" ]; then
  current_shape="VM.Standard.E2.1.Micro"  # 기본값
fi

# Shape에 따른 이미지 조회
if [[ "$current_shape" == *"A1.Flex"* ]]; then
  # A1.Flex는 ARM 아키텍처이므로 aarch64 이미지만 조회
  log info "ARM 기반 Shape 감지: $current_shape"
  if ! IMAGES_RAW=$(oci compute image list --compartment-id "$COMPARTMENT_OCID" --shape "$current_shape" --sort-by TIMECREATED --sort-order DESC 2>/dev/null); then
    log warn "Shape 기반 이미지 조회 실패. Ubuntu aarch64 이미지를 조회합니다..."
    IMAGES_RAW=$(oci compute image list --compartment-id "$COMPARTMENT_OCID" --operating-system "Canonical Ubuntu" --sort-by TIMECREATED --sort-order DESC 2>/dev/null | jq '.data = [.data[] | select(."display-name" | contains("aarch64"))]')
  fi
else
  # E2.1.Micro 및 기타 x86_64 Shape
  log info "x86_64 기반 Shape 감지: $current_shape"
  if ! IMAGES_RAW=$(oci compute image list --compartment-id "$COMPARTMENT_OCID" --operating-system "Canonical Ubuntu" --sort-by TIMECREATED --sort-order DESC 2>/dev/null); then
    log warn "Ubuntu 이미지 조회 실패. 모든 이미지를 조회합니다..."
    IMAGES_RAW=$(oci compute image list --compartment-id "$COMPARTMENT_OCID" --sort-by TIMECREATED --sort-order DESC 2>/dev/null)
  fi
fi

# 이미지 정보 추출 (운영체제 정보 포함)
image_names=($(echo "$IMAGES_RAW" | jq -r '.data[0:15][]? | select(."display-name" != null) | ."display-name"'))
image_ids=($(echo "$IMAGES_RAW" | jq -r '.data[0:15][]? | select(.id != null) | .id'))
image_os=($(echo "$IMAGES_RAW" | jq -r '.data[0:15][]? | select(."operating-system" != null) | ."operating-system"'))

current_image=$(get_current IMAGE_ID)
log success "사용 가능한 OS Image (최신 15개, $current_shape 호환):"
for i in "${!image_ids[@]}"; do
  echo "  $i) ${image_names[$i]} [${image_os[$i]}]"
done

if [ -n "$current_image" ]; then
  echo "현재 Image: $current_image"
fi
read -p "Image 번호 선택 (Enter키로 현재값 유지): " image_idx
if [ -z "$image_idx" ] && [ -n "$current_image" ]; then
  IMAGE_ID="$current_image"
else
  IMAGE_ID="${image_ids[$image_idx]}"
fi
EXISTING=$(echo "$EXISTING" | jq --arg v "$IMAGE_ID" '.IMAGE_ID=$v')
echo "$EXISTING" > "$CONFIG_FILE"
log success "Image 설정: ${image_names[$image_idx]}"

echo ""
log wizard "=== 3.5단계: SSH 키 설정 ==="

# SSH 키 관리
setup_ssh_keys() {
  echo ""
  log info "🔐 SSH 키 설정 (인스턴스 접속을 위해 필요):"
  echo "  1) 기존 SSH 공개키 파일 경로 입력"
  echo "  2) 공개키 내용 직접 입력 (Termius 등에서 복사)"
  echo "  3) 새 SSH 키 쌍 자동 생성"
  echo ""
  
  while true; do
    read -p "선택 (1-3): " ssh_choice
    
    case $ssh_choice in
      1)
        echo ""
        log info "SSH 공개키 파일 경로를 입력하세요:"
        echo "  예: ~/.ssh/id_rsa.pub, ~/.ssh/oracle_key.pub"
        read -p "공개키 파일 경로: " ssh_key_path
        
        # 경로 확장
        ssh_key_path="${ssh_key_path/#\~/$HOME}"
        
        if [[ -f "$ssh_key_path" ]]; then
          SSH_PUBLIC_KEY_PATH="$ssh_key_path"
          log success "SSH 공개키 파일 확인: $ssh_key_path"
          break
        else
          log error "파일을 찾을 수 없습니다: $ssh_key_path"
        fi
        ;;
      2)
        echo ""
        log info "SSH 공개키 내용을 붙여넣으세요:"
        echo "  (ssh-rsa로 시작하는 전체 내용)"
        echo "  입력 완료 후 Enter 두 번 눌러주세요:"
        
        ssh_key_content=""
        while IFS= read -r line; do
          [[ -z "$line" ]] && break
          ssh_key_content+="$line"
        done
        
        if [[ "$ssh_key_content" =~ ^ssh-(rsa|ed25519|ecdsa) ]]; then
          # 임시 파일에 저장
          SSH_PUBLIC_KEY_PATH="/tmp/oracle_ssh_key_$$.pub"
          echo "$ssh_key_content" > "$SSH_PUBLIC_KEY_PATH"
          log success "SSH 공개키 내용이 저장되었습니다."
          break
        else
          log error "올바른 SSH 공개키 형식이 아닙니다. ssh-rsa, ssh-ed25519, 또는 ssh-ecdsa로 시작해야 합니다."
        fi
        ;;
      3)
        echo ""
        log info "새 SSH 키 쌍을 생성합니다..."
        
        # SSH 키 저장 디렉토리 생성
        ssh_dir="$HOME/.ssh"
        mkdir -p "$ssh_dir"
        chmod 700 "$ssh_dir"
        
        # 키 파일명 생성
        timestamp=$(date +%Y%m%d_%H%M%S)
        private_key_path="$ssh_dir/oracle_key_$timestamp"
        public_key_path="$ssh_dir/oracle_key_$timestamp.pub"
        
        # SSH 키 생성
        if ssh-keygen -t rsa -b 4096 -f "$private_key_path" -N "" -C "oracle-instance-$timestamp"; then
          SSH_PUBLIC_KEY_PATH="$public_key_path"
          
          echo ""
          log success "🎉 SSH 키 쌍이 생성되었습니다!"
          echo -e "${YELLOW}${BOLD}⚠️  중요: 다음 파일들을 반드시 안전하게 보관하세요! ⚠️${RESET}"
          echo ""
          echo -e "${CYAN}📁 생성된 파일:${RESET}"
          echo -e "  🔐 개인키: ${private_key_path}"
          echo -e "  🔓 공개키: ${public_key_path}"
          echo ""
          echo -e "${YELLOW}📋 SSH 접속 명령어 (인스턴스 생성 후 사용):${RESET}"
          echo -e "  ${CYAN}ssh -i ${private_key_path} opc@<인스턴스_IP>${RESET}"
          echo ""
          echo -e "${RED}⚠️  개인키를 분실하면 인스턴스에 접속할 수 없습니다!${RESET}"
          echo ""
          read -p "파일 위치를 확인했습니다. 계속하려면 Enter 키를 누르세요..."
          break
        else
          log error "SSH 키 생성에 실패했습니다."
        fi
        ;;
      *)
        log warn "올바른 번호를 선택하세요 (1-3)"
        ;;
    esac
  done
  
  # SSH 공개키를 config.json에 저장
  ssh_key_content=$(cat "$SSH_PUBLIC_KEY_PATH")
  EXISTING=$(echo "$EXISTING" | jq --arg v "$ssh_key_content" '.SSH_PUBLIC_KEY=$v')
  EXISTING=$(echo "$EXISTING" | jq --arg v "$SSH_PUBLIC_KEY_PATH" '.SSH_PUBLIC_KEY_PATH=$v')
  echo "$EXISTING" > "$CONFIG_FILE"
  
  log success "SSH 키 설정 완료!"
}

setup_ssh_keys

echo ""
log wizard "=== 4단계: 인스턴스 사양 설정 ==="

# 선택한 Shape의 제한사항
selected_shape="$SHAPE"
selected_idx="$SELECTED_SHAPE_IDX"
min_ocpu="${min_ocpus[$selected_idx]}"
max_ocpu="${max_ocpus[$selected_idx]}"
min_ram="${min_memory[$selected_idx]}"
max_ram="${max_memory[$selected_idx]}"
always_free="${is_always_free[$selected_idx]}"

log info "💻 선택한 Shape: $selected_shape"
echo "  • OCPU 범위: ${min_ocpu}-${max_ocpu}"
echo "  • RAM 범위: ${min_ram}-${max_ram}GB"
if [[ "$always_free" == "true" ]]; then
  echo "  • 🆓 Always Free 적용"
else
  echo "  • 💰 유료 인스턴스 (과금 주의)"
fi

# 1. 부트 볼륨 크기 설정
echo ""
log info "💾 부트 볼륨 크기 설정:"
echo "  • Always Free: 200GB까지 무료"
echo "  • 유료: 50GB 이상 권장"
echo "  • 최소: 50GB, 최대: 32TB"

current_boot_volume=$(echo "$EXISTING" | jq -r '.bootVolumeConfig.sizeInGBs // empty')
while true; do
  if [ -n "$current_boot_volume" ]; then
    read -p "부트 볼륨 크기(GB) [현재: ${current_boot_volume}GB] (50-32768): " boot_volume_input
    if [ -z "$boot_volume_input" ]; then
      BOOT_VOLUME_SIZE="$current_boot_volume"
      break
    fi
  else
    read -p "부트 볼륨 크기(GB) [권장: 200GB] (50-32768): " boot_volume_input
    if [ -z "$boot_volume_input" ]; then
      BOOT_VOLUME_SIZE="200"
      break
    fi
  fi
  
  if [[ "$boot_volume_input" =~ ^[0-9]+$ ]] && [ "$boot_volume_input" -ge 50 ] && [ "$boot_volume_input" -le 32768 ]; then
    BOOT_VOLUME_SIZE="$boot_volume_input"
    if [ "$boot_volume_input" -gt 200 ] && [[ "$always_free" == "true" ]]; then
      log warn "⚠️ Always Free는 200GB까지만 무료입니다. 초과분은 과금됩니다."
    fi
    break
  else
    log warn "부트 볼륨은 50-32768GB 범위여야 합니다."
  fi
done

# 2. OCPU 설정
echo ""
log info "🖥️ OCPU 설정:"
if [[ "$selected_shape" == *"E2.1.Micro"* ]]; then
  OCPUS="1"
  log info "E2.1.Micro는 1 OCPU로 고정됩니다."
else
  current_ocpus=$(echo "$EXISTING" | jq -r '.shapeConfig.ocpus // empty')
  while true; do
    if [ -n "$current_ocpus" ]; then
      read -p "OCPU 개수 [현재: ${current_ocpus}] (${min_ocpu}-${max_ocpu}): " ocpu_input
      if [ -z "$ocpu_input" ]; then
        OCPUS="$current_ocpus"
        break
      fi
    else
      read -p "OCPU 개수 [권장: 1] (${min_ocpu}-${max_ocpu}): " ocpu_input
      if [ -z "$ocpu_input" ]; then
        OCPUS="1"
        break
      fi
    fi
    
    if [[ "$ocpu_input" =~ ^[0-9]+$ ]] && [ "$ocpu_input" -ge "$min_ocpu" ] && [ "$ocpu_input" -le "$max_ocpu" ]; then
      OCPUS="$ocpu_input"
      
      # Always Free A1 한도 검증
      if [[ "$selected_shape" == *"A1.Flex"* ]] && [ "$ocpu_input" -gt 4 ]; then
        log warn "⚠️ A1.Flex Always Free는 총 4 OCPU까지만 무료입니다."
      fi
      break
    else
      log warn "OCPU는 ${min_ocpu}-${max_ocpu} 범위여야 합니다."
    fi
  done
fi

# 3. RAM 설정
echo ""
log info "🧠 RAM 설정:"
if [[ "$selected_shape" == *"E2.1.Micro"* ]]; then
  MEMORY_IN_GBS="1"
  log info "E2.1.Micro는 1GB RAM으로 고정됩니다."
else
  current_memory=$(echo "$EXISTING" | jq -r '.shapeConfig.memoryInGBs // empty')
  
  # OCPU에 따른 권장 RAM 계산
  if [[ "$selected_shape" == *"A1.Flex"* ]]; then
    recommended_ram=$((OCPUS * 6))
    recommended_ram=$(( recommended_ram > 24 ? 24 : recommended_ram ))
  else
    recommended_ram=$((OCPUS * 8))
  fi
  
  while true; do
    if [ -n "$current_memory" ]; then
      read -p "RAM 크기(GB) [현재: ${current_memory}GB, 권장: ${recommended_ram}GB] (${min_ram}-${max_ram}): " memory_input
      if [ -z "$memory_input" ]; then
        MEMORY_IN_GBS="$current_memory"
        break
      fi
    else
      read -p "RAM 크기(GB) [권장: ${recommended_ram}GB] (${min_ram}-${max_ram}): " memory_input
      if [ -z "$memory_input" ]; then
        MEMORY_IN_GBS="$recommended_ram"
        break
      fi
    fi
    
    if [[ "$memory_input" =~ ^[0-9]+$ ]] && [ "$memory_input" -ge "$min_ram" ] && [ "$memory_input" -le "$max_ram" ]; then
      MEMORY_IN_GBS="$memory_input"
      
      # Always Free A1 한도 검증
      if [[ "$selected_shape" == *"A1.Flex"* ]] && [ "$memory_input" -gt 24 ]; then
        log warn "⚠️ A1.Flex Always Free는 총 24GB RAM까지만 무료입니다."
      fi
      
      # OCPU/RAM 비율 권장사항
      if [[ "$selected_shape" == *"A1.Flex"* ]]; then
        ideal_ram=$((OCPUS * 6))
        if [ "$memory_input" -lt "$ideal_ram" ]; then
          log warn "💡 권장 비율: ARM은 OCPU당 6GB RAM (현재 ${OCPUS} OCPU → ${ideal_ram}GB 권장)"
        fi
      fi
      break
    else
      log warn "RAM은 ${min_ram}-${max_ram}GB 범위여야 합니다."
    fi
  done
fi

# 설정 저장
EXISTING=$(echo "$EXISTING" | \
  jq --argjson ocpus "$OCPUS" --argjson mem "$MEMORY_IN_GBS" --argjson boot "$BOOT_VOLUME_SIZE" \
     '.shapeConfig.ocpus=$ocpus | .shapeConfig.memoryInGBs=$mem | .bootVolumeConfig.sizeInGBs=$boot')
echo "$EXISTING" > "$CONFIG_FILE"

log success "인스턴스 사양 설정 완료!"
echo "  • 💾 부트 볼륨: ${BOOT_VOLUME_SIZE}GB"
echo "  • 🖥️ OCPU: ${OCPUS}개"
echo "  • 🧠 RAM: ${MEMORY_IN_GBS}GB"

# Always Free 사용량 요약
if [[ "$always_free" == "true" ]]; then
  echo ""
  log info "📊 Always Free 사용량:"
  if [[ "$selected_shape" == *"A1.Flex"* ]]; then
    remaining_ocpu=$((4 - OCPUS))
    remaining_ram=$((24 - MEMORY_IN_GBS))
    echo "  • A1 사용: ${OCPUS}/4 OCPU, ${MEMORY_IN_GBS}/24GB RAM"
    echo "  • A1 남은 자원: ${remaining_ocpu} OCPU, ${remaining_ram}GB RAM"
  elif [[ "$selected_shape" == *"E2.1.Micro"* ]]; then
    echo "  • E2 사용: 1/2 인스턴스"
    echo "  • E2 추가 생성 가능: 1개"
  fi
  
  if [ "$BOOT_VOLUME_SIZE" -le 200 ]; then
    echo "  • 부트 볼륨: ${BOOT_VOLUME_SIZE}/200GB (무료)"
  else
    echo "  • 부트 볼륨: ${BOOT_VOLUME_SIZE}GB (200GB 초과분 과금)"
  fi
fi

# 설정 완료 및 요약
print_progress 5 "🎉 최종 설정 완료 및 요약"

log wizard "기본 인스턴스 옵션을 설정합니다..."

# availabilityConfig 및 instanceOptions 설정
EXISTING=$(echo "$EXISTING" \
  | jq '.availabilityConfig.isLiveMigrationPreferred=true | .availabilityConfig.recoveryAction="RESTORE_INSTANCE"')
EXISTING=$(echo "$EXISTING" \
  | jq '.instanceOptions.areLegacyImdsEndpointsDisabled=false')
echo "$EXISTING" > "$CONFIG_FILE"

print_final_summary() {
  echo ""
  echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${GREEN}${BOLD}║                            🎉 설정 완료!                                     ║${RESET}"
  echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
  echo ""
  
  # 설정 요약 출력
  log success "✅ 설정이 완료되었습니다!"
  echo ""
  echo -e "${CYAN}${BOLD}📋 설정 요약:${RESET}"
  echo -e "${CYAN}┌────────────────────────────────────────────────────────────────┐${RESET}"
  
  local compartment_id=$(echo "$EXISTING" | jq -r '.COMPARTMENT_ID // "미설정"')
  local shape=$(echo "$EXISTING" | jq -r '.SHAPE // "미설정"')
  local subnet_id=$(echo "$EXISTING" | jq -r '.SUBNET_ID // "미설정"')
  local image_id=$(echo "$EXISTING" | jq -r '.IMAGE_ID // "미설정"')
  local ocpus=$(echo "$EXISTING" | jq -r '.shapeConfig.ocpus // "미설정"')
  local memory=$(echo "$EXISTING" | jq -r '.shapeConfig.memoryInGBs // "미설정"')
  local boot_volume=$(echo "$EXISTING" | jq -r '.bootVolumeConfig.sizeInGBs // "미설정"')
  local discord_token=$(echo "$EXISTING" | jq -r '.discord_token // "미설정"')
  
  echo -e "${CYAN}│${RESET} 🏛️  Compartment: ${compartment_id:0:30}..."
  echo -e "${CYAN}│${RESET} 💻 Shape: ${shape}"
  echo -e "${CYAN}│${RESET} 🖥️  OCPU: ${ocpus}개"
  echo -e "${CYAN}│${RESET} 🧠 RAM: ${memory}GB"
  echo -e "${CYAN}│${RESET} 💾 부트볼륨: ${boot_volume}GB"
  echo -e "${CYAN}│${RESET} 🤖 Discord: ${discord_token:0:10}..."
  echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${RESET}"
}

print_final_summary

# SSH 키 설정 확인
key_file=$(get_current KEY_FILE)
if [ -n "$key_file" ] && [ -f "$key_file" ]; then
  # 공개키 파일 경로 생성
  pub_key_file="${key_file%.*}_public.pem"
  if [ ! -f "$pub_key_file" ]; then
    pub_key_file="${key_file}.pub"
  fi
  
  if [ -f "$pub_key_file" ]; then
    echo ""
    log info "🔑 SSH 공개키 확인됨: $pub_key_file"
    echo ""
    log wizard "� OCI 콘솔에 아래 공개키를 등록해주세요:"
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────┐${RESET}"
    cat "$pub_key_file" | sed 's/^/│ /'
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────┘${RESET}"
    echo "----------------------------------------"
    echo ""
    log info "등록 경로: OCI 콘솔 → Identity & Security → Users → 본인 계정 → API Keys → Add API Key"
  else
    log warn "공개키 파일을 찾을 수 없습니다: $pub_key_file"
  fi
else
  log warn "개인키 파일을 찾을 수 없습니다: $key_file"
fi

echo ""
log success "🎉 config.json 설정이 완료되었습니다!"
echo ""
log info "📋 Always Free 인스턴스 설정 요약:"
echo "  • 🌏 Region: $(get_current REGION)"
echo "  • 🖥️ Shape: $(get_current SHAPE)"
echo "  • 💾 사양: ${OCPUS} OCPU, ${MEMORY_IN_GBS}GB RAM"
if [[ "$SHAPE" == *"A1.Flex"* ]]; then
  echo "  • 🆓 A1 Free 한도: ${OCPUS}/4 OCPU, ${MEMORY_IN_GBS}/24GB RAM"
elif [[ "$SHAPE" == *"E2.1.Micro"* ]]; then
  echo "  • 🆓 E2 Free 한도: 2개 인스턴스까지"
fi
echo "  • 📍 Availability Domain: $(get_current AVAILABILITY_DOMAIN)"
echo "  • 🤖 Discord Bot: 설정됨"
echo ""

log info "💡 Always Free 팁:"
if [[ "$SHAPE" == *"A1.Flex"* ]]; then
  echo "  • ARM 기반 인스턴스로 성능이 우수합니다"
  echo "  • 총 4 OCPU, 24GB RAM까지 무료로 사용 가능"
  echo "  • 여러 인스턴스로 분할하여 사용할 수 있습니다"
elif [[ "$SHAPE" == *"E2.1.Micro"* ]]; then
  echo "  • AMD 기반 인스턴스로 호환성이 좋습니다"
  echo "  • 최대 2개 인스턴스까지 무료로 사용 가능"
  echo "  • 소규모 서비스에 적합합니다"
fi
echo "  • 매월 744시간(24×31일) 가동 시간 무료"
echo "  • 아웃바운드 데이터 전송 10TB/월 무료"

echo ""
log wizard "다음 단계: bash oci-script-and-bot.sh 실행하여 봇을 시작하세요!"
echo ""

# 설정 파일 최종 검증
echo ""
log info "🔍 설정 파일 최종 검증 중..."

required_keys=("TENANCY_OCID" "USER_OCID" "COMPARTMENT_OCID" "FINGERPRINT" "REGION" "KEY_FILE" "DISCORD_TOKEN" "DISCORD_CLIENT_ID" "DISCORD_GUILD_ID" "DISCORD_CHANNEL_ID" "SHAPE" "SUBNET_ID" "IMAGE_ID" "AVAILABILITY_DOMAIN")

all_valid=true
missing_keys=()

for key in "${required_keys[@]}"; do
  value=$(get_current "$key")
  if [ -z "$value" ] || [ "$value" = "null" ]; then
    missing_keys+=("$key")
    all_valid=false
  fi
done

if [ "$all_valid" = true ]; then
  echo ""
  log success "🎉 모든 필수 설정이 완료되었습니다!"
  
  # OCI 인스턴스 생성 명령어 생성
  generate_launch_command() {
    echo ""
    log info "🚀 OCI 인스턴스 생성 명령어를 생성합니다..."
    
    # 설정값 읽기
    local compartment_id=$(get_current COMPARTMENT_OCID)
    local shape=$(get_current SHAPE)
    local subnet_id=$(get_current SUBNET_ID)
    local image_id=$(get_current IMAGE_ID)
    local availability_domain=$(get_current AVAILABILITY_DOMAIN)
    local ocpus=$(get_current shapeConfig.ocpus)
    local memory=$(get_current shapeConfig.memoryInGBs)
    local boot_volume=$(get_current bootVolumeConfig.sizeInGBs)
    local ssh_key_path=$(get_current SSH_PUBLIC_KEY_PATH)
    
    # JSON 설정 파일들 생성
    local config_dir="$HOME/.oci/launch_configs"
    mkdir -p "$config_dir"
    
    # availabilityConfig.json
    cat > "$config_dir/availabilityConfig.json" << EOF
{
  "isLiveMigrationPreferred": true,
  "recoveryAction": "RESTORE_INSTANCE"
}
EOF
    
    # instanceOptions.json
    cat > "$config_dir/instanceOptions.json" << EOF
{
  "areLegacyImdsEndpointsDisabled": false
}
EOF
    
    # shapeConfig.json (Flex Shape인 경우만)
    if [[ "$shape" == *"Flex"* ]]; then
      cat > "$config_dir/shapeConfig.json" << EOF
{
  "ocpus": $ocpus,
  "memoryInGBs": $memory
}
EOF
    fi
    
    # bootVolumeConfig.json
    cat > "$config_dir/bootVolumeConfig.json" << EOF
{
  "sizeInGBs": $boot_volume
}
EOF
    
    # 인스턴스 생성 스크립트 생성
    local script_path="$HOME/.oci/launch_instance.sh"
    cat > "$script_path" << EOF
#!/bin/bash
# Oracle Cloud Infrastructure 인스턴스 생성 스크립트
# 생성일: $(date)

# 설정 변수
COMPARTMENT_ID="$compartment_id"
SHAPE="$shape"
SUBNET_ID="$subnet_id"
IMAGE_ID="$image_id"
AVAILABILITY_DOMAIN="$availability_domain"
SSH_KEY_PATH="$ssh_key_path"
CONFIG_DIR="$config_dir"

# 인스턴스 이름 (타임스탬프 포함)
INSTANCE_NAME="oracle-instance-\$(date +%Y%m%d-%H%M%S)"

echo "🚀 Oracle Cloud 인스턴스 생성 중..."
echo "  • 이름: \$INSTANCE_NAME"
echo "  • Shape: $shape"
echo "  • OCPU: $ocpus, RAM: ${memory}GB"
echo "  • 부트볼륨: ${boot_volume}GB"
echo ""

# OCI CLI 명령어 실행
EOF
    
    # Flex Shape 여부에 따라 명령어 생성
    if [[ "$shape" == *"Flex"* ]]; then
      cat >> "$script_path" << EOF
oci compute instance launch \\
  --compartment-id "\$COMPARTMENT_ID" \\
  --availability-domain "\$AVAILABILITY_DOMAIN" \\
  --shape "$shape" \\
  --shape-config file://\$CONFIG_DIR/shapeConfig.json \\
  --subnet-id "\$SUBNET_ID" \\
  --image-id "\$IMAGE_ID" \\
  --display-name "\$INSTANCE_NAME" \\
  --assign-public-ip true \\
  --assign-private-dns-record true \\
  --ssh-authorized-keys-file "\$SSH_KEY_PATH" \\
  --availability-config file://\$CONFIG_DIR/availabilityConfig.json \\
  --instance-options file://\$CONFIG_DIR/instanceOptions.json \\
  --source-boot-volume-size-in-gbs $boot_volume \\
  --wait-for-state RUNNING \\
  --wait-interval-seconds 30 \\
  --max-wait-seconds 1800
EOF
    else
      cat >> "$script_path" << EOF
oci compute instance launch \\
  --compartment-id "\$COMPARTMENT_ID" \\
  --availability-domain "\$AVAILABILITY_DOMAIN" \\
  --shape "$shape" \\
  --subnet-id "\$SUBNET_ID" \\
  --image-id "\$IMAGE_ID" \\
  --display-name "\$INSTANCE_NAME" \\
  --assign-public-ip true \\
  --assign-private-dns-record true \\
  --ssh-authorized-keys-file "\$SSH_KEY_PATH" \\
  --availability-config file://\$CONFIG_DIR/availabilityConfig.json \\
  --instance-options file://\$CONFIG_DIR/instanceOptions.json \\
  --source-boot-volume-size-in-gbs $boot_volume \\
  --wait-for-state RUNNING \\
  --wait-interval-seconds 30 \\
  --max-wait-seconds 1800
EOF
    fi
    
    cat >> "$script_path" << EOF

# 결과 확인
if [ \$? -eq 0 ]; then
  echo ""
  echo "✅ 인스턴스 생성 성공!"
  echo ""
  echo "🔐 SSH 접속 방법:"
  echo "  ssh -i ${ssh_key_path%.pub} opc@<인스턴스_공개_IP>"
  echo ""
  echo "💡 인스턴스 정보 확인:"
  echo "  oci compute instance list --compartment-id \$COMPARTMENT_ID --display-name \$INSTANCE_NAME"
else
  echo "❌ 인스턴스 생성 실패"
  echo "자주 발생하는 오류:"
  echo "  • Out of capacity: 다른 Availability Domain 시도"
  echo "  • LimitExceeded: Always Free 한도 초과"
  echo "  • InvalidParameter: 설정값 확인 필요"
fi
EOF
    
    chmod +x "$script_path"
    
    echo ""
    log success "🎯 인스턴스 생성 스크립트가 준비되었습니다!"
    echo ""
    echo -e "${CYAN}📁 생성된 파일:${RESET}"
    echo -e "  🚀 실행 스크립트: ${script_path}"
    echo -e "  ⚙️  설정 파일들: ${config_dir}/"
    echo ""
    echo -e "${YELLOW}🚀 인스턴스 생성 방법:${RESET}"
    echo -e "  ${CYAN}bash $script_path${RESET}"
    echo ""
    echo -e "${YELLOW}💡 자동 재시도 (Out of Capacity 대응):${RESET}"
    echo -e "  ${CYAN}watch -n 300 'bash $script_path'${RESET}"
    echo -e "  (5분마다 자동 재시도, Ctrl+C로 중단)"
    echo ""
  }
  
  generate_launch_command
  
  echo ""
  echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${GREEN}${BOLD}║                     ✅ 설정 마법사 완료!                                    ║${RESET}"
  echo -e "${GREEN}${BOLD}║                                                                              ║${RESET}"
  echo -e "${GREEN}${BOLD}║    다음 단계:                                                                ║${RESET}"
  echo -e "${GREEN}${BOLD}║    1. Discord Bot 서버 초대 (위의 초대 링크 사용)                          ║${RESET}"
  echo -e "${GREEN}${BOLD}║    2. bash ~/.oci/launch_instance.sh (인스턴스 생성)                       ║${RESET}"
  echo -e "${GREEN}${BOLD}║    3. sudo bash oci-script-and-bot.sh (Discord Bot 시작)                   ║${RESET}"
  echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"

  # Discord Bot 초대 링크 재안내
  local client_id=$(get_current DISCORD_CLIENT_ID)
  if [[ -n "$client_id" ]]; then
    local permissions="274878024704"
    local invite_url="https://discord.com/oauth2/authorize?client_id=${client_id}&scope=bot&permissions=${permissions}"
    
    echo ""
    echo -e "${CYAN}🔗 Discord Bot 초대 링크:${RESET}"
    echo -e "${GREEN}${invite_url}${RESET}"
    echo ""
  fi

  echo ""
else
  echo ""
  log error "❌ 다음 필수 설정이 누락되었습니다:"
  for key in "${missing_keys[@]}"; do
    echo "  • $key"
  done
  echo ""
  log error "마법사를 다시 실행하여 누락된 설정을 완료해주세요."
  exit 1
fi

# =============================================================================
# 🔗 유틸리티: Discord Bot 초대 링크 확인
# =============================================================================
# 사용법: bash oci-config-wizard.sh --invite-link
if [[ "$1" == "--invite-link" ]]; then
  echo ""
  echo -e "${CYAN}${BOLD}🔗 Discord Bot 초대 링크 확인${RESET}"
  echo ""
  
  if [[ ! -f "config.json" ]]; then
    log error "config.json 파일을 찾을 수 없습니다."
    log info "먼저 설정 마법사를 실행하세요: bash oci-config-wizard.sh"
    exit 1
  fi
  
  local client_id=$(jq -r '.DISCORD_CLIENT_ID // empty' config.json)
  if [[ -z "$client_id" ]]; then
    log error "DISCORD_CLIENT_ID가 설정되지 않았습니다."
    log info "설정 마법사를 다시 실행하세요: bash oci-config-wizard.sh"
    exit 1
  fi
  
  local permissions="274878024704"
  local invite_url="https://discord.com/oauth2/authorize?client_id=${client_id}&scope=bot&permissions=${permissions}"
  
  echo -e "${CYAN}┌────────────────────────────────────────────────────────────────┐${RESET}"
  echo -e "${CYAN}│${RESET}                     ${BOLD}Discord Bot 초대 링크${RESET}                     ${CYAN}│${RESET}"
  echo -e "${CYAN}├────────────────────────────────────────────────────────────────┤${RESET}"
  echo -e "${CYAN}│${RESET} ${GREEN}${invite_url}${RESET} ${CYAN}│${RESET}"
  echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${RESET}"
  echo ""
  echo -e "${YELLOW}💡 이 링크를 브라우저에서 열어 봇을 Discord 서버에 초대하세요.${RESET}"
  echo ""
  
  # 클립보드 복사 시도
  if command -v xclip >/dev/null 2>&1; then
    echo "$invite_url" | xclip -selection clipboard
    log info "📋 링크가 클립보드에 복사되었습니다!"
  elif command -v pbcopy >/dev/null 2>&1; then
    echo "$invite_url" | pbcopy
    log info "📋 링크가 클립보드에 복사되었습니다!"
  fi
  
  exit 0
fi
