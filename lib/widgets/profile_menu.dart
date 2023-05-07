import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/user_data_provider.dart';

class ProfileMenu extends StatefulWidget {
  final AppUser receiver;

  const ProfileMenu({required this.receiver, super.key});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  var areButtonEnabled = true;

  Widget showTextButton({
    bool block = false,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton.icon(
        onPressed: areButtonEnabled ? onPressed : null,
        style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(double.maxFinite, double.minPositive),
            splashFactory: NoSplash.splashFactory,
            foregroundColor: Theme.of(context).textTheme.bodyMedium?.color),
        icon: Icon(
          icon,
          size: 28,
        ),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void showSnackBar(String content) {
    var scaffoldMessender = ScaffoldMessenger.of(context);
    scaffoldMessender.hideCurrentSnackBar();
    scaffoldMessender.showSnackBar(
      SnackBar(content: Text(content)),
    );
  }

  @override
  Widget build(BuildContext context) {
    var userDataProvider = Provider.of<UserDataProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          indent: 40,
          endIndent: 40,
        ),
        userDataProvider.findFriendById(widget.receiver.id)
            ? showTextButton(
                icon: Icons.person_remove_rounded,
                label: 'Remove from Friend List',
                onPressed: () async {
                  setState(() {
                    areButtonEnabled = false;
                  });
                  showSnackBar('Removing Friend...');
                  await userDataProvider.addOrRemoveUserFriendsAndBlocks(
                    remove: true,
                    user: widget.receiver,
                  );
                  setState(() {
                    areButtonEnabled = true;
                  });
                  showSnackBar('Friend Removed!');
                },
              )
            : showTextButton(
                icon: Icons.person_add_alt_rounded,
                label: 'Add to Friend List',
                onPressed: () async {
                  setState(() {
                    areButtonEnabled = false;
                  });
                  showSnackBar('Adding Friend...');
                  await userDataProvider.addOrRemoveUserFriendsAndBlocks(
                    user: widget.receiver,
                  );
                  setState(() {
                    areButtonEnabled = true;
                  });
                  showSnackBar('Friend Added!');
                },
              ),
        userDataProvider.findBlockById(widget.receiver.id)
            ? showTextButton(
                icon: Icons.person_off_rounded,
                label: 'Unblock User',
                onPressed: () async {
                  setState(() {
                    areButtonEnabled = false;
                  });
                  showSnackBar('Unblocking User...');
                  await userDataProvider.addOrRemoveUserFriendsAndBlocks(
                    remove: true,
                    block: true,
                    user: widget.receiver,
                  );
                  setState(() {
                    areButtonEnabled = true;
                  });
                  showSnackBar('User Unblocked!');
                },
              )
            : showTextButton(
                icon: Icons.person_off_rounded,
                label: 'Block User',
                onPressed: () async {
                  setState(() {
                    areButtonEnabled = false;
                  });
                  showSnackBar('Blocking User...');
                  await userDataProvider.addOrRemoveUserFriendsAndBlocks(
                    block: true,
                    user: widget.receiver,
                  );
                  setState(() {
                    areButtonEnabled = true;
                  });
                  showSnackBar('User Blocked!');
                },
              ),
      ],
    );
  }
}
