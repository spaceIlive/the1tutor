# 🚀 The1Tutor 배포 가이드

## 📋 목차
1. [로컬 Docker 배포](#로컬-docker-배포)
2. [AWS EC2 배포](#aws-ec2-배포)
3. [AWS Elastic Beanstalk 배포](#aws-elastic-beanstalk-배포)
4. [AWS RDS 사용](#aws-rds-사용)
5. [도메인 연결하기](#도메인-연결하기)
6. [문제 해결](#문제-해결)

---

## 🐳 로컬 Docker 배포

### 1. 사전 준비사항
- Docker Desktop 설치
- Docker Compose 설치

### 2. 빌드 및 실행
```bash
# 프로젝트 디렉토리로 이동
cd the1tutor_server

# Docker Compose로 전체 스택 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f app
```

### 3. 접속 확인 (로컬 테스트용)
- **🌐 웹 애플리케이션**: http://localhost:8080
  - 브라우저에서 접속하여 API 테스트
  - 예: http://localhost:8080/api/health (헬스체크)
- **🗄️ 데이터베이스** (개발자용): localhost:3306
  - 사용자: `the1tutor`
  - 비밀번호: `tutorpassword`
  - MySQL Workbench나 DBeaver로 접속 가능

**⚠️ 주의**: `localhost`는 본인 컴퓨터에서만 접속 가능합니다!

---

## ☁️ AWS EC2 배포

### 1. EC2 인스턴스 생성
```bash
# Amazon Linux 2 추천
# t3.medium 이상 권장 (메모리 4GB+)
# 보안 그룹: 포트 8080, 3306, 22 열기
```

### 2. EC2에 Docker 설치
```bash
# Amazon Linux 2의 경우
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 3. 프로젝트 배포
```bash
# 프로젝트 파일 업로드 (scp 또는 git clone)
git clone <your-repository>
cd the1tutor/the1tutor_server

# 배포 스크립트 실행 권한 부여
chmod +x deploy-aws.sh

# 배포 실행
./deploy-aws.sh
```

### 4. 접속 확인 (실제 서비스)
배포 완료 후 다음 방법으로 접속할 수 있습니다:

#### A. 공인 IP 직접 접속 (임시용)
```bash
# EC2 인스턴스의 공인 IP 확인
curl http://checkip.amazonaws.com

# 웹 애플리케이션 접속
http://[공인IP]:8080
```

#### B. 도메인 연결 (권장)
```bash
# 예시: yourdomain.com:8080
# 또는 서브도메인: api.yourdomain.com
```

**⚠️ 중요**: 
- EC2 재시작 시 공인 IP가 변경됩니다
- 실제 서비스는 도메인 연결이 필수입니다!

---

## 🎯 AWS Elastic Beanstalk 배포

### 1. JAR 파일 생성
```bash
# Maven으로 JAR 파일 빌드
mvn clean package -DskipTests

# 생성된 JAR 파일 확인
ls target/*.jar
```

### 2. Elastic Beanstalk 환경 생성
1. AWS 콘솔에서 Elastic Beanstalk 선택
2. 새 애플리케이션 생성
3. 플랫폼: Java 17
4. JAR 파일 업로드

### 3. 환경 변수 설정
```
SPRING_PROFILES_ACTIVE=aws
DB_URL=jdbc:mysql://your-rds-endpoint:3306/the1tutor_db
DB_USERNAME=your-username
DB_PASSWORD=your-password
```

### 4. 접속 확인 (Elastic Beanstalk)
```bash
# Beanstalk이 자동으로 제공하는 URL
http://your-app-name.region.elasticbeanstalk.com
```

---

## 🗄️ AWS RDS 사용

### 1. RDS MySQL 인스턴스 생성
```sql
-- 엔진: MySQL 8.0
-- 인스턴스 클래스: db.t3.micro (개발용) / db.t3.small (운영용)
-- 데이터베이스 이름: the1tutor_db
-- 마스터 사용자: admin
-- 마스터 암호: [안전한 비밀번호]
```

### 2. 보안 그룹 설정
- EC2 보안 그룹에서 RDS 포트 3306 접근 허용
- RDS 보안 그룹에서 EC2로부터의 접근 허용

### 3. 프로덕션 배포
```bash
# 환경변수 설정
export DB_URL="jdbc:mysql://your-rds-endpoint:3306/the1tutor_db?useSSL=true&serverTimezone=Asia/Seoul"
export DB_USERNAME="admin"
export DB_PASSWORD="your-secure-password"

# 프로덕션용 Docker Compose 사용
docker-compose -f docker-compose.prod.yml up -d
```

---

## 🌐 도메인 연결하기

### 도메인이 필요한 이유
1. **공인 IP는 변경됨**: EC2 재시작 시 IP 변경
2. **사용자 편의성**: 기억하기 쉬운 주소
3. **SSL 인증서**: HTTPS 적용 가능
4. **전문성**: 실제 서비스처럼 보임

### 1. 무료 도메인 옵션
```bash
# 무료 도메인 서비스들
- Freenom: .tk, .ml, .ga, .cf 도메인
- GitHub Pages: username.github.io
- Netlify: random-name.netlify.app
- Railway: random-name.up.railway.app
```

### 2. 유료 도메인 (권장)
```bash
# 저렴한 도메인 등록업체
- Namecheap: $8-15/년
- GoDaddy: $10-20/년
- AWS Route 53: $12/년 + DNS 쿼리 비용
```

### 3. Route 53으로 도메인 연결
```bash
# 1. Route 53에서 호스트 영역 생성
# 2. A 레코드 추가: yourdomain.com → EC2 공인 IP
# 3. CNAME 레코드 추가: www.yourdomain.com → yourdomain.com
```

### 4. SSL 인증서 적용 (HTTPS)
```bash
# AWS Certificate Manager (ACM) 사용
# 1. ACM에서 SSL 인증서 요청
# 2. Application Load Balancer 설정
# 3. 포트 443(HTTPS) 리스너 추가
```

---

## 🔍 문제 해결

### 자주 발생하는 문제들

#### 1. 메모리 부족 오류
```bash
# JVM 힙 메모리 조정
export JAVA_OPTS="-Xms256m -Xmx512m"
```

#### 2. 데이터베이스 연결 실패
```bash
# 연결 테스트
docker exec -it the1tutor-mysql mysql -u the1tutor -p
```

#### 3. 포트 충돌
```bash
# 포트 사용 확인
sudo netstat -tlnp | grep :8080
```

#### 4. 외부 접속 불가
```bash
# 방화벽 확인
sudo ufw status

# AWS 보안 그룹 확인
# - 인바운드 규칙에 포트 8080 추가
# - 소스: 0.0.0.0/0 (모든 IP 허용)
```

#### 5. 로그 확인
```bash
# 애플리케이션 로그
docker-compose logs app

# MySQL 로그
docker-compose logs mysql
```

---

## 📊 모니터링

### 1. Spring Boot Actuator 엔드포인트
- Health Check: `/actuator/health`
- Metrics: `/actuator/metrics`
- Info: `/actuator/info`

### 2. 성능 모니터링
```bash
# CPU/메모리 사용량 확인
docker stats

# 컨테이너 상태 확인
docker-compose ps
```

---

## 🔧 추가 설정

### 1. 로그 로테이션
```yaml
# docker-compose.yml에 추가
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 2. 백업 스크립트
```bash
# MySQL 데이터 백업
docker exec the1tutor-mysql mysqldump -u the1tutor -p the1tutor_db > backup.sql
```

---

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. Docker 로그: `docker-compose logs`
2. 애플리케이션 상태: `curl http://[IP]:8080/actuator/health`
3. 데이터베이스 연결: MySQL 클라이언트로 접속 테스트
4. 방화벽/보안 그룹 설정 확인 