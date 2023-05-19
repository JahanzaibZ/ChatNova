import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:provider/provider.dart';

import '../providers/user_data_provider.dart';
import '../widgets/custom_dialog.dart';

class ManageSubscriptionListTile extends StatelessWidget {
  const ManageSubscriptionListTile({super.key});
  @override
  Widget build(BuildContext context) {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final user = Provider.of<UserDataProvider>(context).user;
    return ListTile(
      leading: const Icon(
        Icons.add_card_rounded,
        // size: 30,
      ),
      title: Text(user.isPro ? 'Manage Pro Account' : 'Upgrade to Pro Account'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        user.isPro
            ? showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text(
                    'Downgrade',
                    textAlign: TextAlign.center,
                  ),
                  content: const Text(
                    'Do you want to downgrade to Standard Account?',
                    textAlign: TextAlign.center,
                  ),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  actions: [
                    TextButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(100, 50),
                      ),
                      onPressed: () async {
                        userDataProvider.setUserInfo =
                            user.copyWith(isPro: false);
                        Navigator.of(dialogContext).pop();
                        showCustomDialog(context,
                            content: 'Downgrading...', showActionButton: false);
                        await userDataProvider.fetchAndSetUserProfileInfo();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          await showCustomDialog(context,
                              title: 'Account Downgraded!',
                              content: 'Account Succesfully Downgraded!',
                              showActionButton: true);
                        }
                      },
                      child: const Text('Downgrade'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(100, 50),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    )
                  ],
                ),
              )
            : showDialog(
                context: context,
                builder: (dialogContext) => SimpleDialog(
                  title: const Text(
                    'Upgrade to Pro!',
                    textAlign: TextAlign.center,
                  ),
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 30, right: 30),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          userDataProvider.setUserInfo =
                              user.copyWith(isPro: true);

                          Navigator.of(dialogContext).pop();
                          showCustomDialog(context,
                              content: 'Upgrading...', showActionButton: false);
                          await userDataProvider.fetchAndSetUserProfileInfo();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => UsePaypal(
                                    sandboxMode: true,
                                    clientId:
                                        "AW1TdvpSGbIM5iP4HJNI5TyTmwpY9Gv9dYw8_8yW5lYIbCqf326vrkrp0ce9TAqjEGMHiV3OqJM_aRT0",
                                    secretKey:
                                        "EHHtTDjnmTZATYBPiGzZC_AZUfMpMAzj2VZUeqlFUrRJA_C0pQNCxDccB5qoRQSEdcOnnKQhycuOWdP9",
                                    returnURL: "https://samplesite.com/return",
                                    cancelURL: "https://samplesite.com/cancel",
                                    transactions: const [
                                      {
                                        "amount": {
                                          "total": '4.99',
                                          "currency": "USD",
                                          "details": {
                                            "subtotal": '4.99',
                                            "shipping": '0',
                                            "shipping_discount": 0
                                          }
                                        },
                                        "description":
                                            "Payment for pro account subscription.",
                                      }
                                    ],
                                    note:
                                        "Contact us for any questions on your order.",
                                    onSuccess: (Map params) async {
                                      debugPrint("onSuccess: $params");
                                    },
                                    onError: (error) {
                                      debugPrint("onError: $error");
                                    },
                                    onCancel: (params) {
                                      debugPrint('cancelled: $params');
                                    }),
                              ),
                            );
                          }
                          // setState(() {});
                        },
                        icon: const Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Icon(Icons.paypal_rounded),
                        ),
                        label: const Padding(
                          padding: EdgeInsets.only(
                            top: 15,
                            bottom: 15,
                            right: 15,
                            left: 10,
                          ),
                          child: Text('Pay with Paypal'),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 30, right: 30),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    )
                  ],
                ),
              );
      },
    );
  }
}

// void manageSubscriptionDialog(BuildContext context) {
//   final userDataProvider =
//       Provider.of<UserDataProvider>(context, listen: false);
//   final user = userDataProvider.user;
  
// }
