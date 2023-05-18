import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/splash_screen.dart';
import './screens/main_screen.dart';
import './screens/new_chat_screen.dart';
import './screens/auth_type_screen.dart';
import './screens/auth_screen.dart';
import './screens/opt_screen.dart';
import './screens/profile_setup_screen.dart';
import './screens/privacy_policy_screen.dart';
import './screens/message_screen.dart';
import './screens/profile_screen.dart';
import './screens/manage_users_screen.dart';
import './screens/live_chat_message_screen.dart';
import './helpers/app_theme.dart';
import './providers/auth_provider.dart';
import './providers/user_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserDataProvider(),
        ),
      ],
      child: MaterialApp(
        theme: lightTheme(),
        darkTheme: darkTheme(),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            } else if (snapshot.hasData) {
              return FutureBuilder(
                future: Provider.of<AuthProvider>(
                  context,
                ).isNewUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreen();
                  } else if (snapshot.hasData) {
                    if (snapshot.data == true) {
                      return const ProfileSetupScreen();
                    } else {
                      return FutureBuilder(
                        future: Provider.of<UserDataProvider>(context,
                                listen: false)
                            .fetchAndSetUserProfileInfo(onlyFetch: true),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SplashScreen();
                          } else {
                            return const MainScreen();
                          }
                        },
                      );
                    }
                  } else {
                    // This block should not if program is executing correctly...
                    return const MainScreen();
                  }
                },
              );
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
          ProfileSetupScreen.routeName: (context) => const ProfileSetupScreen(),
          NewChatScreen.routeName: (context) => const NewChatScreen(),
          MessageScreen.routeName: (context) => const MessageScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          ManageUsersScreen.routeName: (context) => const ManageUsersScreen(),
          LiveChatMessageScreen.routeName: (context) =>
              const LiveChatMessageScreen(),
        },
      ),
    );
  }
}
