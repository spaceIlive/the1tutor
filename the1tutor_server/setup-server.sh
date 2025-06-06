#!/bin/bash

echo "🚀 EC2 서버 자동 설정 시작..."

# 시스템 업데이트
echo "📦 시스템 업데이트 중..."
sudo apt update -y

# 필요한 패키지 설치
echo "📦 필요한 패키지 설치 중..."
sudo apt install docker.io docker-compose nginx certbot python3-certbot-nginx -y

# Docker 권한 설정
echo "🐳 Docker 권한 설정 중..."
sudo usermod -aG docker ubuntu

# Nginx 설정 복사
echo "⚙️  Nginx 설정 중..."
sudo cp nginx.conf /etc/nginx/sites-available/default

# Nginx 설정 테스트 및 재시작
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Docker 컨테이너 실행
echo "🐳 Docker 컨테이너 실행 중..."
sudo docker-compose up --build -d

# 상태 확인
echo "📊 서버 상태 확인 중..."
sudo docker ps
echo ""
echo "🔍 서버 응답 테스트..."
sleep 10  # 서버 시작 대기
curl http://localhost:8080/health

echo ""
echo "✅ 서버 설정 완료!"
echo "🌐 HTTP: http://the1tutor.kro.kr"
echo "🔒 SSL 설정: sudo certbot --nginx -d the1tutor.kro.kr -d www.the1tutor.kro.kr"
echo ""
echo "🔧 보안 그룹에서 포트 80, 443을 열어주세요!" 