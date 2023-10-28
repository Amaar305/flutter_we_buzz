// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class WeBuzzUser {
  final String userId;
  final String email;
  final String name;
  final bool isOnline;
  final bool isStaff;
  final bool isAdmin;
  final bool notification;
  final bool isCompleteness;
  final bool isVerified;
  final Timestamp createdAt;
  final String lastActive;

  final String location;
  final Timestamp? lastSeen;

  final String pushToken;
  final String bio;
  final String? imageUrl;
  final String? program;
  final String? level;
  final String? phone;
  final Timestamp? lastUpdatedPassword;
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
    this.lastSeen,
    required this.pushToken,
    this.bio = 'Hey, I\'m using We Buzz!',
    this.imageUrl,
    this.program,
    this.level,
    this.phone,
    this.lastUpdatedPassword,
  });

  WeBuzzUser copyWith({
    String? userId,
    String? email,
    bool? isOnline,
    bool? isStaff,
    bool? isAdmin,
    bool? notification,
    bool? isCompleteness,
    bool? isVerified,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    String? pushToken,
    String? name,
    String? bio,
    String? imageUrl,
    String? program,
    String? level,
    String? phone,
    String? location,
    Timestamp? lastUpdatedPassword,
    String? lastActive,
  }) {
    return WeBuzzUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
      isStaff: isStaff ?? this.isStaff,
      isAdmin: isAdmin ?? this.isAdmin,
      notification: notification ?? this.notification,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      pushToken: pushToken ?? this.pushToken,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      program: program ?? this.program,
      level: level ?? this.level,
      lastUpdatedPassword: lastUpdatedPassword ?? this.lastUpdatedPassword,
      lastActive: lastActive ?? this.lastActive,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      isCompleteness: isCompleteness ?? this.isCompleteness,
      isVerified: isVerified ?? this.isVerified,
    );
  }

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
    };
  }

  factory WeBuzzUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeBuzzUser.fromMap(data);
  }

  factory WeBuzzUser.fromMap(Map<String, dynamic> map) {
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
