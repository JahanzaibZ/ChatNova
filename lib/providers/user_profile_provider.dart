import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileProvider with ChangeNotifier {
  final Map<String, String?> _userInfo = {
    'fullName': null,
    'profileImageURL': null,
    'dateOfBirth': null,
  };

  Map<String, String?> get userInfo {
    return {..._userInfo};
  }

  set setUserInfo(Map<String, String?> userInfo) {
    if (userInfo['fullName'] != null) {
      _userInfo['fullName'] = userInfo['fullName'];
    }
    if (userInfo['profileImageURL'] != null) {
      _userInfo['profileImageURL'] = userInfo['profileImageURL'];
    }
    if (userInfo['dateOfBirth'] != null) {
      _userInfo['dateOfBirth'] = userInfo['dateOfBirth'];
    }
  }

  Future<void> uploadProfileImage(File pickedImage) async {
    try {
      var authInstance = FirebaseAuth.instance;
      var storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${authInstance.currentUser!.uid}.jpg');
      await storageRef.putFile(pickedImage).whenComplete(() async {
        _userInfo['profileImageURL'] = await storageRef.getDownloadURL();
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> setUserProfileInfo() async {
    try {
      var authInstance = FirebaseAuth.instance;
      var firestoreInstance = FirebaseFirestore.instance;
      await firestoreInstance
          .collection('users')
          .doc(authInstance.currentUser!.uid)
          .collection('profile')
          .doc('data')
          .set(userInfo);
    } catch (error) {
      rethrow;
    }
  }
}
