import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static const userNameKey = 'chronosUserName';

  static Future<String?> getUserName() async {
    final preferences = await SharedPreferences.getInstance();
    final name = preferences.getString(userNameKey)?.trim();
    return name == null || name.isEmpty ? null : name;
  }

  static Future<void> saveUserName(String name) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(userNameKey, name.trim());
  }
}
