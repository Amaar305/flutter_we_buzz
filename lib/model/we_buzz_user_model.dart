// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class WeBuzzUser {
  late String userId;
  late String email;
  late String name;
  late String username;
  late String lastActive;
  late String pushToken;
  late String bio;
  late String location;
  late bool isOnline;
  late bool isStaff;
  late bool isAdmin;
  final bool isSuspended;
  late bool notification;
  final bool postNotifications;
  final bool likeNotifications;
  final bool commentNotifications;
  final bool saveNotifications;
  final bool followNotifications;
  final bool userBlockNotifications;
  final bool chatMessageNotifications;
  late bool isCompleteness;
  late bool isVerified;
  final List<String> followers;
  final List<String> following;
  final List<String> savedBuzz;
  final List<String> blockedUsers;
  late Timestamp createdAt;
  late DirectMessagePrivacy directMessagePrivacy;
  late DirectMessagePrivacy onlineStatusIndicator;

  late String? imageUrl;
  late String? program;
  late String? level;
  late String? phone;
  late Timestamp? lastSeen;
  late Timestamp? lastUpdatedPassword;
  WeBuzzUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.isOnline,
    required this.isStaff,
    required this.isAdmin,
    required this.notification,
    required this.isCompleteness,
    required this.isVerified,
    required this.createdAt,
    required this.lastActive,
    required this.location,
    required this.followers,
    required this.following,
    required this.username,
    required this.pushToken,
    required this.blockedUsers,
    required this.savedBuzz,
    this.bio = 'Hey, I\'m using We Buzz!',
    this.directMessagePrivacy = DirectMessagePrivacy.everyone,
    this.onlineStatusIndicator = DirectMessagePrivacy.everyone,
    this.isSuspended = false,
    this.postNotifications = true,
    this.likeNotifications = true,
    this.commentNotifications = true,
    this.saveNotifications = true,
    this.followNotifications = true,
    this.userBlockNotifications = true,
    this.chatMessageNotifications = true,
    this.lastSeen,
    this.imageUrl,
    this.program,
    this.level,
    this.phone,
    this.lastUpdatedPassword,
  });

  Map<String, dynamic> toMap() {
    String directMessagePrivacyType;
    String onlineStatusIndicatorType;

    switch (directMessagePrivacy) {
      case DirectMessagePrivacy.everyone:
        directMessagePrivacyType = directMessagePrivacy.name;
        break;
      case DirectMessagePrivacy.followers:
        directMessagePrivacyType = directMessagePrivacy.name;
        break;
      case DirectMessagePrivacy.following:
        directMessagePrivacyType = directMessagePrivacy.name;
        break;
      case DirectMessagePrivacy.mutual:
        directMessagePrivacyType = directMessagePrivacy.name;
        break;
      default:
        directMessagePrivacyType = "";
    }
    switch (onlineStatusIndicator) {
      case DirectMessagePrivacy.everyone:
        onlineStatusIndicatorType = onlineStatusIndicator.name;
        break;
      case DirectMessagePrivacy.followers:
        onlineStatusIndicatorType = onlineStatusIndicator.name;
        break;
      case DirectMessagePrivacy.following:
        onlineStatusIndicatorType = onlineStatusIndicator.name;
        break;
      case DirectMessagePrivacy.mutual:
        onlineStatusIndicatorType = onlineStatusIndicator.name;
        break;
      default:
        onlineStatusIndicatorType = "";
    }
    return <String, dynamic>{
      'userId': userId,
      'email': email,
      'isOnline': isOnline,
      'isStaff': isStaff,
      'isAdmin': isAdmin,
      'notification': notification,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
      'pushToken': pushToken,
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
      'program': program,
      'level': level,
      'lastUpdatedPassword': lastUpdatedPassword,
      'phone': phone,
      'isCompleteness': isCompleteness,
      'isVerified': isVerified,
      'location': location,
      'lastActive': lastActive,
      "followers": followers,
      "following": following,
      "savedBuzz": savedBuzz,
      "blockedUsers": blockedUsers,
      'username': username,
      "directMessagePrivacy": directMessagePrivacyType,
      "onlineStatusIndicator": onlineStatusIndicatorType,
      "chatMessageNotifications": chatMessageNotifications,
      "postNotifications": postNotifications,
      "likeNotifications": likeNotifications,
      "commentNotifications": commentNotifications,
      "followNotifications": followNotifications,
      "userBlockNotifications": userBlockNotifications,
      "saveNotifications": saveNotifications,
      "isSuspended": isSuspended,
    };
  }

  factory WeBuzzUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeBuzzUser.fromMap(data);
  }

  factory WeBuzzUser.fromMap(Map<String, dynamic> map) {
    DirectMessagePrivacy directMessagePrivacy;
    DirectMessagePrivacy onlineStatusIndicator;

    switch (map['directMessagePrivacy']) {
      case "mutual":
        directMessagePrivacy = DirectMessagePrivacy.mutual;
        break;
      case "following":
        directMessagePrivacy = DirectMessagePrivacy.following;
        break;
      case "followers":
        directMessagePrivacy = DirectMessagePrivacy.followers;
        break;
      case "everyone":
        directMessagePrivacy = DirectMessagePrivacy.everyone;
        break;
      default:
        directMessagePrivacy = DirectMessagePrivacy.unknown;
    }
    switch (map['onlineStatusIndicator']) {
      case "mutual":
        onlineStatusIndicator = DirectMessagePrivacy.mutual;
        break;
      case "following":
        onlineStatusIndicator = DirectMessagePrivacy.following;
        break;
      case "followers":
        onlineStatusIndicator = DirectMessagePrivacy.followers;
        break;
      case "everyone":
        onlineStatusIndicator = DirectMessagePrivacy.everyone;
        break;
      default:
        onlineStatusIndicator = DirectMessagePrivacy.unknown;
    }

    List<String> followers = (map['followers'] as List)
        .map((hashtag) => hashtag.toString())
        .toList();
    List<String> following = (map['following'] as List)
        .map((hashtag) => hashtag.toString())
        .toList();
    List<String> savedBuzz =
        (map['savedBuzz'] as List).map((saved) => saved.toString()).toList();
    List<String> blockedUsers = (map['blockedUsers'] as List)
        .map((blockedUser) => blockedUser.toString())
        .toList();

    return WeBuzzUser(
      userId: map['userId'] as String,
      email: map['email'] as String,
      username: map['username'],
      isOnline: map['isOnline'] as bool,
      isStaff: map['isStaff'] as bool,
      isAdmin: map['isAdmin'] as bool,
      notification: map['notification'] as bool,
      lastSeen: map['lastSeen'] as Timestamp?,
      createdAt: map['createdAt'] as Timestamp,
      pushToken: map['pushToken'] as String,
      bio: map['bio'] as String,
      imageUrl: map['imageUrl'] as String?,
      program: map['program'] as String?,
      level: map['level'] as String?,
      name: map['name'] as String,
      lastUpdatedPassword: map['lastUpdatedPassword'] as Timestamp?,
      lastActive: map['lastActive'] as String,
      phone: map['phone'] as String?,
      location: map['location'] as String,
      isCompleteness: map['isCompleteness'] as bool,
      isVerified: map['isVerified'] as bool,
      followers: followers,
      following: following,
      savedBuzz: savedBuzz,
      blockedUsers: blockedUsers,
      directMessagePrivacy: directMessagePrivacy,
      onlineStatusIndicator: onlineStatusIndicator,
      chatMessageNotifications: map['chatMessageNotifications'],
      commentNotifications: map['commentNotifications'],
      followNotifications: map['followNotifications'],
      isSuspended: map['isSuspended'],
      likeNotifications: map['likeNotifications'],
      postNotifications: map['postNotifications'],
      saveNotifications: map['saveNotifications'],
      userBlockNotifications: map['userBlockNotifications'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WeBuzzUser.fromJson(String source) =>
      WeBuzzUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CampusBuzzUser(userId: $userId, email: $email, isOnline: $isOnline, isStaff: $isStaff, isAdmin: $isAdmin, notification: $notification, lastSeen: $lastSeen, createdAt: $createdAt, followers: pushToken: $pushToken, name: $name, bio: $bio, imageUrl: $imageUrl, program: $program, level: $level, lastUpdatedPassword: $lastUpdatedPassword, phone:$phone, location: $location, username: $username)';
  }
}

enum DirectMessagePrivacy {
  everyone,
  followers,
  following,
  mutual,
  unknown,
}
