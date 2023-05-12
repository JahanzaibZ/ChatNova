import 'package:chatnova/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/message.dart';
import '../helpers/day_diffrence.dart';
import '../screens/profile_screen.dart';
import '../widgets/message_textfield.dart';
import '../widgets/message_bubble.dart';

class MessageScreen extends StatefulWidget {
  static const routeName = '/message-screen';

  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _messagesToBeDeleted = <Message>[];

  dynamic _queryMessagesToBeDeleted(
      {required bool checkIfEmpty, bool? removeMessage, Message? message}) {
    if (checkIfEmpty) {
      return _messagesToBeDeleted.isEmpty;
    } else if (removeMessage == true && message != null) {
      setState(() {
        _messagesToBeDeleted.removeWhere((msg) => msg.id == message.id);
      });
      return;
    } else if (message != null) {
      setState(() {
        _messagesToBeDeleted.add(message);
      });
      return;
    } else {
      return;
    }
  }

  Future<void> _sendMessage(BuildContext context, Message message) async {
    Provider.of<UserDataProvider>(context, listen: false).sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var scaffoldHeight = mediaQuery.size.height -
        (kToolbarHeight * 1.25) -
        mediaQuery.padding.vertical -
        mediaQuery.viewInsets.vertical;
    var receiver = ModalRoute.of(context)?.settings.arguments as AppUser;
    var currentUserId = FirebaseAuth.instance.currentUser!.uid;
    var messages =
        Provider.of<UserDataProvider>(context).messages.where((message) {
      if ((message.senderId == currentUserId &&
              message.receiverId == receiver.id) ||
          (message.senderId == receiver.id &&
              message.receiverId == currentUserId)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return WillPopScope(
      onWillPop: () async {
        if (_messagesToBeDeleted.isNotEmpty) {
          setState(() {
            _messagesToBeDeleted.clear();
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.25,
          title: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => Navigator.of(context).pushNamed(
              ProfileScreen.routeName,
              arguments: receiver,
            ),
            child: Row(
              children: [
                Hero(
                  tag: receiver.id,
                  child: CircleAvatar(
                    backgroundImage:
                        const AssetImage('assets/images/default_profile.png'),
                    foregroundImage: receiver.profilePictureURL != null
                        ? NetworkImage(receiver.profilePictureURL!)
                        : null,
                    radius: 25,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(receiver.name),
              ],
            ),
          ),
          actions: [
            if (_messagesToBeDeleted.isNotEmpty)
              IconButton(
                onPressed: () async {
                  final messagesToBeDeleted = [..._messagesToBeDeleted];
                  _messagesToBeDeleted.clear();
                  await Provider.of<UserDataProvider>(context, listen: false)
                      .deleteMessages(messagesToBeDeleted, currentUserId);
                },
                icon: const Icon(Icons.delete),
              )
          ],
          leading: _messagesToBeDeleted.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel_rounded),
                  onPressed: () => setState(() {
                    _messagesToBeDeleted.clear();
                  }),
                )
              : null,
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
                          final today = DateTime.now();
                          var dayDifference = daysBetweenDates(
                            messages[index].timeStamp.year,
                            messages[index].timeStamp.month,
                            messages[index].timeStamp.day,
                            today.year,
                            today.month,
                            today.day,
                          );
                          if ((index + 1) < messages.length) {
                            final messageDateDiffrence = daysBetweenDates(
                              messages[index].timeStamp.year,
                              messages[index].timeStamp.month,
                              messages[index].timeStamp.day,
                              messages[index + 1].timeStamp.year,
                              messages[index + 1].timeStamp.month,
                              messages[index + 1].timeStamp.day,
                            );
                            if (messageDateDiffrence == 0) {
                              dayDifference = -1;
                            }
                          }
                          return MessageBubble(
                            key: ValueKey(messages[index].id),
                            messagesToBeDelete: _queryMessagesToBeDeleted,
                            message: messages[index],
                            activeUserId: currentUserId,
                            dayDifference: dayDifference,
                          );
                        },
                      ),
              ),
              MessageTextfield(
                recieverId: receiver.id,
                senderId: currentUserId,
                sendMessage: _sendMessage,
              ),
            ],
          ),
        )),
      ),
    );
  }
}
