class ApiConfig {
  static String get baseUrl {
    // 웹 환경에서는 실제 서버 주소 사용
    if (const String.fromEnvironment('API_URL', defaultValue: '').isNotEmpty) {
      return const String.fromEnvironment('API_URL');
    }
    
    // 개발 환경에서는 로컬 서버 주소 사용
    if (const bool.fromEnvironment('DEBUG', defaultValue: true)) {
      return 'http://localhost:8080/api';
    }
    
    // 프로덕션 환경에서는 AWS 서버 주소 사용
    // TODO: EC2 퍼블릭 DNS 또는 도메인으로 교체하세요
    return 'http://43.201.71.52:8080/api';
  }
} 