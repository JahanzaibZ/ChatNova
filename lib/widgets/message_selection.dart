import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';
import '../widgets/message_bubble.dart';

class MessageSelection extends StatefulWidget {
  final Function(
      {required bool checkIfEmpty,
      bool? removeMessage,
      Message? message}) messagesToBeDelete;
  final Message message;
  final String activeUserId;
  final int dayDifference;

  const MessageSelection({
    required this.messagesToBeDelete,
    required this.message,
    required this.activeUserId,
    required this.dayDifference,
    super.key,
  });

  @override
  State<MessageSelection> createState() => _MessageSelectionState();
}

class _MessageSelectionState extends State<MessageSelection> {
  var _isSelected = false;

  Widget _showDate() {
    var date = DateTime.now().toIso8601String();
    if (widget.dayDifference == 0) {
      date = 'Today';
    } else if (widget.dayDifference == 1) {
      date = 'Yesterday';
    } else if (widget.dayDifference > 1 && widget.dayDifference < 7) {
      date = DateFormat.EEEE().format(widget.message.timeStamp);
    } else if (widget.dayDifference >= 7) {
      date = DateFormat.yMMMd().format(widget.message.timeStamp);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        date,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall!.color!.withOpacity(.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainUserMessage = widget.message.senderId == widget.activeUserId;
    _isSelected =
        widget.messagesToBeDelete(checkIfEmpty: true) ? false : _isSelected;
    return Column(
      children: [
        if (widget.dayDifference != -1) _showDate(),
        InkWell(
          splashFactory: NoSplash.splashFactory,
          highlightColor: widget.messagesToBeDelete(checkIfEmpty: true)
              ? mainUserMessage
                  ? null
                  : Colors.transparent
              : Colors.transparent,
          onLongPress: () {
            if (!_isSelected &&
                widget.messagesToBeDelete(checkIfEmpty: true) &&
                mainUserMessage) {
              widget.messagesToBeDelete(
                checkIfEmpty: false,
                message: widget.message,
              );
              setState(() {
                _isSelected = true;
              });
            }
          },
          onTap: () {
            if (_isSelected) {
              widget.messagesToBeDelete(
                checkIfEmpty: false,
                removeMessage: true,
                message: widget.message,
              );
              setState(() {
                _isSelected = false;
              });
            } else if (!_isSelected &&
                !widget.messagesToBeDelete(checkIfEmpty: true) &&
                mainUserMessage) {
              widget.messagesToBeDelete(
                checkIfEmpty: false,
                message: widget.message,
              );
              setState(() {
                _isSelected = true;
              });
            }
          },
          child: MessageBubble(
              isSelected: _isSelected,
              mainUserMessage: mainUserMessage,
              message: widget.message),
        ),
      ],
    );
  }
}
