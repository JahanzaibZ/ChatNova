import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/profile_setup_screen.dart';
import '../screens/manage_users_screen.dart';
import '../providers/user_data_provider.dart';
import '../widgets/manage_subscription_list_tile.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final user = userDataProvider.user;
    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage:
                const AssetImage('assets/images/default_profile.png'),
            foregroundImage: user.profilePictureURL != null
                ? NetworkImage(user.profilePictureURL!)
                : null,
            radius: 30,
          ),
          title: Text(user.name),
          subtitle: Text(
            user.phoneNumber ?? user.emailAddress ?? 'Unknown',
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () => Navigator.of(context).pushNamed(
            ProfileSetupScreen.routeName,
            arguments: true,
          ),
        ),
        const ManageSubscriptionListTile(),
        ListTile(
          leading: const Icon(
            Icons.group_rounded,
            // size: 30,
          ),
          title: const Text('Manage Friends'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () => Navigator.of(context).pushNamed(
            ManageUsersScreen.routeName,
            arguments: false,
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.group_off_rounded,
          ),
          title: const Text('Manage Blocked Users'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () => Navigator.of(context).pushNamed(
            ManageUsersScreen.routeName,
            arguments: true,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const ListTile(
          leading: Icon(
            Icons.wb_sunny_outlined,
          ),
          title: Text('Appearance'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.notifications_outlined,
          ),
          title: Text('Notification'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.privacy_tip_outlined,
          ),
          title: Text('Privacy'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.folder_outlined,
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
          ),
          title: Text('Help'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        const ListTile(
          leading: Icon(
            Icons.mail_outline,
          ),
          title: Text('Invite your Friends'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}
