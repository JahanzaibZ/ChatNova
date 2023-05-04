import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime timeStamp;
  final bool mainUserMessage;

  const MessageBubble({
    required this.message,
    required this.timeStamp,
    required this.mainUserMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var messageBubbleBorder = const Radius.circular(20);
    var appColorScheme = Theme.of(context).colorScheme;
    var mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment:
          mainUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              bottomLeft: mainUserMessage ? messageBubbleBorder : Radius.zero,
              bottomRight: mainUserMessage ? Radius.zero : messageBubbleBorder,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 70, top: 15, bottom: 15),
                child: Text(
                  message,
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
                  DateFormat.jm().format(timeStamp),
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
    );
  }
}
