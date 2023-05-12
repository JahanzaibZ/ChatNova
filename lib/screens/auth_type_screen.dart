import 'package:flutter/material.dart';

import './privacy_policy_screen.dart';
import './auth_screen.dart';
import '../helpers/auth_type.dart';

class AuthTypeScreen extends StatelessWidget {
  static const routeName = '/auth-type-screen';

  const AuthTypeScreen({super.key});

  void navigateToScreen(BuildContext context, AuthType authType) {
    Navigator.pushNamed(
      context,
      AuthScreen.routeName,
      arguments: authType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: deviceSize.height * .5,
              width: deviceSize.width,
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(
                          deviceSize.width * .3, deviceSize.height * .015),
                      bottomRight: Radius.elliptical(
                          deviceSize.width * .87, deviceSize.height * .2),
                    ),
                  ),
                  height: deviceSize.height * .5,
                  width: deviceSize.width,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ChatNOVA',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(
                      height: deviceSize.height * .08,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'Connect easily with your family and friends over countries',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            SizedBox(
              height: deviceSize.height * .5,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      fixedSize:
                          Size(deviceSize.width * .8, deviceSize.height * .07),
                    ),
                    onPressed: () => navigateToScreen(
                        context, AuthType.signInWithEmailAddress),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.email),
                        Text('Continue with email address'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: deviceSize.height * .05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: deviceSize.width * .3,
                        child: const Divider(),
                      ),
                      SizedBox(width: deviceSize.width * .05),
                      const Text('or'),
                      SizedBox(width: deviceSize.width * .05),
                      SizedBox(
                        width: deviceSize.width * .3,
                        child: const Divider(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: deviceSize.height * .05,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        fixedSize: Size(
                            deviceSize.width * .8, deviceSize.height * .07)),
                    onPressed: () => navigateToScreen(
                        context, AuthType.continueWithPhoneNumber),
                    child: const Text('Continue with Phone Number'),
                  ),
                  SizedBox(
                    height: deviceSize.height * .025,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, PrivacyPolicyScreen.routeName),
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
