import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import '../models/auth_models.dart';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  State<StudentSignupScreen> createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _schoolController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  DateTime? _selectedDate;
  String? _selectedGrade;

  final List<String> _ibGrades = [
    'Year 7',
    'Year 8', 
    'Year 9',
    'Year 10',
    'Year 11',
    'Year 12',
    'Year 13',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 6570)), // 18년 전
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      print('=== 학생 회원가입 시작 ===');
      print('이름: ${_nameController.text}');
      print('이메일: ${_emailController.text}');
      print('학년: $_selectedGrade');
      print('학교: ${_schoolController.text}');
      print('생년월일: ${_birthdateController.text}');
      print('핸드폰: ${_phoneController.text}');

      try {
        // AuthProvider를 통한 실제 API 호출
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final request = StudentRegisterRequest(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
          school: _schoolController.text,
          birthdate: DateTime.parse(_birthdateController.text),
          grade: _selectedGrade!,
        );
        
        print('=== API 호출 시작 ===');
        await authProvider.registerStudent(request);
        
        print('=== 회원가입 성공 ===');
        
        setState(() {
          _isLoading = false;
        });

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('학생 회원가입이 완료되었습니다!\n로그인해주세요.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // 로그인 페이지로 이동
        context.go('/student-login');
        
      } catch (e) {
        print('=== 회원가입 실패 ===');
        print('에러: $e');
        
        setState(() {
          _isLoading = false;
        });

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 실패: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4facfe),
              Color(0xFF00f2fe),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/student-login'),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '학생 회원가입',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 56), // 아이콘 버튼 공간 확보
                  ],
                ),
              ),

              // 폼 영역
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // 이름
                          _buildTextField(
                            controller: _nameController,
                            label: '이름',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이름을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 생년월일
                          _buildTextField(
                            controller: _birthdateController,
                            label: '생년월일',
                            icon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: _selectDate,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '생년월일을 선택해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 학년 선택
                          DropdownButtonFormField<String>(
                            value: _selectedGrade,
                            decoration: InputDecoration(
                              labelText: '학년',
                              prefixIcon: Icon(Icons.school_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: _ibGrades.map((String grade) {
                              return DropdownMenuItem<String>(
                                value: grade,
                                child: Text(grade),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGrade = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '학년을 선택해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 핸드폰번호
                          _buildTextField(
                            controller: _phoneController,
                            label: '핸드폰번호',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '핸드폰번호를 입력해주세요';
                              }
                              if (value.length < 10) {
                                return '올바른 핸드폰번호를 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 이메일
                          _buildTextField(
                            controller: _emailController,
                            label: '이메일 (아이디)',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이메일을 입력해주세요';
                              }
                              if (!value.contains('@')) {
                                return '올바른 이메일 형식을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 비밀번호
                          _buildTextField(
                            controller: _passwordController,
                            label: '비밀번호',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호를 입력해주세요';
                              }
                              if (value.length < 6) {
                                return '비밀번호는 6자 이상이어야 합니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 비밀번호 확인
                          _buildTextField(
                            controller: _passwordConfirmController,
                            label: '비밀번호 확인',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePasswordConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePasswordConfirm 
                                  ? Icons.visibility_off 
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscurePasswordConfirm = !_obscurePasswordConfirm;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호 확인을 입력해주세요';
                              }
                              if (value != _passwordController.text) {
                                return '비밀번호가 일치하지 않습니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 다니는 학교
                          _buildTextField(
                            controller: _schoolController,
                            label: '다니는 학교',
                            icon: Icons.school_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '다니는 학교를 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // 회원가입 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4facfe),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      '회원가입',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 로그인 링크
                          Center(
                            child: GestureDetector(
                              onTap: () => context.go('/student-login'),
                              child: Text(
                                '이미 계정이 있으신가요? 로그인',
                                style: TextStyle(
                                  color: Color(0xFF4facfe),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
} 