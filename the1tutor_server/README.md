 # The1Tutor Server

IB 과외 매칭 플랫폼의 백엔드 서버입니다.

## 기능

- 학생/튜터 회원가입 및 로그인
- 자동 매칭 알고리즘
- 매칭 요청 관리
- 과외 세션 관리
- 튜터 승인 시스템
- 시간표 관리

## 기술 스택

- Java 17
- Spring Boot 3.5.0
- Spring Data JPA
- H2 Database (개발용)
- Maven

## 실행 방법

1. 프로젝트 클론
```bash
git clone <repository-url>
cd the1tutor_server
```

2. 의존성 설치 및 컴파일
```bash
mvn clean compile
```

3. 서버 실행
```bash
mvn spring-boot:run
```

4. 서버 접속
- API 서버: https://the1tutor.kro.kr
- H2 콘솔: https://the1tutor.kro.kr/h2-console

## 테스트 계정

### 학생 계정
- 이메일: student@test.com
- 비밀번호: password123

### 튜터 계정
- 이메일: tutor@test.com
- 비밀번호: password123

## API 엔드포인트

### 인증 API

#### 학생 회원가입
```
POST /api/auth/register/student
Content-Type: application/json

{
  "name": "김학생",
  "email": "student@example.com",
  "password": "password123",
  "birthdate": "2005-03-15",
  "phone": "010-1234-5678",
  "school": "국제학교",
  "grade": "Year 11"
}
```

#### 튜터 회원가입
```
POST /api/auth/register/tutor
Content-Type: application/json

{
  "name": "박튜터",
  "email": "tutor@example.com",
  "password": "password123",
  "birthdate": "1995-08-20",
  "phone": "010-9876-5432",
  "school": "서울대학교",
  "major": "수학교육"
}
```

#### 로그인
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "student@test.com",
  "password": "password123",
  "userType": "STUDENT"
}
```

### 학생 API

#### 매칭 요청 생성
```
POST /api/student/{studentId}/match-request
Content-Type: application/json

{
  "subject": "Mathematics HL",
  "learningGoal": "미적분 개념 이해하고 싶습니다",
  "tutorStyle": "친근함",
  "classMethod": "줌 온라인",
  "selectedTimeSlots": ["월-14:00", "수-15:00"],
  "motivation": "수학 성적을 향상시키고 싶습니다"
}
```

#### 매칭된 과목 조회
```
GET /api/student/{studentId}/matched-subjects
```

#### 대기 중인 매칭 요청 조회
```
GET /api/student/{studentId}/pending-requests
```

### 튜터 API

#### 매칭 요청 조회
```
GET /api/tutor/{tutorId}/match-requests
```

#### 매칭 요청 수락
```
POST /api/tutor/{tutorId}/match-requests/{requestId}/accept
```

#### 매칭 요청 거절
```
POST /api/tutor/{tutorId}/match-requests/{requestId}/reject
```

#### 진행 중인 세션 조회
```
GET /api/tutor/{tutorId}/sessions
```

### 스케줄 API

#### 튜터 시간표 조회
```
GET /api/schedule/tutor/{tutorId}
```

#### 튜터 가능한 시간 업데이트
```
POST /api/schedule/tutor/{tutorId}/available
Content-Type: application/json

{
  "availableSlots": ["월-14:00", "월-15:00", "화-10:00", "수-16:00"]
}
```

#### 학생 시간표 조회
```
GET /api/schedule/student/{studentId}
```

## 매칭 알고리즘

1. **과목 필터링**: 요청된 과목을 가르칠 수 있는 승인된 튜터들을 조회
2. **시간대 매칭**: 학생이 선택한 시간대와 튜터의 가능한 시간대를 비교
3. **점수 계산**: 
   - 과목 전문성: +10점
   - 시간대 겹침: 매칭되는 시간대당 +5점
   - 기본 점수: +3점
4. **최적 튜터 선택**: 가장 높은 점수를 받은 튜터를 자동 할당

## 데이터베이스 스키마

### 주요 테이블
- `users`: 기본 사용자 정보
- `students`: 학생 추가 정보
- `tutors`: 튜터 추가 정보 및 승인 상태
- `tutor_schedules`: 튜터 시간표
- `match_requests`: 매칭 요청
- `tutoring_sessions`: 확정된 과외 세션

## 개발 환경 설정

### H2 데이터베이스 접속
1. 브라우저에서 https://the1tutor.kro.kr/h2-console 접속
2. 연결 정보:
   - JDBC URL: jdbc:h2:mem:testdb
   - User Name: sa
   - Password: (빈 값)

### 로그 확인
- 애플리케이션 로그: DEBUG 레벨로 설정
- SQL 쿼리: 콘솔에 출력됨

## 향후 개선사항

1. JWT 토큰 기반 인증 구현
2. 비밀번호 암호화 (BCrypt)
3. MySQL/PostgreSQL 연동
4. 실시간 채팅 기능 (WebSocket)
5. 파일 업로드 기능
6. 이메일 알림 시스템
7. 결제 시스템 연동