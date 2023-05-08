class Message {
  final String id;
  final String text;
  final DateTime timeStamp;
  final String senderId;
  final String receiverId;

  Message({
    required this.id,
    required this.text,
    required this.timeStamp,
    required this.senderId,
    required this.receiverId,
  });
}
