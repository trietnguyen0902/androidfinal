import 'package:flutter/material.dart';
import 'preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _preferencesService = PreferencesService();
  bool _darkMode = false;
  double _fontSize = 14.0;
  bool _autoAnswer = false;
  String _autoAnswerMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final theme = await _preferencesService.getTheme();
    final fontSize = await _preferencesService.getFontSize();
    final autoAnswer = await _preferencesService.getAutoAnswer();

    setState(() {
      _darkMode = theme;
      _fontSize = fontSize;
      _autoAnswer = autoAnswer['enabled'];
      _autoAnswerMessage = autoAnswer['message'];
    });
  }

  void _savePreferences() async {
    await _preferencesService.saveTheme(_darkMode);
    await _preferencesService.saveFontSize(_fontSize);
    await _preferencesService.saveAutoAnswer(_autoAnswer, _autoAnswerMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Dark Mode'),
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                _savePreferences();
              },
            ),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              label: '${_fontSize.toStringAsFixed(1)} px',
              onChanged: (value) {
                setState(() => _fontSize = value);
                _savePreferences();
              },
            ),
            SwitchListTile(
              title: Text('Auto Answer Mode'),
              value: _autoAnswer,
              onChanged: (value) {
                setState(() => _autoAnswer = value);
                _savePreferences();
              },
            ),
            if (_autoAnswer)
              TextField(
                decoration: InputDecoration(labelText: 'Auto Answer Message'),
                onChanged: (value) {
                  setState(() => _autoAnswerMessage = value);
                  _savePreferences();
                },
              ),
          ],
        ),
      ),
    );
  }
}
