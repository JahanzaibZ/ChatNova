import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';
import '../widgets/message_textfield.dart';
import '../providers/messages_provider.dart';

class MessageScreen extends StatelessWidget {
  static const routeName = '/message-screen';

  Future<void> sendMessage(BuildContext context, Message message) async {
    Provider.of<MessagesProvider>(context, listen: false).sendMessage(message);
  }

  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var scaffoldHeight = mediaQuery.size.height -
        (kToolbarHeight * 1.25) -
        mediaQuery.padding.vertical -
        mediaQuery.viewInsets.vertical;
    var friendInfo =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.25,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  const AssetImage('assets/images/default_profile.png'),
              foregroundImage: friendInfo['friendImageURL'] != null
                  ? NetworkImage(friendInfo['friendImageURL'])
                  : null,
              radius: 25,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(friendInfo['friendName']),
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: SizedBox(
        height: scaffoldHeight,
        width: mediaQuery.size.width,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                child: Column(
                  children: const [],
                ),
              ),
            ),
            MessageTextfield(
              recieverId: friendInfo['friendId'],
              senderId: FirebaseAuth.instance.currentUser!.uid,
              sendMessage: sendMessage,
            ),
          ],
        ),
      )),
    );
  }
}
