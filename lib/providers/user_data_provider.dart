import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserDataProvider with ChangeNotifier {
  var _user = AppUser();
  final List<AppUser> _userFriends = [];

  AppUser get user {
    return _user;
  }

  List<AppUser> get userFriends {
    return [..._userFriends];
  }

  set setUserInfo(AppUser user) {
    _user = user;
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
        _user = _user.copyWith(
            profilePictureURL: await storageRef.getDownloadURL());
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
          .set({
        'name': _user.name,
        'emailAddress': _user.emailAddress,
        'phoneNumber': _user.phoneNumber,
        'profilePictureURL': _user.profilePictureURL,
        'dateOfBirth': Timestamp.fromDate(_user.dateOfBirth!),
        'isPro': _user.isPro,
      });
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
        _user = AppUser(
          id: authInstance.currentUser!.uid,
          name: snapshotData['name'],
          emailAddress: snapshotData['emailAddress'],
          phoneNumber: snapshotData['phoneNumber'],
          profilePictureURL: snapshotData['profilePictureURL'],
          dateOfBirth: (snapshotData['dateOfBirth'] as Timestamp).toDate(),
          isPro: snapshotData['isPro'],
        );
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
        await firestoreFriendsPath
            .set({'friends': _userFriends.map((friend) => friend.id).toList()});
      }
      var documentSnapshot = await firestoreFriendsPath.get();
      var snapshotData = documentSnapshot.data();
      if (snapshotData != null && snapshotData['friends'] != null) {
        _userFriends.clear();
        for (String friendId in snapshotData['friends']) {
          documentSnapshot = await firestoreInstance
              .collection('users')
              .doc(friendId)
              .collection('data')
              .doc('profile')
              .get();
          var documentData = documentSnapshot.data();
          if (documentData != null) {
            _userFriends.add(AppUser(
              id: friendId,
              name: documentData['name'],
              emailAddress: documentData['emailAddress'],
              phoneNumber: documentData['phoneNumber'],
              profilePictureURL: documentData['profilePictureURL'],
              dateOfBirth: (documentData['dateOfBirth'] as Timestamp).toDate(),
              isPro: documentData['isPro'],
            ));
          }
        }
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }
}
