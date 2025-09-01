#!/bin/bash

set -e

CONFIG_FILE="config.json"

echo "==== OCI/Discord Bot 통합 config.json 생성 마법사 ===="

# 1. OCI/Discord 필수 정보 입력 받기
read -p "OCI Tenancy OCID: " TENANCY_OCID
read -p "OCI User OCID: " USER_OCID
read -p "OCI Compartment OCID: " COMPARTMENT_OCID
read -p "OCI API Key Fingerprint: " FINGERPRINT
read -p "OCI Region (예: ap-seoul-1): " REGION
read -p "API Private Key 파일 경로 (예: /home/ubuntu/.oci/oci_api_key.pem): " KEY_FILE

read -p "Discord Bot Token: " DISCORD_TOKEN
read -p "Discord Client ID: " DISCORD_CLIENT_ID
read -p "Discord Guild ID: " DISCORD_GUILD_ID
read -p "Discord Channel ID: " DISCORD_CHANNEL_ID

echo ""
echo "==== OCI Shape 선택 ===="
SHAPES_RAW=$(oci compute shape list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null | jq -c '.data')
shapes=($(echo "$SHAPES_RAW" | jq -r '.[] | .shape'))
mems=($(echo "$SHAPES_RAW" | jq -r '.[] | .memory_in_gbs'))
ocpus=($(echo "$SHAPES_RAW" | jq -r '.[] | .ocpus'))
for i in "${!shapes[@]}"; do
  echo "$i) ${shapes[$i]} (OCPUs: ${ocpus[$i]}, Memory: ${mems[$i]}GB)"
done
while true; do
  read -p "Shape 번호 선택: " shape_idx
  if [[ "$shape_idx" =~ ^[0-9]+$ ]] && [ "$shape_idx" -ge 0 ] && [ "$shape_idx" -lt "${#shapes[@]}" ]; then
    SHAPE="${shapes[$shape_idx]}"
    SHAPE_OCPUS="${ocpus[$shape_idx]}"
    SHAPE_MEM="${mems[$shape_idx]}"
    break
  fi
  echo "올바른 번호를 입력하세요."
done

echo ""
echo "==== OCI Subnet 선택 ===="
SUBNETS_RAW=$(oci network subnet list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null | jq -c '.data')
subnet_names=($(echo "$SUBNETS_RAW" | jq -r '.[] | .display_name'))
subnet_ids=($(echo "$SUBNETS_RAW" | jq -r '.[] | .id'))
for i in "${!subnet_ids[@]}"; do
  echo "$i) ${subnet_names[$i]} (${subnet_ids[$i]})"
done
while true; do
  read -p "Subnet 번호 선택: " subnet_idx
  if [[ "$subnet_idx" =~ ^[0-9]+$ ]] && [ "$subnet_idx" -ge 0 ] && [ "$subnet_idx" -lt "${#subnet_ids[@]}" ]; then
    SUBNET_ID="${subnet_ids[$subnet_idx]}"
    break
  fi
  echo "올바른 번호를 입력하세요."
done

echo ""
echo "==== OCI Image 선택 ===="
IMAGES_RAW=$(oci compute image list --compartment-id "$COMPARTMENT_OCID" 2>/dev/null | jq -c '.data')
image_names=($(echo "$IMAGES_RAW" | jq -r '.[] | .display_name'))
image_ids=($(echo "$IMAGES_RAW" | jq -r '.[] | .id'))
for i in "${!image_ids[@]}"; do
  echo "$i) ${image_names[$i]} (${image_ids[$i]})"
done
while true; do
  read -p "Image 번호 선택: " image_idx
  if [[ "$image_idx" =~ ^[0-9]+$ ]] && [ "$image_idx" -ge 0 ] && [ "$image_idx" -lt "${#image_ids[@]}" ]; then
    IMAGE_ID="${image_ids[$image_idx]}"
    break
  fi
  echo "올바른 번호를 입력하세요."
done

echo ""
echo "==== shapeConfig 옵션 설정 ===="
read -p "OCPUs (기본값 ${SHAPE_OCPUS}): " USER_OCPUS
read -p "MemoryInGBs (기본값 ${SHAPE_MEM}): " USER_MEM
OCPUS="${USER_OCPUS:-$SHAPE_OCPUS}"
MEMORY_IN_GBS="${USER_MEM:-$SHAPE_MEM}"

echo ""
echo "==== config.json 생성 중 ===="

cat > $CONFIG_FILE <<EOF
{
  "TENANCY_OCID": "$TENANCY_OCID",
  "USER_OCID": "$USER_OCID",
  "COMPARTMENT_OCID": "$COMPARTMENT_OCID",
  "FINGERPRINT": "$FINGERPRINT",
  "REGION": "$REGION",
  "KEY_FILE": "$KEY_FILE",
  "DISCORD_TOKEN": "$DISCORD_TOKEN",
  "DISCORD_CLIENT_ID": "$DISCORD_CLIENT_ID",
  "DISCORD_GUILD_ID": "$DISCORD_GUILD_ID",
  "DISCORD_CHANNEL_ID": "$DISCORD_CHANNEL_ID",
  "SHAPE": "$SHAPE",
  "SUBNET_ID": "$SUBNET_ID",
  "IMAGE_ID": "$IMAGE_ID",
  "availabilityConfig": {
    "isLiveMigrationPreferred": true,
    "recoveryAction": "RESTORE_INSTANCE"
  },
  "instanceOptions": {
    "areLegacyImdsEndpointsDisabled": false
  },
  "shapeConfig": {
    "ocpus": $OCPUS,
    "memoryInGBs": $MEMORY_IN_GBS
  }
}
EOF

echo "✅ config.json 파일이 생성되었습니다."
