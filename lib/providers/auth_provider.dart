import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/auth_type.dart';

class AuthProvider with ChangeNotifier {
  final _authInstance = FirebaseAuth.instance;
  final Map<String, String?> _userCredentials = {
    'phone': null,
    'email': null,
    'password': null,
  };

  Map<String, Object?> get userCredentials {
    var userCreds = _userCredentials;
    return userCreds;
  }

  set setUserCredentials(Map<String, String?> userCreds) {
    if (userCreds['phone'] != null) {
      _userCredentials['phone'] = userCreds['phone'];
    }
    if (userCreds['email'] != null) {
      _userCredentials['email'] = userCreds['email'];
    }
    if (userCreds['password'] != null) {
      _userCredentials['password'] = userCreds['password'];
    }
  }

  final Map<String, Object?> _otpCredentials = {
    'verificationId': null,
    'resendToken': null,
    'verificationComplete': false,
    'isAuthenticated': false,
  };

  Map<String, Object?> get otpCredentials {
    var optCreds = _otpCredentials;
    return optCreds;
  }

  set setOtpCredentials(Map<String, Object?> otpCreds) {
    if (otpCreds['verificationId'] != null) {
      _otpCredentials['verificationId'] = otpCreds['verificationId'];
    }
    if (otpCreds['resendToken'] != null) {
      _otpCredentials['resendToken'] = otpCreds['resendToken'];
    }
    if (otpCreds['verificationComplete'] != null) {
      _otpCredentials['verificationComplete'] =
          otpCreds['verificationComplete'];
    }
    if (otpCreds['isAuthenticated'] != null) {
      _otpCredentials['isAuthenticated'] = otpCreds['isAuthenticated'];
    }
    notifyListeners();
  }

  Future<void> sendOTP([int? resendToken]) async {
    var completer = Completer<void>();
    // Completer<void>() used to wait for callback functions to complete as FirebaseAuth.instance.verifyPhoneNumber() does not wait for the request to be verified but only waits for request to be sent, which is its normal behaviour.
    await _authInstance.verifyPhoneNumber(
      phoneNumber: _userCredentials['phone'],
      verificationCompleted: (phoneAuthCredential) async {
        // Commented until a solution is found

        // debugPrint('Executed Verification Completed Callback!');
        // _otpCredentials['verificationComplete'] = true;
        // notifyListeners();
        // // Show Dialog here
        // await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        // _otpCredentials['isAuthenticated'] = true;
        // notifyListeners();
        // // Pop screens here
        // completer.complete();
      },
      verificationFailed: (error) {
        debugPrint('Executed Verification Failed Callback!');
        completer.completeError(error);
      },
      codeSent: (verificationId, forceResendingToken) {
        debugPrint('Executed Code Sent Callback!');
        _otpCredentials['verificationId'] = verificationId;
        _otpCredentials['resendToken'] = forceResendingToken;
        completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        debugPrint('Executed codeAutoRetrievalTimeout Callback!');
      },
      forceResendingToken: resendToken,
    );
    _otpCredentials['verificationComplete'] = false;
    _otpCredentials['isAuthenticated'] = false;
    return completer.future;
  }

  Future<void> authenticateWithEmailAndPassword(AuthType authType) async {
    if (authType == AuthType.signUpWithEmailAddress) {
      await _authInstance.createUserWithEmailAndPassword(
        email: _userCredentials['email']!,
        password: _userCredentials['password']!,
      );
    } else {
      await _authInstance.signInWithEmailAndPassword(
        email: _userCredentials['email']!,
        password: _userCredentials['password']!,
      );
    }
    return;
  }
}
