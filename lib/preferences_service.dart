import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> saveTheme(bool darkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', darkMode);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false;
  }

  Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
  }


  // Save notification setting
  Future<void> setNotificationsEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications_enabled', isEnabled);
  }

  // Get notification setting
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true; // Default is true
  }
  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark_mode', isDarkMode);
  }
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_mode') ?? false; // Default is false
  }
  Future<void> setFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('font_size', fontSize);
  }
  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('font_size') ?? 16.0; // Default is 16.0
  }
  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'English';  // Default language is English
  }
}
