#!/bin/bash

# The1Tutor H2 데이터베이스 백업 스크립트
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
DB_DIR="/var/lib/the1tutor/db"
DB_NAME="the1tutor"

echo "🗄️ The1Tutor H2 데이터베이스 백업을 시작합니다..."

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# H2 데이터베이스 파일 백업
echo "📊 H2 데이터베이스 파일 백업 중..."
if [ -f "$DB_DIR/${DB_NAME}.mv.db" ]; then
    cp $DB_DIR/${DB_NAME}.mv.db $BACKUP_DIR/${DB_NAME}_backup_${DATE}.mv.db
fi

if [ -f "$DB_DIR/${DB_NAME}.trace.db" ]; then
    cp $DB_DIR/${DB_NAME}.trace.db $BACKUP_DIR/${DB_NAME}_backup_${DATE}.trace.db
fi

# 백업 파일들을 하나의 tar.gz로 압축
echo "📦 백업 파일 압축 중..."
cd $BACKUP_DIR
tar -czf ${DB_NAME}_backup_${DATE}.tar.gz ${DB_NAME}_backup_${DATE}.*
rm -f ${DB_NAME}_backup_${DATE}.mv.db ${DB_NAME}_backup_${DATE}.trace.db

# 7일 이상 된 백업 파일 삭제
echo "🧹 오래된 백업 파일 정리 중..."
find $BACKUP_DIR -name "${DB_NAME}_backup_*.tar.gz" -mtime +7 -delete

echo "✅ 백업 완료: $BACKUP_DIR/${DB_NAME}_backup_${DATE}.tar.gz"

# 백업 상태 확인
if [ -f "$BACKUP_DIR/${DB_NAME}_backup_${DATE}.tar.gz" ]; then
    echo "✅ 백업 성공"
    ls -lh $BACKUP_DIR/${DB_NAME}_backup_${DATE}.tar.gz
else
    echo "❌ 백업 실패"
    exit 1
fi 