class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String token;
  final int userId;
  final String userType;
  final String message;
  final String? approvalStatus;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.userType,
    required this.message,
    this.approvalStatus,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      userId: json['userId'],
      userType: json['userType'],
      message: json['message'],
      approvalStatus: json['approvalStatus'],
    );
  }

  @override
  String toString() {
    return 'LoginResponse(userId: $userId, userType: $userType, message: $message, approvalStatus: $approvalStatus, token: ${token.substring(0, 20)}...)';
  }
}

class StudentRegisterRequest {
  final String email;
  final String password;
  final String name;
  final String phone;
  final DateTime birthdate;
  final String school;
  final String grade;

  StudentRegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.birthdate,
    required this.school,
    required this.grade,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'birthdate': birthdate.toIso8601String().split('T')[0],
      'school': school,
      'grade': grade,
    };
  }
}

class TutorRegisterRequest {
  final String email;
  final String password;
  final String name;
  final String phone;
  final DateTime birthdate;
  final String school;
  final String major;
  final List<String> specializedSubjects;

  TutorRegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.birthdate,
    required this.school,
    required this.major,
    required this.specializedSubjects,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'birthdate': birthdate.toIso8601String().split('T')[0],
      'school': school,
      'major': major,
      'specializedSubjects': specializedSubjects,
    };
  }
} 