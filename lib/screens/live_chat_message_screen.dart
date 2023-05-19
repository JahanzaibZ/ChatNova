import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../providers/user_data_provider.dart';
import '../screens/profile_screen.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_textfield.dart';

class LiveChatMessageScreen extends StatefulWidget {
  static const routeName = '/live-chat-message-screen';

  const LiveChatMessageScreen({super.key});

  @override
  State<LiveChatMessageScreen> createState() => _LiveChatMessageScreenState();
}

class _LiveChatMessageScreenState extends State<LiveChatMessageScreen> {
  List<Message> liveChatMessages = [];
  late StreamSubscription<dynamic> liveChatSubscription;
  late StreamSubscription<dynamic> liveChatMessageSubscription;

  Future<void> _sendMessage(BuildContext context, Message message) async {
    Provider.of<UserDataProvider>(context, listen: false)
        .sendLiveMessage(message);
  }

  @override
  void dispose() {
    liveChatSubscription.cancel();
    liveChatMessageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var scaffoldHeight = mediaQuery.size.height -
        (kToolbarHeight * 1.25) -
        mediaQuery.padding.vertical -
        mediaQuery.viewInsets.vertical;
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final liveChatUser = userDataProvider.liveChatUser;
    if (liveChatUser.id != 'NO_ID') {
      liveChatMessages = userDataProvider.liveChatMessages;
    }
    final mainUser = userDataProvider.user;
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    liveChatSubscription =
        routeArgs['liveChatSubscription'] as StreamSubscription<dynamic>;

    liveChatMessageSubscription =
        routeArgs['liveChatMessageSubscription'] as StreamSubscription<dynamic>;
    return WillPopScope(
      onWillPop: liveChatUser.id == 'NO_ID'
          ? () async {
              userDataProvider.setUserLiveChatStatus(true);
              userDataProvider.deleteLiveMessages();
              return true;
            }
          : () async {
              final bool? pop = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Are you sure?',
                    textAlign: TextAlign.center,
                  ),
                  content: const Text(
                    'You will be disconnected from this live chat!',
                    textAlign: TextAlign.center,
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(80, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        final userDataProvider = Provider.of<UserDataProvider>(
                            context,
                            listen: false);
                        userDataProvider.setUserLiveChatStatus(true);
                        userDataProvider.deleteLiveMessages();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Yes'),
                    )
                  ],
                ),
              );
              return pop ?? false;
            },
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight * 1.25,
            title: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => Navigator.of(context).pushNamed(
                ProfileScreen.routeName,
                arguments: liveChatUser,
              ),
              child: Row(
                children: [
                  Hero(
                    tag: liveChatUser.id,
                    child: CircleAvatar(
                      backgroundImage:
                          const AssetImage('assets/images/default_profile.png'),
                      foregroundImage: liveChatUser.profilePictureURL != null
                          ? NetworkImage(liveChatUser.profilePictureURL!)
                          : null,
                      radius: 25,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(liveChatUser.name),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
              child: SizedBox(
            height: scaffoldHeight,
            width: mediaQuery.size.width,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: liveChatMessages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == (liveChatMessages.length)) {
                        final matchingInterests = <String>[];
                        for (final mainUserInteret in mainUser.interests) {
                          for (final liveChatUserInterest
                              in liveChatUser.interests) {
                            if (liveChatUserInterest == mainUserInteret) {
                              matchingInterests.add(liveChatUserInterest);
                            }
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          child: Text(
                            'Matching Interests:\n\n${matchingInterests.join('\n')}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color!
                                  .withOpacity(.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        return MessageBubble(
                          isSelected: false,
                          message: liveChatMessages[index],
                          mainUserMessage:
                              liveChatMessages[index].senderId == mainUser.id,
                        );
                      }
                    },
                  ),
                ),
                if (liveChatUser.id == 'NO_ID')
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Text('${liveChatUser.name} disconnected!'),
                  ),
                if (liveChatUser.id != 'NO_ID')
                  MessageTextfield(
                    recieverId: liveChatUser.id,
                    senderId: mainUser.id,
                    sendMessage: _sendMessage,
                  ),
              ],
            ),
          ))),
    );
  }
}
