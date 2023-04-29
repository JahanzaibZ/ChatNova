import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../models/message.dart';

class MessagesProvider with ChangeNotifier {
  Future<void> sendMessage(Message message) async {
    var firstoreInstance = FirebaseFirestore.instance;
    firstoreInstance
        .collection('chats')
        .doc('${message.receiverId}-${message.senderId}')
        .collection('messages')
        .doc()
        .set({
      'text': message.text,
      'timeStamp': message.timeStamp,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
    });

    // Future<void> receiveMessage() async {
    //   StreamBuilder(stream: FirebaseFirestore.instance.collection(''),);
    // }
  }
}
