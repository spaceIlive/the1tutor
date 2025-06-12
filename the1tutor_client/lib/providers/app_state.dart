import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';

class AppState extends ChangeNotifier {
  String _userType = '';
  List<ChatMessage> _chatMessages = [];
  UserProfile? _userProfile;
  List<MatchRequest> _matchRequests = [];
  List<TutoringSession> _tutoringSessions = [];
  List<Subject> _matchedSubjects = [];
  List<PendingSubject> _pendingSubjects = [];
  
  // API 호출을 위한 토큰 저장
  String? _authToken;
  int? _currentUserId;
  
  // 회원가입 임시 저장소
  Map<String, dynamic> _signupInfo = {};
  
  // 튜터 승인 상태 관리
  Set<String> _approvedTutors = {'admin@gmail.com'}; // admin은 기본 승인
  
  // 튜터 시간표 관리
  Set<String> _tutorAvailableSlots = {};
  Set<String> _tutorFixedSlots = {};

  String get userType => _userType;
  List<ChatMessage> get chatMessages => _chatMessages;
  UserProfile? get userProfile => _userProfile;
  List<MatchRequest> get matchRequests => _matchRequests;
  List<TutoringSession> get tutoringSessions => _tutoringSessions;
  List<Subject> get matchedSubjects => _matchedSubjects;
  List<PendingSubject> get pendingSubjects => _pendingSubjects;
  Set<String> get tutorAvailableSlots => _tutorAvailableSlots;
  Set<String> get tutorFixedSlots => _tutorFixedSlots;

  void setUserType(String type) {
    _userType = type;
    notifyListeners();
  }

  // AuthProvider에서 로그인 정보를 받아서 사용자 프로필 설정
  Future<void> initializeUserFromAuth({
    required int userId,
    required String email,
    required UserType userType,
    required String token,
  }) async {
    print('=== initializeUserFromAuth 호출됨 ===');
    print('사용자 ID: $userId');
    print('이메일: $email');
    print('사용자 타입: $userType');
    
    // 인증 정보 저장
    _authToken = token;
    _currentUserId = userId;
    _userType = userType == UserType.STUDENT ? 'student' : 'tutor';
    
    try {
      // 실제 서버에서 사용자 프로필 가져오기
      print('서버에서 사용자 프로필 조회 중...');
      final apiProfile = await ApiClient.getUserProfile(userId, token);
      
      // API 프로필을 AppState 프로필로 변환
      _userProfile = UserProfile(
        userId: userId,
        name: apiProfile.name,
        email: apiProfile.email,
        avatar: 'https://via.placeholder.com/150',
        grade: apiProfile.grade,
        school: apiProfile.school,
        subjects: apiProfile.specializedSubjects,
      );
      
      print('사용자 프로필 조회 완료: ${_userProfile?.name}');
      
      // 튜터인 경우 실제 데이터 로드
      if (_userType == 'tutor') {
        await _loadTutorData();
      }
      
      // 학생인 경우 매칭된 과목 조회
      if (_userType == 'student') {
        await _loadMatchedSubjects();
        await refreshPendingRequests(); // 대기중인 요청도 로드
      }
      
      // 더미 데이터 초기화 (API 데이터가 없는 경우 보완용)
      _initializeAdditionalDummyData();
      
    } catch (e) {
      print('API 호출 실패, 기본 프로필 사용: $e');
      // API 호출 실패 시 기본 프로필 생성
      _userProfile = UserProfile(
        userId: userId,
        name: _getDefaultNameFromEmail(email),
        email: email,
        avatar: 'https://via.placeholder.com/150',
        grade: userType == UserType.STUDENT ? 'DP 1' : null,
        school: '테스트 학교',
        subjects: userType == UserType.TUTOR ? ['수학', '물리', '영어'] : null,
      );
      
      // 사용자 타입에 따라 더미 데이터 초기화
      initializeDummyData();
    }
    
    notifyListeners();
  }
  
  Future<void> _loadMatchedSubjects() async {
    if (_currentUserId == null || _authToken == null) return;
    
    try {
      print('매칭된 과목 조회 중...');
      final matchedSubjectsFromApi = await ApiClient.getStudentMatchedSubjects(_currentUserId!, _authToken!);
      
      // API 응답을 AppState Subject 모델로 변환
      _matchedSubjects = matchedSubjectsFromApi.map((apiSubject) => Subject(
        id: apiSubject.id.toString(),
        name: apiSubject.subject,
        tutor: apiSubject.tutorName,
        nextClass: apiSubject.nextSessionTime,
      )).toList();
      
      print('매칭된 과목 ${_matchedSubjects.length}개 로드됨');
    } catch (e) {
      print('매칭된 과목 조회 실패: $e');
      // API 실패 시 빈 리스트로 설정 (더미 데이터 제거)
      _matchedSubjects = [];
    }
  }
  
  Future<void> _loadTutorData() async {
    if (_currentUserId == null || _authToken == null) return;
    
    try {
      print('튜터 데이터 로드 중...');
      
      // 매칭 요청 조회
      await _loadTutorMatchRequests();
      
      // 과외 세션 조회
      await _loadTutorSessions();
      
      print('튜터 데이터 로드 완료');
    } catch (e) {
      print('튜터 데이터 로드 실패: $e');
      // API 실패 시 더미 데이터 사용
      _loadDummyTutorData();
    }
  }
  
  Future<void> _loadTutorMatchRequests() async {
    if (_currentUserId == null || _authToken == null) return;
    
    try {
      print('튜터 매칭 요청 조회 중...');
      final matchRequestsFromApi = await ApiClient.getTutorMatchRequests(_currentUserId!, _authToken!);
      
      // API 응답을 AppState MatchRequest 모델로 변환
      _matchRequests = matchRequestsFromApi.map((apiRequest) => MatchRequest(
        id: apiRequest.id.toString(),
        studentName: apiRequest.studentName,
        subject: apiRequest.subject,
        message: apiRequest.message,
      )).toList();
      
      print('매칭 요청 ${_matchRequests.length}개 로드됨');
    } catch (e) {
      print('매칭 요청 조회 실패: $e');
      // 실패 시 빈 리스트로 설정
      _matchRequests = [];
    }
  }
  
  Future<void> _loadTutorSessions() async {
    if (_currentUserId == null || _authToken == null) return;
    
    try {
      print('튜터 세션 조회 중...');
      final sessionsFromApi = await ApiClient.getTutorSessions(_currentUserId!, _authToken!);
      
      // API 응답을 AppState TutoringSession 모델로 변환
      _tutoringSessions = sessionsFromApi.map((apiSession) => TutoringSession(
        id: apiSession.id.toString(),
        subject: apiSession.subject,
        student: apiSession.student,
        time: apiSession.nextClass,
      )).toList();
      
      print('과외 세션 ${_tutoringSessions.length}개 로드됨');
    } catch (e) {
      print('과외 세션 조회 실패: $e');
      // 실패 시 빈 리스트로 설정
      _tutoringSessions = [];
    }
  }
  
  void _loadDummyTutorData() {
    print('더미 튜터 데이터 로드');
    _matchRequests = [
      MatchRequest(id: '1', studentName: '김학생', subject: 'Mathematics HL', message: '수학 HL 과외 요청드립니다.'),
      MatchRequest(id: '2', studentName: '박학생', subject: 'English A HL', message: '영어 A HL 도움 부탁드려요.'),
    ];

    _tutoringSessions = [
      TutoringSession(id: '1', subject: 'Mathematics HL', student: '김학생', time: DateTime.now().add(Duration(hours: 2))),
      TutoringSession(id: '2', subject: 'English A HL', student: '박학생', time: DateTime.now().add(Duration(days: 1, hours: 3))),
    ];
  }

  String _getDefaultNameFromEmail(String email) {
    if (email == 'student@test.com') {
      return '테스트 학생';
    } else if (email == 'tutor@test.com') {
      return '테스트 튜터';
    } else {
      return email.split('@')[0];
    }
  }

  void setSignupInfo({
    required String name,
    required String email,
    required String grade,
    required String school,
    required String birthdate,
    required String phone,
  }) {
    _signupInfo = {
      'name': name,
      'email': email,
      'grade': grade,
      'school': school,
      'birthdate': birthdate,
      'phone': phone,
    };
  }

  void setUserProfileFromLogin(String email) {
    print('=== setUserProfileFromLogin 호출됨 (레거시) ===');
    print('입력된 이메일: $email');
    print('저장된 회원가입 정보: $_signupInfo');
    
    if (_signupInfo.isNotEmpty && _signupInfo['email'] == email) {
      print('회원가입 정보 매칭됨 - 실제 이름 사용: ${_signupInfo['name']}');
      _userProfile = UserProfile(
        userId: _currentUserId!,
        name: _signupInfo['name'],
        email: _signupInfo['email'],
        avatar: 'https://via.placeholder.com/150',
        grade: _signupInfo['grade'],
        school: _signupInfo['school'],
        subjects: _userType == 'tutor' ? ['Mathematics HL', 'Physics HL', 'English A HL'] : null,
      );
    } else {
      print('회원가입 정보 없음 - 기본 프로필 사용');
      // 기본 프로필 (회원가입 정보가 없는 경우)
      _userProfile = UserProfile(
        userId: _currentUserId!,
        name: _getDefaultNameFromEmail(email),
        email: email,
        avatar: 'https://via.placeholder.com/150',
        grade: _userType == 'student' ? 'Year 11 (DP 1)' : null,
        school: '미설정',
        subjects: _userType == 'tutor' ? ['Mathematics HL', 'Physics HL', 'English A HL'] : null,
      );
    }
    print('최종 설정된 프로필: ${_userProfile?.name}');
    notifyListeners();
  }

  void setUserProfile({
    required String name,
    required String email,
    String? grade,
    String? school,
    List<String>? subjects,
  }) {
    _userProfile = UserProfile(
      userId: _currentUserId!,
      name: name,
      email: email,
      avatar: 'https://via.placeholder.com/150',
      grade: grade,
      school: school,
      subjects: subjects,
    );
    notifyListeners();
  }

  void addMatchedSubject(Subject subject) {
    _matchedSubjects.add(subject);
    notifyListeners();
  }

  void removeMatchedSubject(String subjectId) {
    _matchedSubjects.removeWhere((subject) => subject.id == subjectId);
    notifyListeners();
  }

  bool get hasMatchedSubjects => _matchedSubjects.isNotEmpty;
  bool get hasPendingSubjects => _pendingSubjects.isNotEmpty;

  void addPendingSubject(PendingSubject subject) {
    _pendingSubjects.add(subject);
    notifyListeners();
  }

  void removePendingSubject(String subjectId) {
    _pendingSubjects.removeWhere((subject) => subject.id == subjectId);
    notifyListeners();
  }

  void addChatMessage(ChatMessage message) {
    _chatMessages.add(message);
    notifyListeners();
  }

  void _initializeAdditionalDummyData() {
    print('=== _initializeAdditionalDummyData 호출됨 ===');
    print('사용자 타입: $_userType');
    print('사용자 이메일: ${_userProfile?.email}');
    
    // test 계정일 때만 더미 매칭 데이터 추가
    if (_userProfile?.email == 'student@test.com' && _userType == 'student') {
      print('테스트 학생 계정 - 더미 매칭 데이터 추가 (수학만)');
      _matchedSubjects = [
        Subject(
          id: '1',
          name: 'Mathematics HL',
          tutor: '김수학 선생님',
          nextClass: DateTime.now().add(Duration(hours: 2)),
        ),
      ];
      
      // 더미 채팅 메시지 (과외 시작 상황)
      _chatMessages = [
        ChatMessage(
          id: '1', 
          sender: 'system', 
          content: '과외방에 오신 것을 환영합니다! 👋', 
          timestamp: DateTime.now().subtract(Duration(hours: 24)), 
          isSystem: true
        ),
        ChatMessage(
          id: '2',
          sender: '김수학 선생님',
          content: '안녕하세요! 수학 과외를 담당하게 된 김수학입니다. 앞으로 잘 부탁드려요 😊',
          timestamp: DateTime.now().subtract(Duration(hours: 23)),
        ),
        ChatMessage(
          id: '3',
          sender: '테스트 학생',
          content: '안녕하세요 선생님! 수학이 많이 어려워서 과외를 신청했어요. 열심히 하겠습니다!',
          timestamp: DateTime.now().subtract(Duration(hours: 22)),
        ),
        ChatMessage(
          id: '4',
          sender: '김수학 선생님',
          content: '좋습니다! 우선 어떤 단원이 가장 어려우신지 알려주세요. 그리고 목표 점수가 있으신가요?',
          timestamp: DateTime.now().subtract(Duration(hours: 21)),
        ),
        ChatMessage(
          id: '5',
          sender: '테스트 학생',
          content: '미적분이 정말 어려워요... 그리고 최종 시험에서 6점 이상 받는 게 목표입니다!',
          timestamp: DateTime.now().subtract(Duration(hours: 20)),
        ),
        ChatMessage(
          id: '6',
          sender: '김수학 선생님',
          content: '미적분은 차근차근 개념부터 잡아가면 충분히 가능해요! 6점도 달성할 수 있습니다. 다음 수업 때 기초부터 차근차근 시작해보죠 📚',
          timestamp: DateTime.now().subtract(Duration(hours: 19)),
        ),
        ChatMessage(
          id: '7',
          sender: '테스트 학생',
          content: '감사합니다! 정말 기대돼요 ✨',
          timestamp: DateTime.now().subtract(Duration(hours: 18)),
        ),
      ];
    } else {
      // 일반 더미 채팅 메시지
      _chatMessages = [
        ChatMessage(id: '1', sender: 'system', content: '과외방에 오신 것을 환영합니다!', timestamp: DateTime.now().subtract(Duration(hours: 1)), isSystem: true),
      ];
    }
    
    // 튜터 시간표 초기화 (튜터인 경우에만)
    if (_userType == 'tutor') {
      initializeTutorSchedule();
    }
  }

  void initializeDummyData() {
    print('=== initializeDummyData 호출됨 (레거시) ===');
    _initializeAdditionalDummyData();
    notifyListeners();
  }

  // 튜터 승인 상태 확인
  bool isTutorApproved(String email) {
    return _approvedTutors.contains(email);
  }
  
  // 튜터 승인 (관리자용)
  void approveTutor(String email) {
    _approvedTutors.add(email);
    notifyListeners();
  }
  
  // 튜터 시간표 저장
  void updateTutorSchedule(Set<String> availableSlots) {
    _tutorAvailableSlots = Set.from(availableSlots);
    notifyListeners();
  }
  
  // 튜터 시간표 초기화 (더미 데이터)
  void initializeTutorSchedule() {
    _tutorAvailableSlots = {
      '월-14:00', '월-14:30', '월-15:00', '월-15:30',
      '화-10:00', '화-10:30', '화-11:00', '화-11:30',
      '수-16:00', '수-16:30', '수-17:00', '수-17:30',
      '목-14:00', '목-14:30', '목-15:00', '목-15:30',
      '금-10:00', '금-10:30', '금-11:00', '금-11:30',
    };
    
    _tutorFixedSlots = {
      '화-10:00', '화-10:30',
      '목-14:00', '목-14:30',
    };
  }

  // 매칭 요청 생성
  Future<void> createMatchRequest({
    required String subject,
    required String learningGoal,
    required String tutorStyle,
    required String classMethod,
    required List<String> selectedTimeSlots,
    required String motivation,
  }) async {
    if (_currentUserId == null || _authToken == null) {
      print('=== 인증 정보 없음 ===');
      print('User ID: $_currentUserId');
      print('Token: ${_authToken != null ? "존재함" : "없음"}');
      throw Exception('로그인이 필요합니다.');
    }
    
    try {
      print('=== AppState.createMatchRequest 시작 ===');
      print('User ID: $_currentUserId');
      print('요청 데이터 준비 중...');
      print('  - 과목: $subject');
      print('  - 학습 목표: $learningGoal');
      print('  - 튜터 스타일: $tutorStyle');
      print('  - 수업 방식: $classMethod');
      print('  - 선택된 시간대: $selectedTimeSlots');
      print('  - 신청 동기: $motivation');
      
      final request = MatchRequestCreateRequest(
        subject: subject,
        learningGoal: learningGoal,
        tutorStyle: tutorStyle,
        classMethod: classMethod,
        selectedTimeSlots: selectedTimeSlots,
        motivation: motivation,
      );
      
      print('=== ApiClient.createMatchRequest 호출 ===');
      final response = await ApiClient.createMatchRequest(_currentUserId!, request, _authToken!);
      
      print('=== 서버 응답 받음 ===');
      print('응답 ID: ${response.id}');
      print('응답 과목: ${response.subject}');
      print('응답 상태: ${response.status}');
      print('응답 학생명: ${response.studentName}');
      print('응답 생성일: ${response.createdAt}');
      
      // 대기중인 과목으로 추가
      final pendingSubject = PendingSubject(
        id: response.id.toString(),
        name: response.subject,
        learningGoal: response.learningGoal,
        tutorStyle: response.tutorStyle,
        selectedTimeSlots: response.selectedTimeSlots,
        motivation: response.motivation,
        requestDate: response.createdAt,
      );
      
      _pendingSubjects.add(pendingSubject);
      print('=== AppState 업데이트 완료 ===');
      print('대기중인 과목 추가됨: ${response.subject}');
      print('현재 대기중인 과목 수: ${_pendingSubjects.length}');
      notifyListeners();
    } catch (e) {
      print('=== AppState.createMatchRequest 실패 ===');
      print('에러 타입: ${e.runtimeType}');
      print('에러 메시지: $e');
      rethrow;
    }
  }
  
  // 대기중인 요청 새로고침
  Future<void> refreshPendingRequests() async {
    if (_currentUserId == null || _authToken == null) return;
    
    try {
      print('=== 대기중인 요청 새로고침 ===');
      final pendingRequests = await ApiClient.getStudentPendingRequests(_currentUserId!, _authToken!);
      
      _pendingSubjects = pendingRequests.map((request) => PendingSubject(
        id: request.id.toString(),
        name: request.subject,
        learningGoal: request.learningGoal,
        tutorStyle: request.tutorStyle,
        selectedTimeSlots: request.selectedTimeSlots,
        motivation: request.motivation,
        requestDate: request.createdAt,
      )).toList();
      
      print('대기중인 요청 ${_pendingSubjects.length}개 로드됨');
      notifyListeners();
    } catch (e) {
      print('대기중인 요청 새로고침 실패: $e');
    }
  }
  
  // 튜터 데이터 새로고침
  Future<void> refreshTutorData() async {
    if (_userType != 'tutor') return;
    
    try {
      print('=== 튜터 데이터 새로고침 ===');
      await _loadTutorData();
      notifyListeners();
    } catch (e) {
      print('튜터 데이터 새로고침 실패: $e');
    }
  }
  
  // 학생 데이터 새로고침
  Future<void> refreshStudentData() async {
    if (_userType != 'student') return;
    
    try {
      print('=== 학생 데이터 새로고침 ===');
      await _loadMatchedSubjects();
      await refreshPendingRequests();
      notifyListeners();
    } catch (e) {
      print('학생 데이터 새로고침 실패: $e');
    }
  }
  
  // 매칭 요청 수락
  Future<void> acceptMatchRequest(String requestId) async {
    if (_currentUserId == null || _authToken == null) return;
    
    try {
      print('매칭 요청 수락: $requestId');
      final session = await ApiClient.acceptMatchRequest(_currentUserId!, int.parse(requestId), _authToken!);
      
      // 새로운 세션을 목록에 추가
      final newSession = TutoringSession(
        id: session.id.toString(),
        subject: session.subject,
        student: session.student,
        time: session.nextClass,
      );
      _tutoringSessions.add(newSession);
      
      // 매칭 요청에서 제거
      _matchRequests.removeWhere((request) => request.id == requestId);
      
      print('매칭 요청 수락 완료');
      notifyListeners();
    } catch (e) {
      print('매칭 요청 수락 실패: $e');
      rethrow;
    }
  }
  
  // 매칭 요청 거절
  Future<void> rejectMatchRequest(String requestId) async {
    if (_currentUserId == null || _authToken == null) return;
    
    try {
      print('매칭 요청 거절: $requestId');
      await ApiClient.rejectMatchRequest(_currentUserId!, int.parse(requestId), _authToken!);
      
      // 매칭 요청에서 제거
      _matchRequests.removeWhere((request) => request.id == requestId);
      
      print('매칭 요청 거절 완료');
      notifyListeners();
    } catch (e) {
      print('매칭 요청 거절 실패: $e');
      rethrow;
    }
  }
}

class UserProfile {
  final int userId;
  final String name;
  final String email;
  final String avatar;
  final String? grade;
  final String? school;
  final List<String>? subjects;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.avatar,
    this.grade,
    this.school,
    this.subjects,
  });
}

class Subject {
  final String id;
  final String name;
  final String tutor;
  final DateTime nextClass;

  Subject({
    required this.id,
    required this.name,
    required this.tutor,
    required this.nextClass,
  });
}

class ChatMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final bool isSystem;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isSystem = false,
  });
}

class MatchRequest {
  final String id;
  final String studentName;
  final String subject;
  final String message;

  MatchRequest({
    required this.id,
    required this.studentName,
    required this.subject,
    required this.message,
  });
}

class TutoringSession {
  final String id;
  final String subject;
  final String student;
  final DateTime time;

  TutoringSession({
    required this.id,
    required this.subject,
    required this.student,
    required this.time,
  });
}

class PendingSubject {
  final String id;
  final String name;
  final String learningGoal;
  final String tutorStyle;
  final List<String> selectedTimeSlots;
  final String motivation;
  final DateTime requestDate;

  PendingSubject({
    required this.id,
    required this.name,
    required this.learningGoal,
    required this.tutorStyle,
    required this.selectedTimeSlots,
    required this.motivation,
    required this.requestDate,
  });
} 