import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/resend_otp_button.dart';
import '../widgets/custom_dialog.dart';
import '../helpers/auth_exception.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp-screen';

  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  var _smsCode = '000000';
  var _isLoading = false;
  var _isAuthenticated = false;

  Future<void> _confirmOtp(AuthProvider authProvider) async {
    try {
      var isValid = _formKey.currentState!.validate();
      if (isValid) {
        _formKey.currentState!.save();
        FocusScope.of(context).unfocus();
        setState(() {
          _isLoading = true;
        });
        showCustomDialog(context,
            content: 'Loading...', showActionButton: false);
        await authProvider.authenticateWithCredentials(_smsCode);
        setState(() {
          _isAuthenticated = true;
        });
        if (mounted) {
          Navigator.of(context).popUntil(
            (route) => route.isFirst,
          );
        }
      }
    } on AuthException catch (error) {
      Navigator.of(context).pop();
      showCustomDialog(
        context,
        title: 'Error occured!',
        content: error.toString(),
        showActionButton: true,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      Navigator.of(context).pop();
      showCustomDialog(
        context,
        title: 'Unknown error!',
        content: error.toString(),
        showActionButton: true,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scaffoldBodyHeight = mediaQuery.size.height -
        kToolbarHeight -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // debugPrint(receivedArgs.toString());
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * .08),
        height: scaffoldBodyHeight,
        width: mediaQuery.size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: scaffoldBodyHeight * .3,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 32,
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
                          'We have sent you an SMS with the code at ${authProvider.userCredentials['phone']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(.7),
                          ),
                        ),
                      ),
                    ]),
              ),
              SizedBox(
                height: scaffoldBodyHeight * .4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6)
                        ],
                        // maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Confirmation Code',
                          // counterText: '',
                        ),
                        onSaved: (newValue) {
                          _smsCode = newValue!;
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 6) {
                            return 'Please enter the the 6 digit code';
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ResendOtpButton(isAuthenticated: _isAuthenticated)
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: scaffoldBodyHeight * .3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(mediaQuery.size.width * .4,
                          mediaQuery.size.height * .07),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed:
                        _isLoading ? null : () => _confirmOtp(authProvider),
                    child: const Text('Confirm'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
