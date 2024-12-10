import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mail/font_setting.dart';
import 'package:mail/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _preferencesService = PreferencesService();
  bool _darkMode = false;
  bool _autoAnswer = false;
  bool _notification = false;
  String _autoAnswerMessage = '';
  String _displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
  TextEditingController _autoAnswerController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final theme = await _preferencesService.getTheme();
    final autoAnswer = await _preferencesService.getAutoAnswer();
    final notification = await _preferencesService.getNotification();
    final fontSize = await _preferencesService.getFontSize();
    final fontFamily = await _preferencesService.getFontFamily();
    
    setState(() {
      _darkMode = theme;
      _autoAnswer = autoAnswer['enabled'];
      _autoAnswerMessage = autoAnswer['message'];
      _notification = notification;
      _displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
      _autoAnswerController.text = _autoAnswerMessage; 

      // Update the font settings in the provider
      final fontSettings = Provider.of<FontSettingsProvider>(context, listen: false);
      fontSettings.setFontSize(fontSize);
      fontSettings.setFontFamily(fontFamily!);
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
    ) ?? false;

    if (deleteConfirmed) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.delete();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? newPassword = await _showPasswordDialog();
      if (newPassword != null && newPassword.isNotEmpty) {
        try {
          await user.updatePassword(newPassword);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to change password: $e')),
          );
        }
      }
    }
  }

  Future<String?> _showPasswordDialog() {
    TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter new password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleTwoStepVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email verification: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? displayName = await _showNameDialog();
      if (displayName != null && displayName.isNotEmpty) {
        try {
          await user.updateDisplayName(displayName);
          setState(() {
            _displayName = displayName;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  Future<String?> _showNameDialog() {
    TextEditingController nameController = TextEditingController();
    nameController.text = _displayName;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter new display name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(nameController.text);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

Future<void> _logout() async {
  try {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Update shared preferences to mark the user as logged out
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    // Optional: Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  } catch (e) {
    // Handle errors (if any)
    debugPrint('Logout failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during logout: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<FontSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
              value: settings.isDarkMode,
              onChanged: (value) {
                settings.toggleDarkMode();
              },
            ),
            const Text(
              'Font Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Font Size:'),
            DropdownButton<double>(
              value: settings.fontSize,
              items: [12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0, 32.0]
                  .map((size) => DropdownMenuItem(
                        value: size,
                        child: Text('${size.toString()} px'),
                      ))
                  .toList(),
              onChanged: (newFontSize) {
                settings.setFontSize(newFontSize!);
              },
            ),
            const SizedBox(height: 20),
            const Text('Font Family:'),
            DropdownButton<String>(
              value: settings.fontFamily,
              items: ['Arial', 'Courier', 'Roboto', 'Times New Roman']
                  .map((family) => DropdownMenuItem(
                        value: family,
                        child: Text(family),
                      ))
                  .toList(),
              onChanged: (newFontFamily) {
                settings.setFontFamily(newFontFamily!);
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
                  setState(() {
                    _autoAnswerMessage = value;
                  });
                  _savePreferences();
                },
                controller: _autoAnswerController, // Using persistent controller
                textDirection: TextDirection.ltr, // Set the text direction to LTR
              ),
            const Divider(height: 30),
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
            const Divider(height: 30),
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
            ElevatedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock),
              label: const Text('Change Password'),
            ),
            ElevatedButton.icon(
              onPressed: _toggleTwoStepVerification,
              icon: const Icon(Icons.security),
              label: const Text('Enable/Disable Two-Step Verification'),
            ),
            ElevatedButton.icon(
              onPressed: _updateProfile,
              icon: const Icon(Icons.person),
              label: const Text('Update Profile'),
            ),
            const Divider(height: 30),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
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
                    ) ?? false;

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
