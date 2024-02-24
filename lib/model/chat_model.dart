// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/pages/dashboard/my_app_controller.dart';
import '../views/utils/constants.dart';
import 'message_model.dart';
import 'message_enum_type.dart';
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
  late Map<String, bool> readStatus; // Map to track read status for each member

  late List<WeBuzzUser> _recipients;

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
    required this.createdAt,
  }) {
    _recipients =
        members.where((user) => user.userId != currentUserId).toList();
    readStatus = {}; // Initialize the read status map
    _initializeReadStatus(); // Initialize read status based on existing messages
  }

  List<WeBuzzUser> get recipients {
    return _recipients;
  }

  WeBuzzUser get groupOwner =>
      members.firstWhere((user) => user.userId == createdBy);

  String title() {
    if (!group) {
      return recipients.first.username;
    } else if (groupTitle != null && group) {
      final gTitle = groupTitle!.length > 25
          ? "${groupTitle!.substring(0, 25)}..."
          : groupTitle!;
      return gTitle;
    } else {
      var names = _recipients.map((user) => user.username).join(", ");
      names = names.length > 25 ? "${names.substring(0, 25)}..." : names;

      return names;
    }
  }

  String imageUrl() => !group
      ? _recipients.first.imageUrl != null
          ? _recipients.first.imageUrl!
          : defaultProfileImage
      : defaultGroupImage;

  // Initialize read status based on existing messages
  void _initializeReadStatus() {
    for (var member in members) {
      if (member.userId != currentUserId) {
        readStatus[member.userId] = messages.any(
          (message) =>
              message.senderID == member.userId &&
              message.status == MessageStatus.viewed,
        );
      }
    }
  }

  // Update read status for a specific message and member
  void updateReadStatus(String messageID, String memberID) {
    readStatus[memberID] = true;
  }

  @override
  String toString() {
    return 'ChatConversation(uid: $uid, currentUserId: $currentUserId, createdBy: $createdBy, createdAt: $createdAt, group: $group, activity: $activity, groupTitle: $groupTitle, recentTime: $recentTime, members: $members, messages: $messages, _recipients: $_recipients, readStatus: $readStatus)';
  }
}

class Conversation {
  final String uid;
  final String currentUserId;
  final String createdBy;
  final String? groupTitle;
  final bool isGroup;
  final bool activity;
  final List<String> members;
  final Timestamp createdAt;
  final Timestamp recentTime;

  Conversation({
    required this.uid,
    required this.currentUserId,
    required this.createdBy,
    required this.groupTitle,
    required this.isGroup,
    required this.activity,
    required this.members,
    required this.createdAt,
    required this.recentTime,
  });

  List<WeBuzzUser> get users {
    List<WeBuzzUser> recipients = [];
    for (var uid in members) {
      var user = AppController.instance.weBuzzUsers
          .firstWhere((user) => user.userId == uid);
      recipients.add(user);
    }

    return recipients;
  }

  String title() {
    if (!isGroup) {
      return users.firstWhere((user) => user.userId != currentUserId).username;
    } else if (groupTitle != null && isGroup) {
      final gTitle = groupTitle!.length > 25
          ? "${groupTitle!.substring(0, 25)}..."
          : groupTitle!;
      return gTitle;
    } else {
      var names = users.map((user) => user.username).join(", ");
      names = names.length > 25 ? "${names.substring(0, 25)}..." : names;

      return names;
    }
  }

  String imageUrl(WeBuzzUser user) {
    if (!isGroup) {
      return user.imageUrl??defaultProfileImage;
    } else {
      return defaultGroupImage;
    }
  }

  factory Conversation.fromJson(Map<String, dynamic> json, String id) {
    return Conversation(
      uid: id,
      currentUserId: FirebaseAuth.instance.currentUser!.uid,
      isGroup: json['is_group'],
      activity: json['is_activity'],
      members: List<String>.from(
        (json['members'] as List<dynamic>),
      ),
      createdAt: json['created_at'] as Timestamp,
      groupTitle: json['group_title'],
      createdBy: json['created_by'],
      recentTime: json['recent_time'] as Timestamp,
    );
  }

  factory Conversation.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final json = snapshot.data() as Map<String, dynamic>;
    return Conversation.fromJson(json, snapshot.id);
  }
}
