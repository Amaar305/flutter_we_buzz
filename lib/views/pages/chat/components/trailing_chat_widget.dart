import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hi_tweet/model/message_enum_type.dart';

import '../../../../model/message_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/my_date_utils.dart';

class TrailingChat extends StatelessWidget {
  const TrailingChat({
    super.key,
    this.message,
  });

  final MessageModel? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox();
    } else {
      if (message!.status == MessageStatus.notView &&
          message!.senderID != FirebaseAuth.instance.currentUser!.uid) {
        return Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      } else {
        return Text(
          MyDateUtil.getLastMessageTime(
            time: message!.sentTime,
          ),
        );
      }
    }
  }
}
