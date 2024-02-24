import 'package:flutter/material.dart';

import '../../../../../model/message_model.dart';
import '../../../../utils/constants.dart';

class AudioMessage extends StatelessWidget {
  const AudioMessage({
    super.key,
    required this.message,
    required this.isMe,
  });
  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      // height: 30,
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 0.75,
        vertical: kDefaultPadding / 2.5,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.primary.withOpacity(isMe ? 1 : 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_arrow,
            color: isMe ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 2,
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.4),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            "0.37",
            style: TextStyle(fontSize: 12, color: isMe ? Colors.white : null),
          ),
        ],
      ),
    );
  }
}
