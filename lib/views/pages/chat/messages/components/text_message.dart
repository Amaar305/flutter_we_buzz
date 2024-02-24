import 'package:flutter/material.dart';

import '../../../../../model/message_model.dart';
import '../../../../utils/constants.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
    required this.message,
    required this.isMe,
  });

  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(top: kDefaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 0.75,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.primary.withOpacity(isMe ? 1 : 0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: 16,
          color: isMe
              ? Colors.black
              : Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
    );
  }
}
