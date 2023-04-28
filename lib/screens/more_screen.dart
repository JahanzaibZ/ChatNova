import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/user_data_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var authInstance = FirebaseAuth.instance;
    var userInfo = Provider.of<UserDataProvider>(context).userInfo;
    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage:
                const AssetImage('assets/images/default_profile.png'),
            foregroundImage: userInfo['profileImageURL'] != null
                ? NetworkImage(userInfo['profileImageURL']!)
                : null,
            radius: 30,
          ),
          title: Text(userInfo['fullName'] ?? 'Unknown'),
          subtitle: Text(
            authInstance.currentUser?.phoneNumber ??
                authInstance.currentUser?.email ??
                'Unknown',
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.account_circle_outlined,
            // size: 30,
          ),
          title: Text('Account'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.chat_bubble_outline,
            // size: 30,
          ),
          title: Text('Chats'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const SizedBox(
          height: 10,
        ),
        const ListTile(
          leading: Icon(
            Icons.wb_sunny_outlined,
            // size: 30,
          ),
          title: Text('Appearance'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.notifications_outlined,
            // size: 30,
          ),
          title: Text('Notification'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.privacy_tip_outlined,
            // size: 30,
          ),
          title: Text('Privacy'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.folder_outlined,
            // size: 30,
          ),
          title: Text('Data Usage'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const Divider(
          indent: 20,
          endIndent: 20,
        ),
        const ListTile(
          leading: Icon(
            Icons.help_outline,
            // size: 30,
          ),
          title: Text('Help'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.mail_outline,
            // size: 30,
          ),
          title: Text('Invite your Friends'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}
