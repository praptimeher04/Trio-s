import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const CampusFinancialApp());
}

class CampusFinancialApp extends StatelessWidget {
  const CampusFinancialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Financial Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RegisterScreen(),
    );
  }
}
