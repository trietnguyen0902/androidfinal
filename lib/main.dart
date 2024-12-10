import 'package:flutter/material.dart';
import 'package:mail/compose_email_screen.dart';
import 'package:mail/draft_screen.dart';
import 'package:provider/provider.dart';
import 'font_setting.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  // Check if the user is logged in
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false; 

  runApp(
    ChangeNotifierProvider(
      create: (context) => FontSettingsProvider(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final fontSettings = context.watch<FontSettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Email Service Test',
      theme: ThemeData(
        brightness: fontSettings.isDarkMode ? Brightness.dark : Brightness.light,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSettings.fontSize), 
          bodyMedium: TextStyle(fontFamily: fontSettings.fontFamily), 
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSettings.fontSize), 
          bodyMedium: TextStyle(fontFamily: fontSettings.fontFamily), 
        ),
      ),
      themeMode: fontSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light, 
      initialRoute: isLoggedIn ? '/' : '/login', 
      routes: {
        '/': (context) => HomeScreen(), 
        '/login': (context) => const LoginScreen(), 
        '/settings': (context) => const SettingsScreen(), 
        '/compose': (context) => const ComposeEmailScreen(), 
        '/drafts': (context) => const DraftsScreen(), 
      },
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr, 
          child: child!,
        );
      },
    );
  }
}

