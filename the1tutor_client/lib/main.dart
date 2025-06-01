import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/student_login_screen.dart';
import 'screens/student_signup_screen.dart';
import 'screens/student_screen.dart';
import 'screens/tutor_login_screen.dart';
import 'screens/tutor_signup_screen.dart';
import 'screens/tutor_registration_screen.dart';
import 'screens/tutor_home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/matching_screen.dart';
import 'providers/app_state.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/student-login',
        builder: (context, state) => const StudentLoginScreen(),
      ),
      GoRoute(
        path: '/student-signup',
        builder: (context, state) => const StudentSignupScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentScreen(),
      ),
      GoRoute(
        path: '/tutor-login',
        builder: (context, state) => const TutorLoginScreen(),
      ),
      GoRoute(
        path: '/tutor-signup',
        builder: (context, state) => const TutorSignupScreen(),
      ),
      GoRoute(
        path: '/tutor-registration',
        builder: (context, state) => const TutorRegistrationScreen(),
      ),
      GoRoute(
        path: '/tutor',
        builder: (context, state) => const TutorHomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/matching',
        builder: (context, state) => const MatchingScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The1Tutor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
