import 'package:flutter/material.dart';
import 'package:mail/login_screen.dart';
import 'preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _preferencesService = PreferencesService();
  bool _darkMode = false;
  bool _autoAnswer = false;
  bool _notification = false;
  String _autoAnswerMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final theme = await _preferencesService.getTheme();
    final autoAnswer = await _preferencesService.getAutoAnswer();
    final notification = await _preferencesService.getNotification();

    setState(() {
      _darkMode = theme;
      _autoAnswer = autoAnswer['enabled'];
      _autoAnswerMessage = autoAnswer['message'];
      _notification = notification;
    });
  }

  void _savePreferences() async {
    await _preferencesService.saveTheme(_darkMode);
    await _preferencesService.saveAutoAnswer(_autoAnswer, _autoAnswerMessage);
    await _preferencesService.saveNotification(_notification);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  void _resetPreferences() {
    setState(() {
      _darkMode = false;
      _autoAnswer = false;
      _autoAnswerMessage = '';
      _notification = false;
    });
    _savePreferences();
  }

  Future<void> _deleteAccount() async {
    final deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
        false;

    if (deleteConfirmed) {
      // Placeholder for delete account logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Return to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                _savePreferences();
                // Apply the theme change
                if (_darkMode) {
                  // Dark theme
                  ThemeMode.dark;
                } else {
                  // Light theme
                  ThemeMode.light;
                }
              },
            ),
            const Divider(height: 30),
            const Text(
              'Auto Answer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Enable Auto Answer'),
              subtitle: const Text('Automatically reply to all emails'),
              value: _autoAnswer,
              onChanged: (value) {
                setState(() => _autoAnswer = value);
                _savePreferences();
              },
            ),
            if (_autoAnswer)
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Auto Answer Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() => _autoAnswerMessage = value);
                  _savePreferences();
                },
                controller: TextEditingController(text: _autoAnswerMessage),
              ),
            const Divider(height: 30),
                       const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive notifications for new messages'),
              value: _notification,
              onChanged: (value) {
                setState(() {
                  _notification = value;
                });
                _savePreferences();
              },
            ),
            const Text(
              'Account Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
            const Divider(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final resetConfirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Settings'),
                        content: const Text('Are you sure you want to reset all settings?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (resetConfirmed) {
                  _resetPreferences();
                }
              },
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Default'),
            ),
          ],
        ),
      ),
    );
  }
}
