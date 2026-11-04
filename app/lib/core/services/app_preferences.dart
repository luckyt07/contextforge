import 'package:shared_preferences/shared_preferences.dart';

/// Singleton wrapper around [SharedPreferences].
///
/// Call [AppPreferences.init()] once in `main()` before [runApp].
/// After that every read/write is synchronous — no `await` needed.
class AppPreferences {
  AppPreferences._();

  static late SharedPreferences _prefs;

  /// Must be called once in `main()` before using any other method.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Generic accessors ────────────────────────────────────────────────────

  static String? getString(String key) => _prefs.getString(key);
  static int? getInt(String key) => _prefs.getInt(key);
  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  static Future<bool> setInt(String key, int value) =>
      _prefs.setInt(key, value);
  static Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(key, value);
  static Future<bool> remove(String key) => _prefs.remove(key);
}
