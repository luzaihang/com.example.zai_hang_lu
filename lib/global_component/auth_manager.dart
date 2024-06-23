import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _loginTimestampKey = 'loginTimestamp';
  static const String _userNameKey = 'userName';
  static const String _userPasswordKey = 'userPassword';
  static const String _uniqueIDKey = 'uniqueID';
  static const int _expireDuration =
      24 * 60 * 60 * 1000; // 24 hours in milliseconds

  static Future<void> login(
    String userName,
    String userPassword,
    String uniqueID,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setInt(
        _loginTimestampKey, DateTime.now().millisecondsSinceEpoch);

    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userPasswordKey, userPassword);
    await prefs.setString(_uniqueIDKey, uniqueID);
  }

  ///单独更改昵称
  static Future<void> setUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  static Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (isLoggedIn) {
      int loginTimestamp = prefs.getInt(_loginTimestampKey) ?? 0;
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      if (currentTimestamp - loginTimestamp < _expireDuration) {
        return true;
      } else {
        await clearLoginStatus();
        return false;
      }
    }

    return false;
  }

  static Future<void> logout() async {
    await clearLoginStatus();
  }

  static Future<void> clearLoginStatus({bool clearAll = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_loginTimestampKey);

    if (clearAll) {
      await prefs.remove(_userNameKey);
      await prefs.remove(_userPasswordKey);
      await prefs.remove(_uniqueIDKey);
    }
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPasswordKey);
  }

  static Future<String?> getUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uniqueIDKey);
  }
}
