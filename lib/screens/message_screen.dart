import 'package:chatnova/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/message.dart';
import '../widgets/message_textfield.dart';
import '../widgets/message_bubble.dart';

class MessageScreen extends StatelessWidget {
  static const routeName = '/message-screen';

  Future<void> sendMessage(BuildContext context, Message message) async {
    Provider.of<UserDataProvider>(context, listen: false).sendMessage(message);
  }

  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var scaffoldHeight = mediaQuery.size.height -
        (kToolbarHeight * 1.25) -
        mediaQuery.padding.vertical -
        mediaQuery.viewInsets.vertical;
    var friend = ModalRoute.of(context)?.settings.arguments as AppUser;
    var currentUserId = FirebaseAuth.instance.currentUser!.uid;
    var messages =
        Provider.of<UserDataProvider>(context).messages.where((message) {
      if ((message.senderId == currentUserId &&
              message.receiverId == friend.id) ||
          (message.senderId == friend.id &&
              message.receiverId == currentUserId)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.25,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  const AssetImage('assets/images/default_profile.png'),
              foregroundImage: friend.profilePictureURL != null
                  ? NetworkImage(friend.profilePictureURL!)
                  : null,
              radius: 25,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(friend.name),
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: SizedBox(
        height: scaffoldHeight,
        width: mediaQuery.size.width,
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const SizedBox()
                  : ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          message: messages[index].text,
                          timeStamp: messages[index].timeStamp,
                          mainUserMessage:
                              messages[index].senderId == currentUserId,
                        );
                      },
                    ),
            ),
            MessageTextfield(
              recieverId: friend.id!,
              senderId: currentUserId,
              sendMessage: sendMessage,
            ),
          ],
        ),
      )),
    );
  }
}
