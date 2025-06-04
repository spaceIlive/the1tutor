# 멀티스테이지 빌드를 위한 Dockerfile (Maven 기반)
FROM maven:3.9.5-eclipse-temurin-17 as builder

# 작업 디렉토리 설정
WORKDIR /app

# pom.xml과 Maven Wrapper 복사
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# 의존성 캐싱을 위해 pom.xml만 먼저 복사하고 의존성 다운로드
RUN mvn dependency:go-offline -B

# 소스코드 복사
COPY src src

# 애플리케이션 빌드 (테스트 스킵)
RUN mvn clean package -DskipTests

# 런타임 스테이지
FROM eclipse-temurin:17-jre

# 시간대 설정
RUN apt-get update && apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 작업 디렉토리 설정
WORKDIR /app

# 빌드된 JAR 파일 복사
COPY --from=builder /app/target/*.jar app.jar

# 애플리케이션 포트 노출
EXPOSE 8080

# 애플리케이션 실행 (AWS 프로파일 사용)
ENTRYPOINT ["java", "-Dspring.profiles.active=aws", "-jar", "app.jar"] 