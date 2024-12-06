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

  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('fontSize') ?? 14.0;
  }

  Future<void> saveAutoAnswer(bool enabled, String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoAnswer', enabled);
    await prefs.setString('autoAnswerMessage', message);
  }

  Future<Map<String, dynamic>> getAutoAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('autoAnswer') ?? false,
      'message': prefs.getString('autoAnswerMessage') ?? '',
    };
  }
  Future<bool> getNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification') ?? false;
  }
  Future<void> saveNotification(bool notification) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification', notification);
  }
}
