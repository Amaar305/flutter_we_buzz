import 'package:cloud_firestore/cloud_firestore.dart';

import '../views/utils/constants.dart';
import 'chat_message_model.dart';
import 'we_buzz_user_model.dart';

class ChatConversation {
  final String uid;
  final String currentUserId;
  final String createdBy;
  final Timestamp createdAt;
  final bool group;
  final bool activity;
  final String? groupTitle;

  final Timestamp recentTime;
  final List<WeBuzzUser> members;
  List<MessageModel> messages;

  late List<WeBuzzUser> _recepeints;

  ChatConversation({
    required this.uid,
    required this.currentUserId,
    required this.createdBy,
    required this.group,
    required this.activity,
    required this.members,
    required this.messages,
    required this.recentTime,
    this.groupTitle,
    required this.createdAt
  }) {
    _recepeints =
        members.where((user) => user.userId != currentUserId).toList();
  }

  List<WeBuzzUser> recepeints() {
    return _recepeints;
  }

  WeBuzzUser get groupOwner =>
      members.firstWhere((user) => user.userId == createdBy);

  String title() {
    if (!group) {
      return recepeints().first.username;
    } else if (groupTitle != null && group) {
      final gTitile = groupTitle!.length > 25
          ? "${groupTitle!.substring(0, 25)}..."
          : groupTitle!;
      return gTitile;
    } else {
      var names = _recepeints.map((user) => user.username).join(", ");
      names = names.length > 25 ? "${names.substring(0, 25)}..." : names;

      return names;
    }
  }

  String imageUrl() => !group
      ? _recepeints.first.imageUrl != null
          ? _recepeints.first.imageUrl!
          : defaultProfileImage
      : defaultGroupImage;
}
