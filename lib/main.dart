import 'package:flutter/material.dart';

import './screens/auth_type_screen.dart';
import './helpers/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: AuthTypeScreen(),
    );
  }
}
