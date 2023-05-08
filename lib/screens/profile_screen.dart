import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../widgets/profile_menu.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile-screen';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var receiver = ModalRoute.of(context)?.settings.arguments as AppUser;
    final mediaQuery = MediaQuery.of(context);
    final scaffoldBodyHeight = mediaQuery.size.height -
        kToolbarHeight -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: scaffoldBodyHeight * .5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  transitionOnUserGestures: true,
                  tag: receiver.id,
                  child: CircleAvatar(
                    radius: mediaQuery.devicePixelRatio * 40,
                    foregroundImage: receiver.profilePictureURL == null
                        ? null
                        : NetworkImage(receiver.profilePictureURL!),
                    backgroundImage: const AssetImage(
                      'assets/images/default_profile.png',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  receiver.name,
                  style: const TextStyle(fontSize: 40),
                ),
              ],
            ),
          ),
          SizedBox(
            height: scaffoldBodyHeight * .5,
            child: ProfileMenu(receiver: receiver),
          ),
        ],
      ),
    );
  }
}
