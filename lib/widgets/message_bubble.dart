import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';

class MessageBubble extends StatefulWidget {
  final Function(
      {required bool checkIfEmpty,
      bool? removeMessage,
      Message? message}) messagesToBeDelete;
  final Message message;
  final String activeUserId;
  final int dayDifference;

  const MessageBubble({
    required this.messagesToBeDelete,
    required this.message,
    required this.activeUserId,
    required this.dayDifference,
    super.key,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
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
    var messageBubbleBorder = const Radius.circular(20);
    var appColorScheme = Theme.of(context).colorScheme;
    var mediaQuery = MediaQuery.of(context);
    var mainUserMessage = widget.message.senderId == widget.activeUserId;
    _isSelected =
        widget.messagesToBeDelete(checkIfEmpty: true) ? false : _isSelected;
    return Column(
      children: [
        // _showDate(),
        InkWell(
          child: InkWell(
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
            child: Container(
              color: _isSelected ? Colors.blueGrey.withOpacity(.2) : null,
              child: Row(
                mainAxisAlignment: mainUserMessage
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    constraints: BoxConstraints(
                      minWidth: mediaQuery.size.width * .3,
                      maxWidth: mediaQuery.size.width * .8,
                    ),
                    decoration: BoxDecoration(
                      color: mainUserMessage
                          ? appColorScheme.primary.withOpacity(.75)
                          : appColorScheme.surface.withOpacity(.3),
                      borderRadius: BorderRadius.only(
                        topLeft: messageBubbleBorder,
                        topRight: messageBubbleBorder,
                        bottomLeft:
                            mainUserMessage ? messageBubbleBorder : Radius.zero,
                        bottomRight:
                            mainUserMessage ? Radius.zero : messageBubbleBorder,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 70, top: 15, bottom: 15),
                          child: Text(
                            widget.message.text,
                            style: TextStyle(
                              color: mainUserMessage
                                  ? appColorScheme.onPrimary
                                  : appColorScheme.onSurface,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 10,
                          child: Text(
                            overflow: TextOverflow.fade,
                            DateFormat.jm().format(widget.message.timeStamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: mainUserMessage
                                  ? appColorScheme.onPrimary.withOpacity(.4)
                                  : appColorScheme.onSurface.withOpacity(.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
