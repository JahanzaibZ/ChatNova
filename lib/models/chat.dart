import '../models/app_user.dart';

class Chat {
  final int? numberOfUnreadMessages;
  final AppUser receiver;
  final String lastMessageText;
  final DateTime lastMessageTimeStamp;

  Chat({
    this.numberOfUnreadMessages,
    required this.receiver,
    required this.lastMessageText,
    required this.lastMessageTimeStamp,
  });

  Chat copyWith(
      {int? numberOfUnreadMessages,
      AppUser? receiver,
      String? lastMessageText,
      DateTime? lastMessageTimeStamp}) {
    {
      return Chat(
        numberOfUnreadMessages:
            numberOfUnreadMessages ?? this.numberOfUnreadMessages,
        receiver: receiver ?? this.receiver,
        lastMessageText: lastMessageText ?? this.lastMessageText,
        lastMessageTimeStamp: lastMessageTimeStamp ?? this.lastMessageTimeStamp,
      );
    }
  }
}
