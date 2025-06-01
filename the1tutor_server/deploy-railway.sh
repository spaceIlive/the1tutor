#!/bin/bash

# Railway 배포 스크립트
echo "🚂 Railway 배포를 시작합니다..."

# 1. Railway CLI 설치 확인
if ! command -v railway &> /dev/null; then
    echo "📦 Railway CLI 설치 중..."
    npm install -g @railway/cli
fi

# 2. 로그인 (브라우저에서 인증)
echo "🔐 Railway 로그인..."
railway login

# 3. 프로젝트 초기화
echo "🎯 Railway 프로젝트 초기화..."
railway init

# 4. 환경변수 설정
echo "⚙️ 환경변수 설정..."
railway variables set SPRING_PROFILES_ACTIVE=aws
railway variables set DB_URL='${{MYSQLDATABASE_URL}}'

# 5. MySQL 데이터베이스 추가
echo "🗄️ MySQL 데이터베이스 추가..."
railway add mysql

# 6. 애플리케이션 배포
echo "🚀 애플리케이션 배포..."
railway up

echo "✅ Railway 배포 완료!"
echo "🌐 서비스 URL을 확인하세요: railway domain" 