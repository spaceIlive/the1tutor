import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_models.dart';
import '../services/api_client.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  int? _userId;
  UserType? _userType;
  String? _approvalStatus; // 튜터 승인 상태
  bool _isLoggedIn = false;
  bool _isLoading = false;

  String? get token => _token;
  int? get userId => _userId;
  UserType? get userType => _userType;
  String? get approvalStatus => _approvalStatus;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // 튜터 승인 상태 확인 메서드
  bool get isTutorApproved => _userType == UserType.TUTOR && _approvalStatus == 'APPROVED';
  bool get isTutorPending => _userType == UserType.TUTOR && _approvalStatus == 'PENDING';
  bool get isTutorRejected => _userType == UserType.TUTOR && _approvalStatus == 'REJECTED';

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getInt('user_id');
    _approvalStatus = prefs.getString('approval_status');
    final userTypeString = prefs.getString('user_type');
    
    if (userTypeString != null) {
      _userType = UserType.values.firstWhere(
        (e) => e.toString().split('.').last == userTypeString,
      );
    }
    
    _isLoggedIn = _token != null && _userId != null && _userType != null;
    notifyListeners();
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null && _userId != null && _userType != null) {
      await prefs.setString('auth_token', _token!);
      await prefs.setInt('user_id', _userId!);
      await prefs.setString('user_type', _userType!.toString().split('.').last);
      if (_approvalStatus != null) {
        await prefs.setString('approval_status', _approvalStatus!);
      }
    }
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_type');
    await prefs.remove('approval_status');
  }

  Future<bool> login(String email, String password, {Function(int, String, UserType)? onLoginSuccess}) async {
    print('=== 로그인 시작 ===');
    print('Email: $email');
    
    _isLoading = true;
    notifyListeners();

    try {
      // 테스트 계정 확인 및 처리
      if (email == 'student@test.com' || email == 'tutor@test.com') {
        print('=== 테스트 계정 로그인 처리 ===');
        
        // 테스트 계정에 대한 하드코딩된 데이터 설정
        _token = 'test_token_${DateTime.now().millisecondsSinceEpoch}';
        
        if (email == 'student@test.com') {
          _userId = 9999; // 테스트 학생 ID
          _userType = UserType.STUDENT;
          _approvalStatus = null; // 학생은 승인 상태가 없음
          print('테스트 학생 계정으로 로그인');
        } else { // tutor@test.com
          _userId = 8888; // 테스트 튜터 ID
          _userType = UserType.TUTOR;
          _approvalStatus = 'APPROVED'; // 테스트 튜터는 승인된 상태
          print('테스트 튜터 계정으로 로그인');
        }
        
        _isLoggedIn = true;
        
        print('토큰: $_token');
        print('사용자 ID: $_userId');
        print('사용자 타입: $_userType');
        print('승인 상태: $_approvalStatus');
        
        await _saveAuthData();
        print('인증 데이터 저장 완료');
        
        // AppState 초기화 콜백 호출
        if (onLoginSuccess != null) {
          await onLoginSuccess(_userId!, email, _userType!);
        }
        
        _isLoading = false;
        notifyListeners();
        print('=== 테스트 계정 로그인 성공 ===');
        return true;
      }
      
      // 일반 계정의 경우 기존 API 호출 로직 수행
      print('API 호출 준비 중...');
      final loginRequest = LoginRequest(email: email, password: password);
      print('LoginRequest 생성 완료: ${loginRequest.toJson()}');
      
      print('API 호출 시작...');
      final response = await ApiClient.login(loginRequest);
      print('API 응답 받음: ${response.toString()}');
      
      _token = response.token;
      _userId = response.userId;
      _userType = UserType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == response.userType,
      );
      _approvalStatus = response.approvalStatus;
      _isLoggedIn = true;
      
      print('토큰: $_token');
      print('사용자 ID: $_userId');
      print('사용자 타입: $_userType');
      print('승인 상태: $_approvalStatus');
      
      await _saveAuthData();
      print('인증 데이터 저장 완료');
      
      // AppState 초기화 콜백 호출
      if (onLoginSuccess != null) {
        await onLoginSuccess(_userId!, email, _userType!);
      }
      
      _isLoading = false;
      notifyListeners();
      print('=== 로그인 성공 ===');
      return true;
    } catch (e) {
      print('=== 로그인 에러 ===');
      print('에러: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> registerStudent(StudentRegisterRequest request) async {
    print('=== AuthProvider.registerStudent 시작 ===');
    print('요청 데이터: ${request.toJson()}');
    
    _isLoading = true;
    notifyListeners();

    try {
      print('ApiClient.registerStudent 호출...');
      final response = await ApiClient.registerStudent(request);
      print('회원가입 API 응답: $response');
      
      _isLoading = false;
      notifyListeners();
      print('=== 학생 회원가입 성공 ===');
      return true;
    } catch (e) {
      print('=== 학생 회원가입 실패 ===');
      print('에러: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> registerTutor(TutorRegisterRequest request) async {
    print('=== AuthProvider.registerTutor 시작 ===');
    print('요청 데이터: ${request.toJson()}');
    
    _isLoading = true;
    notifyListeners();

    try {
      print('ApiClient.registerTutor 호출...');
      final response = await ApiClient.registerTutor(request);
      print('회원가입 API 응답: $response');
      
      _isLoading = false;
      notifyListeners();
      print('=== 튜터 회원가입 성공 ===');
      return true;
    } catch (e) {
      print('=== 튜터 회원가입 실패 ===');
      print('에러: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userType = null;
    _approvalStatus = null;
    _isLoggedIn = false;
    
    await _clearAuthData();
    notifyListeners();
  }
} 