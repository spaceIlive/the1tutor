import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_state.dart';
import '../models/user.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appState = Provider.of<AppState>(context, listen: false);
      
      try {
        print('=== 화면에서 로그인 시작 ===');
        await authProvider.login(
          _emailController.text, 
          _passwordController.text,
          onLoginSuccess: (userId, email, userType) async {
            print('로그인 성공 콜백 호출됨');
            // AppState 초기화 (토큰 포함)
            await appState.initializeUserFromAuth(
              userId: userId,
              email: email,
              userType: userType,
              token: authProvider.token!,
            );
          },
        );
        
        print('로그인 완료 후 사용자 타입 확인: ${authProvider.userType}');
        
        // 로그인 성공 후 유저 타입 확인
        if (authProvider.userType == UserType.STUDENT) {
          print('학생 계정 확인됨, /student로 이동 시도');
          // 약간의 지연 후 화면 전환
          Future.delayed(Duration(milliseconds: 100), () {
            context.go('/student');
          });
          print('/student로 이동 명령 실행됨 (지연 후)');
        } else {
          print('학생 계정이 아님: ${authProvider.userType}');
          // 학생이 아닌 경우 에러 메시지
          _showErrorDialog('학생 계정이 아닙니다. 학생 계정으로 로그인해주세요.');
        }
      } catch (e) {
        print('로그인 에러 발생: $e');
        _showErrorDialog('로그인에 실패했습니다: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 뒤로가기 버튼
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () => context.go('/'),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 로고
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        '학생 로그인',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '과외를 시작해보세요!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // 로그인 폼
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // 이메일 입력
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: '이메일 (아이디)',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
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

                              // 비밀번호 입력
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: '비밀번호',
                                  prefixIcon: Icon(Icons.lock_outline),
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
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
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
                              const SizedBox(height: 24),

                              // 로그인 버튼
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4facfe),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: authProvider.isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          '로그인',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 비밀번호 찾기
                              TextButton(
                                onPressed: () {
                                  // 비밀번호 찾기 기능
                                },
                                child: Text(
                                  '비밀번호를 잊으셨나요?',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 회원가입 링크
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '계정이 없으신가요? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/student-signup'),
                              child: Text(
                                '회원가입',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 테스트 계정 안내
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '테스트 계정: student@test.com / password123',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 