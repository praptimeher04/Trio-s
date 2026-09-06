// Campus Financial Ecosystem Entry Point
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reseller_dashboard_screen.dart';
import 'screens/super_admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final bool isRegistered = prefs.getBool('is_registered') ?? false;
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final String userEmail = prefs.getString('user_email') ?? '';
  final String userName = prefs.getString('user_name') ?? 'Hitija Mhatre';
  final String userRole = prefs.getString('user_role') ?? 'Student';
  final int userType = prefs.getInt('user_type') ?? 0;

  String initialRoute = '/login';

  if (isLoggedIn) {
    if (userType == 2) {
      initialRoute = '/super-admin-dashboard';
    } else if (userType == 1) {
      initialRoute = '/admin-dashboard';
    } else {
      initialRoute = '/student-dashboard';
    }
  } else if (isRegistered) {
    initialRoute = '/login';
  } else {
    initialRoute = '/register';
  }

  runApp(CampusFinancialApp(
    initialRoute: initialRoute,
    userName: userName,
    userEmail: userEmail,
    userRole: userRole,
  ));
}

class CampusFinancialApp extends StatelessWidget {
  final String initialRoute;
  final String userName;
  final String userEmail;
  final String userRole;

  const CampusFinancialApp({
    super.key,
    required this.initialRoute,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Pay & Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(initialEmail: userEmail),
        '/register': (context) => const RegisterScreen(),
        '/student-dashboard': (context) => DashboardScreen(
              userName: userName,
              userEmail: userEmail,
              userRole: userRole,
            ),
        '/admin-dashboard': (context) => ResellerDashboardScreen(
              resellerName: userName,
              resellerEmail: userEmail,
            ),
        '/super-admin-dashboard': (context) => SuperAdminDashboardScreen(
              adminName: userName,
              adminEmail: userEmail,
            ),
      },
    );
  }
}
