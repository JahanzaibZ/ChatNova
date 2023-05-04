import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        } else if (chat.receiver!.name!
            .toLowerCase()
            .contains(searchFieldTextEditingController.text.toLowerCase())) {
          return true;
        } else {
          return false;
        }
      },
    ).toList();
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
          child: ListView.builder(
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        const AssetImage('assets/images/default_profile.png'),
                    foregroundImage: filteredChats[index]
                                .receiver!
                                .profilePictureURL !=
                            null
                        ? NetworkImage(
                            filteredChats[index].receiver!.profilePictureURL!)
                        : null,
                    radius: 30,
                  ),
                  title: Text(filteredChats[index].receiver!.name ?? 'Unknown'),
                  subtitle: Text(
                    filteredChats[index].lastMessageText ?? 'Unknown',
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
