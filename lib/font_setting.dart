import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSettingsProvider with ChangeNotifier {
  double _fontSize = 14.0;
  String _fontFamily = 'Arial';
  bool _isDarkMode = false;
  bool _autoAnswer = false;
  String _autoAnswerMessage = '';

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  bool get isDarkMode => _isDarkMode;
  bool get autoAnswer => _autoAnswer;
  String get autoAnswerMessage => _autoAnswerMessage;

  FontSettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    _fontFamily = prefs.getString('fontFamily') ?? 'Arial';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _autoAnswer = prefs.getBool('autoAnswer') ?? false;
    _autoAnswerMessage = prefs.getString('autoAnswerMessage') ?? '';
    notifyListeners();
  }

  void setFontSize(double size) async {
    _fontSize = size;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', _fontSize);
    notifyListeners();
  }

  void setFontFamily(String family) async {
    _fontFamily = family;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fontFamily', _fontFamily);
    notifyListeners();
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void toggleAutoAnswer() async {
    _autoAnswer = !_autoAnswer;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoAnswer', _autoAnswer);
    notifyListeners();
  }

  void setAutoAnswerMessage(String message) async {
    _autoAnswerMessage = message;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('autoAnswerMessage', _autoAnswerMessage);
    notifyListeners();
  }
}
