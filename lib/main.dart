import 'package:flutter/material.dart';
import 'package:resume_analyzer_web/pages/upload_page.dart';
import 'package:resume_analyzer_web/theme.dart';

void main() => runApp(const ResumeAnalyzerApp());

class ResumeAnalyzerApp extends StatelessWidget {
  const ResumeAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume Analyzer',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const UploadPage(),
    );
  }
}