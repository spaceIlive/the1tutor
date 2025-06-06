#!/bin/bash

# AWS EC2 배포 스크립트
echo "🚀 The1Tutor AWS 배포를 시작합니다..."

# 1. Docker 이미지 빌드
echo "📦 Docker 이미지 빌드 중..."
docker build -t the1tutor-app .

# 2. 기존 컨테이너 정리
echo "🧹 기존 컨테이너 정리 중..."
docker-compose down

# 3. 새 컨테이너 시작
echo "🎯 새 컨테이너 시작 중..."
docker-compose up -d

# 4. 상태 확인
echo "⏳ 컨테이너 상태 확인 중..."
sleep 10
docker-compose ps

# 5. 로그 확인
echo "📋 애플리케이션 로그 확인..."
docker-compose logs app --tail=20

echo "✅ 배포 완료! 서비스가 https://the1tutor.kro.kr 에서 실행 중입니다."
echo "📊 MySQL 데이터베이스는 localhost:3306 에서 접근 가능합니다." 