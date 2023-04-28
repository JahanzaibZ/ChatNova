import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataProvider with ChangeNotifier {
  final Map<String, dynamic> _userInfo = {
    'fullName': null,
    'profileImageURL': null,
    'dateOfBirth': null,
  };
  final List<String> _userFriends = [];

  Map<String, dynamic> get userInfo {
    return {..._userInfo};
  }

  set setUserInfo(Map<String, dynamic> userInfo) {
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
          .collection('data')
          .doc('profile')
          .set(userInfo);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getUserProfileInfo() async {
    try {
      var authInstance = FirebaseAuth.instance;
      var firestoreInstance = FirebaseFirestore.instance;
      var documentSnapshot = await firestoreInstance
          .collection('users')
          .doc(authInstance.currentUser!.uid)
          .collection('data')
          .doc('profile')
          .get();
      var snapshotData = documentSnapshot.data();
      if (snapshotData != null) {
        setUserInfo = snapshotData;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getUserFriends() async {
    try {
      var authInstance = FirebaseAuth.instance;
      var firestoreInstance = FirebaseFirestore.instance;
      var documentSnapshot = await firestoreInstance
          .collection('users')
          .doc(authInstance.currentUser!.uid)
          .collection('data')
          .doc('other')
          .get();
      var snapshotData = documentSnapshot.data();
      if (snapshotData != null) {
        for (String friend in snapshotData['friends']) {
          _userFriends.add(friend);
        }
      }
    } catch (error) {
      rethrow;
    }
  }
}
