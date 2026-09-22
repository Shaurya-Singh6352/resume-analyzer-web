import 'package:flutter/material.dart';
import 'package:resume_analyzer_web/pages/login_page.dart';
import 'package:resume_analyzer_web/pages/upload_page.dart';
import 'package:resume_analyzer_web/services/auth_service.dart';
import 'package:resume_analyzer_web/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.restoreSession();
  runApp(const ResumeAnalyzerApp());
}

class ResumeAnalyzerApp extends StatelessWidget {
  const ResumeAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume Analyzer',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: AuthService.instance.isLoggedIn ? const UploadPage() : const LoginPage(),
    );
  }
}