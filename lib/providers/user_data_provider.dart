import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/message.dart';

class UserDataProvider with ChangeNotifier {
  var _liveChatUser = AppUser(
    id: 'NO_ID',
    name: 'NO_NAME',
    dateOfBirth: DateTime.now(),
    interests: ['NO_INTERESTS'],
  );
  var _user = AppUser(
    id: 'NO_ID',
    name: 'NO_NAME',
    dateOfBirth: DateTime.now(),
    interests: ['NO_INTERESTS'],
  );
  final Map<String, dynamic> _friendsStatus = {};
  final List<AppUser> _userFriends = [];
  final List<AppUser> _userBlocks = [];
  final List<Chat> _chats = [];
  final List<Message> _messages = [];
  final List<Message> _liveChatMessages = [];

  var _messageDocuments = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  var _liveMessageDocuments = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

  AppUser get liveChatUser {
    return _liveChatUser;
  }

  AppUser get user {
    return _user;
  }

  Map<String, dynamic> get friendsStatus {
    return {..._friendsStatus};
  }

  List<AppUser> get userFriends {
    return [..._userFriends];
  }

  List<AppUser> get userBlocks {
    return [..._userBlocks];
  }

  List<Chat> get chats {
    return [..._chats];
  }

  List<Message> get messages {
    return [..._messages];
  }

  List<Message> get liveChatMessages {
    return [..._liveChatMessages];
  }

  set setUserInfo(AppUser user) {
    _user = user;
  }

  bool findFriendById(String id) {
    return !_userFriends.every((friend) => !(friend.id == id));
  }

  bool findBlockById(String id) {
    return !_userBlocks.every((block) => !(block.id == id));
  }

  void clearAllLists() {
    _userFriends.clear();
    _userBlocks.clear();
    _messages.clear();
    _chats.clear();
  }

  Future<void> uploadProfileImage(File pickedImage) async {
    try {
      final authInstance = FirebaseAuth.instance;
      final storageRef = FirebaseStorage.instance
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

  Future<StreamSubscription> listenAndReadUserStatusFromDatabase() async {
    final databaseRef = FirebaseDatabase.instance.ref('userStatus');
    var listChanged = false;
    return databaseRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final eventSnapshotData = event.snapshot.value as Map<dynamic, dynamic>;
        _friendsStatus.clear();
        eventSnapshotData.forEach((key, value) {
          for (final friend in _userFriends) {
            if (friend.id == key) {
              if (!listChanged) {
                listChanged = true;
              }
              _friendsStatus.addAll({key: value});
            }
          }
          if (listChanged) {
            notifyListeners();
          }
        });
      }
    });
  }

  Future<void> setUserStatus([bool setOffline = false]) async {
    final databaseRef = FirebaseDatabase.instance.ref('userStatus');
    if (!setOffline) {
      await databaseRef.onDisconnect().update({_user.id: null});
      await databaseRef.update({_user.id: true});
    } else {
      await databaseRef.update({_user.id: null});
    }
  }

  Future<void> addOrRemoveUserFriendsAndBlocks({
    bool remove = false,
    bool block = false,
    bool delayed = true,
    required AppUser user,
  }) async {
    if (delayed) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (block) {
      if (remove) {
        _userBlocks.removeWhere((block) => block.id == user.id);
      } else {
        _userBlocks.add(user);
        _userFriends.removeWhere((friend) => friend.id == user.id);
      }
      final ref = FirebaseFirestore.instance
          .collection('messages')
          .doc('DEFAULT_MESSAGE');
      await ref.set({'timeStamp': DateTime.now()}, SetOptions(merge: true));
    } else {
      if (remove) {
        _userFriends.removeWhere(
          (friend) => friend.id == user.id,
        );
      } else {
        _userFriends.add(user);
        _userBlocks.removeWhere(
          (block) => block.id == user.id,
        );
      }
    }
    await fetchAndSetUserFriendsAndBlocks();
  }

  Future<void> fetchAndSetUserProfileInfo({bool onlyFetch = false}) async {
    try {
      final authInstance = FirebaseAuth.instance;
      final firestoreInstance = FirebaseFirestore.instance;
      final firestoreUserPath = firestoreInstance
          .collection('users')
          .doc(authInstance.currentUser!.uid);
      if (!onlyFetch) {
        await firestoreUserPath.set(
          {
            'name': _user.name,
            'emailAddress': _user.emailAddress,
            'phoneNumber': _user.phoneNumber,
            'profilePictureURL': _user.profilePictureURL,
            'dateOfBirth': Timestamp.fromDate(_user.dateOfBirth),
            'interests': _user.interests,
            'isPro': _user.isPro,
          },
          SetOptions(merge: true),
        );
      }
      final documentSnapshot = await firestoreUserPath.get();
      final snapshotData = documentSnapshot.data();
      await fetchAndSetUserFriendsAndBlocks(onlyFetch: true);
      if (snapshotData != null) {
        _user = AppUser(
          id: authInstance.currentUser!.uid,
          name: snapshotData['name'],
          emailAddress: snapshotData['emailAddress'],
          phoneNumber: snapshotData['phoneNumber'],
          profilePictureURL: snapshotData['profilePictureURL'],
          dateOfBirth: (snapshotData['dateOfBirth'] as Timestamp).toDate(),
          interests: <String>[...snapshotData['interests']],
          isPro: snapshotData['isPro'],
        );
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetUserFriendsAndBlocks({bool onlyFetch = false}) async {
    try {
      final authInstance = FirebaseAuth.instance;
      final firestoreInstance = FirebaseFirestore.instance;
      final firestoreFriendsPath = firestoreInstance
          .collection('users')
          .doc(authInstance.currentUser!.uid);
      if (!onlyFetch) {
        await firestoreFriendsPath.set(
          {
            'friends': _userFriends.isNotEmpty
                ? _userFriends.map((friend) => friend.id).toList()
                : null,
            'blocks': _userBlocks.isNotEmpty
                ? _userBlocks.map((block) => block.id).toList()
                : null,
          },
          SetOptions(merge: true),
        );
      }
      var documentSnapshot = await firestoreFriendsPath.get();
      final snapshotData = documentSnapshot.data();
      if (snapshotData != null) {
        if (snapshotData['friends'] != null) {
          _userFriends.clear();
          for (String friendId in snapshotData['friends']) {
            documentSnapshot =
                await firestoreInstance.collection('users').doc(friendId).get();
            final documentData = documentSnapshot.data();
            if (documentData != null) {
              _userFriends.add(AppUser(
                id: friendId,
                name: documentData['name'],
                emailAddress: documentData['emailAddress'],
                phoneNumber: documentData['phoneNumber'],
                profilePictureURL: documentData['profilePictureURL'],
                dateOfBirth:
                    (documentData['dateOfBirth'] as Timestamp).toDate(),
                interests: <String>[...documentData['interests']],
                isPro: documentData['isPro'],
              ));
            }
          }
        }
        if (snapshotData['blocks'] != null) {
          _userBlocks.clear();
          for (String blockId in snapshotData['blocks']) {
            documentSnapshot =
                await firestoreInstance.collection('users').doc(blockId).get();
            final documentData = documentSnapshot.data();
            if (documentData != null) {
              _userBlocks.add(
                AppUser(
                  id: blockId,
                  name: documentData['name'],
                  emailAddress: documentData['emailAddress'],
                  phoneNumber: documentData['phoneNumber'],
                  profilePictureURL: documentData['profilePictureURL'],
                  dateOfBirth:
                      (documentData['dateOfBirth'] as Timestamp).toDate(),
                  interests: <String>[...documentData['interests']],
                  isPro: documentData['isPro'],
                ),
              );
            }
          }
        }
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<AppUser?> fetchUnknownUserInfoByPhone(String phoneNumber) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final documents = (await firestoreInstance.collection('users').get()).docs;
    for (final doc in documents) {
      final docData = doc.data();
      if (docData['phoneNumber'] != null &&
          (docData['phoneNumber'] as String)
              .replaceAll(RegExp(r'^\++'), '')
              .contains(phoneNumber.replaceAll(RegExp(r'^0+|^\++|\s+'), ''))) {
        return AppUser(
          id: doc.id,
          name: docData['name'],
          emailAddress: docData['emailAddress'],
          phoneNumber: docData['phoneNumber'],
          profilePictureURL: docData['profilePictureURL'],
          dateOfBirth: (docData['dateOfBirth'] as Timestamp).toDate(),
          interests: <String>[...docData['interests']],
          isPro: docData['isPro'],
        );
      }
    }
    return null;
  }

  Future<AppUser?> fetchUnknownUserInfoByEmail(String email) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final documents = (await firestoreInstance.collection('users').get()).docs;
    for (final doc in documents) {
      final docData = doc.data();
      if (docData['emailAddress'] == email) {
        return AppUser(
          id: doc.id,
          name: docData['name'],
          emailAddress: docData['emailAddress'],
          phoneNumber: docData['phoneNumber'],
          profilePictureURL: docData['profilePictureURL'],
          dateOfBirth: (docData['dateOfBirth'] as Timestamp).toDate(),
          interests: <String>[...docData['interests']],
          isPro: docData['isPro'],
        );
      }
    }
    return null;
  }

  Future<AppUser> fetchUnknownUserInfoById(String userId) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final documentData =
        (await firestoreInstance.collection('users').doc(userId).get()).data();
    return AppUser(
      id: userId,
      name: documentData!['name'],
      emailAddress: documentData['emailAddress'],
      phoneNumber: documentData['phoneNumber'],
      profilePictureURL: documentData['profilePictureURL'],
      dateOfBirth: (documentData['dateOfBirth'] as Timestamp).toDate(),
      interests: <String>[...documentData['interests']],
      isPro: documentData['isPro'],
    );
  }

  AppUser? fetchUnknownUserFromFriendsListById(String userId) {
    for (final friend in userFriends) {
      if (friend.id == userId) {
        return friend;
      }
    }
    return null;
  }

  Future<void> sendMessage(Message message) async {
    final firstoreInstance = FirebaseFirestore.instance;
    firstoreInstance.collection('messages').doc().set({
      'text': message.text,
      'timeStamp': message.timeStamp,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
    });
  }

  Future<StreamSubscription> listenAndReadMessasgesFromFirestore() async {
    final firestoreInstance = FirebaseFirestore.instance;
    final messageStream = firestoreInstance
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .snapshots();
    return messageStream.listen(
      (documentSnapshot) async {
        var updatedMessages = <Message>[];
        _messageDocuments.clear();
        _messageDocuments = documentSnapshot.docs;
        for (final messageDocument in _messageDocuments) {
          final message = messageDocument.data();
          if ((message['receiverId'] == _user.id &&
                  _userBlocks
                      .every((user) => user.id != message['senderId'])) ||
              (message['senderId'] == _user.id &&
                  _userBlocks
                      .every((user) => user.id != message['receiverId']))) {
            updatedMessages.add(Message(
              id: messageDocument.id,
              text: message['text'],
              receiverId: message['receiverId'].toString(),
              senderId: message['senderId'],
              timeStamp: (message['timeStamp'] as Timestamp).toDate(),
            ));
          }
        }
        if (_messages.length != updatedMessages.length) {
          _messages.clear();
          for (var message in updatedMessages) {
            _messages.add(message);
          }
          await createAndUpdateChats();
        }
      },
      onError: (error) => debugPrint('Messages Stream Error Encountered!'),
      cancelOnError: true,
    );
  }

  Future<void> deleteMessages(
      List<Message> messages, String currentUserid) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final message in messages) {
      for (final messageDocument in _messageDocuments) {
        if (messageDocument.id == message.id) {
          batch.delete(messageDocument.reference);
        }
      }
    }
    notifyListeners();
    if (_messages.isEmpty) {
      createAndUpdateChats();
    }
    await batch.commit();
  }

  Future<void> createAndUpdateChats() async {
    _chats.clear();
    for (final message in _messages) {
      final chatIndex = _chats.indexWhere((chat) =>
          (chat.receiver.id == message.receiverId ||
              chat.receiver.id == message.senderId));
      if (chatIndex != -1) {
        if (_chats[chatIndex]
            .lastMessageTimeStamp
            .isBefore(message.timeStamp)) {
          _chats[chatIndex] = _chats[chatIndex].copyWith(
              lastMessageText: message.text,
              lastMessageTimeStamp: message.timeStamp);
        }
      }

      if (chatIndex == -1) {
        final chatReceiver = fetchUnknownUserFromFriendsListById(
              message.senderId == _user.id
                  ? message.receiverId
                  : message.senderId,
            ) ??
            await fetchUnknownUserInfoById(
              message.senderId == _user.id
                  ? message.receiverId
                  : message.senderId,
            );
        _chats.add(Chat(
          receiver: chatReceiver,
          lastMessageText: message.text,
          lastMessageTimeStamp: message.timeStamp,
        ));
      }
    }
    notifyListeners();
  }

  Future<StreamSubscription> listenAndFetchLiveChatUsersFromDatabase() async {
    final lobbyRef = FirebaseDatabase.instance.ref('liveChatUsers');
    return lobbyRef.onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          final eventSnapshotData =
              event.snapshot.value as Map<dynamic, dynamic>;
          if (_liveChatUser.id != 'NO_ID') {
            if (!eventSnapshotData.containsKey(_liveChatUser.id)) {
              _liveChatUser = _liveChatUser.copyWith(id: 'NO_ID');
              notifyListeners();
            }
          } else {
            eventSnapshotData.forEach(
              (key, value) {
                for (final interest in (<String>[...value['interests']])) {
                  if (key != _user.id && _user.interests.contains(interest)) {
                    _liveChatUser = AppUser(
                      id: key,
                      name: value['name'],
                      emailAddress: value['emailAddress'],
                      phoneNumber: value['phoneNumber'],
                      dateOfBirth: DateTime.tryParse(value['dateOfBirth']) ??
                          DateTime.now(),
                      profilePictureURL: value['profilePictureURL'],
                      interests: <String>[...value['interests']],
                      isPro: value['isPro'],
                    );
                    break;
                  }
                }
              },
            );
          }
        }
      },
      onError: (error) =>
          debugPrint(' Live Chat Lobby Stream Error Encountered!'),
      cancelOnError: true,
    );
  }

  Future<void> setUserLiveChatStatus([bool remove = false]) async {
    final databaseRef = FirebaseDatabase.instance.ref('liveChatUsers');
    if (remove) {
      await databaseRef.update({_user.id: null});
      if (_liveChatUser.id != 'NO_ID') {
        _liveChatUser = _liveChatUser.copyWith(id: 'NO_ID');
      }
    } else {
      await databaseRef.onDisconnect().update({_user.id: null});
      await databaseRef.update({
        _user.id: {
          'name': _user.name,
          'emailAddress': _user.emailAddress,
          'phoneNumber': _user.phoneNumber,
          'dateOfBirth': _user.dateOfBirth.toIso8601String(),
          'profilePictureURL': _user.profilePictureURL,
          'interests': _user.interests,
          'isPro': _user.isPro,
        }
      });
    }
  }

  Future<void> sendLiveMessage(Message message) async {
    final firstoreInstance = FirebaseFirestore.instance;
    firstoreInstance.collection('liveMessages').doc().set({
      'text': message.text,
      'timeStamp': message.timeStamp,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
    });
  }

  Future<StreamSubscription> listenAndReadLiveMessasgesFromFirestore(
      String liveChatUserId) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final messageStream = firestoreInstance
        .collection('liveMessages')
        .orderBy('timeStamp', descending: true)
        .snapshots();
    return messageStream.listen(
      (documentSnapshot) async {
        var updatedMessages = <Message>[];
        _liveMessageDocuments.clear();
        _liveMessageDocuments = documentSnapshot.docs;
        for (final messageDocument in _liveMessageDocuments) {
          final message = messageDocument.data();
          final userId = FirebaseAuth.instance.currentUser!.uid;
          if ((message['receiverId'] == userId &&
                  message['senderId'] == liveChatUserId) ||
              (message['senderId'] == userId &&
                  message['receiverId'] == liveChatUserId)) {
            updatedMessages.add(Message(
              id: messageDocument.id,
              text: message['text'],
              receiverId: message['receiverId'].toString(),
              senderId: message['senderId'],
              timeStamp: (message['timeStamp'] as Timestamp).toDate(),
            ));
          }
        }
        if (_liveChatMessages.length != updatedMessages.length) {
          _liveChatMessages.clear();
          for (var message in updatedMessages) {
            _liveChatMessages.add(message);
          }
          notifyListeners();
        }
      },
      onError: (error) =>
          debugPrint(' Live Chat Messages Stream Error Encountered!'),
      cancelOnError: true,
    );
  }

  Future<void> deleteLiveMessages() async {
    final batch = FirebaseFirestore.instance.batch();
    final liveChatMessages = [..._liveChatMessages];
    for (final message in liveChatMessages) {
      _liveChatMessages.removeWhere((msg) => msg.id == message.id);
      for (final messageDocument in _liveMessageDocuments) {
        if (messageDocument.id == message.id) {
          batch.delete(messageDocument.reference);
        }
      }
    }
    await batch.commit();
  }
}
