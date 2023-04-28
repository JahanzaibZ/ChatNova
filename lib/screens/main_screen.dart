import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/live_chat_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/more_screen.dart';
import '../screens/new_chat_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main-screen';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var currentIndex = 1;

  PreferredSizeWidget _scaffoldAppBar() {
    var title = 'Chat';
    var actions = <Widget>[];
    if (currentIndex == 0) {
      title = 'Live Chat';
    } else if (currentIndex == 1) {
      title = 'Chats';
      actions = [
        IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, NewChatScreen.routeName),
            icon: const Icon(Icons.add))
      ];
    } else if (currentIndex == 2) {
      title = 'More';
      actions = [
        IconButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.logout_outlined),
        )
      ];
    }
    return AppBar(
      // backgroundColor: Colors.amber,
      toolbarHeight: kToolbarHeight * 1.25,
      title: Text(
        title,
        textScaleFactor: 1.25,
      ),
      actions: actions,
    );
  }

  Widget _scaffoldBody() {
    switch (currentIndex) {
      case 0:
        return const LiveChatScreen();
      case 1:
        return const ChatScreen();
      case 2:
        return const MoreScreen();
      default:
        return const ChatScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _scaffoldAppBar(),
      body: _scaffoldBody(),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
            currentIndex: currentIndex,
            showUnselectedLabels: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            onTap: (value) => setState(() {
                  currentIndex = value;
                }),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.group,
                ),
                label: 'Live Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                label: 'More',
              )
            ]),
      ),
    );
  }
}
