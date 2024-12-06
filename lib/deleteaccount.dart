import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mail/login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Re-authenticate the user if necessary
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: 'your_current_password'); // Replace with user's password input

        // Re-authenticate the user to perform sensitive actions like account deletion
        await user.reauthenticateWithCredential(credential);
        await user.delete();

        // After deleting the account, log out and navigate
        await _auth.signOut();
        Navigator.push(context,MaterialPageRoute(builder: (context) => const LoginScreen()),);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) const CircularProgressIndicator(),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _deleteAccount,
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
