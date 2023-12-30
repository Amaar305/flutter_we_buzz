import 'package:flutter/material.dart';
import 'package:hi_tweet/model/message_enum_type.dart';

import '../../../../utils/constants.dart';

class MessageStatusDot extends StatelessWidget {
  const MessageStatusDot({super.key, required this.status});
  final MessageStatus status;
  @override
  Widget build(BuildContext context) {
    Color dotColor(MessageStatus status) {
      switch (status) {
        case MessageStatus.notSent:
          return Colors.red;
        case MessageStatus.notView:
        // Theme.of(context).colorScheme.primary.withOpacity(0.5);
          return Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1);
        case MessageStatus.viewed:
          return Theme.of(context).colorScheme.primary;
        
        default:
          return Colors.transparent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: kDefaultPadding / 2),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: dotColor(status),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == MessageStatus.notSent ? Icons.close : Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
