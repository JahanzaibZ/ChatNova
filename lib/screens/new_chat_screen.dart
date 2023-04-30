import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/message_screen.dart';
import '../providers/user_data_provider.dart';

class NewChatScreen extends StatelessWidget {
  static const routeName = '/new-chat-screen';

  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserDataProvider>(context, listen: false);
    var friendList = userProvider.userFriends;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.25,
          title: const Text(
            'New Chat',
          ),
        ),
        body: ListView.builder(
          itemCount: userProvider.userFriends.length,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  const AssetImage('assets/images/default_profile.png'),
              foregroundImage: friendList[index].profilePictureURL != null
                  ? NetworkImage(friendList[index].profilePictureURL!)
                  : null,
              radius: 30,
            ),
            title: Text(friendList[index].name ?? 'Unknown'),
            onTap: () => Navigator.of(context).pushReplacementNamed(
              MessageScreen.routeName,
              arguments: friendList[0],
            ),
          ),
        ));
  }
}
