import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  static const String SHARED_PREF_FILE = "com.zf_sdk.ZFSurveyPref";

  static final PreferenceManager _sharedPrefSingleton =
      PreferenceManager._internal();
  factory PreferenceManager() {
    return _sharedPrefSingleton;
  }
  PreferenceManager._internal();

  late SharedPreferences _sharedPref;

  // Initialize the PreferenceManager instance with context and token
  Future<void> init(String token) async {
    await _initializeSharedPreferences(token);
  }

  // Initialize SharedPreferences with a token
  Future<void> _initializeSharedPreferences(String token) async {
    _sharedPref = await SharedPreferences.getInstance();
  }

  // Get a long value from SharedPreferences
  int getLong(String key) {
    return _sharedPref.getInt(key) ?? 0;
  }

  // Save a long value to SharedPreferences
  Future<void> putLong(String key, int value) async {
    await _sharedPref.setInt(key, value);
  }

  // Save a string value to SharedPreferences
  Future<void> putString(String key, String value) async {
    await _sharedPref.setString(key, value);
  }

  // Get a string value from SharedPreferences
  String getString(String key, String defaultValue) {
    return _sharedPref.getString(key) ?? defaultValue;
  }

  // Save a boolean value to SharedPreferences
  Future<void> putBoolean(String key, bool value) async {
    await _sharedPref.setBool(key, value);
  }

  // Get a boolean value from SharedPreferences
  bool getBoolean(String key, bool defaultValue) {
    return _sharedPref.getBool(key) ?? defaultValue;
  }

  // Save a list of strings to SharedPreferences
  Future<void> putStringList(String key, List<String> value) async {
    await _sharedPref.setStringList(key, value);
  }

  // Get a list of strings from SharedPreferences
  List<String>? getStringList(String key, List<String>? defaultValue) {
    return _sharedPref.getStringList(key) ?? defaultValue;
  }

  // Clear all preferences
  Future<void> clearAllPrefs() async {
    await _sharedPref.clear();
  }
}
