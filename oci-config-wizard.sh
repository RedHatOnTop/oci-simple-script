#!/bin/bash

set -e

CONFIG_FILE="config.json"

# config.json이 이미 존재하면 기존 값을 불러옴
if [ -f "$CONFIG_FILE" ]; then
  EXISTING=$(cat "$CONFIG_FILE")
else
  EXISTING="{}"
fi

# jq helper: 기존 값 있으면, 그 값 반환
get_current() {
  local key="$1"
  echo "$EXISTING" | jq -r --arg k "$key" '.[$k] // empty'
}

# 값을 입력받고 즉시 저장
prompt_and_save() {
  local key="$1"
  local msg="$2"
  local current
  current=$(get_current "$key")
  local prompt="$msg"
  if [ -n "$current" ]; then
    prompt="$msg [현재값: $current] (빈칸 입력시 현재값 유지): "
  else
    prompt="$msg: "
  fi
  read -p "$prompt" val
  if [ -z "$val" ] && [ -n "$current" ]; then
    val="$current"
  fi
  # jq로 해당 key만 갱신
  EXISTING=$(echo "$EXISTING" | jq --arg k "$key" --arg v "$val" '.[$k]=$v')
  echo "$EXISTING" > "$CONFIG_FILE"
}

### 입력받는 부분
echo "==== OCI/Discord Bot 통합 config.json 실시간 생성 마법사 ===="

prompt_and_save TENANCY_OCID "OCI Tenancy OCID"
prompt_and_save USER_OCID "OCI User OCID"
prompt_and_save COMPARTMENT_OCID "OCI Compartment OCID"
prompt_and_save FINGERPRINT "OCI API Key Fingerprint"
prompt_and_save REGION "OCI Region (예: ap-seoul-1)"
prompt_and_save KEY_FILE "API Private Key 파일 경로 (예: /home/ubuntu/.oci/oci_api_key.pem)"

prompt_and_save DISCORD_TOKEN "Discord Bot Token"
prompt_and_save DISCORD_CLIENT_ID "Discord Client ID"
prompt_and_save DISCORD_GUILD_ID "Discord Guild ID"
prompt_and_save DISCORD_CHANNEL_ID "Discord Channel ID"

# Shape 선택
echo ""
echo "==== OCI Shape 선택 ===="
COMPARTMENT_OCID=$(get_current COMPARTMENT_OCID)
SHAPES_RAW=$(oci compute shape list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null | jq -c '.data')
shapes=($(echo "$SHAPES_RAW" | jq -r '.[] | .shape'))
mems=($(echo "$SHAPES_RAW" | jq -r '.[] | .memory_in_gbs'))
ocpus=($(echo "$SHAPES_RAW" | jq -r '.[] | .ocpus'))

current_shape=$(get_current SHAPE)
for i in "${!shapes[@]}"; do
  echo "$i) ${shapes[$i]} (OCPUs: ${ocpus[$i]}, Memory: ${mems[$i]}GB)"
done
if [ -n "$current_shape" ]; then
  echo "현재 Shape: $current_shape"
fi
read -p "Shape 번호 선택 (빈칸 입력시 현재값 유지): " shape_idx
if [ -z "$shape_idx" ] && [ -n "$current_shape" ]; then
  SHAPE="$current_shape"
else
  SHAPE="${shapes[$shape_idx]}"
fi
EXISTING=$(echo "$EXISTING" | jq --arg SHAPE "$SHAPE" '.SHAPE=$SHAPE')
echo "$EXISTING" > "$CONFIG_FILE"

# Subnet 선택
echo ""
echo "==== OCI Subnet 선택 ===="
SUBNETS_RAW=$(oci network subnet list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null | jq -c '.data')
subnet_names=($(echo "$SUBNETS_RAW" | jq -r '.[] | .display_name'))
subnet_ids=($(echo "$SUBNETS_RAW" | jq -r '.[] | .id'))

current_subnet=$(get_current SUBNET_ID)
for i in "${!subnet_ids[@]}"; do
  echo "$i) ${subnet_names[$i]} (${subnet_ids[$i]})"
done
if [ -n "$current_subnet" ]; then
  echo "현재 Subnet: $current_subnet"
fi
read -p "Subnet 번호 선택 (빈칸 입력시 현재값 유지): " subnet_idx
if [ -z "$subnet_idx" ] && [ -n "$current_subnet" ]; then
  SUBNET_ID="$current_subnet"
else
  SUBNET_ID="${subnet_ids[$subnet_idx]}"
fi
EXISTING=$(echo "$EXISTING" | jq --arg SUBNET_ID "$SUBNET_ID" '.SUBNET_ID=$SUBNET_ID')
echo "$EXISTING" > "$CONFIG_FILE"

# Image 선택
echo ""
echo "==== OCI Image 선택 ===="
IMAGES_RAW=$(oci compute image list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null | jq -c '.data')
image_names=($(echo "$IMAGES_RAW" | jq -r '.[] | .display_name'))
image_ids=($(echo "$IMAGES_RAW" | jq -r '.[] | .id'))

current_image=$(get_current IMAGE_ID)
for i in "${!image_ids[@]}"; do
  echo "$i) ${image_names[$i]} (${image_ids[$i]})"
done
if [ -n "$current_image" ]; then
  echo "현재 Image: $current_image"
fi
read -p "Image 번호 선택 (빈칸 입력시 현재값 유지): " image_idx
if [ -z "$image_idx" ] && [ -n "$current_image" ]; then
  IMAGE_ID="$current_image"
else
  IMAGE_ID="${image_ids[$image_idx]}"
fi
EXISTING=$(echo "$EXISTING" | jq --arg IMAGE_ID "$IMAGE_ID" '.IMAGE_ID=$IMAGE_ID')
echo "$EXISTING" > "$CONFIG_FILE"

# shapeConfig 옵션
echo ""
echo "==== shapeConfig 옵션 설정 ===="
current_ocpus=$(echo "$EXISTING" | jq -r '.shapeConfig.ocpus // empty')
current_mem=$(echo "$EXISTING" | jq -r '.shapeConfig.memoryInGBs // empty')
SHAPE_IDX=""
for i in "${!shapes[@]}"; do
  if [[ "${shapes[$i]}" == "$SHAPE" ]]; then
    SHAPE_IDX="$i"
    break
  fi
done
default_ocpus="${ocpus[$SHAPE_IDX]}"
default_mem="${mems[$SHAPE_IDX]}"

read -p "OCPUs (기본값 ${default_ocpus}, 현재값: ${current_ocpus}, 빈칸 유지): " USER_OCPUS
if [ -z "$USER_OCPUS" ] && [ -n "$current_ocpus" ]; then
  OCPUS="$current_ocpus"
elif [ -z "$USER_OCPUS" ]; then
  OCPUS="$default_ocpus"
else
  OCPUS="$USER_OCPUS"
fi

read -p "MemoryInGBs (기본값 ${default_mem}, 현재값: ${current_mem}, 빈칸 유지): " USER_MEM
if [ -z "$USER_MEM" ] && [ -n "$current_mem" ]; then
  MEMORY_IN_GBS="$current_mem"
elif [ -z "$USER_MEM" ]; then
  MEMORY_IN_GBS="$default_mem"
else
  MEMORY_IN_GBS="$USER_MEM"
fi

EXISTING=$(echo "$EXISTING" | \
  jq --argjson ocpus "$OCPUS" --argjson mem "$MEMORY_IN_GBS" \
     '.shapeConfig.ocpus=$ocpus | .shapeConfig.memoryInGBs=$mem')
echo "$EXISTING" > "$CONFIG_FILE"

# availabilityConfig 및 instanceOptions 고정값 (변경 원하면 추가)
EXISTING=$(echo "$EXISTING" \
  | jq '.availabilityConfig.isLiveMigrationPreferred=true | .availabilityConfig.recoveryAction="RESTORE_INSTANCE"')
EXISTING=$(echo "$EXISTING" \
  | jq '.instanceOptions.areLegacyImdsEndpointsDisabled=false')
echo "$EXISTING" > "$CONFIG_FILE"

echo ""
echo "✅ config.json 파일이 실시간으로 갱신되었습니다."
