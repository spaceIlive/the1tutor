#!/bin/bash

echo "🔒 SSL 인증서 설정 시작..."

# 이메일 주소 설정 (실제 이메일로 변경하세요)
EMAIL="gyun6266@gmail.com"

# Let's Encrypt SSL 인증서 설정
sudo certbot --nginx -d the1tutor.kro.kr -d www.the1tutor.kro.kr --email $EMAIL --agree-tos --non-interactive

# Nginx 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl restart nginx

echo ""
echo "✅ SSL 설정 완료!"
echo "🌐 HTTPS: https://the1tutor.kro.kr"
echo "🔄 자동 갱신 설정: sudo crontab -e 추가"
echo "0 12 * * * /usr/bin/certbot renew --quiet" 