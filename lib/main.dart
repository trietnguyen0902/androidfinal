import 'package:firebase_core/firebase_core.dart';
import 'package:mail/font_setting.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => FontSettingsProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch for font settings changes in the provider
    final fontSettings = context.watch<FontSettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Email Service Test',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSettings.fontSize), // Apply font size from provider
          bodyMedium: TextStyle(fontFamily: fontSettings.fontFamily), // Apply font family from provider
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSettings.fontSize), // Apply font size from provider
          bodyMedium: TextStyle(fontFamily: fontSettings.fontFamily), // Apply font family from provider
        ),
      ),
      themeMode: ThemeMode.system, // Use system theme mode (light/dark)

      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // Login screen
        '/settings': (context) => SettingsScreen(), // Settings screen
      },
    builder: (context, child) {
    return Directionality(
      textDirection: TextDirection.ltr, // Forces LTR globally
      child: child!,
    );
  },
    );
  }
}
