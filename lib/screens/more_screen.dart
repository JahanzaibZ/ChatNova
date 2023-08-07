import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/profile_setup_screen.dart';
import '../screens/manage_users_screen.dart';
import '../providers/user_data_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scaffoldBodyHeight = mediaQuery.size.height -
        kToolbarHeight -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final user = userDataProvider.user;
    return Column(
      children: [
        SizedBox(
          height: scaffoldBodyHeight * .45,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
              onTap: () => Navigator.of(context).pushNamed(
                ProfileSetupScreen.routeName,
                arguments: true,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                height: scaffoldBodyHeight * .2,
                child: ClipOval(
                  child: user.profilePictureURL != null
                      ? FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder: const AssetImage(
                              'assets/images/default_profile.png'),
                          image: NetworkImage(user.profilePictureURL!),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/default_profile.png'),
                        )
                      : Image.asset('assets/images/default_profile.png'),
                ),
              ),
            ),
            Text(
              user.name,
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              user.phoneNumber ?? user.emailAddress ?? 'Unknown',
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: IconButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  ProfileSetupScreen.routeName,
                  arguments: true,
                ),
                icon: const Icon(Icons.mode_edit_rounded),
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.group_rounded,
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
                height: 20,
                child: Divider(),
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
          ),
        ),
      ],
    );
  }
}
