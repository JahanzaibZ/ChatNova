import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageTextfield extends StatefulWidget {
  final Function sendMessage;
  final String recieverId;
  final String senderId;

  const MessageTextfield(
      {required this.senderId,
      required this.recieverId,
      required this.sendMessage,
      super.key});

  @override
  State<MessageTextfield> createState() => _MessageTextfieldState();
}

class _MessageTextfieldState extends State<MessageTextfield> {
  final _messageTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var appTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Theme(
        data: appTheme.copyWith(
          inputDecorationTheme: appTheme.inputDecorationTheme.copyWith(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
              color: appTheme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(20)),
          width: mediaQuery.size.width,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageTextEditingController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText: 'Send a message',
                  ),
                ),
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                color: appTheme.colorScheme.primary,
                style: IconButton.styleFrom(
                  fixedSize: Size(mediaQuery.size.width * .07,
                      mediaQuery.size.height * .07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _messageTextEditingController.text.trim().isEmpty
                    ? null
                    : () {
                        widget.sendMessage(
                          context,
                          Message(
                            id: "NO_ID",
                            text: _messageTextEditingController.text.trim(),
                            timeStamp: DateTime.now(),
                            senderId: widget.senderId,
                            receiverId: widget.recieverId,
                          ),
                        );
                        _messageTextEditingController.clear();
                      },
                icon: const Icon(Icons.send_rounded),
              )
            ],
          ),
        ),
      ),
    );
  }
}
