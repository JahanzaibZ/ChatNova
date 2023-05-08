import 'package:flutter/material.dart';

Future<void> showCustomDialog(BuildContext context,
    {String? title, String? content, required bool showActionButton}) async {
  var mediaQuery = MediaQuery.of(context);
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        width: mediaQuery.size.width * .8,
        height: mediaQuery.size.height * .4,
        child: Column(
          mainAxisAlignment: title != null
              ? MainAxisAlignment.spaceBetween
              : showActionButton
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.center,
          children: [
            if (title != null)
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            if (content != null)
              Text(
                content,
                // textAlign: title != null ? null : TextAlign.center,
                textAlign: TextAlign.center,
                style: title != null
                    ? Theme.of(context).textTheme.bodyLarge
                    : Theme.of(context).textTheme.titleLarge,
              ),
            if (showActionButton)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * .25,
                      MediaQuery.of(context).size.height * .06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ok'),
              ),
          ],
        ),
      ),
    ),
  );
}
