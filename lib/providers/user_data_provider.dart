import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/message.dart';

class UserDataProvider with ChangeNotifier {
  var _user = AppUser();
  final List<AppUser> _userFriends = [];
  final List<Chat> _chats = [];
  final List<Message> _messages = [];

  AppUser get user {
    return _user;
  }

  List<AppUser> get userFriends {
    return [..._userFriends];
  }

  List<Chat> get chats {
    return [..._chats];
  }

  List<Message> get messages {
    return [..._messages];
  }

  set setUserInfo(AppUser user) {
    _user = user;
  }

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

  Future<void> fetchAndSetUserProfileInfo({bool onlyFetch = false}) async {
    try {
      var authInstance = FirebaseAuth.instance;
      var firestoreInstance = FirebaseFirestore.instance;
      var firestoreUserPath = firestoreInstance
          .collection('users')
          .doc(authInstance.currentUser!.uid)
          .collection('data')
          .doc('profile');
      if (!onlyFetch) {
        await firestoreUserPath.set({
          'name': _user.name,
          'emailAddress': _user.emailAddress,
          'phoneNumber': _user.phoneNumber,
          'profilePictureURL': _user.profilePictureURL,
          'dateOfBirth': Timestamp.fromDate(_user.dateOfBirth!),
          'isPro': _user.isPro,
        });
      }
      var documentSnapshot = await firestoreUserPath.get();
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

  Future<AppUser> fetchUnknownUserInfo(String userId) async {
    var firestoreInstance = FirebaseFirestore.instance;
    var documentData = (await firestoreInstance
            .collection('users')
            .doc(userId)
            .collection('data')
            .doc('profile')
            .get())
        .data();
    return AppUser(
      id: userId,
      name: documentData!['name'],
      emailAddress: documentData['emailAddress'],
      phoneNumber: documentData['phoneNumber'],
      profilePictureURL: documentData['profilePictureURL'],
      isPro: documentData['isPro'],
    );
  }

  AppUser? fetchUnknownUserFromFriendsList(String userId) {
    for (var friend in userFriends) {
      if (friend.id == userId) {
        return friend;
      }
    }
    return null;
  }

  Future<void> sendMessage(Message message) async {
    var firstoreInstance = FirebaseFirestore.instance;
    firstoreInstance.collection('messages').doc().set({
      'text': message.text,
      'timeStamp': message.timeStamp,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
    });
  }

  Future<StreamSubscription> listenAndReadMessasgesFromFirestore() async {
    var firestoreInstance = FirebaseFirestore.instance;
    var messageStream = firestoreInstance
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .snapshots();
    return messageStream.listen(
      (documentSnapshot) async {
        var snapshotData = documentSnapshot.docs;
        if (snapshotData.isNotEmpty) {
          _messages.clear();
          var messageAdded = false;
          for (var messageDocument in snapshotData) {
            var message = messageDocument.data();
            var userId = FirebaseAuth.instance.currentUser!.uid;
            if (message['receiverId'] == userId ||
                message['senderId'] == userId) {
              _messages.add(Message(
                text: message['text'],
                receiverId: message['receiverId'],
                senderId: message['senderId'],
                timeStamp: (message['timeStamp'] as Timestamp).toDate(),
              ));
              if (!messageAdded) {
                messageAdded = true;
              }
            }
          }
          if (messageAdded) {
            await createAndUpdateChats();
            notifyListeners();
          }
        }
      },
      onError: (error) => debugPrint(' Stream Error Encountered!'),
      cancelOnError: true,
    );
  }

  Future<void> createAndUpdateChats() async {
    var currentUserId = FirebaseAuth.instance.currentUser!.uid;
    for (var message in messages) {
      var chatIndex = _chats.indexWhere((chat) =>
          (chat.receiver!.id == message.receiverId ||
              chat.receiver!.id == message.senderId));
      if (chatIndex != -1) {
        if (_chats[chatIndex]
            .lastMessageTimeStamp!
            .isBefore(message.timeStamp!)) {
          _chats[chatIndex] = _chats[chatIndex].copyWith(
              lastMessageText: message.text,
              lastMessageTimeStamp: message.timeStamp);
        }
      }

      if (chatIndex == -1) {
        var chatReceiver = fetchUnknownUserFromFriendsList(
              message.senderId == currentUserId
                  ? message.receiverId!
                  : message.senderId!,
            ) ??
            await fetchUnknownUserInfo(
              message.senderId == currentUserId
                  ? message.receiverId!
                  : message.senderId!,
            );
        _chats.add(Chat(
          receiver: chatReceiver,
          lastMessageText: message.text,
          lastMessageTimeStamp: message.timeStamp,
        ));
      }
    }
  }
}
