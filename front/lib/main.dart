import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
<<<<<<< HEAD
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reseller_dashboard_screen.dart';
import 'services/session_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusFinancialApp());
=======
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
>>>>>>> 573e9e486d9083ebe9d747949ef918ce377d0c1d
}

class CampusFinancialApp extends StatelessWidget {
  final Widget initialScreen;

  const CampusFinancialApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Pay & Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
<<<<<<< HEAD
      home: FutureBuilder<Map<String, dynamic>>(
        future: SessionService.getSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF8FAFC),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF059669),
                ),
              ),
            );
          }

          final session = snapshot.data;
          final bool isLoggedIn = session?['isLoggedIn'] == true;
          final int userType = session?['userType'] ?? 0;
          final String userName = session?['userName'] ?? 'Hitija Mhatre';
          final String userEmail = session?['userEmail'] ?? 'student@campus.edu';
          final String userRole = session?['userRole'] ?? 'Student';
          final String mobileNumber = session?['mobileNumber'] ?? '+91 98765 43210';

          if (isLoggedIn) {
            if (userType == 1) {
              return ResellerDashboardScreen(
                resellerName: userName,
                resellerEmail: userEmail,
                resellerMobile: mobileNumber,
              );
            } else {
              return DashboardScreen(
                userName: userName,
                userEmail: userEmail,
                userRole: userRole,
              );
            }
          }

          return const LoginScreen();
        },
      ),
=======
      home: initialScreen,
>>>>>>> 573e9e486d9083ebe9d747949ef918ce377d0c1d
    );
  }
}
