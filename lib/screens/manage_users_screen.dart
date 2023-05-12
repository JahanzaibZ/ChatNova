import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/user_data_provider.dart';

class ManageUsersScreen extends StatefulWidget {
  static const routeName = '/manage-users-screen';

  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  var _manageBlock = false;
  var _isDeleteButtonEnabled = true;
  Future<void> _removeUser(
      AppUser user, UserDataProvider userDataProvider) async {
    var scaffoldMessnger = ScaffoldMessenger.of(context);
    scaffoldMessnger.showSnackBar(SnackBar(
        content:
            Text(_manageBlock ? 'Unblocking User...' : 'Removing Friend...')));
    setState(() {
      _isDeleteButtonEnabled = false;
    });
    await userDataProvider.addOrRemoveUserFriendsAndBlocks(
      block: _manageBlock,
      remove: true,
      user: user,
    );
    scaffoldMessnger.hideCurrentSnackBar();
    scaffoldMessnger.showSnackBar(SnackBar(
        content: Text(_manageBlock ? 'User Unblocked!' : 'Friend Removed!')));
    setState(() {
      _isDeleteButtonEnabled = true;
    });
  }

  Future<void> showAddDialog() {
    final deviceSize = MediaQuery.of(context).size;
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            dialogMenuItem(
              title: 'Add using Email Address',
              onPressed: () => Navigator.of(context).pop(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: deviceSize.width * .20,
                  child: const Divider(),
                ),
                SizedBox(width: deviceSize.width * .05),
                const Text('or'),
                SizedBox(width: deviceSize.width * .05),
                SizedBox(
                  width: deviceSize.width * .20,
                  child: const Divider(),
                ),
              ],
            ),
            dialogMenuItem(
              title: 'Import From Contacts',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget dialogMenuItem({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: onPressed,
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(title)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _manageBlock = ModalRoute.of(context)?.settings.arguments as bool;
    final userDataProvider = Provider.of<UserDataProvider>(context);
    var users = _manageBlock
        ? userDataProvider.userBlocks
        : userDataProvider.userFriends;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.25,
        leading: BackButton(
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          _manageBlock ? 'Blocked Users' : 'Friends',
          textScaleFactor: 1.25,
        ),
        centerTitle: true,
        actions: [
          if (!_manageBlock)
            IconButton(
              onPressed: () async {
                await showAddDialog();
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    const AssetImage('assets/images/default_profile.png'),
                foregroundImage: users[index].profilePictureURL != null
                    ? NetworkImage(users[index].profilePictureURL!)
                    : null,
                radius: 30,
              ),
              title: Text(users[index].name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_rounded),
                onPressed: _isDeleteButtonEnabled
                    ? () => _removeUser(users[index], userDataProvider)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
