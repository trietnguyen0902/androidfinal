import 'package:flutter/material.dart';
import 'preferences_service.dart';

class FontSettingsProvider with ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();

  double _fontSize = 14.0;
  String _fontFamily = 'Arial';

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  FontSettingsProvider() {
    _loadFontSettings();
  }

  // Load font settings from shared preferences
  Future<void> _loadFontSettings() async {
    _fontSize = await _preferencesService.getFontSize();
    _fontFamily = await _preferencesService.getFontFamily() ?? 'Arial';
    notifyListeners();
  }

  // Update font size
  Future<void> setFontSize(double newFontSize) async {
    _fontSize = newFontSize;
    await _preferencesService.saveFontSize(newFontSize);
    notifyListeners();
  }

  // Update font family
  Future<void> setFontFamily(String newFontFamily) async {
    _fontFamily = newFontFamily;
    await _preferencesService.saveFontFamily(newFontFamily);
    notifyListeners();
  }
}
