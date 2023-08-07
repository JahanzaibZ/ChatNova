import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import './opt_screen.dart';
import '../widgets/custom_dialog.dart';
import '../providers/auth_provider.dart';
import '../helpers/auth_type.dart';
import '../helpers/auth_exception.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordTextFieldFocusNode = FocusNode();

  var _authType = AuthType.continueWithPhoneNumber;
  var _passwordVisibility = false;
  var _isInit = true;
  var _isLoading = false;

  Future<void> _submitForm() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      var isValid = _formKey.currentState!.validate();
      var continueAnyway = false;
      if (isValid) {
        _formKey.currentState!.save();
        FocusScope.of(context).unfocus();
        setState(() {
          _isLoading = true;
        });
        if (_authType == AuthType.continueWithPhoneNumber) {
          await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Important Note!',
                    textAlign: TextAlign.center,
                  ),
                  content: const Text(
                    'Apologies for the inconvenience, but since our app has not been published on Google Play, you may be redirected to a web browser for reCaptcha verification. This is a requirement imposed by Google. Thank you for your understanding.',
                    textAlign: TextAlign.justify,
                    textScaleFactor: .95,
                  ),
                  actionsPadding: const EdgeInsets.only(bottom: 20),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                            MediaQuery.of(context).size.width * .25,
                            MediaQuery.of(context).size.height * .06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        continueAnyway = true;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                );
              });
          if (continueAnyway && mounted) {
            showCustomDialog(context,
                content: 'Loading...', showActionButton: false);
            await authProvider.sendOTP();
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              Navigator.of(context).popAndPushNamed(
                OtpScreen.routeName,
              );
            }
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          showCustomDialog(context,
              content: 'Loading...', showActionButton: false);
          await authProvider.authenticateWithEmailAndPassword(_authType);
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      }
    } on AuthException catch (error) {
      Navigator.of(context).pop();
      await showCustomDialog(
        context,
        title: 'Error Occured!',
        content: error.toString(),
        showActionButton: true,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
      showCustomDialog(
        context,
        title: 'Unknown Error!',
        content: error.toString(),
        showActionButton: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit) {
      _authType = ModalRoute.of(context)?.settings.arguments as AuthType;
      _isInit = !_isInit;
    }
    final mediaQuery = MediaQuery.of(context);
    final scaffoldBodyHeight = mediaQuery.size.height -
        kToolbarHeight -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * .08),
        height: scaffoldBodyHeight,
        width: mediaQuery.size.width,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: scaffoldBodyHeight * .3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _authType == AuthType.continueWithPhoneNumber
                            ? 'Enter Your Phone Number'
                            : _authType == AuthType.signInWithEmailAddress
                                ? 'Sign In'
                                : 'Sign Up',
                        style: TextStyle(
                          fontSize:
                              _authType == AuthType.continueWithPhoneNumber
                                  ? 26
                                  : 42,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: mediaQuery.size.height * .02,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _authType == AuthType.continueWithPhoneNumber
                              ? 'Please confirm your country code and enter your phone number'
                              : 'with Email Address',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: scaffoldBodyHeight * .4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_authType != AuthType.continueWithPhoneNumber)
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email address',
                            labelText: 'Email Address',
                          ),
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_passwordTextFieldFocusNode),
                          onSaved: (newValue) {
                            authProvider.setUserCredentials = {
                              'email': newValue!.trim()
                            };
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email field cannot be empty';
                            }
                            return null;
                          },
                        ),
                      if (_authType == AuthType.continueWithPhoneNumber)
                        IntlPhoneField(
                          showCountryFlag: false,
                          initialCountryCode: 'PK',
                          flagsButtonPadding: const EdgeInsets.only(left: 10),
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          onSaved: (newValue) {
                            authProvider.setUserCredentials = {
                              'phone': newValue?.completeNumber
                            };
                          },
                        ),
                      if (_authType != AuthType.continueWithPhoneNumber)
                        SizedBox(
                          height: mediaQuery.size.height *
                              (_authType == AuthType.continueWithPhoneNumber
                                  ? .025
                                  : .05),
                        ),
                      if (_authType != AuthType.continueWithPhoneNumber)
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _passwordVisibility ? false : true,
                          focusNode: _passwordTextFieldFocusNode,
                          decoration: InputDecoration(
                            hintText:
                                _authType == AuthType.signInWithEmailAddress
                                    ? 'Enter your password'
                                    : 'Enter a strong password',
                            labelText: 'Password',
                            suffixIcon: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () => setState(() {
                                _passwordVisibility = !_passwordVisibility;
                              }),
                              child: Icon(_passwordVisibility
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                          ),
                          onSaved: (newValue) => authProvider
                              .setUserCredentials = {'password': newValue},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password field cannot be empty';
                            } else if (_authType !=
                                    AuthType.signInWithEmailAddress &&
                                value.length < 7) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                        ),
                      if (_authType != AuthType.continueWithPhoneNumber)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed:
                                  _authType == AuthType.signInWithEmailAddress
                                      ? () {}
                                      : null,
                              child: Text(
                                  _authType == AuthType.signInWithEmailAddress
                                      ? 'Forgot password?'
                                      : ''),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: scaffoldBodyHeight * .3,
                  width: mediaQuery.size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(mediaQuery.size.width * .4,
                                  mediaQuery.size.height * .07),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submitForm,
                            child: Text(_authType ==
                                    AuthType.continueWithPhoneNumber
                                ? 'Continue'
                                : _authType == AuthType.signInWithEmailAddress
                                    ? 'Sign In'
                                    : 'Sign Up'),
                          )
                        ],
                      ),
                      SizedBox(
                        height: scaffoldBodyHeight * .08,
                      ),
                      if (_authType != AuthType.continueWithPhoneNumber)
                        Text(
                          _authType == AuthType.signInWithEmailAddress
                              ? 'Don\'t have an account?'
                              : 'Already have a account?',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (_authType != AuthType.continueWithPhoneNumber)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_authType ==
                                  AuthType.signInWithEmailAddress) {
                                _authType = AuthType.signUpWithEmailAddress;
                              } else {
                                _authType = AuthType.signInWithEmailAddress;
                              }
                            });
                          },
                          style: TextButton.styleFrom(),
                          child: Text(
                            _authType == AuthType.signInWithEmailAddress
                                ? 'Register now!'
                                : 'Log in!',
                            style: const TextStyle(fontSize: 12),
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
