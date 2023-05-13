import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_data_provider.dart';
import '../screens/profile_screen.dart';

Future<void> showAddByEmailDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      final formKey = GlobalKey<FormState>();
      var userEmail = 'NO_EMAIL';
      var isInvalidEmail = false;
      var isLoading = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return Form(
            key: formKey,
            child: SimpleDialog(
              title: const Text(
                'Enter the user email address',
                textAlign: TextAlign.center,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'e.g. john@gmail.com',
                    ),
                    onChanged: (newValue) {
                      if (isInvalidEmail) {
                        setState(() {
                          isInvalidEmail = false;
                        });
                      }
                      if (newValue.isNotEmpty) {
                        formKey.currentState!.validate();
                      }
                      userEmail = newValue;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email field cannot be empty';
                      } else if (isInvalidEmail) {
                        return 'User with this email address not found!';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 40,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(60, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final isValid = formKey.currentState!.validate();
                            if (isValid) {
                              debugPrint('Function Executed!');
                              final userDataProvider =
                                  Provider.of<UserDataProvider>(context,
                                      listen: false);
                              FocusScope.of(context).unfocus();
                              setState(() {
                                debugPrint('setState Executed!');
                                isLoading = true;
                              });
                              final user = await userDataProvider
                                  .fetchUnknownUserInfoByEmail(userEmail);
                              debugPrint('User: $user');
                              if (user != null && context.mounted) {
                                debugPrint('COndition executed!');
                                Navigator.of(context).pushReplacementNamed(
                                    ProfileScreen.routeName,
                                    arguments: user);
                              } else {
                                setState(() {
                                  isInvalidEmail = true;
                                  isLoading = false;
                                });
                                formKey.currentState!.validate();
                              }
                            }
                          },
                    child: Text(isLoading ? 'Searching...' : 'Search'),
                  ),
                )
              ],
            ),
          );
        },
      );
    },
  );
}
