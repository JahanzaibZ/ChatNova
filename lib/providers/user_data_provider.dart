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
  final List<Map<String, dynamic>> _userFriends = [];

  Map<String, dynamic> get userInfo {
    return {..._userInfo};
  }

  List<Map<String, dynamic>> get userFriends {
    return [..._userFriends];
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

  // set addUserFriend(String friendId) {
  //   _userFriends.add(friendId);
  //   fetchAndSetUserFriends();
  // }

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
      await fetchAndSetUserFriends(onlyFetch: true);
      if (snapshotData != null) {
        setUserInfo = snapshotData;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetUserFriends({bool onlyFetch = false}) async {
    try {
      var authInstance = FirebaseAuth.instance;
      var firestoreInstance = FirebaseFirestore.instance;
      var firestoreFriendsPath = firestoreInstance
          .collection('users')
          .doc(authInstance.currentUser!.uid)
          .collection('data')
          .doc('other');
      if (!onlyFetch) {
        await firestoreFriendsPath.set({
          'friends': _userFriends.map((friend) => friend['friendId']).toList()
        });
      }
      var documentSnapshot = await firestoreFriendsPath.get();
      var snapshotData = documentSnapshot.data();
      // debugPrint(
      //     'snapshotData: ${snapshotData!['friends']}\n_userFriendsMapping: ${_userFriends.map((friend) => friend['friendId']).toList()}');
      // debugPrint(
      //     'Condition: ${_userFriends.map((friend) => friend['friendId']).toList() != snapshotData['friends'] as List<dynamic>}');
      if (snapshotData != null) {
        for (String friendId in snapshotData['friends']) {
          documentSnapshot = await firestoreInstance
              .collection('users')
              .doc(friendId)
              .collection('data')
              .doc('profile')
              .get();
          var documentData = documentSnapshot.data();
          if (documentData != null) {
            _userFriends.clear();
            _userFriends.add({
              'friendId': friendId,
              'friendName': documentData['fullName'],
              'friendImageURL': documentData['profileImageURL']
            });
          }
        }
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error occured! $error');
      rethrow;
    }
  }
}
