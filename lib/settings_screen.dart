import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'preferences_service.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PreferencesService _preferencesService = PreferencesService();
  bool _isLoading = false;
  String? _message;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  double _fontSize = 16.0;
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings (e.g., dark mode, notifications, language)
  Future<void> _loadSettings() async {
    final notificationsEnabled = await _preferencesService.getNotificationsEnabled();
    final darkMode = await _preferencesService.getDarkMode();
    final fontSize = await _preferencesService.getFontSize();
    final language = await _preferencesService.getLanguage();
    
    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _darkMode = darkMode;
      _fontSize = fontSize;

    });
  }

  // Save settings
  void _saveSettings() async {
    await _preferencesService.setNotificationsEnabled(_notificationsEnabled);
    await _preferencesService.setDarkMode(_darkMode);
    await _preferencesService.setFontSize(_fontSize);

  }

  // Change profile picture
  Future<void> _pickProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profilePicUrl = image.path; // Store path or upload to Firebase
      });
    }
  }

  // Sign out the user
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  // Delete the user's account
  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Reauthenticate before deleting the account
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: 'your_current_password', // Replace with actual password input
        );

        await user.reauthenticateWithCredential(credential);
        await user.delete();

        // Log out and redirect to login screen
        await _auth.signOut();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message ?? 'An error occurred during account deletion';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update theme (Dark Mode)
  void _toggleDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
    _saveSettings(); // Save theme to SharedPreferences
  }

  // Update font size
  void _updateFontSize(double value) {
    setState(() {
      _fontSize = value;
    });
    _saveSettings(); // Save font size to SharedPreferences
  }

  // Update language selection

  // Toggle notifications
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    _saveSettings(); // Save notification setting to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Picture Section
            GestureDetector(
              onTap: _pickProfilePicture,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicUrl != null
                    ? FileImage(File(_profilePicUrl!))
                    : const AssetImage('assets/default_profile_pic.png') as ImageProvider,
                child: _profilePicUrl == null
                    ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Notifications Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enable Notifications'),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _isLoading ? null : _toggleNotifications,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dark Mode Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Mode'),
                Switch(
                  value: _darkMode,
                  onChanged: _isLoading ? null : _toggleDarkMode,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Font Size Section
            const Text('Font Size'),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              label: '${_fontSize.toStringAsFixed(1)}',
              onChanged: _isLoading ? null : _updateFontSize,
            ),
            const SizedBox(height: 16),

            // Delete Account Section
            ElevatedButton(
              onPressed: _isLoading ? null : _deleteAccount,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Delete Account'),
            ),
            const SizedBox(height: 16),

            // Sign Out Section
            ElevatedButton(
              onPressed: _isLoading ? null : _signOut,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Out'),
            ),
            const SizedBox(height: 16),

            // Message Display
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                style: const TextStyle(color: Colors.red),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
