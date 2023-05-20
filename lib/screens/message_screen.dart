import 'package:chatnova/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/message.dart';
import '../helpers/day_diffrence.dart';
import '../screens/profile_screen.dart';
import '../widgets/message_textfield.dart';
import '../widgets/message_selection.dart';

class MessageScreen extends StatefulWidget {
  static const routeName = '/message-screen';

  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _messagesToBeDeleted = <Message>[];

  bool _isUserOnline(String receiverId) {
    var isOnline = false;
    final friendsStatus = Provider.of<UserDataProvider>(context).friendsStatus;
    friendsStatus.forEach(
      (key, value) {
        if (receiverId == key) {
          isOnline = true;
        }
      },
    );
    return isOnline;
  }

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
          title: Theme(
            data: Theme.of(context).copyWith(
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            child: ListTile(
              leading: Hero(
                tag: receiver.id,
                child: ClipOval(
                  child: receiver.profilePictureURL != null
                      ? FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder: const AssetImage(
                              'assets/images/default_profile.png'),
                          image: NetworkImage(receiver.profilePictureURL!),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/default_profile.png'),
                        )
                      : Image.asset('assets/images/default_profile.png'),
                ),
              ),
              title: Text(receiver.name),
              subtitle: _isUserOnline(receiver.id)
                  ? Text(
                      'Online',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!
                            .withOpacity(.5),
                      ),
                    )
                  : null,
              onTap: () => Navigator.of(context).pushNamed(
                ProfileScreen.routeName,
                arguments: receiver,
              ),
            ),
          ),

          //   Row(
          //     children: [
          //       SizedBox(
          //         width: mediaQuery.size.width * .2,
          //         child: Hero(
          //           tag: receiver.id,
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(20),
          //             child: FadeInImage(
          //               placeholder: const AssetImage(
          //                   'assets/images/default_profile_square.png'),
          //               image: (receiver.profilePictureURL == null
          //                       ? const AssetImage(
          //                           'assets/images/default_profile_square.png')
          //                       : NetworkImage(receiver.profilePictureURL!))
          //                   as ImageProvider<Object>,
          //               imageErrorBuilder: (context, error, stackTrace) =>
          //                   Image.asset(
          //                       'assets/images/default_profile_square.png'),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(
          //         width: 20,
          //       ),
          //       Text(receiver.name),
          //     ],
          //   ),
          // ),
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
                            return MessageSelection(
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
          ),
        ),
      ),
    );
  }
}
