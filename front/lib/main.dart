import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final bool isRegistered = prefs.getBool('is_registered') ?? false;
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final String userEmail = prefs.getString('user_email') ?? '';
  final String userName = prefs.getString('user_name') ?? 'Hitija Mhatre';
  final String userRole = prefs.getString('user_role') ?? 'Student';

  Widget initialScreen;
  if (isLoggedIn) {
    initialScreen = DashboardScreen(
      userName: userName,
      userEmail: userEmail,
      userRole: userRole,
    );
  } else if (isRegistered) {
    initialScreen = LoginScreen(
      initialEmail: userEmail,
      registeredName: userName,
    );
  } else {
    initialScreen = const RegisterScreen();
  }

  runApp(CampusFinancialApp(initialScreen: initialScreen));
}

class CampusFinancialApp extends StatelessWidget {
  final Widget initialScreen;

  const CampusFinancialApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Financial Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialScreen,
    );
  }
}
