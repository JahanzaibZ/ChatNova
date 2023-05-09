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

  @override
  Widget build(BuildContext context) {
    _manageBlock = ModalRoute.of(context)?.settings.arguments as bool;
    var userDataProvider = Provider.of<UserDataProvider>(context);
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
              onPressed: () {},
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
