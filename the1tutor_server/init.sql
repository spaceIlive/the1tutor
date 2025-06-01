-- MySQL 데이터베이스 초기화 스크립트
CREATE DATABASE IF NOT EXISTS the1tutor_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE the1tutor_db;

-- 사용자 생성 (Docker Compose에서 이미 생성되지만 안전장치)
-- CREATE USER IF NOT EXISTS 'the1tutor'@'%' IDENTIFIED BY 'tutorpassword';
-- GRANT ALL PRIVILEGES ON the1tutor_db.* TO 'the1tutor'@'%';
-- FLUSH PRIVILEGES;

-- 테이블은 Spring Boot JPA가 자동으로 생성할 예정이므로 
-- 별도의 테이블 생성 구문은 작성하지 않음

-- 초기 데이터가 필요한 경우 여기에 INSERT 구문 추가
-- 예시:
-- INSERT INTO subjects (name, description) VALUES 
-- ('Mathematics HL', 'IB Mathematics Higher Level'),
-- ('English A HL', 'IB English A Higher Level'),
-- ('Physics HL', 'IB Physics Higher Level'); 