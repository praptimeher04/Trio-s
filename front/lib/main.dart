// Campus Financial Ecosystem Entry Point
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reseller_dashboard_screen.dart';
import 'screens/super_admin_dashboard_screen.dart';
import 'services/session_service.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusFinancialApp());
}

class CampusFinancialApp extends StatelessWidget {
  const CampusFinancialApp({super.key});

  Future<Map<String, dynamic>> _loadSessionWithDbCheck() async {
    final session = await SessionService.getSession();
    if (session['isLoggedIn'] == true && session['userId'] != null) {
      try {
        final int userId = session['userId'] is int
            ? session['userId']
            : (int.tryParse(session['userId'].toString()) ?? 0);
        if (userId > 0) {
          final dbUser = await ApiService.getUserById(userId);
          if (dbUser != null) {
            final int dbType = dbUser['userType'] is int
                ? dbUser['userType']
                : (int.tryParse(dbUser['userType']?.toString() ?? '0') ?? 0);
            
            final String dbEmail = (dbUser['email'] ?? session['userEmail'] ?? '').toString().toLowerCase();
            final String dbName = (dbUser['name'] ?? session['userName'] ?? '').toString().toLowerCase();
            final String dbRole = (dbUser['role'] ?? session['userRole'] ?? '').toString().toLowerCase();

            final bool isSuperAdmin = (dbType == 2) || dbRole == 'admin' || dbEmail.contains('sankalp') || dbName.contains('sankalp');
            final bool isResellerAccount = !isSuperAdmin && ((dbType == 1) ||
                dbRole == 'reseller' ||
                dbEmail.contains('purva') ||
                dbEmail.contains('reseller') ||
                dbName.contains('purva'));

            final int currentType = isSuperAdmin ? 2 : (isResellerAccount ? 1 : (session['userType'] ?? 0));

            session['userType'] = currentType;
            if (dbUser['name'] != null && dbUser['name'].toString().isNotEmpty) {
              session['userName'] = dbUser['name'];
            }
            if (dbUser['email'] != null && dbUser['email'].toString().isNotEmpty) {
              session['userEmail'] = dbUser['email'];
            }
            session['userRole'] = isSuperAdmin ? 'Super Admin' : (isResellerAccount ? 'Reseller' : (dbUser['role'] ?? session['userRole'] ?? 'Student'));
            if (dbUser['mobileNumber'] != null && dbUser['mobileNumber'].toString().isNotEmpty) {
              session['mobileNumber'] = dbUser['mobileNumber'];
            }

            await SessionService.saveSession(
              isLoggedIn: true,
              userId: userId,
              userType: currentType,
              userName: session['userName'],
              userEmail: session['userEmail'],
              userRole: session['userRole'],
              mobileNumber: session['mobileNumber'],
            );
          }
        }
      } catch (_) {}
    }
    return session;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Campus Pay & Finance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/student-dashboard': (context) => const DashboardScreen(),
            '/admin-dashboard': (context) => const ResellerDashboardScreen(resellerName: 'Reseller', resellerEmail: 'reseller@campus.edu'),
            '/super-admin-dashboard': (context) => const SuperAdminDashboardScreen(),
          },
          home: FutureBuilder<Map<String, dynamic>>(
            future: _loadSessionWithDbCheck(),
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
              final int userType = session?['userType'] is int
                  ? session!['userType']
                  : (int.tryParse(session?['userType']?.toString() ?? '0') ?? 0);
              final String userName = session?['userName'] ?? 'Hitija Mhatre';
              final String userEmail = session?['userEmail'] ?? 'hitija@student.campus.edu';
              final String userRole = session?['userRole'] ?? 'Student';
              final String mobileNumber = session?['mobileNumber'] ?? '+91 98765 43210';

              final String email = userEmail.toLowerCase();
              final String name = userName.toLowerCase();
              final String role = userRole.toLowerCase();

              final bool isSuperAdmin = (userType == 2) || role == 'admin' || email.contains('sankalp') || name.contains('sankalp');
              final bool isReseller = !isSuperAdmin && ((userType == 1) ||
                  role == 'reseller' ||
                  email.contains('purva') ||
                  email.contains('reseller') ||
                  name.contains('purva'));

              if (isLoggedIn) {
                if (isSuperAdmin) {
                  return SuperAdminDashboardScreen(
                    adminName: userName,
                    adminEmail: userEmail,
                  );
                } else if (isReseller) {
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
      },
    );
  }
}
