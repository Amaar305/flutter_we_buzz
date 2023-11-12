import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hi_tweet/model/we_buzz_user_model.dart';
import 'package:hi_tweet/views/utils/constants.dart';

import 'chat_message.dart';

class ChatConversation {
  final String uid;
  final String currentUserId;
  final bool group;
  final bool activity;
  final String? groupTitle;

  final Timestamp recentTime;
  final List<WeBuzzUser> members;
  List<ChatMessage> messages;

  late final List<WeBuzzUser> _recepeints;

  ChatConversation({
    required this.uid,
    required this.currentUserId,
    required this.group,
    required this.activity,
    required this.members,
    required this.messages,
    required this.recentTime,
    this.groupTitle,
  }) {
    _recepeints =
        members.where((user) => user.userId != currentUserId).toList();
  }

  List<WeBuzzUser> recepeints() {
    return _recepeints;
  }

  String title() {
    if (!group) {
      return recepeints().first.username;
    } else if (groupTitle != null && group) {
      return groupTitle!;
    } else {
      var names = _recepeints.map((user) => user.username).join(", ");
      names = names.length > 35 ? names.substring(0, 35) : names;

      return names;
    }
  }

  String imageUrl() => !group
      ? _recepeints.first.imageUrl != null
          ? _recepeints.first.imageUrl!
          : defaultProfileImage
      : 'https://firebasestorage.googleapis.com/v0/b/my-hi-tweet.appspot.com/o/group-chat.png?alt=media&token=442b5b62-4e02-487e-9de4-a7ba4440b5a9&_gl=1*196xeoe*_ga*MTUxNDc4MTA2OC4xNjc1OTQwOTc4*_ga_CW55HF8NVT*MTY5OTI1MjU0Ni4xMTAuMS4xNjk5MjUyNTg1LjIxLjAuMA..';
}
