class User {
  final int id;
  final String email;
  final String name;
  final String phone;
  final DateTime birthdate;
  final String school;
  final UserType userType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.birthdate,
    required this.school,
    required this.userType,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      birthdate: DateTime.parse(json['birthdate']),
      school: json['school'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['userType'],
      ),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'birthdate': birthdate.toIso8601String().split('T')[0],
      'school': school,
      'userType': userType.toString().split('.').last.toUpperCase(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

enum UserType { 
  STUDENT, 
  TUTOR 
} 