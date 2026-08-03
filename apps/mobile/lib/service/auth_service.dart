import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String validPhone = "9875682324";
  static const String validOtp = "123456";

  static const String loginKey = "isLoggedIn";

  static Future<void> saveLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, true);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey) ?? false;
  }
}