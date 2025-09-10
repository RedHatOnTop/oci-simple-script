#!/bin/bash

# =============================================================================
# 🤖 OCI Always Free Discord Bot 실행기
# =============================================================================
# Oracle Cloud Infrastructure Always Free 인스턴스 자동 생성을 위한
# Discord Bot 실행 및 관리 스크립트입니다.
# 
# 특징:
# • 🎯 Always Free 특화 인스턴스 생성
# • 🤖 Discord 슬래시 명령어 지원
# • 🔧 PM2 기반 서비스 관리
# • 📊 실시간 상태 모니터링
# =============================================================================

set -euo pipefail

# =============================
# 🌐 Language selection (EN default)
# =============================
LANG_CHOICE="en"
EARLY_CONFIG_FILE="config.json"

# Offer language choice only if not preset via config
if [ -f "$EARLY_CONFIG_FILE" ]; then
  PRESET_LANG=$(grep -o '"LANGUAGE"[[:space:]]*:[[:space:]]*"[a-z]*"' "$EARLY_CONFIG_FILE" 2>/dev/null | sed -E 's/.*"([a-z]+)".*/\1/')
  case "$PRESET_LANG" in
    ko|en) LANG_CHOICE="$PRESET_LANG" ;;
  esac
fi

if [ -z "${PRESET_LANG:-}" ]; then
  echo "=============================================="
  echo " Select language / 언어 선택"
  echo "  [1] English (default)"
  echo "  [2] 한국어"
  echo "=============================================="
  read -r -p "> Choice (1-2) [1]: " _sel
  case "${_sel:-1}" in
    2|ko|KO|Ko) LANG_CHOICE="ko" ;;
    *) LANG_CHOICE="en" ;;
  esac
fi

# Localized strings (header and a few key lines)
if [ "$LANG_CHOICE" = "ko" ]; then
  HDR_TITLE_LEFT="🤖 OCI Always Free Discord Bot"
  HDR_TITLE_RIGHT="실행기"
  HDR_SUB1="Oracle Cloud Infrastructure 인스턴스 자동 생성"
  HDR_INFO1="🎯 Always Free 특화: E2.1.Micro, A1.Flex 자동 생성"
  HDR_INFO2="🤖 Discord 통합: /status, /launch, /log 명령어"
  HDR_INFO3="🔧 PM2 관리: 백그라운드 서비스로 실행"
else
  HDR_TITLE_LEFT="🤖 OCI Always Free Discord Bot"
  HDR_TITLE_RIGHT="Launcher"
  HDR_SUB1="Oracle Cloud Infrastructure instance auto-creation"
  HDR_INFO1="🎯 Always Free focused: E2.1.Micro, A1.Flex"
  HDR_INFO2="🤖 Discord integration: /status, /launch, /log"
  HDR_INFO3="🔧 PM2 managed: runs as a background service"
fi

# 🔧 sudo 실행 및 OCI CLI PATH 설정
setup_sudo_environment() {
  # sudo 실행 확인 및 안내
  if [[ $EUID -ne 0 ]]; then
    if [ "$LANG_CHOICE" = "ko" ]; then
      echo -e "\033[1;33m⚠️ 이 스크립트는 pm2 전역 설치를 위해 sudo 권한이 필요합니다.\033[0m"
      echo ""
      echo -e "\033[0;36mℹ️ 다음 명령어로 다시 실행하세요:\033[0m"
      echo -e "\033[1;32msudo bash $0\033[0m"
      echo ""
      echo -e "\033[1;33m💡 참고: sudo 실행 시에도 사용자 계정의 OCI CLI 설정을 사용합니다.\033[0m"
    else
      echo -e "\033[1;33m⚠️ This script requires sudo privileges for global pm2 installation.\033[0m"
      echo ""
      echo -e "\033[0;36mℹ️ Please run with the following command:\033[0m"
      echo -e "\033[1;32msudo bash $0\033[0m"
      echo ""
      echo -e "\033[1;33m💡 Note: Your user account's OCI CLI configuration will be used even with sudo.\033[0m"
    fi
    exit 1
  fi
  
  # 원래 사용자 정보 확인
  ORIGINAL_USER=${SUDO_USER:-$(whoami)}
  ORIGINAL_HOME=$(eval echo ~$ORIGINAL_USER)
  
  # OCI CLI 심볼릭 링크 생성 (사용자 설치된 OCI CLI를 시스템 경로에 링크)
  local user_oci_paths=(
    "$ORIGINAL_HOME/bin/oci"
    "$ORIGINAL_HOME/.local/bin/oci"
    "$ORIGINAL_HOME/lib/oracle-cli/bin/oci"
  )
  
  # 사용자의 OCI CLI 찾기 및 심볼릭 링크 생성
  for oci_path in "${user_oci_paths[@]}"; do
    if [[ -x "$oci_path" ]]; then
      if [[ ! -L "/usr/local/bin/oci" ]]; then
        if [ "$LANG_CHOICE" = "ko" ]; then
          echo -e "\033[0;36mℹ️ $(date '+%H:%M:%S')\033[0m OCI CLI 심볼릭 링크 생성: $oci_path -> /usr/local/bin/oci"
        else
          echo -e "\033[0;36mℹ️ $(date '+%H:%M:%S')\033[0m Creating OCI CLI symlink: $oci_path -> /usr/local/bin/oci"
        fi
        ln -sf "$oci_path" /usr/local/bin/oci
      fi
      break
    fi
  done
  
  # OCI 설정 파일 경로 설정 (원래 사용자의 홈 디렉토리 사용)
  export OCI_CLI_RC_FILE="$ORIGINAL_HOME/.oci/config"
  export OCI_CONFIG_FILE="$ORIGINAL_HOME/.oci/config"
  
  if [ "$LANG_CHOICE" = "ko" ]; then
    echo -e "\033[0;36mℹ️ $(date '+%H:%M:%S')\033[0m 환경 설정 완료 - 원래 사용자: $ORIGINAL_USER"
    echo -e "\033[0;36mℹ️ $(date '+%H:%M:%S')\033[0m OCI 설정 경로: $OCI_CONFIG_FILE"
  else
    echo -e "\033[0;36mℹ️ $(date '+%H:%M:%S')\033[0m Environment setup complete - Original user: $ORIGINAL_USER"
    echo -e "\033[0;36mℹ️ $(date '+%H:%M:%S')\033[0m OCI config path: $OCI_CONFIG_FILE"
  fi
  
  # OCI CLI 접근 가능 여부 확인
  if command -v oci >/dev/null 2>&1; then
    local oci_path=$(which oci)
    if [ "$LANG_CHOICE" = "ko" ]; then
      echo -e "\033[0;32m✅ $(date '+%H:%M:%S')\033[0m OCI CLI 발견: $oci_path"
    else
      echo -e "\033[0;32m✅ $(date '+%H:%M:%S')\033[0m OCI CLI found: $oci_path"
    fi
  else
    if [ "$LANG_CHOICE" = "ko" ]; then
      echo -e "\033[1;33m⚠️ $(date '+%H:%M:%S')\033[0m OCI CLI를 찾을 수 없습니다."
      echo "  사용자 경로를 확인하거나 다음 명령어로 수동 링크 생성:"
      echo "  sudo ln -s /home/\$USER/bin/oci /usr/local/bin/oci"
    else
      echo -e "\033[1;33m⚠️ $(date '+%H:%M:%S')\033[0m OCI CLI not found."
      echo "  Check user paths or create manual link with:"
      echo "  sudo ln -s /home/\$USER/bin/oci /usr/local/bin/oci"
    fi
  fi
}

# 환경 설정 실행
setup_sudo_environment

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
    bot)     echo -e "${MAGENTA}🤖 [${timestamp}]${RESET} ${BOLD}${msg}${RESET}" ;;
    fail)    echo -e "${RED}❌ [${timestamp}]${RESET} ${msg}" ;;
    *)       echo -e "${WHITE}${msg}${RESET}" ;;
  esac
}

print_header() {
  clear
  echo -e "${MAGENTA}${BOLD}"
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║                                                                              ║"
  printf "║ %60s %21s║\n" "${HDR_TITLE_LEFT}" "${HDR_TITLE_RIGHT}"
  echo "║                                                                              ║"
  printf "║ %74s ║\n" "${HDR_SUB1}"
  echo "║                                                                              ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
  echo ""
  log info "${HDR_INFO1}"
  log info "${HDR_INFO2}"
  log info "${HDR_INFO3}"
  echo ""
}

WORKDIR="$(pwd)"
# sudo 실행 시 원래 사용자의 config.json 사용
if [[ $EUID -eq 0 ]] && [[ -n "${ORIGINAL_USER:-}" ]]; then
  CONFIG_FILE="$ORIGINAL_HOME/$(basename "$WORKDIR")/config.json"
  # 원래 사용자 디렉토리에 config.json이 없으면 현재 디렉토리 확인
  if [[ ! -f "$CONFIG_FILE" ]]; then
    CONFIG_FILE="$WORKDIR/config.json"
  fi
else
  CONFIG_FILE="$WORKDIR/config.json"
fi

print_header
if [ "$LANG_CHOICE" = "ko" ]; then
  log bot "OCI Discord Bot 자동화 스크립트를 시작합니다!"
else
  log bot "Starting OCI Discord Bot automation script!"
fi

# sudo 환경에서 실행 중인지 확인 및 설정
if [[ $EUID -eq 0 ]]; then
  log info "🔑 sudo 권한으로 실행 중 - 환경 설정 적용됨"
fi

echo ""

# 1. config.json 파일 존재 및 유효성 검증
if [ ! -f "$CONFIG_FILE" ]; then
  if [ "$LANG_CHOICE" = "ko" ]; then
    log fail "$CONFIG_FILE 파일이 없습니다."
    log info "먼저 다음 명령어를 실행하세요: bash oci-config-wizard.sh"
  else
    log fail "$CONFIG_FILE not found."
    log info "Please run: bash oci-config-wizard.sh first"
  fi
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  if [ "$LANG_CHOICE" = "ko" ]; then
    log info "jq 설치 중..."
  else
    log info "Installing jq..."
  fi
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y jq
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y jq
  else
    if [ "$LANG_CHOICE" = "ko" ]; then
      log fail "jq를 수동으로 설치해주세요."
    else
      log fail "Please install jq manually."
    fi
    exit 1
  fi
  [ "$LANG_CHOICE" = "ko" ] && log success "jq 설치 완료" || log success "jq installed"
fi

# config.json에서 값 추출 함수
get_config() {
  local key="$1"
  local value=$(jq -r ".${key}" "$CONFIG_FILE")
  if [ "$value" = "null" ] || [ -z "$value" ]; then
    log fail "config.json에서 $key 값을 찾을 수 없습니다."
    exit 1
  fi
  echo "$value"
}

# 필수 설정값 추출 및 검증
log info "📋 config.json에서 설정값 로드 중..."

TENANCY_OCID=$(get_config "TENANCY_OCID")
USER_OCID=$(get_config "USER_OCID")
COMPARTMENT_OCID=$(get_config "COMPARTMENT_OCID")
FINGERPRINT=$(get_config "FINGERPRINT")
REGION=$(get_config "REGION")
KEY_FILE=$(get_config "KEY_FILE")

DISCORD_TOKEN=$(get_config "DISCORD_TOKEN")
DISCORD_CLIENT_ID=$(get_config "DISCORD_CLIENT_ID")
DISCORD_GUILD_ID=$(get_config "DISCORD_GUILD_ID")
DISCORD_CHANNEL_ID=$(get_config "DISCORD_CHANNEL_ID")

AVAILABILITY_DOMAIN=$(get_config "AVAILABILITY_DOMAIN")
SHAPE=$(get_config "SHAPE")
SUBNET_ID=$(get_config "SUBNET_ID")
IMAGE_ID=$(get_config "IMAGE_ID")

# shapeConfig 추출
OCPUS=$(jq -r '.shapeConfig.ocpus' "$CONFIG_FILE")
MEMORY_IN_GBS=$(jq -r '.shapeConfig.memoryInGBs' "$CONFIG_FILE")

log success "모든 설정값 로드 완료"

# Persist LANGUAGE in config.json if missing
if ! jq -er '.LANGUAGE' "$CONFIG_FILE" >/dev/null 2>&1; then
  tmp=$(mktemp)
  jq --arg lang "$LANG_CHOICE" '.LANGUAGE = $lang' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
fi

# 2. OCI CLI 설치 확인
echo ""
log info "🔧 OCI CLI 설치 확인 중..."
if ! command -v oci > /dev/null; then
  log info "OCI CLI 설치 중..."
  bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
  export PATH="$HOME/bin:$PATH"
  log success "OCI CLI 설치 완료"
else
  log success "OCI CLI 이미 설치됨"
fi

# 3. OCI config 파일 검증 및 갱신
echo ""
log info "⚙️ OCI config 파일 검증 중..."
mkdir -p ~/.oci

# 키 파일 경로 확장 (~ 처리)
KEY_FILE_EXPANDED="${KEY_FILE/#\~/$HOME}"

# 키 파일 존재 확인
if [ ! -f "$KEY_FILE_EXPANDED" ]; then
  log warn "API 키 파일이 없습니다: $KEY_FILE_EXPANDED"
  read -p "새로운 키를 생성하시겠습니까? (y/N): " create_key
  if [[ "$create_key" =~ ^[Yy]$ ]]; then
    log info "새로운 API 키 생성 중..."
    openssl genrsa -out "$KEY_FILE_EXPANDED" 2048
    PUB_KEY_PATH="${KEY_FILE_EXPANDED%.*}_public.pem"
    openssl rsa -pubout -in "$KEY_FILE_EXPANDED" -out "$PUB_KEY_PATH"
    chmod 600 "$KEY_FILE_EXPANDED"
    log success "API 키 생성 완료"
    log warn "🔑 OCI 콘솔에 아래 공개키를 등록해주세요:"
    echo "----------------------------------------"
    cat "$PUB_KEY_PATH"
    echo "----------------------------------------"
  else
    log fail "API 키 파일이 필요합니다."
    exit 1
  fi
else
  log success "API 키 파일 확인됨: $KEY_FILE_EXPANDED"
  chmod 600 "$KEY_FILE_EXPANDED"
fi

# OCI config 파일 생성/갱신
OCI_CONFIG_PATH="$HOME/.oci/config"
log info "OCI config 파일 생성/갱신 중..."
cat <<EOF > "$OCI_CONFIG_PATH"
[DEFAULT]
user=${USER_OCID}
fingerprint=${FINGERPRINT}
tenancy=${TENANCY_OCID}
region=${REGION}
key_file=${KEY_FILE_EXPANDED}
EOF

log success "OCI config 파일 생성 완료: $OCI_CONFIG_PATH"

# 4. Node.js, npm, pm2 설치
echo ""
if [ "$LANG_CHOICE" = "ko" ]; then
  log info "📦 Node.js 및 의존성 설치 중..."
else
  log info "📦 Installing Node.js and dependencies..."
fi

if ! command -v node > /dev/null; then
  if [ "$LANG_CHOICE" = "ko" ]; then
    log info "Node.js 설치 중..."
  else
    log info "Installing Node.js..."
  fi
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
  if [ "$LANG_CHOICE" = "ko" ]; then
    log success "Node.js 설치 완료"
  else
    log success "Node.js installation completed"
  fi
else
  if [ "$LANG_CHOICE" = "ko" ]; then
    log success "Node.js 이미 설치됨: $(node --version)"
  else
    log success "Node.js already installed: $(node --version)"
  fi
fi

if ! command -v pm2 > /dev/null; then
  if [ "$LANG_CHOICE" = "ko" ]; then
    log info "pm2 설치 중..."
  else
    log info "Installing pm2..."
  fi
  
  # npm 권한 확인 및 처리
  if ! npm install -g pm2 2>/dev/null; then
    log warning "권한 오류로 인해 sudo로 PM2를 설치합니다..."
    if [[ $EUID -ne 0 ]]; then
      log info "스크립트를 sudo로 다시 실행합니다..."
      exec sudo -E "$0" "$@"
    else
      # 이미 sudo로 실행 중이면 환경 설정 후 설치
      setup_sudo_environment
      npm install -g pm2
    fi
  fi
  if [ "$LANG_CHOICE" = "ko" ]; then
    log success "pm2 설치 완료"
  else
    log success "pm2 installation completed"
  fi
else
  if [ "$LANG_CHOICE" = "ko" ]; then
    log success "pm2 이미 설치됨"
  else
    log success "pm2 already installed"
  fi
fi

# 5. package.json 및 의존성 설치
echo ""
if [ "$LANG_CHOICE" = "ko" ]; then
  log info "📋 Discord.js 의존성 설치 중..."
else
  log info "📋 Installing Discord.js dependencies..."
fi

if [ ! -f "package.json" ]; then
  if [ "$LANG_CHOICE" = "ko" ]; then
    log info "package.json 생성 중..."
  else
    log info "Creating package.json..."
  fi
  cat <<EOF > package.json
{
  "name": "oci-discord-bot",
  "version": "1.0.0",
  "description": "OCI Instance Auto Creation Discord Bot",
  "main": "oci-discord-bot.js",
  "scripts": {
    "start": "node oci-discord-bot.js"
  },
  "dependencies": {
    "discord.js": "^14.14.1",
    "dotenv": "^16.3.1"
  }
}
EOF
fi

if [ ! -d "node_modules" ]; then
  npm install
  if [ "$LANG_CHOICE" = "ko" ]; then
    log success "의존성 설치 완료"
  else
    log success "Dependencies installation completed"
  fi
fi

# 6. .env 파일 생성 (Node.js용)
echo ""
if [ "$LANG_CHOICE" = "ko" ]; then
  log info "🔧 .env 파일 생성 중..."
else
  log info "🔧 Creating .env file..."
fi
cat <<EOF > .env
DISCORD_TOKEN=${DISCORD_TOKEN}
DISCORD_CLIENT_ID=${DISCORD_CLIENT_ID}
DISCORD_GUILD_ID=${DISCORD_GUILD_ID}
DISCORD_CHANNEL_ID=${DISCORD_CHANNEL_ID}
TENANCY_OCID=${TENANCY_OCID}
USER_OCID=${USER_OCID}
COMPARTMENT_OCID=${COMPARTMENT_OCID}
FINGERPRINT=${FINGERPRINT}
REGION=${REGION}
KEY_FILE=${KEY_FILE_EXPANDED}
EOF

if [ "$LANG_CHOICE" = "ko" ]; then
  log success ".env 파일 생성 완료"
else
  log success ".env file created successfully"
fi
# 7. Discord 봇 코드 생성 (config.json 기반)
echo ""
if [ "$LANG_CHOICE" = "ko" ]; then
  log info "🤖 Discord 봇 코드 생성 중..."
else
  log info "🤖 Generating Discord bot code..."
fi
cat <<'EOF' > oci-discord-bot.js
require('dotenv').config();
const { Client, GatewayIntentBits, REST, Routes, SlashCommandBuilder, EmbedBuilder } = require('discord.js');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const TOKEN = process.env.DISCORD_TOKEN;
const CLIENT_ID = process.env.DISCORD_CLIENT_ID;
const GUILD_ID = process.env.DISCORD_GUILD_ID;
const CHANNEL_ID = process.env.DISCORD_CHANNEL_ID;

// config.json에서 OCI 설정 로드
const CONFIG_FILE = './config.json';
let ociConfig = {};
try {
  ociConfig = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
} catch (error) {
  console.error('config.json 로드 실패:', error);
  process.exit(1);
}

let attemptCount = 0;
const startTime = Date.now();
let autoLaunch = true;
let lastResults = [];
const LOG_FILE = './oci_bot.log';

// 🌐 언어 지원 시스템 (default to English)
const LANG = ociConfig.LANGUAGE || 'en';

const translations = {
  ko: {
    // Discord Bot 명령어 설명
    status_desc: '🤖 봇 상태 및 최근 결과 확인',
    launch_desc: '🚀 OCI 인스턴스 즉시 생성 시도',
    log_desc: '📜 최근 시도 로그 확인',
    log_count_desc: '표시할 로그 개수 (1-50)',
    stop_desc: '⏹️ 자동 인스턴스 생성 중지',
    start_desc: '▶️ 자동 인스턴스 생성 시작',
    config_desc: '⚙️ 현재 OCI 설정 확인',
    stats_desc: '📊 상세 통계 및 성공률 분석',
    stats_period_desc: '통계 기간',
    instances_desc: '🖥️ 현재 실행 중인 인스턴스 목록 조회',
    instances_filter_desc: '필터 옵션',
    resources_desc: '💰 Always Free 자원 사용량 조회',
    schedule_desc: '⏰ 자동 생성 스케줄 설정',
    schedule_interval_desc: '시도 간격 (3-60분)',
    alert_desc: '🔔 알림 설정 관리',
    alert_type_desc: '알림 유형',
    alert_enabled_desc: '알림 활성화/비활성화',
    help_desc: '❓ 사용 가능한 명령어 안내',
    
    // 선택 옵션들
    today: '📅 오늘',
    week: '📆 이번 주',
    month: '🗓️ 이번 달',
    all: '📈 전체',
    running: '🟢 실행 중',
    stopped: '🔴 중지됨',
    all_filter: '🟡 전체',
    success_alert: '✅ 성공 알림',
    failure_alert: '❌ 실패 알림',
    daily_alert: '📊 일일 요약',
    error_alert: '⚠️ 오류 알림',
    
    // 메시지
    bot_status: '🤖 OCI 자동화 봇 상태',
    uptime: '⌛ 업타임',
    total_attempts: '🔢 총 시도 횟수',
    auto_creation: '🔄 자동 생성',
    enabled: '🟢 활성화',
    disabled: '🔴 비활성화',
    recent_result: '📊 최근 결과',
    success: '✅ 성공',
    failed: '❌ 실패',
    stopped: '⏹️ 자동 인스턴스 생성이 중지되었습니다.',
    started: '▶️ 자동 인스턴스 생성이 시작되었습니다.',
    already_active: '🔄 이미 자동 생성이 활성화되어 있습니다.',
    no_logs: '📜 아직 시도 로그가 없습니다.',
    command_error: '❌ 명령어 실행 중 오류가 발생했습니다.',
    schedule_changed: '⏰ 스케줄 설정 변경',
    interval_updated: '자동 인스턴스 생성 간격이 변경되었습니다.',
    help_title: '📖 OCI Discord Bot 명령어 가이드',
    help_description: 'Oracle Cloud Infrastructure Always Free 인스턴스 자동 생성 봇',
    help_basic: '🤖 기본 명령어',
    help_control: '⚙️ 제어 명령어', 
    help_analysis: '📊 분석 명령어',
    help_notification: '🔔 알림 명령어',
    help_current_status: '📈 현재 상태',
    help_footer: 'Always Free 인스턴스 생성을 위한 Discord Bot',
    auto_creation_status: '자동 생성',
    attempt_interval: '시도 간격',
    previous_interval: '🔄 이전 간격',
    new_interval: '🆕 새로운 간격',
    next_attempt: '📅 다음 시도',
    schedule_updated_desc: '자동 인스턴스 생성 간격이 변경되었습니다.',
    about_minutes: '약 분 후'
  },
  en: {
    // Discord Bot command descriptions
    status_desc: '🤖 Check bot status and recent results',
    launch_desc: '🚀 Immediately attempt OCI instance creation',
    log_desc: '📜 View recent attempt logs',
    log_count_desc: 'Number of logs to display (1-50)',
    stop_desc: '⏹️ Stop automatic instance creation',
    start_desc: '▶️ Start automatic instance creation',
    config_desc: '⚙️ Check current OCI configuration',
    stats_desc: '📊 Detailed statistics and success rate analysis',
    stats_period_desc: 'Statistics period',
    instances_desc: '🖥️ List currently running instances',
    instances_filter_desc: 'Filter options',
    resources_desc: '💰 Always Free resource usage',
    schedule_desc: '⏰ Set automatic creation schedule',
    schedule_interval_desc: 'Attempt interval (3-60 minutes)',
    alert_desc: '🔔 Manage notification settings',
    alert_type_desc: 'Notification type',
    alert_enabled_desc: 'Enable/disable notifications',
    help_desc: '❓ Available command guide',
    
    // Choice options
    today: '📅 Today',
    week: '📆 This Week',
    month: '🗓️ This Month',
    all: '📈 All Time',
    running: '🟢 Running',
    stopped: '🔴 Stopped',
    all_filter: '🟡 All',
    success_alert: '✅ Success Alert',
    failure_alert: '❌ Failure Alert',
    daily_alert: '📊 Daily Summary',
    error_alert: '⚠️ Error Alert',
    
    // Messages
    bot_status: '🤖 OCI Automation Bot Status',
    uptime: '⌛ Uptime',
    total_attempts: '🔢 Total Attempts',
    auto_creation: '🔄 Auto Creation',
    enabled: '🟢 Enabled',
    disabled: '🔴 Disabled',
    recent_result: '📊 Recent Result',
    success: '✅ Success',
    failed: '❌ Failed',
    stopped: '⏹️ Automatic instance creation has been stopped.',
    started: '▶️ Automatic instance creation has been started.',
    already_active: '🔄 Auto creation is already active.',
    no_logs: '📜 No attempt logs available yet.',
    command_error: '❌ An error occurred while executing the command.',
    schedule_changed: '⏰ Schedule Settings Changed',
    interval_updated: 'Automatic instance creation interval has been updated.',
    help_title: '📖 OCI Discord Bot Command Guide',
    help_description: 'Oracle Cloud Infrastructure Always Free instance auto-creation bot',
    help_basic: '🤖 Basic Commands',
    help_control: '⚙️ Control Commands',
    help_analysis: '📊 Analysis Commands', 
    help_notification: '🔔 Notification Commands',
    help_current_status: '📈 Current Status',
    help_footer: 'Discord Bot for Always Free instance creation',
    auto_creation_status: 'Auto Creation',
    attempt_interval: 'Attempt Interval',
    previous_interval: '🔄 Previous Interval',
    new_interval: '🆕 New Interval', 
    next_attempt: '📅 Next Attempt',
    schedule_updated_desc: 'Automatic instance creation interval has been updated.',
    about_minutes: 'About minutes later'
  }
};

// 번역 함수
function t(key) {
  return translations[LANG][key] || translations['ko'][key] || key;
}

// 🆕 새로운 기능을 위한 변수들
let scheduleInterval = 5; // 기본 5분 간격 (분)
let alertSettings = {
  success: true,
  failure: false,
  daily: true,
  error: true
};
let dailyStats = {
  attempts: 0,
  successes: 0,
  lastReset: new Date().toDateString()
};
let instanceCache = []; // 인스턴스 목록 캐시
let lastStatsUpdate = 0; // 마지막 통계 업데이트 시간

function getUptime() {
  const ms = Date.now() - startTime;
  const sec = Math.floor(ms / 1000);
  const min = Math.floor(sec / 60);
  const hour = Math.floor(min / 60);
  return `${hour}h ${min % 60}m ${sec % 60}s`;
}

function writeLog(msg) {
  const timestamp = new Date().toISOString();
  const logMsg = `[${timestamp}] ${msg}`;
  fs.appendFileSync(LOG_FILE, logMsg + '\n');
  console.log(logMsg);
}

function sendEmbed(interaction, status, errorMsg = null, manual = false) {
  // Helper to safely render a short code block within Discord field limits
  const makeShortCodeBlock = (text) => {
    const MAX = 1010; // Discord field value limit is ~1024
    const wrapStart = '```bash\n';
    const wrapEnd = '\n```';
    const budget = MAX - (wrapStart.length + wrapEnd.length);
    let content = text || '';
    if (content.length > budget) {
      const half = Math.floor((budget - 5) / 2);
      content = content.slice(0, half) + '\n...\n' + content.slice(-half);
    }
    return wrapStart + content + wrapEnd;
  };

  const embed = new EmbedBuilder()
    .setTitle(manual ? '🚀 OCI 인스턴스 수동 생성 시도' : '⚡ OCI 인스턴스 자동 생성 시도')
    .addFields(
      { name: '⏰ 시도 시간', value: new Date().toISOString(), inline: false },
      { name: '🔢 시도 회차', value: attemptCount.toString(), inline: true },
      { name: '⌛ 업타임', value: getUptime(), inline: true },
      { name: '📊 결과', value: status ? '✅ 성공' : '❌ 실패', inline: true },
      { name: '🖥️ Shape', value: ociConfig.SHAPE || 'Unknown', inline: true },
      { name: '🌏 Region', value: ociConfig.REGION || 'Unknown', inline: true },
      { name: '💾 사양', value: `${ociConfig.shapeConfig?.ocpus || '?'} OCPU, ${ociConfig.shapeConfig?.memoryInGBs || '?'}GB RAM`, inline: true }
    )
    .setColor(status ? 0x00ff00 : 0xff0000)
    .setTimestamp();
    
  if (errorMsg) {
    embed.addFields({ name: '❗ 오류 상세', value: errorMsg.substring(0, 1000), inline: false });
    // Append attempted command if we have the last executed command in log (pull from recent writeLog line)
    try {
      const logTail = fs.readFileSync(LOG_FILE, 'utf8').toString().split('\n').reverse().slice(0, 50);
      const execLine = logTail.find(l => l.includes('Executing: oci compute instance launch')) || '';
      const attempted = execLine.replace(/^.*Executing: /, '');
      if (attempted) {
        const cmdTitle = (LANG === 'ko') ? '🧪 시도한 명령' : '🧪 Attempted Command';
        embed.addFields({ name: cmdTitle, value: makeShortCodeBlock(attempted), inline: false });
      }
    } catch (_) { /* ignore */ }
  }

  // 🔧 FIX: 비동기 처리 개선 - interaction이 이미 deferred 상태일 수 있음 
  if (interaction) {
    // deferred reply인지 확인하고 적절한 메서드 사용
    if (interaction.deferred) {
      interaction.editReply({ embeds: [embed] }).catch(err => 
        writeLog('Failed to edit reply: ' + err)
      );
    } else {
      interaction.reply({ embeds: [embed] }).catch(err => 
        writeLog('Failed to reply: ' + err)
      );
    }
  } else {
    const channel = client.channels.cache.get(CHANNEL_ID);
    if (channel) channel.send({ embeds: [embed] });
  }

  lastResults.unshift({
    time: new Date().toISOString(),
    attempt: attemptCount,
    uptime: getUptime(),
    status: status,
    error: errorMsg
  });
  lastResults = lastResults.slice(0, 20);

  writeLog(`Attempt #${attemptCount} | ${status ? 'SUCCESS' : 'FAIL'}${errorMsg ? ' | ' + errorMsg : ''}`);
}

function tryLaunchInstance(interaction = null, manual = false) {
  attemptCount += 1;
  
  // 일일 통계 초기화 (새로운 날)
  if (dailyStats.lastReset !== new Date().toDateString()) {
    dailyStats.attempts = 0;
    dailyStats.successes = 0;
    dailyStats.lastReset = new Date().toDateString();
  }
  
  // 시도 횟수 증가
  dailyStats.attempts += 1;
  
  writeLog(`Starting attempt #${attemptCount} (${manual ? 'manual' : 'auto'})`);
  
  // config.json 기반 OCI 명령어 구성
  const bootArg = (ociConfig.bootVolumeConfig && ociConfig.bootVolumeConfig.sizeInGBs)
    ? ` --boot-volume-size-in-gbs ${ociConfig.bootVolumeConfig.sizeInGBs}`
    : '';

  // SSH 키 처리
  const sshKeyArg = ociConfig.sshKeyPath ? 
    ` --ssh-authorized-keys-file "${ociConfig.sshKeyPath}.pub"` : '';
  
  // Shape Config 처리 (A1.Flex의 경우만)
  const shapeConfigArg = (ociConfig.SHAPE === 'VM.Standard.A1.Flex' && ociConfig.shapeConfig) ?
    ` --shape-config '{"ocpus":${ociConfig.shapeConfig.ocpus},"memoryInGBs":${ociConfig.shapeConfig.memoryInGBs}}'` : '';

  const ociCommand = [
    'oci compute instance launch',
    '--availability-domain', `"${ociConfig.AVAILABILITY_DOMAIN}"`,
    '--compartment-id', `"${ociConfig.COMPARTMENT_OCID}"`,
    '--shape', `"${ociConfig.SHAPE}"`,
    '--subnet-id', `"${ociConfig.SUBNET_ID}"`,
    '--assign-public-ip', 'true',
    '--display-name', `"oci-auto-instance-${Date.now()}"`,
    '--image-id', `"${ociConfig.IMAGE_ID}"`,
    '--wait-for-state', 'RUNNING',
    '--max-wait-seconds', '300'
  ].join(' ') + shapeConfigArg + sshKeyArg + bootArg;

  writeLog(`Executing: ${ociCommand}`);

  exec(ociCommand, { timeout: 120000 }, (error, stdout, stderr) => {
    const combined = `${stdout}\n${stderr}`.trim();
    
    // 성공/실패 판정
    let status = false;
    let errorMsg = null;
    
    if (error) {
      errorMsg = `Command execution error: ${error.message}`;
      if (stderr) errorMsg += `\nStderr: ${stderr}`;
      
      // Enhanced error parsing logic - extract message from response
      const parseErrorResponse = (responseText) => {
        try {
          // First try to parse the entire response as JSON
          try {
            const errorData = JSON.parse(responseText);
            return extractErrorInfo(errorData);
          } catch (e) {
            // If full parsing fails, try to find JSON objects
          }
          
          // Try to find and parse JSON objects in the response
          const jsonRegex = /\{(?:[^{}]|{[^{}]*})*\}/g;
          let match;
          while ((match = jsonRegex.exec(responseText)) !== null) {
            try {
              const errorData = JSON.parse(match[0]);
              const result = extractErrorInfo(errorData);
              if (result) return result;
            } catch (parseError) {
              continue; // Try next JSON match
            }
          }
          return null;
        } catch (error) {
          return null;
        }
      };
      
      const extractErrorInfo = (errorData) => {
        // Check for various error message formats
        if (errorData.message) {
          return {
            code: errorData.code || errorData.status || 'Error',
            message: errorData.message,
            details: errorData.details || errorData['opc-request-id']
          };
        }
        
        // Check for nested error objects
        if (errorData.error && errorData.error.message) {
          return {
            code: errorData.error.code || errorData.error.status || 'Error',
            message: errorData.error.message,
            details: errorData.error.details || errorData['opc-request-id']
          };
        }
        
        // Check for OCI-specific error formats
        if (errorData.serviceError && errorData.serviceError.message) {
          return {
            code: errorData.serviceError.code || 'ServiceError',
            message: errorData.serviceError.message,
            details: errorData.serviceError.details || errorData['opc-request-id']
          };
        }
        
        return null;
      };
      
      // Try to parse error from both stderr and stdout
      let parsedError = parseErrorResponse(stderr) || parseErrorResponse(stdout) || parseErrorResponse(combined);
      
      if (parsedError) {
        errorMsg = `**${parsedError.code}:** ${parsedError.message}`;
        if (parsedError.details) {
          errorMsg += `\n**Request ID:** ${parsedError.details}`;
        }
      } else {
        // Fallback to pattern matching for known error types
        if (combined.toLowerCase().includes('out of capacity')) {
          errorMsg = '**Out of Capacity:** No available resources in the selected availability domain';
        } else if (combined.toLowerCase().includes('limitexceeded')) {
          errorMsg = '**Limit Exceeded:** Always Free resource limit has been reached';
        } else if (combined.toLowerCase().includes('invalid')) {
          errorMsg = '**Invalid Configuration:** Please check your settings';
        } else if (combined.toLowerCase().includes('insufficientauthorization')) {
          errorMsg = '**Insufficient Authorization:** Check your API key permissions';
        } else if (combined.toLowerCase().includes('notfound')) {
          errorMsg = '**Resource Not Found:** Check your compartment and resource IDs';
        } else if (combined.toLowerCase().includes('conflict')) {
          errorMsg = '**Resource Conflict:** Resource name may already exist';
        } else if (combined.toLowerCase().includes('quotaexceeded')) {
          errorMsg = '**Quota Exceeded:** Service quota limit reached';
        }
      }
      
  // Keep attempted command separate; we'll add it as a dedicated embed field later
      
    } else if ((combined.includes('"lifecycle-state"') && combined.includes('RUNNING')) || 
               (combined.includes('"id"') && combined.includes('ocid1.instance'))) {
      status = true;
      
      // 성공한 인스턴스 정보 추출
      try {
        const instanceData = JSON.parse(combined);
        // OCI CLI는 보통 data 객체 안에 실제 데이터를 포함
        const data = instanceData.data || instanceData;
        
        const instanceId = data.id;
        const displayName = data['display-name'] || data.displayName;
        const shape = data.shape;
        const lifecycleState = data['lifecycle-state'] || data.lifecycleState;
        const availabilityDomain = data['availability-domain'] || data.availabilityDomain;
        
        writeLog(`Instance creation succeeded! ID: ${instanceId}, State: ${lifecycleState}`);
        
        // 성공 메시지에 인스턴스 정보 추가
        errorMsg = `🎉 **인스턴스 생성 성공!**\n\n` +
                  `**🆔 Instance ID:** ${instanceId ? instanceId.split('.').pop().substring(0, 16) + '...' : 'Unknown'}\n` +
                  `**📝 Display Name:** ${displayName || 'oci-auto-instance'}\n` +
                  `**🖥️ Shape:** ${shape || ociConfig.SHAPE}\n` +
                  `**📍 상태:** ${getStatusEmoji(lifecycleState)} ${lifecycleState || 'PROVISIONING'}\n` +
                  `**� Availability Domain:** ${availabilityDomain ? availabilityDomain.split(':').pop() : ociConfig.AVAILABILITY_DOMAIN?.split('.').pop()}\n\n` +
                  `**📊 총 시도 횟수:** ${attemptCount}회\n` +
                  `**⏰ 소요 시간:** ${getUptime()}\n\n` +
                  `**💡 다음 단계:**\n` +
                  `• 인스턴스가 완전히 부팅될 때까지 2-5분 대기\n` +
                  `• OCI 콘솔에서 공개 IP 확인 또는 \`/instances\` 명령어 사용\n` +
                  `• SSH 접속: \`ssh -i ~/.ssh/oci-key opc@<PUBLIC_IP>\``;
        
        // 통계 업데이트
        dailyStats.successes++;
        
        // 성공 시 자동 생성 중지 (선택사항)
        if (autoLaunch) {
          writeLog('Auto-launch disabled after successful creation');
          // autoLaunch = false; // 주석 처리 - 계속 시도하려면 제거
        }
        
      } catch (parseError) {
        writeLog('Instance creation succeeded but failed to parse details: ' + parseError.message);
        errorMsg = `🎉 **인스턴스 생성 성공!**\n\n` +
                  `**📊 총 시도 횟수:** ${attemptCount}회\n` +
                  `**⏰ 소요 시간:** ${getUptime()}\n\n` +
                  `**💡 OCI 콘솔에서 생성된 인스턴스를 확인하세요!**`;
      }
    } else {
      // Use enhanced parsing for non-error responses too
      const parseErrorResponse = (responseText) => {
        try {
          // First try to parse the entire response as JSON
          try {
            const errorData = JSON.parse(responseText);
            return extractErrorInfo(errorData);
          } catch (e) {
            // If full parsing fails, try to find JSON objects
          }
          
          // Try to find and parse JSON objects in the response
          const jsonRegex = /\{(?:[^{}]|{[^{}]*})*\}/g;
          let match;
          while ((match = jsonRegex.exec(responseText)) !== null) {
            try {
              const errorData = JSON.parse(match[0]);
              const result = extractErrorInfo(errorData);
              if (result) return result;
            } catch (parseError) {
              continue; // Try next JSON match
            }
          }
          return null;
        } catch (error) {
          return null;
        }
      };
      
      const extractErrorInfo = (errorData) => {
        if (errorData.message) {
          return {
            code: errorData.code || errorData.status || 'Error',
            message: errorData.message,
            details: errorData.details || errorData['opc-request-id']
          };
        }
        if (errorData.error && errorData.error.message) {
          return {
            code: errorData.error.code || errorData.error.status || 'Error',
            message: errorData.error.message,
            details: errorData.error.details || errorData['opc-request-id']
          };
        }
        return null;
      };
      
      let parsedError = parseErrorResponse(combined);
      
      if (parsedError) {
        errorMsg = `**${parsedError.code}:** ${parsedError.message}`;
        if (parsedError.details) {
          errorMsg += `\n**Request ID:** ${parsedError.details}`;
        }
      } else if (combined.toLowerCase().includes('out of capacity')) {
        errorMsg = '**Out of Capacity:** No available resources in the selected availability domain';
      } else if (combined.toLowerCase().includes('invalid')) {
        errorMsg = '**Configuration Error:** Please check your settings';
      } else {
        errorMsg = `**Unknown Response**`;
      }
      
      errorMsg += `\n\n**Attempted Command:**\n\`\`\`bash\n${ociCommand}\n\`\`\``;
    }
    
    sendEmbed(interaction, status, errorMsg, manual);
    
    // 성공 시 추가 알림 (채널 전체에)
    if (status && !interaction) {
      // 자동 생성 성공 시에만 (수동 생성은 이미 interaction으로 응답함)
      const successChannel = client.channels.cache.get(CHANNEL_ID);
      if (successChannel) {
        const celebrationEmbed = new EmbedBuilder()
          .setTitle('🎉 OCI Always Free 인스턴스 생성 성공!')
          .setDescription(`**${attemptCount}번째 시도**에서 드디어 성공했습니다!`)
          .addFields(
            { name: '🖥️ 생성된 인스턴스', value: ociConfig.SHAPE || 'Unknown', inline: true },
            { name: '⏱️ 총 소요 시간', value: getUptime(), inline: true },
            { name: '📍 Region/AD', value: `${ociConfig.REGION}/${ociConfig.AVAILABILITY_DOMAIN?.split('.').pop()}`, inline: true }
          )
          .setColor(0xffd700) // 금색
          .setTimestamp()
          .setFooter({ text: '축하합니다! 이제 무료 서버를 사용할 수 있습니다!' });
        
        successChannel.send({ 
          content: '🚨 **중요 알림** 🚨', 
          embeds: [celebrationEmbed] 
        });
      }
    }
  });
}

// 슬래시 명령어 정의
const commands = [
  new SlashCommandBuilder().setName('status').setDescription(t('status_desc')),
  new SlashCommandBuilder().setName('launch').setDescription(t('launch_desc')),
  new SlashCommandBuilder()
    .setName('log')
    .setDescription(t('log_desc'))
    .addIntegerOption(option => 
      option.setName('count')
        .setDescription(t('log_count_desc'))
        .setRequired(false)
        .setMinValue(1)
        .setMaxValue(50)
    ),
  new SlashCommandBuilder().setName('stop').setDescription(t('stop_desc')),
  new SlashCommandBuilder().setName('start').setDescription(t('start_desc')),
  new SlashCommandBuilder().setName('config').setDescription(t('config_desc')),
  
  // 🆕 새로운 고급 기능들
  new SlashCommandBuilder()
    .setName('stats')
    .setDescription(t('stats_desc'))
    .addStringOption(option =>
      option.setName('period')
        .setDescription(t('stats_period_desc'))
        .addChoices(
          { name: t('today'), value: 'today' },
          { name: t('week'), value: 'week' },
          { name: t('month'), value: 'month' },
          { name: t('all'), value: 'all' }
        )
        .setRequired(false)
    ),
    
  new SlashCommandBuilder()
    .setName('instances')
    .setDescription(t('instances_desc'))
    .addStringOption(option =>
      option.setName('filter')
        .setDescription(t('instances_filter_desc'))
        .addChoices(
          { name: t('running'), value: 'running' },
          { name: t('stopped'), value: 'stopped' },
          { name: t('all_filter'), value: 'all' }
        )
        .setRequired(false)
    ),
    
  new SlashCommandBuilder()
    .setName('resources')
    .setDescription(t('resources_desc')),
    
  new SlashCommandBuilder()
    .setName('schedule')
    .setDescription(t('schedule_desc'))
    .addIntegerOption(option =>
      option.setName('interval')
        .setDescription(t('schedule_interval_desc'))
        .setMinValue(3)
        .setMaxValue(60)
        .setRequired(true)
    ),
    
  new SlashCommandBuilder()
    .setName('alert')
    .setDescription(t('alert_desc'))
    .addStringOption(option =>
      option.setName('type')
        .setDescription(t('alert_type_desc'))
        .addChoices(
          { name: t('success_alert'), value: 'success' },
          { name: t('failure_alert'), value: 'failure' },
          { name: t('daily_alert'), value: 'daily' },
          { name: t('error_alert'), value: 'error' }
        )
        .setRequired(true)
    )
    .addBooleanOption(option =>
      option.setName('enabled')
        .setDescription(t('alert_enabled_desc'))
        .setRequired(true)
    ),
    
  new SlashCommandBuilder().setName('help').setDescription(t('help_desc')),
  new SlashCommandBuilder().setName('test').setDescription('OCI CLI 연결 테스트')
].map(cmd => cmd.toJSON());

// Discord REST API로 슬래시 명령어 등록
const rest = new REST({ version: '10' }).setToken(TOKEN);
(async () => {
  try {
    writeLog('Registering slash commands...');
    await rest.put(
      Routes.applicationGuildCommands(CLIENT_ID, GUILD_ID),
      { body: commands }
    );
    writeLog('✅ Slash commands registered successfully');
  } catch (error) {
    writeLog('❌ Failed to register slash commands: ' + error);
  }
})();

const client = new Client({ 
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages] 
});

client.on('interactionCreate', async interaction => {
  if (!interaction.isChatInputCommand()) return;
  const cmd = interaction.commandName;

  try {
    switch (cmd) {
      case 'status':
        const last = lastResults[0];
        
        // 성공률 계산
        const recentAttempts = lastResults.slice(0, 10);
        const recentSuccesses = recentAttempts.filter(r => r.status).length;
        const successRate = recentAttempts.length > 0 ? 
          ((recentSuccesses / recentAttempts.length) * 100).toFixed(1) : '0.0';
        
        // 다음 시도까지 남은 시간 계산
        const nextAttemptTime = autoLaunch ? 
          `약 ${scheduleInterval}분 후` : '자동 생성 중지됨';
        
        const embed = new EmbedBuilder()
          .setTitle('🤖 ' + t('bot_status'))
          .addFields(
            { name: '⏰ ' + t('uptime'), value: getUptime(), inline: true },
            { name: '🔢 ' + t('total_attempts'), value: attemptCount.toString(), inline: true },
            { name: '📈 최근 성공률', value: `${successRate}% (최근 ${recentAttempts.length}회)`, inline: true },
            { name: '🚀 ' + t('auto_creation'), value: autoLaunch ? `🟢 ${t('enabled')}` : `🔴 ${t('disabled')}`, inline: true },
            { name: '⏱️ 다음 시도', value: nextAttemptTime, inline: true },
            { name: '⚙️ 시도 간격', value: `${scheduleInterval}분`, inline: true },
            { name: '🖥️ Shape', value: ociConfig.SHAPE || 'Unknown', inline: true },
            { name: '🌏 Region', value: ociConfig.REGION || 'Unknown', inline: true },
            { name: '💾 사양', value: `${ociConfig.shapeConfig?.ocpus || '?'} OCPU, ${ociConfig.shapeConfig?.memoryInGBs || '?'}GB RAM`, inline: true }
          )
          .setColor(autoLaunch ? 0x00ff00 : 0xff6b35)
          .setTimestamp();
          
        if (last) {
          const timeSinceLastAttempt = new Date() - new Date(last.time);
          const minutesAgo = Math.floor(timeSinceLastAttempt / (1000 * 60));
          const timeAgoText = minutesAgo < 1 ? '방금 전' : 
                             minutesAgo < 60 ? `${minutesAgo}분 전` : 
                             `${Math.floor(minutesAgo / 60)}시간 ${minutesAgo % 60}분 전`;
          
          embed.addFields({
            name: '📋 ' + t('recent_result'),
            value: `${last.status ? '✅ ' + t('success') : '❌ ' + t('failed')} (${timeAgoText})`,
            inline: false
          });
        }
        
        await interaction.reply({ embeds: [embed] });
        break;

      case 'launch':
        await interaction.deferReply();
        
        // 즉시 시작 알림
        const startEmbed = new EmbedBuilder()
          .setTitle('🚀 인스턴스 생성 시도 시작')
          .setDescription('OCI 인스턴스 생성을 시도하고 있습니다...')
          .addFields(
            { name: '🎯 Target Shape', value: ociConfig.SHAPE || 'Unknown', inline: true },
            { name: '🌍 Region', value: ociConfig.REGION || 'Unknown', inline: true },
            { name: '⏱️ 예상 소요 시간', value: '30초 ~ 2분', inline: true }
          )
          .setColor(0xffaa00)
          .setTimestamp();
        
        await interaction.editReply({ embeds: [startEmbed] });
        
        // 인스턴스 생성 시도
        tryLaunchInstance(interaction, true);
        break;

      case 'log':
        let count = interaction.options.getInteger('count') || 5;
        count = Math.min(Math.max(count, 1), lastResults.length);
        
        if (lastResults.length === 0) {
          await interaction.reply(t('no_logs'));
          break;
        }
        
        const logs = lastResults.slice(0, count).map((r, i) =>
          `**${i + 1}.** [${r.time}] #${r.attempt} | ${r.status ? '✅' : '❌'} | ${r.uptime}${r.error ? '\n   ↳ ' + r.error.substring(0, 100) : ''}`
        ).join('\n\n');
        
        const logEmbed = new EmbedBuilder()
          .setTitle(`📜 최근 ${count}회 시도 로그`)
          .setDescription(logs)
          .setColor(0x0099ff)
          .setTimestamp();
          
        await interaction.reply({ embeds: [logEmbed] });
        break;

      case 'stop':
        autoLaunch = false;
        writeLog('Auto launch stopped by user command');
        await interaction.reply(t('stopped'));
        break;

      case 'start':
        if (!autoLaunch) {
          autoLaunch = true;
          writeLog('Auto launch started by user command');
          await interaction.reply(t('started'));
        } else {
          await interaction.reply(t('already_active'));
        }
        break;

      case 'config':
        const configEmbed = new EmbedBuilder()
          .setTitle('⚙️ 현재 OCI 설정')
          .addFields(
            { name: '🌏 Region', value: ociConfig.REGION || 'N/A', inline: true },
            { name: '🖥️ Shape', value: ociConfig.SHAPE || 'N/A', inline: true },
            { name: '💾 사양', value: `${ociConfig.shapeConfig?.ocpus || '?'} OCPU, ${ociConfig.shapeConfig?.memoryInGBs || '?'}GB RAM`, inline: true },
            { name: '🏢 Tenancy', value: (ociConfig.TENANCY_OCID || '').substring(0, 50) + '...', inline: false },
            { name: '📁 Compartment', value: (ociConfig.COMPARTMENT_OCID || '').substring(0, 50) + '...', inline: false }
          )
          .setColor(0x0099ff)
          .setTimestamp();
          
        await interaction.reply({ embeds: [configEmbed] });
        break;

      case 'help':
        const helpEmbed = new EmbedBuilder()
          .setTitle(t('help_title'))
          .setDescription(t('help_description'))
          .addFields(
            { name: t('help_basic'), value: '`/status` - ' + (LANG === 'ko' ? '봇 상태 확인' : 'Check bot status') + '\n`/launch` - ' + (LANG === 'ko' ? '즉시 인스턴스 생성' : 'Create instance immediately') + '\n`/log [count]` - ' + (LANG === 'ko' ? '시도 로그 확인' : 'Check attempt logs'), inline: true },
            { name: t('help_control'), value: '`/start` - ' + (LANG === 'ko' ? '자동 생성 시작' : 'Start auto creation') + '\n`/stop` - ' + (LANG === 'ko' ? '자동 생성 중지' : 'Stop auto creation') + '\n`/schedule [min]` - ' + (LANG === 'ko' ? '간격 설정' : 'Set interval'), inline: true },
            { name: t('help_analysis'), value: '`/stats [period]` - ' + (LANG === 'ko' ? '상세 통계' : 'Detailed stats') + '\n`/instances [filter]` - ' + (LANG === 'ko' ? '인스턴스 목록' : 'Instance list') + '\n`/resources` - ' + (LANG === 'ko' ? '자원 사용량' : 'Resource usage'), inline: true },
            { name: t('help_notification'), value: '`/alert [type] [on/off]` - ' + (LANG === 'ko' ? '알림 설정' : 'Alert settings') + '\n`/config` - ' + (LANG === 'ko' ? '현재 설정 확인' : 'Check config') + '\n`/test` - ' + (LANG === 'ko' ? 'OCI CLI 연결 테스트' : 'OCI CLI connection test') + '\n`/help` - ' + (LANG === 'ko' ? '이 도움말' : 'This help'), inline: true },
            { name: t('help_current_status'), value: `${t('auto_creation_status')}: ${autoLaunch ? t('enabled') : t('disabled')}\n${t('uptime')}: ${getUptime()}\n${t('attempt_interval')}: ${scheduleInterval}${LANG === 'ko' ? '분' : ' min'}`, inline: false }
          )
          .setColor(0x0099ff)
          .setTimestamp()
          .setFooter({ text: t('help_footer') });
          
        await interaction.reply({ embeds: [helpEmbed] });
        break;

      case 'test':
        await handleOciTestCommand(interaction);
        break;

      // 🆕 새로운 명령어들
      case 'stats':
        await handleStatsCommand(interaction);
        break;

      case 'instances':
        await handleInstancesCommand(interaction);
        break;

      case 'resources':
        await handleResourcesCommand(interaction);
        break;

      case 'schedule':
        await handleScheduleCommand(interaction);
        break;

      case 'alert':
        await handleAlertCommand(interaction);
        break;
    }
  } catch (error) {
    writeLog('Command execution error: ' + error);
    // 🔧 FIX: interaction이 이미 replied 되었을 수 있으므로 안전하게 처리
    try {
      if (interaction.deferred) {
        await interaction.editReply(t('command_error'));
      } else if (!interaction.replied) {
        await interaction.reply(t('command_error'));
      }
    } catch (replyError) {
      writeLog('Failed to send error message: ' + replyError);
    }
  }
});

// 🆕 새로운 명령어 핸들러 함수들
async function handleStatsCommand(interaction) {
  const period = interaction.options.getString('period') || 'today';
  
  // 일일 통계 초기화 (새로운 날)
  if (dailyStats.lastReset !== new Date().toDateString()) {
    dailyStats.attempts = 0;
    dailyStats.successes = 0;
    dailyStats.lastReset = new Date().toDateString();
  }
  
  let filteredResults = lastResults;
  let periodName = '전체';
  
  const now = new Date();
  switch (period) {
    case 'today':
      const today = now.toDateString();
      filteredResults = lastResults.filter(r => new Date(r.time).toDateString() === today);
      periodName = '오늘';
      break;
    case 'week':
      const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      filteredResults = lastResults.filter(r => new Date(r.time) >= weekAgo);
      periodName = '이번 주';
      break;
    case 'month':
      const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      filteredResults = lastResults.filter(r => new Date(r.time) >= monthAgo);
      periodName = '이번 달';
      break;
  }
  
  const totalAttempts = filteredResults.length;
  const successes = filteredResults.filter(r => r.status).length;
  const successRate = totalAttempts > 0 ? ((successes / totalAttempts) * 100).toFixed(1) : 0;
  
  const statsEmbed = new EmbedBuilder()
    .setTitle(`📊 ${periodName} 상세 통계`)
    .addFields(
      { name: '🎯 총 시도 횟수', value: totalAttempts.toString(), inline: true },
      { name: '✅ 성공 횟수', value: successes.toString(), inline: true },
      { name: '📈 성공률', value: `${successRate}%`, inline: true },
      { name: '❌ 실패 횟수', value: (totalAttempts - successes).toString(), inline: true },
      { name: '⏰ 평균 간격', value: `${scheduleInterval}분`, inline: true },
      { name: '🚀 자동 생성', value: autoLaunch ? '🟢 활성화' : '🔴 비활성화', inline: true }
    )
    .setColor(successRate > 50 ? 0x00ff00 : successRate > 20 ? 0xffff00 : 0xff0000)
    .setTimestamp();
  
  if (totalAttempts > 0) {
    const lastAttempt = filteredResults[0];
    statsEmbed.addFields({
      name: '🕒 마지막 시도',
      value: `${lastAttempt.status ? '✅ 성공' : '❌ 실패'} - ${lastAttempt.time}`,
      inline: false
    });
  }
  
  await interaction.reply({ embeds: [statsEmbed] });
}

// 상태 이모지 헬퍼 함수
function getStatusEmoji(state) {
  switch (state) {
    case 'RUNNING': return '🟢';
    case 'STOPPED': return '🔴';
    case 'STOPPING': return '🟡';
    case 'STARTING': return '🟡';
    case 'PROVISIONING': return '🟠';
    case 'TERMINATING': return '⚫';
    case 'TERMINATED': return '⚫';
    default: return '⚪';
  }
}

async function handleInstancesCommand(interaction) {
  const filter = interaction.options.getString('filter') || 'all';
  
  await interaction.deferReply();
  
  try {
    const { exec } = require('child_process');
    // 인스턴스와 VNIC 정보를 함께 가져오기 위해 더 자세한 명령어 사용
    const command = `oci compute instance list --compartment-id "${ociConfig.COMPARTMENT_OCID}" --all --output json`;
    
    exec(command, { timeout: 30000 }, (error, stdout, stderr) => {
      if (error) {
        writeLog(`Instance list command failed: ${error.message}`);
        interaction.editReply('❌ 인스턴스 목록을 가져오는데 실패했습니다.\nOCI CLI 설정을 확인해주세요.');
        return;
      }
      
      try {
        const response = JSON.parse(stdout);
        if (!response.data) {
          interaction.editReply('❌ 잘못된 응답 형식입니다.');
          return;
        }
        
        const instances = response.data;
        let filteredInstances = instances;
        
        if (filter === 'running') {
          filteredInstances = instances.filter(i => i['lifecycle-state'] === 'RUNNING');
        } else if (filter === 'stopped') {
          filteredInstances = instances.filter(i => i['lifecycle-state'] === 'STOPPED');
        }
        
        if (filteredInstances.length === 0) {
          const filterName = filter === 'all' ? '전체' : 
                           filter === 'running' ? '실행 중인' : 
                           filter === 'stopped' ? '정지된' : filter;
          interaction.editReply(`🔍 ${filterName} 인스턴스가 없습니다.`);
          return;
        }
        
        const instanceFields = filteredInstances.slice(0, 10).map(instance => {
          // OCI CLI 실제 필드명 사용
          const createdDate = new Date(instance['time-created'] || instance.timeCreated).toLocaleDateString('ko-KR');
          const displayName = instance['display-name'] || instance.displayName || 'Unknown';
          const lifecycleState = instance['lifecycle-state'] || instance.lifecycleState || 'Unknown';
          const shape = instance.shape || 'Unknown';
          const instanceId = instance.id ? instance.id.split('.').pop().substring(0, 8) + '...' : 'Unknown';
          
          // OCPU/Memory 정보 (A1.Flex의 경우)
          let specs = '';
          if (shape === 'VM.Standard.A1.Flex' && instance['shape-config']) {
            const shapeConfig = instance['shape-config'];
            const ocpus = shapeConfig.ocpus || shapeConfig.ocpus || 1;
            const memory = shapeConfig['memory-in-gbs'] || shapeConfig.memoryInGBs || 6;
            specs = `\n**사양:** ${ocpus} OCPU, ${memory}GB RAM`;
          } else if (shape === 'VM.Standard.E2.1.Micro') {
            specs = `\n**사양:** 1 OCPU, 1GB RAM`;
          }
          
          return {
            name: `🖥️ ${displayName}`,
            value: `**상태:** ${getStatusEmoji(lifecycleState)} ${lifecycleState}\n` +
                   `**Shape:** ${shape}${specs}\n` +
                   `**인스턴스 ID:** ${instanceId}\n` +
                   `**생성일:** ${createdDate}`,
            inline: true
          };
        });
        
        const instanceEmbed = new EmbedBuilder()
          .setTitle(`🖥️ 인스턴스 목록 (${filter === 'all' ? '전체' : filter})`)
          .setDescription(`총 **${filteredInstances.length}개**의 인스턴스`)
          .addFields(instanceFields)
          .setColor(0x0099ff)
          .setTimestamp();
          
        if (filteredInstances.length > 10) {
          instanceEmbed.setFooter({ text: `처음 10개만 표시됨 (총 ${filteredInstances.length}개)` });
        }
        
        interaction.editReply({ embeds: [instanceEmbed] });
      } catch (parseError) {
        writeLog(`Instance list parse error: ${parseError.message}`);
        interaction.editReply('❌ 인스턴스 데이터 파싱에 실패했습니다.');
      }
    });
  } catch (error) {
    writeLog(`Instance list error: ${error.message}`);
    interaction.editReply('❌ 명령 실행 중 오류가 발생했습니다.');
  }
}

async function handleResourcesCommand(interaction) {
  await interaction.deferReply();
  
  try {
    const { exec } = require('child_process');
    
    // 실제 OCI CLI 명령어 사용 - 인스턴스 목록 조회
    const instanceCommand = `oci compute instance list --compartment-id "${ociConfig.COMPARTMENT_OCID}" --all --output json`;
    
    exec(instanceCommand, { timeout: 30000 }, (error, stdout, stderr) => {
      if (error) {
        writeLog(`Resource command failed: ${error.message}`);
        interaction.editReply('❌ 리소스 정보를 가져오는데 실패했습니다.\nOCI CLI 설정을 확인해주세요.');
        return;
      }
      
      try {
        const response = JSON.parse(stdout);
        if (!response.data) {
          interaction.editReply('❌ 잘못된 응답 형식입니다.');
          return;
        }
        
        const instances = response.data.filter(i => 
          i['lifecycle-state'] === 'RUNNING' || 
          i['lifecycle-state'] === 'STARTING' || 
          i['lifecycle-state'] === 'PROVISIONING'
        );
        
        // Always Free 리소스 계산
        let e2MicroCount = 0;
        let a1FlexOcpus = 0;
        let a1FlexMemory = 0;
        let totalBootStorage = 0;
        
        instances.forEach(instance => {
          const shape = instance.shape;
          
          if (shape === 'VM.Standard.E2.1.Micro') {
            e2MicroCount += 1;
          } else if (shape === 'VM.Standard.A1.Flex') {
            // A1.Flex 인스턴스의 OCPU/Memory 정보
            const shapeConfig = instance['shape-config'] || instance.shapeConfig;
            if (shapeConfig) {
              a1FlexOcpus += shapeConfig.ocpus || shapeConfig.ocpus || 1;
              a1FlexMemory += shapeConfig['memory-in-gbs'] || shapeConfig.memoryInGBs || 6;
            } else {
              // 기본값 사용
              a1FlexOcpus += 1;
              a1FlexMemory += 6;
            }
          }
          
          // 부트 볼륨 계산 - 실제 API 호출 없이 추정
          totalBootStorage += 47; 
        });
        
        // Always Free 한도
        const limits = {
          e2Micro: { used: e2MicroCount, limit: 2 },
          a1FlexOcpu: { used: a1FlexOcpus, limit: 4 },
          a1FlexMemory: { used: a1FlexMemory, limit: 24 },
          bootStorage: { used: totalBootStorage, limit: 200 }
        };
        
        // 사용률 계산
        const e2Usage = (limits.e2Micro.used / limits.e2Micro.limit * 100).toFixed(1);
        const a1OcpuUsage = (limits.a1FlexOcpu.used / limits.a1FlexOcpu.limit * 100).toFixed(1);
        const a1MemUsage = (limits.a1FlexMemory.used / limits.a1FlexMemory.limit * 100).toFixed(1);
        const storageUsage = (limits.bootStorage.used / limits.bootStorage.limit * 100).toFixed(1);
        
        const resourceEmbed = new EmbedBuilder()
          .setTitle('💰 Always Free 리소스 사용량')
          .setDescription(`현재 **${instances.length}개** 인스턴스가 실행 중입니다`)
          .addFields(
            { 
              name: '🖥️ E2.1.Micro 인스턴스', 
              value: `**${limits.e2Micro.used}/${limits.e2Micro.limit}** 사용 중\n` +
                     `사용률: ${e2Usage}%\n` +
                     `남은 자원: **${limits.e2Micro.limit - limits.e2Micro.used}개**`,
              inline: true 
            },
            { 
              name: '⚡ A1.Flex OCPU', 
              value: `**${limits.a1FlexOcpu.used}/${limits.a1FlexOcpu.limit}** 사용 중\n` +
                     `사용률: ${a1OcpuUsage}%\n` +
                     `남은 자원: **${limits.a1FlexOcpu.limit - limits.a1FlexOcpu.used} OCPU**`,
              inline: true 
            },
            { 
              name: '🧠 A1.Flex 메모리', 
              value: `**${limits.a1FlexMemory.used}GB/${limits.a1FlexMemory.limit}GB** 사용 중\n` +
                     `사용률: ${a1MemUsage}%\n` +
                     `남은 자원: **${limits.a1FlexMemory.limit - limits.a1FlexMemory.used}GB**`,
              inline: true 
            },
            { 
              name: '💾 부트 볼륨', 
              value: `**${limits.bootStorage.used}GB/${limits.bootStorage.limit}GB** 사용 중\n` +
                     `사용률: ${storageUsage}%\n` +
                     `남은 자원: **${limits.bootStorage.limit - limits.bootStorage.used}GB**`,
              inline: true 
            },
            { 
              name: '🌐 네트워크 (무제한)', 
              value: `• 아웃바운드: **10TB/월** 무료\n` +
                     `• 로드밸런서: **10Mbps** 무료\n` +
                     `• 공개 IP: **제한 없음**`,
              inline: true 
            },
            { 
              name: '📈 추천 액션', 
              value: getRecommendation(limits),
              inline: true 
            }
          )
          .setColor(getResourceColor(limits))
          .setTimestamp()
          .setFooter({ text: '📊 실시간 OCI 인스턴스 기반 계산' });
        
        interaction.editReply({ embeds: [resourceEmbed] });
      } catch (parseError) {
        writeLog(`Resource parse error: ${parseError.message}`);
        interaction.editReply('❌ 리소스 데이터 파싱에 실패했습니다.');
      }
    });
  } catch (error) {
    writeLog(`Resource error: ${error.message}`);
    interaction.editReply('❌ 명령 실행 중 오류가 발생했습니다.');
  }
}

// 리소스 추천 헬퍼 함수
function getRecommendation(limits) {
  const canCreateE2 = limits.e2Micro.used < limits.e2Micro.limit;
  const remainingA1Ocpu = limits.a1FlexOcpu.limit - limits.a1FlexOcpu.used;
  const remainingA1Memory = limits.a1FlexMemory.limit - limits.a1FlexMemory.used;
  
  if (canCreateE2 && remainingA1Ocpu >= 1) {
    return `🟢 **추가 생성 가능**\n• E2.Micro: ${limits.e2Micro.limit - limits.e2Micro.used}개\n• A1.Flex: ${remainingA1Ocpu}/${Math.floor(remainingA1Memory/6)} OCPU 가능`;
  } else if (canCreateE2) {
    return `🟡 **E2.Micro만 가능**\n• ${limits.e2Micro.limit - limits.e2Micro.used}개 추가 생성 가능`;
  } else if (remainingA1Ocpu >= 1) {
    return `🟡 **A1.Flex만 가능**\n• ${remainingA1Ocpu} OCPU 추가 가능`;
  } else {
    return `🔴 **한도 초과**\n• Always Free 리소스 모두 사용 중`;
  }
}

// 리소스 상태별 색상
function getResourceColor(limits) {
  const totalUsage = (
    (limits.e2Micro.used / limits.e2Micro.limit) +
    (limits.a1FlexOcpu.used / limits.a1FlexOcpu.limit) +
    (limits.a1FlexMemory.used / limits.a1FlexMemory.limit)
  ) / 3;
  
  if (totalUsage < 0.5) return 0x00ff00; // 초록색 - 여유
  if (totalUsage < 0.8) return 0xffff00; // 노란색 - 보통
  return 0xff0000; // 빨간색 - 한도 근접
}

// OCI CLI 연결 테스트 함수
async function handleOciTestCommand(interaction) {
  await interaction.deferReply();
  
  try {
    const { exec } = require('child_process');
    
    // 기본 OCI CLI 테스트
    const testCommand = `oci iam compartment get --compartment-id "${ociConfig.COMPARTMENT_OCID}" --output json`;
    
    exec(testCommand, { timeout: 15000 }, (error, stdout, stderr) => {
      if (error) {
        const testEmbed = new EmbedBuilder()
          .setTitle('❌ OCI CLI 연결 테스트 실패')
          .addFields(
            { name: '🔍 오류 내용', value: error.message.substring(0, 1000), inline: false },
            { name: '💡 해결 방법', value: '• `oci setup config` 실행\n• API 키 권한 확인\n• 네트워크 연결 확인', inline: false }
          )
          .setColor(0xff0000)
          .setTimestamp();
        
        interaction.editReply({ embeds: [testEmbed] });
        return;
      }
      
      try {
        const response = JSON.parse(stdout);
        const compartmentData = response.data || response;
        
        const testEmbed = new EmbedBuilder()
          .setTitle('✅ OCI CLI 연결 테스트 성공')
          .addFields(
            { name: '🏢 Compartment Name', value: compartmentData.name || 'Unknown', inline: true },
            { name: '🆔 Compartment ID', value: compartmentData.id ? compartmentData.id.split('.').pop().substring(0, 16) + '...' : 'Unknown', inline: true },
            { name: '📍 상태', value: compartmentData['lifecycle-state'] || compartmentData.lifecycleState || 'Unknown', inline: true },
            { name: '🛠️ 사용 가능한 명령어', value: '• `/instances` - 인스턴스 목록\n• `/resources` - 리소스 사용량\n• `/launch` - 인스턴스 생성', inline: false }
          )
          .setColor(0x00ff00)
          .setTimestamp()
          .setFooter({ text: 'OCI CLI가 정상적으로 설정되었습니다!' });
        
        interaction.editReply({ embeds: [testEmbed] });
      } catch (parseError) {
        interaction.editReply('❌ 응답 파싱에 실패했지만 OCI CLI는 작동하는 것 같습니다.');
      }
    });
  } catch (error) {
    interaction.editReply('❌ 테스트 실행 중 오류가 발생했습니다.');
  }
}

async function handleScheduleCommand(interaction) {
  const newInterval = interaction.options.getInteger('interval');
  const oldInterval = scheduleInterval;
  
  scheduleInterval = newInterval;
  
  // 🔧 FIX: 스케줄 타이머 재시작 - 이 부분이 빠져있어서 간격 변경이 적용되지 않았음
  if (typeof global.updateSchedule === 'function') {
    global.updateSchedule();
  }
  
  const scheduleEmbed = new EmbedBuilder()
    .setTitle(t('schedule_changed'))
    .addFields(
      { name: t('previous_interval'), value: `${oldInterval}${LANG === 'ko' ? '분' : ' min'}`, inline: true },
      { name: t('new_interval'), value: `${newInterval}${LANG === 'ko' ? '분' : ' min'}`, inline: true },
      { name: t('next_attempt'), value: LANG === 'ko' ? `약 ${newInterval}분 후` : `About ${newInterval} min later`, inline: true }
    )
    .setDescription(LANG === 'ko' ? 
      `자동 인스턴스 생성 간격이 **${newInterval}분**으로 설정되었습니다.` : 
      `Automatic instance creation interval has been set to **${newInterval} minutes**.`)
    .setColor(0x00ff00)
    .setTimestamp();
  
  writeLog(`Schedule interval changed from ${oldInterval} to ${newInterval} minutes`);
  await interaction.reply({ embeds: [scheduleEmbed] });
}

async function handleAlertCommand(interaction) {
  const alertType = interaction.options.getString('type');
  const enabled = interaction.options.getBoolean('enabled');
  
  alertSettings[alertType] = enabled;
  
  const alertEmbed = new EmbedBuilder()
    .setTitle('🔔 알림 설정 변경')
    .addFields(
      { name: '📝 알림 유형', value: getAlertTypeName(alertType), inline: true },
      { name: '⚙️ 상태', value: enabled ? '🟢 활성화' : '🔴 비활성화', inline: true },
      { name: '📊 현재 설정', value: Object.entries(alertSettings).map(([key, val]) => 
        `${getAlertTypeName(key)}: ${val ? '🟢' : '🔴'}`).join('\n'), inline: false }
    )
    .setColor(enabled ? 0x00ff00 : 0xff0000)
    .setTimestamp();
  
  writeLog(`Alert setting changed: ${alertType} = ${enabled}`);
  await interaction.reply({ embeds: [alertEmbed] });
}

function getStatusEmoji(status) {
  switch (status) {
    case 'RUNNING': return '🟢';
    case 'STOPPED': return '🔴';
    case 'STARTING': return '🟡';
    case 'STOPPING': return '🟠';
    case 'TERMINATED': return '⚫';
    default: return '❓';
  }
}

function getAlertTypeName(type) {
  switch (type) {
    case 'success': return '✅ 성공 알림';
    case 'failure': return '❌ 실패 알림';
    case 'daily': return '📊 일일 요약';
    case 'error': return '⚠️ 오류 알림';
    default: return type;
  }
}

client.once('ready', () => {
  writeLog('🤖 Discord bot is ready!');
  console.log(`✅ 봇이 ${client.user.tag}로 로그인했습니다!`);
  
  // 🆕 개선된 스케줄링 시스템
  let scheduleTimer;
  
  function startSchedule() {
    if (scheduleTimer) {
      clearInterval(scheduleTimer);
    }
    
    writeLog(`Setting up schedule: every ${scheduleInterval} minutes`);
    scheduleTimer = setInterval(() => {
      if (autoLaunch) {
        writeLog('⏰ Scheduled instance creation attempt');
        tryLaunchInstance();
      }
    }, scheduleInterval * 60 * 1000);
  }
  
  // 초기 스케줄 시작
  startSchedule();
  
  // 스케줄 변경을 위한 글로벌 함수
  global.updateSchedule = () => {
    startSchedule();
  };
  
  // 🆕 일일 요약 알림 (매일 자정)
  const now = new Date();
  const tomorrow = new Date(now);
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(0, 0, 0, 0);
  const msUntilMidnight = tomorrow.getTime() - now.getTime();
  
  setTimeout(() => {
    if (alertSettings.daily) {
      sendDailySummary();
    }
    
    // 매일 자정마다 일일 요약 전송
    setInterval(() => {
      if (alertSettings.daily) {
        sendDailySummary();
      }
    }, 24 * 60 * 60 * 1000);
  }, msUntilMidnight);
  
  // 시작 시 첫 번째 시도
  writeLog('Starting initial instance creation attempt...');
  tryLaunchInstance();
});

// 🆕 일일 요약 함수
async function sendDailySummary() {
  try {
    const today = new Date().toDateString();
    const todayResults = lastResults.filter(r => new Date(r.time).toDateString() === today);
    
    const totalAttempts = todayResults.length;
    const successes = todayResults.filter(r => r.status).length;
    const successRate = totalAttempts > 0 ? ((successes / totalAttempts) * 100).toFixed(1) : 0;
    
    const summaryEmbed = new EmbedBuilder()
      .setTitle('📊 일일 활동 요약')
      .setDescription(`${new Date().toLocaleDateString()} 활동 보고서`)
      .addFields(
        { name: '🎯 총 시도', value: totalAttempts.toString(), inline: true },
        { name: '✅ 성공', value: successes.toString(), inline: true },
        { name: '📈 성공률', value: `${successRate}%`, inline: true },
        { name: '⏰ 봇 업타임', value: getUptime(), inline: true },
        { name: '🔄 자동 생성', value: autoLaunch ? '🟢 활성화' : '🔴 비활성화', inline: true },
        { name: '📅 다음 시도', value: `${scheduleInterval}분 후`, inline: true }
      )
      .setColor(successRate > 50 ? 0x00ff00 : successRate > 0 ? 0xffff00 : 0xff0000)
      .setTimestamp()
      .setFooter({ text: 'OCI Always Free Discord Bot' });
    
    const channel = await client.channels.fetch(ociConfig.DISCORD_CHANNEL_ID);
    await channel.send({ embeds: [summaryEmbed] });
    
    writeLog('📊 Daily summary sent');
  } catch (error) {
    writeLog('Failed to send daily summary: ' + error);
  }
}

client.on('error', error => {
  writeLog('Discord client error: ' + error);
});

client.login(TOKEN);
EOF

if [ "$LANG_CHOICE" = "ko" ]; then
  log success "Discord 봇 코드 생성 완료!"
else
  log success "Discord bot code generated successfully!"
fi

# 8. PM2로 봇 실행
echo ""
if [ "$LANG_CHOICE" = "ko" ]; then
  log info "🚀 PM2로 Discord 봇 시작 중..."
else
  log info "🚀 Starting Discord bot with PM2..."
fi

# 기존 봇 프로세스 정리
pm2 delete oci-discord-bot >/dev/null 2>&1 || true

# 새 봇 프로세스 시작
pm2 start oci-discord-bot.js --name oci-discord-bot --time
pm2 save

if [ "$LANG_CHOICE" = "ko" ]; then
  log success "🎉 OCI Discord Bot 설정이 모두 완료되었습니다!"
  echo ""
  log info "📊 봇 상태 확인:"
  pm2 status
  
  echo ""
  log bot "🤖 Discord에서 다음 슬래시 명령어를 사용할 수 있습니다:"
  echo "  /status  - 봇 상태 확인"
  echo "  /launch  - 즉시 인스턴스 생성"
  echo "  /log     - 최근 로그 확인"
  echo "  /config  - OCI 설정 확인"
  echo "  /stop    - 자동 생성 중지"
  echo "  /start   - 자동 생성 시작"
  echo "  /help    - 도움말"
else
  log success "🎉 OCI Discord Bot setup completed successfully!"
  echo ""
  log info "📊 Bot status check:"
  pm2 status
  
  echo ""
  log bot "🤖 Available slash commands in Discord:"
  echo "  /status  - Check bot status"
  echo "  /launch  - Launch instance immediately"
  echo "  /log     - View recent logs"
  echo "  /config  - Check OCI configuration"
  echo "  /stop    - Stop auto-creation"
  echo "  /start   - Start auto-creation"
  echo "  /help    - Show help"
fi

echo ""
if [ "$LANG_CHOICE" = "ko" ]; then
  log info "📋 유용한 명령어:"
  echo "  pm2 logs oci-discord-bot  # 봇 로그 실시간 확인"
  echo "  pm2 restart oci-discord-bot  # 봇 재시작"
  echo "  pm2 stop oci-discord-bot     # 봇 중지"
  echo "  tail -f oci_bot.log          # 봇 활동 로그 확인"
  
  echo ""
  log success "✅ 설정 완료! Discord에서 봇을 사용해보세요."
else
  log info "📋 Useful commands:"
  echo "  pm2 logs oci-discord-bot  # View bot logs in real-time"
  echo "  pm2 restart oci-discord-bot  # Restart bot"
  echo "  pm2 stop oci-discord-bot     # Stop bot"
  echo "  tail -f oci_bot.log          # Monitor bot activity logs"
  
  echo ""
  log success "✅ Setup complete! Try using the bot in Discord."
fi
