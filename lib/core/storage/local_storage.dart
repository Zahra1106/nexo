import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('nexo_storage');
  }

  // Login save karo
  static Future<void> saveLogin(String username, String password) async {
    await _box.put('username', username);
    await _box.put('password', password);
  }

  static String? getUsername() => _box.get('username');
  static String? getPassword() => _box.get('password');

  static bool isLoggedIn() =>
      getUsername() != null && getPassword() != null;

  static Future<void> clearLogin() async {
    await _box.delete('username');
    await _box.delete('password');
  }
}