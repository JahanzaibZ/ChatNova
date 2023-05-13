import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/auth_type.dart';
import '../helpers/auth_exception.dart';

class AuthProvider with ChangeNotifier {
  final _authInstance = FirebaseAuth.instance;
  final Map<String, dynamic> _userCredentials = {
    'phone': null,
    'email': null,
    'password': null,
  };

  Map<String, dynamic> get userCredentials {
    return {..._userCredentials};
  }

  set setUserCredentials(Map<String, dynamic> userCreds) {
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
    return {..._otpCredentials};
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

  Future<dynamic> isNewUser([bool? setKey]) async {
    try {
      var authInstance = FirebaseAuth.instance;
      var firestoreInstance = FirebaseFirestore.instance
          .collection('users')
          .doc(authInstance.currentUser!.uid);
      if (setKey == true) {
        await firestoreInstance.set(
          {'isNewUser': setKey},
          SetOptions(merge: true),
        );
        notifyListeners();
      } else if (setKey == false) {
        await firestoreInstance.set(
          {'isNewUser': setKey},
          SetOptions(merge: true),
        );
        notifyListeners();
      } else {
        var snapshot = await firestoreInstance.get();
        var data = snapshot.data();
        if (data != null && data.containsKey('isNewUser')) {
          return data['isNewUser'];
        } else {
          return true;
        }
      }
    } catch (error) {
      return true;
    }
  }

  Future<void> sendOTP([int? resendToken]) async {
    try {
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
    } on FirebaseAuthException catch (error) {
      throw AuthException('${error.message}\nError code: ${error.code}');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> authenticateWithEmailAndPassword(AuthType authType) async {
    try {
      if (authType == AuthType.signUpWithEmailAddress) {
        await _authInstance.createUserWithEmailAndPassword(
          email: _userCredentials['email']!,
          password: _userCredentials['password']!,
        );

        await isNewUser(true);
      } else {
        await _authInstance.signInWithEmailAndPassword(
          email: _userCredentials['email']!,
          password: _userCredentials['password']!,
        );
      }
      return;
    } on FirebaseAuthException catch (error) {
      String message;
      if (error.code == 'email-already-in-use') {
        message = 'An account with this email address already exist!';
      } else if (error.code == 'invalid-email') {
        message = 'Invalid email address or format, please try again!';
      } else if (error.code == 'operation-not-allowed') {
        message = 'Operation now allowed!\nPlease contact customer support.';
      } else if (error.code == 'weak-password') {
        message =
            'Week password! Please enter a strong password and try again.';
      } else if (error.code == 'user-disabled') {
        message = 'Account disabled! Please contact customer support.';
      } else if (error.code == 'user-not-found') {
        message = 'Account with the specified email address not found!';
      } else if (error.code == 'wrong-password') {
        message =
            'Incorrect password! Please enter correct password and try again.';
      } else {
        message =
            'Unexpected Error! Code: ${error.code}, message: ${error.message}\n\n Please contact customer support.';
      }
      throw AuthException(message);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> authenticateWithCredentials(String smsCode) async {
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: _otpCredentials['verificationId'] as String,
          smsCode: smsCode);
      var userCreds =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      if (userCreds.additionalUserInfo?.isNewUser == true) {
        await isNewUser(true);
      }
    } on FirebaseAuthException catch (error) {
      String message;
      if (error.code == 'account-exists-with-different-credential') {
        message = 'Account already exists with different credential!';
      } else if (error.code == 'invalid-credential') {
        message = 'Credentials are invalid.';
      } else if (error.code == 'operation-not-allowed') {
        message = 'Operation now allowed!';
      } else if (error.code == 'user-disabled') {
        message = 'Account is disbaled.';
      } else if (error.code == 'user-not-found') {
        message = 'User not found.';
      } else if (error.code == 'wrong-password') {
        message = 'Wrong Password.';
      } else if (error.code == 'invalid-verification-code') {
        message =
            'Incorrect verfication code, please enter the correct code and try again.';
      } else if (error.code == 'invalid-verification-id') {
        message = 'Invalid verificatio id.';
      } else {
        message =
            'Unexpected Error! Code: ${error.code}, message: ${error.message}\n\n Please contact customer support.';
      }
      throw AuthException(message);
    } catch (error) {
      rethrow;
    }
  }
}
