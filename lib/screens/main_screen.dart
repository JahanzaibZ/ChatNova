import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/main-screen';

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text('MainScreen'),
      ),
    );
  }
}
