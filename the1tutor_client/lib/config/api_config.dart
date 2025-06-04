import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // 환경 변수가 설정된 경우 우선 사용
    if (const String.fromEnvironment('API_URL', defaultValue: '').isNotEmpty) {
      return const String.fromEnvironment('API_URL');
    }
    
    // 웹 환경에서는 항상 EC2 서버 HTTPS 주소 사용
    if (kIsWeb) {
      // 임시 테스트: localhost 사용
      return 'http://localhost:8080/api';
      // return 'https://15.164.222.124/api';
    }
    
    // 모바일 개발 환경에서만 로컬 서버 주소 사용
    if (kDebugMode) {
      return 'http://localhost:8080/api';
    }
    
    // 프로덕션 환경에서는 AWS 서버 주소 사용
    return 'http://15.164.222.124:8080/api';
  }
} 