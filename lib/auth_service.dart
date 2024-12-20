
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> register(String phone, String password) async {
    try {
      final email = _formatEmail(phone);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<User?> login(String phone, String password) async {
    try {
      final email = _formatEmail(phone);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _formatEmail(String phone) {
    return '$phone@example.com'; 
  }

  resetPassword(String email) {}
  User? get currentUser {

    

    return FirebaseAuth.instance.currentUser;

  }
Future<void> signOut(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);  
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
}
}
