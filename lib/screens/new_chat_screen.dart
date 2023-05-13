import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/message_screen.dart';
import '../screens/manage_users_screen.dart';
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
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(
                    ManageUsersScreen.routeName,
                    arguments: false),
                icon: const Icon(Icons.group_rounded))
          ],
        ),
        body: friendList.isEmpty
            ? const Center(
                child: Text(
                  'You have no friends yet!',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: friendList.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          const AssetImage('assets/images/default_profile.png'),
                      foregroundImage: friendList[index].profilePictureURL !=
                              null
                          ? NetworkImage(friendList[index].profilePictureURL!)
                          : null,
                      radius: 30,
                    ),
                    title: Text(friendList[index].name),
                    onTap: () => Navigator.of(context).pushReplacementNamed(
                      MessageScreen.routeName,
                      arguments: friendList[index],
                    ),
                  ),
                ),
              ));
  }
}
