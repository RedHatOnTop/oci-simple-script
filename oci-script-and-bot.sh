#!/bin/bash

set -e

# 색상 및 이모지 정의
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"
SUCCESS="✅"
FAIL="❌"
INFO="ℹ️"
WARN="⚠️"
BOT="🤖"

log() {
  local type="$1"
  local msg="$2"
  case "$type" in
    success) echo -e "${GREEN}${SUCCESS} ${msg}${RESET}" ;;
    fail)    echo -e "${RED}${FAIL} ${msg}${RESET}" ;;
    info)    echo -e "${CYAN}${INFO} ${msg}${RESET}" ;;
    warn)    echo -e "${YELLOW}${WARN} ${msg}${RESET}" ;;
    bot)     echo -e "${BOLD}${BOT} ${msg}${RESET}" ;;
    *)       echo -e "${msg}" ;;
  esac
}

WORKDIR="$(pwd)"
CONFIG_FILE="$WORKDIR/config.json"

# 1. config.json에서 값 추출 및 파일화 (+ 개선된 검증)
if [ ! -f "$CONFIG_FILE" ]; then
  log fail "$CONFIG_FILE 파일이 없습니다. config.json을 먼저 작성하세요."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  log info "jq 설치 중..."
  sudo apt-get update && sudo apt-get install -y jq
  log success "jq 설치 완료"
fi

extract_and_validate() {
  local key="$1"
  local type="$2" # "string" or "json"
  local file="$WORKDIR/$key"
  local value
  if [ "$type" = "string" ]; then
    value=$(jq -r ".${key}" "$CONFIG_FILE")
    if [ "$value" = "null" ] || [ -z "$value" ]; then
      log fail "$key 값이 config.json에 없습니다."
      exit 1
    fi
    echo "$value" > "$file"
  elif [ "$type" = "json" ]; then
    value=$(jq ".${key}" "$CONFIG_FILE")
    if [ "$value" = "null" ] || [ -z "$value" ]; then
      log fail "$key JSON이 config.json에 없습니다."
      exit 1
    fi
    echo "$value" | jq '.' > "$file"
  fi
}

extract_and_validate "A" "string"
extract_and_validate "C" "string"
extract_and_validate "S" "string"
extract_and_validate "I" "string"
extract_and_validate "availabilityConfig" "json"
extract_and_validate "instanceOptions" "json"
extract_and_validate "shapeConfig" "json"

log success "config.json에서 각 인자 파일/JSON 분리 저장 완료"

# 2. .env 파일 로드 및 필수값 검증
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
  log success ".env 파일 로드 완료"
else
  log fail ".env 파일이 없습니다. 필수 값을 채워넣어 주세요."
  exit 1
fi

REQUIRED_VARS=(TENANCY_OCID USER_OCID COMPARTMENT_OCID FINGERPRINT REGION DISCORD_TOKEN DISCORD_CLIENT_ID DISCORD_GUILD_ID DISCORD_CHANNEL_ID)
for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR}" ]; then
    log fail "$VAR 환경변수가 누락되었습니다. .env 파일을 확인하세요."
    exit 1
  fi
done

# 3. OCI CLI 설치
if ! command -v oci > /dev/null; then
  log info "OCI CLI 설치 중..."
  bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
  export PATH="$HOME/bin:$PATH"
  log success "OCI CLI 설치 완료"
else
  log success "OCI CLI 이미 설치됨"
fi

# 4. ~/.oci 디렉토리 및 키 생성/사용자 키 선택
mkdir -p ~/.oci

if [ -n "$CUSTOM_PRIVATE_KEY_PATH" ] && [ -f "$CUSTOM_PRIVATE_KEY_PATH" ]; then
  KEY_PATH="$CUSTOM_PRIVATE_KEY_PATH"
  PUB_KEY_PATH="$CUSTOM_PUBLIC_KEY_PATH"
  log info "사용자 지정 SSH 키를 사용합니다: $KEY_PATH"
else
  KEY_PATH="$HOME/.oci/oci_api_key.pem"
  PUB_KEY_PATH="$HOME/.oci/oci_api_key_public.pem"
  if [ ! -f "$KEY_PATH" ]; then
    openssl genrsa -out "$KEY_PATH" 2048
    openssl rsa -pubout -in "$KEY_PATH" -out "$PUB_KEY_PATH"
    log success "API용 키페어 생성 완료"
  else
    log info "API용 키페어 이미 존재"
  fi
fi

if [ -f "$KEY_PATH" ]; then
  chmod 600 "$KEY_PATH"
  log info "키 파일 권한이 600으로 설정됨"
fi

cat <<EOF > ~/.oci/config
[DEFAULT]
user=${USER_OCID}
fingerprint=${FINGERPRINT}
tenancy=${TENANCY_OCID}
region=${REGION}
key_file=${KEY_PATH}
EOF

log success "OCI config 파일 생성 완료!"
log info "OCI 콘솔에 아래 퍼블릭키를 등록하세요:"
log bot "$(cat "$PUB_KEY_PATH")"

# 5. Node.js, npm, pm2 설치
if ! command -v node > /dev/null; then
  log info "Node.js 설치 중..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
  log success "Node.js 설치 완료"
fi
if ! command -v pm2 > /dev/null; then
  log info "pm2 설치 중..."
  npm install -g pm2
  log success "pm2 설치 완료"
fi

# 6. 디스코드 봇 코드 생성 (슬래시 명령어, 환경변수 적용, OCI 오류 중단 안전장치 추가)
cat <<'EON' > oci-discord-bot.js
require('dotenv').config();
const { Client, GatewayIntentBits, REST, Routes, SlashCommandBuilder, EmbedBuilder } = require('discord.js');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const WORKDIR = process.cwd();

const TOKEN = process.env.DISCORD_TOKEN;
const CLIENT_ID = process.env.DISCORD_CLIENT_ID;
const GUILD_ID = process.env.DISCORD_GUILD_ID;
const CHANNEL_ID = process.env.DISCORD_CHANNEL_ID;
const PUB_KEY_PATH = process.env.CUSTOM_PUBLIC_KEY_PATH || process.env.PUB_KEY_PATH || path.join(process.env.HOME, '.oci', 'oci_api_key_public.pem');

let attemptCount = 0;
const startTime = Date.now();
let autoLaunch = true;
let lastResults = [];
const LOG_FILE = './oci_bot.log';

function fileArg(fileName) {
  const filePath = path.join(WORKDIR, fileName);
  if (!fs.existsSync(filePath)) {
    throw new Error(`필수 파일 ${fileName}이 없습니다.`);
  }
  let value = fs.readFileSync(filePath, 'utf8').trim();
  if (!value || value === 'null') {
    throw new Error(`파일 ${fileName}의 값이 올바르지 않습니다.`);
  }
  return `"${filePath}"`;
}

function getUptime() {
  const ms = Date.now() - startTime;
  const sec = Math.floor(ms / 1000);
  const min = Math.floor(sec / 60);
  const hour = Math.floor(min / 60);
  return `${hour}h ${min % 60}m ${sec % 60}s`;
}

function writeLog(msg) {
  fs.appendFileSync(LOG_FILE, `[${new Date().toISOString()}] ${msg}\n`);
}

function sendEmbed(interaction, status, errorMsg = null, manual=false) {
  const embed = new EmbedBuilder()
    .setTitle(manual ? 'OCI 인스턴스 수동 생성 시도' : 'OCI 인스턴스 자동 생성 시도')
    .addFields(
      { name: '시도 시간', value: new Date().toISOString(), inline: false },
      { name: '시도 회차', value: attemptCount.toString(), inline: true },
      { name: '업타임', value: getUptime(), inline: true },
      { name: '성공 여부', value: status ? '✅ 성공' : '❌ 실패', inline: true }
    )
    .setColor(status ? 0x00ff00 : 0xff0000);
  if (errorMsg) embed.addFields({ name: '오류 메시지', value: errorMsg, inline: false });

  if (interaction) interaction.reply({ embeds: [embed] });
  else {
    const channel = client.channels.cache.get(CHANNEL_ID);
    channel.send({ embeds: [embed] });
  }

  lastResults.unshift({
    time: new Date().toISOString(),
    attempt: attemptCount,
    uptime: getUptime(),
    status: status,
    error: errorMsg
  });
  lastResults = lastResults.slice(0,20);

  writeLog(`Attempt #${attemptCount} | ${status ? 'SUCCESS' : 'FAIL'}${errorMsg ? ' | ' + errorMsg : ''}`);
}

function tryLaunchInstance(interaction=null, manual=false) {
  attemptCount += 1;
  const OCI_CMD = [
    'oci compute instance launch',
    '--availability-domain', fileArg('A'),
    '--compartment-id', fileArg('C'),
    '--shape', 'VM.Standard.A1.Flex',
    '--subnet-id', fileArg('S'),
    '--assign-private-dns-record', 'true',
    '--assign-public-ip', 'false',
    '--availability-config', fileArg('availabilityConfig.json'),
    '--display-name', 'my-new-instance',
    '--image-id', fileArg('I'),
    '--instance-options', fileArg('instanceOptions.json'),
    '--shape-config', fileArg('shapeConfig.json'),
    '--ssh-authorized-keys-file', PUB_KEY_PATH
  ].join(' ');

  exec(OCI_CMD, (error, stdout, stderr) => {
    const combined = `${stdout}\n${stderr}`;
    if (/invalid/i.test(combined)) {
      sendEmbed(interaction, false, `OCI 오류 발생(즉시 중단): ${combined}`, manual);
      writeLog(`OCI 오류(즉시 중단): ${combined}`);
      process.exit(1);
      return;
    }
    let status = !error;
    let errorMsg = error ? error.message + '\n' + stderr : null;
    sendEmbed(interaction, status, errorMsg, manual);
  });
}

const commands = [
  new SlashCommandBuilder().setName('status').setDescription('봇 상태 요약'),
  new SlashCommandBuilder().setName('launch').setDescription('OCI 인스턴스 즉시 생성'),
  new SlashCommandBuilder().setName('log').setDescription('최근 N회 로그').addIntegerOption(option => option.setName('count').setDescription('로그 개수').setRequired(false)),
  new SlashCommandBuilder().setName('stop').setDescription('자동 생성 중지'),
  new SlashCommandBuilder().setName('start').setDescription('자동 생성 시작'),
  new SlashCommandBuilder().setName('help').setDescription('명령어 안내')
].map(cmd => cmd.toJSON());

const rest = new REST({ version: '10' }).setToken(TOKEN);

(async () => {
  try {
    await rest.put(
      Routes.applicationGuildCommands(CLIENT_ID, GUILD_ID),
      { body: commands }
    );
    console.log('✅ 슬래시 명령어 등록 완료');
    writeLog('Slash commands registered');
  } catch (error) {
    console.error(error);
    writeLog('Slash command register failed: ' + error);
  }
})();

const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages] });

client.on('interactionCreate', async interaction => {
  if (!interaction.isChatInputCommand()) return;
  const cmd = interaction.commandName;

  if (cmd === 'status') {
    const last = lastResults[0];
    const embed = new EmbedBuilder()
      .setTitle('OCI 봇 상태')
      .addFields(
        { name: '업타임', value: getUptime(), inline: true },
        { name: '시도 회차', value: attemptCount.toString(), inline: true },
        { name: '자동 생성', value: autoLaunch ? '🟢 ON' : '🔴 OFF', inline: true }
      );
    if (last) embed.addFields(
      { name: '최근 결과', value: `${last.status ? '✅ 성공' : '❌ 실패'} (${last.time})`, inline: false }
    );
    interaction.reply({ embeds: [embed] });
  }
  else if (cmd === 'launch') {
    tryLaunchInstance(interaction, true);
  }
  else if (cmd === 'log') {
    let n = interaction.options.getInteger('count') || 5;
    n = Math.min(Math.max(n,1),lastResults.length);
    const logs = lastResults.slice(0,n).map(r =>
      `[${r.time}] #${r.attempt} | ${r.status?'✅':'❌'} | ${r.uptime}${r.error ? '\n' + r.error : ''}`).join('\n\n');
    const embed = new EmbedBuilder()
      .setTitle(`최근 ${n}회 시도 로그`)
      .setDescription(logs);
    interaction.reply({ embeds: [embed] });
  }
  else if (cmd === 'stop') {
    autoLaunch = false;
    interaction.reply('자동 인스턴스 생성이 일시 중지되었습니다.');
    writeLog('Auto launch stopped');
  }
  else if (cmd === 'start') {
    if (!autoLaunch) {
      autoLaunch = true;
      interaction.reply('자동 인스턴스 생성이 재시작되었습니다.');
      writeLog('Auto launch started');
    } else {
      interaction.reply('이미 자동 생성이 활성화되어 있습니다.');
    }
  }
  else if (cmd === 'help') {
    interaction.reply(`사용 가능한 명령어:
/status - 봇 상태 요약
/launch - 인스턴스 즉시 생성
/log [count] - 최근 N회 로그
/stop - 자동 생성 중지
/start - 자동 생성 시작
/help - 명령어 안내`);
  }
});

client.once('ready', () => {
  console.log('🤖 Discord 봇 준비됨');
  writeLog('Discord bot ready');
  setInterval(() => {
    if (autoLaunch) tryLaunchInstance();
  }, 60 * 60 * 1000);
  tryLaunchInstance();
});

client.login(TOKEN);
EON

log success "Discord 봇 파일(oci-discord-bot.js) 생성 완료!"

# 7. .env 파일 Node.js용 복사
cp .env .env.node

pm2 delete oci-discord-bot >/dev/null 2>&1 || true
log info "pm2로 봇 실행 중..."
pm2 start oci-discord-bot.js --name oci-discord-bot

log success "모든 자동화 완료! pm2로 봇이 실행중입니다."
pm2 status
