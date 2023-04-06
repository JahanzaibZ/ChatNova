import 'package:flutter/material.dart';

import '../helpers/auth_type.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var passwordVisibility = false;
  var isInit = true;

  @override
  Widget build(BuildContext context) {
    final authType =
        ModalRoute.of(context)?.settings.arguments ?? AuthType.signIn;
    final mediaQuery = MediaQuery.of(context);
    final scaffoldBodyHeight =
        mediaQuery.size.height - kToolbarHeight - mediaQuery.padding.top;
    if (authType != AuthType.signIn && isInit) {
      passwordVisibility = true;
      isInit = false;
    }
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: scaffoldBodyHeight,
        width: mediaQuery.size.width,
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: scaffoldBodyHeight * .2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    authType == AuthType.signIn ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: mediaQuery.size.height * .02,
                  ),
                  if (authType != AuthType.signIn)
                    Text(
                      authType == AuthType.signUpWithEmailAddress
                          ? 'with Email Address'
                          : 'with Phone Number',
                    ),
                ],
              ),
            ),
            SizedBox(
              height: scaffoldBodyHeight * .4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    keyboardType: authType == AuthType.signUpWithPhoneNumber
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: authType == AuthType.signIn
                          ? 'Enter your email or phone number'
                          : authType == AuthType.signUpWithEmailAddress
                              ? 'Enter your email address'
                              : 'Enter your phone number',
                      labelText: authType == AuthType.signIn
                          ? 'Email/Phone Number'
                          : authType == AuthType.signUpWithEmailAddress
                              ? 'Email Address'
                              : 'Phone Number',
                    ),
                  ),
                  SizedBox(
                    height: mediaQuery.size.height * .04,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: passwordVisibility ? false : true,
                    decoration: InputDecoration(
                      hintText: authType == AuthType.signIn
                          ? 'Enter your password'
                          : 'Enter a strong password',
                      labelText: 'Password',
                      suffixIcon: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => setState(() {
                          passwordVisibility = !passwordVisibility;
                        }),
                        child: Icon(passwordVisibility
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: scaffoldBodyHeight * .4,
              width: mediaQuery.size.width,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(mediaQuery.size.width * .4,
                              mediaQuery.size.height * .07),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () {},
                      child: Text(
                          authType == AuthType.signIn ? 'Sign In' : 'Sign Up'),
                    )
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
