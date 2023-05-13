import 'package:chatnova/screens/new_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/user_data_provider.dart';
import '../screens/message_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var searchFieldTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final filteredChats = Provider.of<UserDataProvider>(context).chats.where(
      (chat) {
        if (searchFieldTextEditingController.text.isEmpty) {
          return true;
        } else if (chat.receiver.name
            .toLowerCase()
            .contains(searchFieldTextEditingController.text.toLowerCase())) {
          return true;
        } else {
          return false;
        }
      },
    ).toList()
      ..sort(
        (chatA, chatB) =>
            chatB.lastMessageTimeStamp.compareTo(chatA.lastMessageTimeStamp),
      );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
                filled: true,
              ),
            ),
            child: TextField(
              controller: searchFieldTextEditingController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredChats.isEmpty
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text(
                    'Oops! No chats were found.',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(NewChatScreen.routeName),
                      child: const Text('Start a new chat!'))
                ])
              : ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: const AssetImage(
                              'assets/images/default_profile.png'),
                          foregroundImage:
                              filteredChats[index].receiver.profilePictureURL !=
                                      null
                                  ? NetworkImage(filteredChats[index]
                                      .receiver
                                      .profilePictureURL!)
                                  : null,
                          radius: 30,
                        ),
                        title: Text(filteredChats[index].receiver.name),
                        subtitle: Text(
                          filteredChats[index].lastMessageText,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color!
                                  .withOpacity(.5)),
                        ),
                        trailing: Text(
                          DateFormat.jm().format(
                              filteredChats[index].lastMessageTimeStamp),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color!
                                  .withOpacity(.5)),
                        ),
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          await Navigator.of(context).pushNamed(
                            MessageScreen.routeName,
                            arguments: filteredChats[index].receiver,
                          );
                          setState(() {
                            searchFieldTextEditingController.clear();
                          });
                        });
                  },
                ),
        ),
      ],
    );
  }
}
