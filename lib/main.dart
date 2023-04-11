import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './screens/auth_type_screen.dart';
import 'screens/auth_screen.dart';
import './screens/privacy_policy_screen.dart';
import './helpers/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return MaterialApp(
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: const AuthTypeScreen(),
      routes: {
        AuthTypeScreen.routeName: (context) => const AuthTypeScreen(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        PrivacyPolicyScreen.routeName: (context) => const PrivacyPolicyScreen(),
      },
    );
  }
}
