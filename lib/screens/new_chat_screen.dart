import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_data_provider.dart';

class NewChatScreen extends StatelessWidget {
  static const routeName = '/new-chat-screen';

  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<UserDataProvider>(context, listen: false).getUserFriends();
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.25,
          title: const Text(
            'New Chat',
          ),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {},
        ));
  }
}
