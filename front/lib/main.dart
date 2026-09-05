import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reseller_dashboard_screen.dart';
import 'services/session_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusFinancialApp());
}

class CampusFinancialApp extends StatelessWidget {
  const CampusFinancialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Pay & Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
    );
  }
}
