#!/bin/bash

# Oracle Cloud 배포 스크립트
echo "🌟 Oracle Cloud 배포를 시작합니다..."

# 1. 시스템 업데이트
echo "📦 시스템 업데이트 중..."
sudo dnf update -y

# 2. Docker 설치
echo "🐳 Docker 설치 중..."
sudo dnf install -y dnf-utils zip unzip
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf remove -y runc
sudo dnf install -y docker-ce --nobest
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# 3. Docker Compose 설치
echo "🔧 Docker Compose 설치 중..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. 방화벽 설정
echo "🔥 방화벽 설정 중..."
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload

# 5. 애플리케이션 배포
echo "🚀 애플리케이션 배포 중..."
docker-compose up -d

echo "✅ Oracle Cloud 배포 완료!"
echo "🌐 서비스 접속: http://[인스턴스-공인IP]:8080" 