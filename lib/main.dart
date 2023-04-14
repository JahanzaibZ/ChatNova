import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/splash_screen.dart';
import './screens/main_screen.dart';
import './screens/auth_type_screen.dart';
import './screens/auth_screen.dart';
import './screens/opt_screen.dart';
import './screens/privacy_policy_screen.dart';
import './helpers/app_theme.dart';
import './providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        theme: lightTheme(),
        darkTheme: darkTheme(),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            } else if (snapshot.hasData) {
              return const MainScreen();
            } else {
              return const AuthTypeScreen();
            }
          },
        ),
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          MainScreen.routeName: (context) => const MainScreen(),
          AuthTypeScreen.routeName: (context) => const AuthTypeScreen(),
          AuthScreen.routeName: (context) => const AuthScreen(),
          OtpScreen.routeName: (context) => const OtpScreen(),
          PrivacyPolicyScreen.routeName: (context) =>
              const PrivacyPolicyScreen(),
        },
      ),
    );
  }
}
