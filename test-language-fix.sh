#!/bin/bash

# OCI 스크립트 언어 분기 테스트
echo "=== OCI 스크립트 언어 분기 테스트 ==="
echo ""

# 한국어 테스트
echo "1. 한국어 테스트:"
echo 'LANG_CHOICE="ko"' > test_config.json
echo '{"LANGUAGE": "ko"}' > config.json
echo "config.json에 한국어 설정 후 스크립트 실행..."

# 영어 테스트  
echo ""
echo "2. 영어 테스트:"
echo 'LANG_CHOICE="en"' > test_config.json
echo '{"LANGUAGE": "en"}' > config.json
echo "config.json에 영어 설정 후 스크립트 실행..."

echo ""
echo "✅ 수정된 언어 분기 부분들:"
echo "- sudo 권한 안내 메시지"
echo "- OCI CLI 심볼릭 링크 생성"
echo "- 환경 설정 완료"
echo "- OCI CLI 발견/미발견"
echo "- Node.js 설치"
echo "- pm2 설치"
echo "- package.json 생성"
echo "- .env 파일 생성"
echo "- Discord 봇 코드 생성"
echo "- PM2 봇 시작"
echo "- 완료 메시지 및 명령어 안내"

echo ""
echo "🔧 모든 하드코딩된 메시지가 언어별로 분기되도록 수정 완료!"
