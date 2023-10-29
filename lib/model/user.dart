// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class WeBuzzUser {
  late String userId;
  late String email;
  late String name;
  late bool isOnline;
  late bool isStaff;
  late bool isAdmin;
  late bool notification;
  late bool isCompleteness;
  late bool isVerified;
  late Timestamp createdAt;
  late String lastActive;

  late String location;
  late Timestamp? lastSeen;
  final List<String> followers;
  final List<String> following;
  late String pushToken;
  late String bio;
  late String? imageUrl;
  late String? program;
  late String? level;
  late String? phone;
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
    this.lastSeen,
    required this.pushToken,
    this.bio = 'Hey, I\'m using We Buzz!',
    this.imageUrl,
    this.program,
    this.level,
    this.phone,
    this.lastUpdatedPassword,
  });

  Map<String, dynamic> toMap() {
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
    };
  }

  factory WeBuzzUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeBuzzUser.fromMap(data);
  }

  factory WeBuzzUser.fromMap(Map<String, dynamic> map) {
    List<String> followers = (map['followers'] as List)
        .map((hashtag) => hashtag.toString())
        .toList();
    List<String> following = (map['following'] as List)
        .map((hashtag) => hashtag.toString())
        .toList();
    return WeBuzzUser(
      userId: map['userId'] as String,
      email: map['email'] as String,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory WeBuzzUser.fromJson(String source) =>
      WeBuzzUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CampusBuzzUser(userId: $userId, email: $email, isOnline: $isOnline, isStaff: $isStaff, isAdmin: $isAdmin, notification: $notification, lastSeen: $lastSeen, createdAt: $createdAt, followers: pushToken: $pushToken, name: $name, bio: $bio, imageUrl: $imageUrl, program: $program, level: $level, lastUpdatedPassword: $lastUpdatedPassword, phone:$phone, location: $location)';
  }
}
