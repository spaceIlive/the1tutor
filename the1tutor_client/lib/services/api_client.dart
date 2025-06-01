import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else {
      // Android 에뮬레이터
      return 'http://10.0.2.2:8080/api';
    }
  }

  // ============ AUTH API ============
  
  static Future<LoginResponse> login(LoginRequest request) async {
    print('=== ApiClient.login 시작 ===');
    print('요청 데이터: ${request.toJson()}');
    
    final url = Uri.parse('$baseUrl/auth/login');
    print('요청 URL: $url');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    ).timeout(Duration(seconds: 10));

    print('=== 로그인 응답 ===');
    print('응답 상태 코드: ${response.statusCode}');
    print('응답 헤더: ${response.headers}');
    print('응답 바디 (원본): ${response.body}');
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('파싱된 JSON 데이터: $jsonData');
      print('approvalStatus 필드: ${jsonData['approvalStatus']}');
      
      final loginResponse = LoginResponse.fromJson(jsonData);
      print('LoginResponse 객체: ${loginResponse.toString()}');
      print('=== ApiClient.login 완료 ===');
      
      return loginResponse;
    } else {
      print('로그인 실패: ${response.statusCode} - ${response.body}');
      throw Exception('로그인 실패: ${response.body}');
    }
  }

  static Future<LoginResponse> registerStudent(StudentRegisterRequest request) async {
    final url = Uri.parse('$baseUrl/auth/register/student');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        throw Exception('학생 회원가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<LoginResponse> registerTutor(TutorRegisterRequest request) async {
    final url = Uri.parse('$baseUrl/auth/register/tutor');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        throw Exception('튜터 회원가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<UserProfile> getUserProfile(int userId, String token) async {
    print('=== 사용자 프로필 조회 API 호출 ===');
    print('사용자 ID: $userId');
    
    final url = Uri.parse('$baseUrl/auth/profile/$userId');
    print('요청 URL: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('파싱된 프로필 데이터: $data');
        return UserProfile.fromJson(data);
      } else {
        throw Exception('프로필 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('프로필 조회 예외: $e');
      rethrow;
    }
  }
  
  // ============ STUDENT API ============
  
  static Future<MatchRequestResponse> createMatchRequest(
    int studentId, 
    MatchRequestCreateRequest request, 
    String token
  ) async {
    print('=== ApiClient.createMatchRequest 시작 ===');
    print('학생 ID: $studentId');
    print('토큰: ${token.substring(0, 20)}...');
    
    final url = Uri.parse('$baseUrl/student/$studentId/match-request');
    print('요청 URL: $url');
    
    final requestBody = jsonEncode(request.toJson());
    print('=== 요청 데이터 ===');
    print('JSON 변환 전 request: ${request.toString()}');
    print('JSON 변환 후 body: $requestBody');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    print('=== 요청 헤더 ===');
    headers.forEach((key, value) {
      if (key == 'Authorization') {
        print('$key: Bearer ${token.substring(0, 20)}...');
      } else {
        print('$key: $value');
      }
    });
    
    try {
      print('=== HTTP POST 요청 시작 ===');
      final response = await http.post(
        url,
        headers: headers,
        body: requestBody,
      ).timeout(Duration(seconds: 10));
      
      print('=== HTTP 응답 받음 ===');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 헤더: ${response.headers}');
      print('응답 본문 길이: ${response.body.length}');
      print('응답 본문: ${response.body}');
      
      if (response.statusCode == 200) {
        print('=== JSON 파싱 시작 ===');
        final data = jsonDecode(response.body);
        print('파싱된 매칭 요청 응답: $data');
        
        print('=== MatchRequestResponse 객체 생성 ===');
        final matchResponse = MatchRequestResponse.fromJson(data);
        print('생성된 객체 ID: ${matchResponse.id}');
        print('생성된 객체 과목: ${matchResponse.subject}');
        
        return matchResponse;
      } else {
        print('=== HTTP 에러 응답 ===');
        print('에러 상태 코드: ${response.statusCode}');
        print('에러 응답 본문: ${response.body}');
        throw Exception('매칭 요청 생성 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('=== ApiClient.createMatchRequest 예외 ===');
      print('예외 타입: ${e.runtimeType}');
      print('예외 메시지: $e');
      rethrow;
    }
  }
  
  static Future<List<StudentSubjectResponse>> getStudentMatchedSubjects(int studentId, String token) async {
    print('=== 학생 매칭된 과목 조회 API 호출 ===');
    print('학생 ID: $studentId');
    
    final url = Uri.parse('$baseUrl/student/$studentId/matched-subjects');
    print('요청 URL: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('파싱된 매칭 과목 데이터: $data');
        return data.map((json) => StudentSubjectResponse.fromJson(json)).toList();
      } else {
        throw Exception('매칭된 과목 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('매칭된 과목 조회 예외: $e');
      rethrow;
    }
  }
  
  static Future<List<MatchRequestResponse>> getStudentPendingRequests(int studentId, String token) async {
    print('=== 학생 대기 중인 요청 조회 API 호출 ===');
    print('학생 ID: $studentId');
    
    final url = Uri.parse('$baseUrl/student/$studentId/pending-requests');
    print('요청 URL: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('파싱된 대기 요청 데이터: $data');
        return data.map((json) => MatchRequestResponse.fromJson(json)).toList();
      } else {
        throw Exception('대기 중인 요청 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('대기 중인 요청 조회 예외: $e');
      rethrow;
    }
  }
  
  // ============ TUTOR API ============
  
  static Future<List<TutorViewResponse>> getTutorMatchRequests(int tutorId, String token) async {
    print('=== 튜터 매칭 요청 조회 API 호출 ===');
    print('튜터 ID: $tutorId');
    
    final url = Uri.parse('$baseUrl/tutor/$tutorId/match-requests');
    print('요청 URL: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('파싱된 튜터 요청 데이터: $data');
        return data.map((json) => TutorViewResponse.fromJson(json)).toList();
      } else {
        throw Exception('튜터 매칭 요청 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('튜터 매칭 요청 조회 예외: $e');
      rethrow;
    }
  }
  
  static Future<TutoringSessionResponse> acceptMatchRequest(int tutorId, int requestId, String token) async {
    print('=== 매칭 요청 수락 API 호출 ===');
    print('튜터 ID: $tutorId, 요청 ID: $requestId');
    
    final url = Uri.parse('$baseUrl/tutor/$tutorId/match-requests/$requestId/accept');
    print('요청 URL: $url');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('파싱된 세션 응답: $data');
        return TutoringSessionResponse.fromJson(data);
      } else {
        throw Exception('매칭 요청 수락 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('매칭 요청 수락 예외: $e');
      rethrow;
    }
  }
  
  static Future<void> rejectMatchRequest(int tutorId, int requestId, String token) async {
    print('=== 매칭 요청 거절 API 호출 ===');
    print('튜터 ID: $tutorId, 요청 ID: $requestId');
    
    final url = Uri.parse('$baseUrl/tutor/$tutorId/match-requests/$requestId/reject');
    print('요청 URL: $url');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      print('응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('매칭 요청 거절 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('매칭 요청 거절 예외: $e');
      rethrow;
    }
  }
  
  static Future<List<TutoringSessionResponse>> getTutorSessions(int tutorId, String token) async {
    print('=== 튜터 세션 조회 API 호출 ===');
    print('튜터 ID: $tutorId');
    
    final url = Uri.parse('$baseUrl/tutor/$tutorId/sessions');
    print('요청 URL: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('파싱된 튜터 세션 데이터: $data');
        return data.map((json) => TutoringSessionResponse.fromJson(json)).toList();
      } else {
        throw Exception('튜터 세션 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('튜터 세션 조회 예외: $e');
      rethrow;
    }
  }
  
  // ============ HEALTH CHECK ============
  
  static Future<Map<String, String>> healthCheck() async {
    final url = Uri.parse('${baseUrl.replaceAll('/api', '')}/health');
    
    try {
      final response = await http.get(url).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.cast<String, String>();
      } else {
        throw Exception('Health check 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============ 시간표 관련 메서드들 ============
  
  // 공통 헤더 생성 메서드
  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      // TODO: 실제 토큰 처리 필요 시 추가
    };
  }
  
  // 튜터 시간표 조회
  Future<Map<String, dynamic>> getTutorSchedule(int tutorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/tutor/$tutorId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('시간표를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 튜터 가능한 시간 업데이트
  Future<void> updateTutorAvailableSlots(int tutorId, Set<String> availableSlots) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule/tutor/$tutorId/available'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'availableSlots': availableSlots.toList(),
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? '시간표 저장에 실패했습니다');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 학생 시간표 조회
  Future<Map<String, dynamic>> getStudentSchedule(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/student/$studentId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('시간표를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

// ============ API 응답 모델 클래스들 ============

class UserProfile {
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String school;
  final String userType;
  final DateTime createdAt;
  final String? grade;
  final String? major;
  final List<String>? specializedSubjects;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.school,
    required this.userType,
    required this.createdAt,
    this.grade,
    this.major,
    this.specializedSubjects,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      school: json['school'],
      userType: json['userType'],
      createdAt: DateTime.parse(json['createdAt']),
      grade: json['grade'],
      major: json['major'],
      specializedSubjects: json['specializedSubjects']?.cast<String>(),
    );
  }
}

class MatchRequestCreateRequest {
  final String subject;
  final String learningGoal;
  final String tutorStyle;
  final String classMethod;
  final List<String> selectedTimeSlots;
  final String motivation;

  MatchRequestCreateRequest({
    required this.subject,
    required this.learningGoal,
    required this.tutorStyle,
    required this.classMethod,
    required this.selectedTimeSlots,
    required this.motivation,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'learningGoal': learningGoal,
      'tutorStyle': tutorStyle,
      'classMethod': classMethod,
      'selectedTimeSlots': selectedTimeSlots,
      'motivation': motivation,
    };
  }
}

class MatchRequestResponse {
  final int id;
  final String studentName;
  final String subject;
  final String learningGoal;
  final String tutorStyle;
  final List<String> selectedTimeSlots;
  final String motivation;
  final String status;
  final DateTime createdAt;

  MatchRequestResponse({
    required this.id,
    required this.studentName,
    required this.subject,
    required this.learningGoal,
    required this.tutorStyle,
    required this.selectedTimeSlots,
    required this.motivation,
    required this.status,
    required this.createdAt,
  });

  factory MatchRequestResponse.fromJson(Map<String, dynamic> json) {
    return MatchRequestResponse(
      id: json['id'],
      studentName: json['studentName'],
      subject: json['subject'],
      learningGoal: json['learningGoal'],
      tutorStyle: json['tutorStyle'],
      selectedTimeSlots: List<String>.from(json['selectedTimeSlots'] ?? []),
      motivation: json['motivation'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class StudentSubjectResponse {
  final int id;
  final String name;
  final String tutor;
  final DateTime nextClass;

  StudentSubjectResponse({
    required this.id,
    required this.name,
    required this.tutor,
    required this.nextClass,
  });

  factory StudentSubjectResponse.fromJson(Map<String, dynamic> json) {
    return StudentSubjectResponse(
      id: json['id'],
      name: json['name'],
      tutor: json['tutor'],
      nextClass: DateTime.parse(json['nextClass']),
    );
  }
  
  String get subject => name;
  String get tutorName => tutor;
  DateTime get nextSessionTime => nextClass;
}

class TutorViewResponse {
  final int id;
  final String studentName;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;

  TutorViewResponse({
    required this.id,
    required this.studentName,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory TutorViewResponse.fromJson(Map<String, dynamic> json) {
    return TutorViewResponse(
      id: json['id'],
      studentName: json['studentName'],
      subject: json['subject'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TutoringSessionResponse {
  final int id;
  final String subject;
  final String student;
  final String tutor;
  final DateTime nextClass;
  final String status;

  TutoringSessionResponse({
    required this.id,
    required this.subject,
    required this.student,
    required this.tutor,
    required this.nextClass,
    required this.status,
  });

  factory TutoringSessionResponse.fromJson(Map<String, dynamic> json) {
    return TutoringSessionResponse(
      id: json['id'],
      subject: json['subject'],
      student: json['student'],
      tutor: json['tutor'],
      nextClass: DateTime.parse(json['nextClass']),
      status: json['status'],
    );
  }
} 