import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserType = 'user_type'; // 0: Student, 1: Reseller, 2: Admin
  static const String _keyLastSelectedType = 'last_selected_type';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyMobileNumber = 'mobile_number';

  /// Save user type selection permanently
  static Future<void> saveLastSelectedUserType(int userType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastSelectedType, userType);
      await prefs.setInt(_keyUserType, userType);
    } catch (_) {}
  }

  /// Retrieve last selected user type
  static Future<int> getLastSelectedUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyLastSelectedType) ?? prefs.getInt(_keyUserType) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Save login session permanently in device/browser local storage
  static Future<void> saveSession({
    required bool isLoggedIn,
    required int userType,
    required String userName,
    required String userEmail,
    String? userRole,
    String? mobileNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
      await prefs.setInt(_keyUserType, userType);
      await prefs.setInt(_keyLastSelectedType, userType);
      await prefs.setString(_keyUserName, userName);
      await prefs.setString(_keyUserEmail, userEmail);
      if (userRole != null) await prefs.setString(_keyUserRole, userRole);
      if (mobileNumber != null) await prefs.setString(_keyMobileNumber, mobileNumber);
    } catch (_) {}
  }

  /// Retrieve saved session state upon app load / browser refresh
  static Future<Map<String, dynamic>> getSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final int userType = prefs.getInt(_keyLastSelectedType) ?? prefs.getInt(_keyUserType) ?? 0;
      final String defaultRole = userType == 2 ? 'Admin' : (userType == 1 ? 'Reseller' : 'Student');
      final String defaultName = userType == 2 ? 'Sankalp (Admin)' : (userType == 1 ? 'Purva (Reseller)' : 'Hitija Mhatre');
      final String defaultEmail = userType == 2 ? 'sankalp@admin.campus.edu' : (userType == 1 ? 'purva@reseller.campus.edu' : 'student@campus.edu');
      final String userName = prefs.getString(_keyUserName) ?? defaultName;
      final String userEmail = prefs.getString(_keyUserEmail) ?? defaultEmail;
      final String userRole = prefs.getString(_keyUserRole) ?? defaultRole;
      final String mobileNumber = prefs.getString(_keyMobileNumber) ?? '+91 98765 43210';

      return {
        'isLoggedIn': isLoggedIn,
        'userType': userType,
        'userName': userName,
        'userEmail': userEmail,
        'userRole': userRole,
        'mobileNumber': mobileNumber,
      };
    } catch (_) {
      return {
        'isLoggedIn': false,
        'userType': 0,
        'userName': 'Hitija Mhatre',
        'userEmail': 'student@campus.edu',
        'userRole': 'Student',
        'mobileNumber': '+91 98765 43210',
      };
    }
  }

  /// Clear login credentials upon logout while keeping userType preference
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserRole);
      await prefs.remove(_keyMobileNumber);
    } catch (_) {}
  }
}
