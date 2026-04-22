import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:unimates/screens/auth.dart';
import 'package:unimates/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimates/services/notification_service.dart';
import 'package:unimates/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeMode.notifier,
      builder: (context, mode, _) => MaterialApp(
        title: 'UniMates - Student Community',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: mode,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  // Keep HomeScreen alive once created so it never gets recreated on
  // subsequent auth stream emissions (e.g. token refresh events).
  HomeScreen? _homeScreen;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          _homeScreen ??= const HomeScreen();
          return _homeScreen!;
        }

        // User logged out — reset cached screen so next login gets a fresh one
        _homeScreen = null;
        return const AuthScreen();
      },
    );
  }
}

