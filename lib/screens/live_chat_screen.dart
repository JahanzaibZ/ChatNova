import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_data_provider.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/live_chat_message_screen.dart';
import '../widgets/custom_dialog.dart';

class LiveChatScreen extends StatelessWidget {
  const LiveChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userInterests =
        Provider.of<UserDataProvider>(context, listen: false).user.interests;
    final deviceSize = MediaQuery.of(context).size;
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Your interests:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              userInterests.join('\n'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pushNamed(ProfileSetupScreen.routeName, arguments: true),
            child: const Text('Edit Interests!'),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: Size(deviceSize.width * .4, deviceSize.height * .06),
              ),
              onPressed: () async {
                final userDataProvider =
                    Provider.of<UserDataProvider>(context, listen: false);
                var liveChatUser = userDataProvider.liveChatUser;
                showCustomDialog(context,
                    content: 'Searching for users...', showActionButton: false);
                await userDataProvider.setUserLiveChatStatus();
                final liveChatSubscription = await userDataProvider
                    .listenAndFetchLiveChatUsersFromDatabase();
                for (var i = 0; i < 6; i++) {
                  liveChatUser = userDataProvider.liveChatUser;
                  if (liveChatUser.id == 'NO_ID') {
                    await Future.delayed(const Duration(seconds: 1));
                  } else {
                    break;
                  }
                }
                if (liveChatUser.id == 'NO_ID' && context.mounted) {
                  liveChatSubscription.cancel();
                  Navigator.of(context).pop();
                  showCustomDialog(context,
                      title: 'User Not Found!',
                      content:
                          'No user with matching interets found, please try again later',
                      showActionButton: true);
                  userDataProvider.setUserLiveChatStatus(true);
                } else {
                  final liveChatMessageSubscription = await userDataProvider
                      .listenAndReadLiveMessasgesFromFirestore(liveChatUser.id);
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(
                        LiveChatMessageScreen.routeName,
                        arguments: {
                          'liveChatSubscription': liveChatSubscription,
                          'liveChatMessageSubscription':
                              liveChatMessageSubscription,
                        });
                  }
                }
              },
              child: const Text('Connect!'))
        ],
      ),
    );
  }
}
