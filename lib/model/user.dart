// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampusBuzzUser {
  final String userId;
  final String email;
  final bool isOnline;
  final bool isStaff;
  final bool isAdmin;
  final bool notification;
  final bool isCompleteness;
  final bool isVerified;
  final Timestamp createdAt;
  final List<CampusBuzzUser> followers;
  final List<CampusBuzzUser> following;
  final String location;
  final Timestamp? lastSeen;

  final String pushToken;
  final String name;
  final String? bio;
  final String? imageUrl;
  final String? program;
  final String? level;
  final String? phone;
  final Timestamp? lastUpdatedPassword;
  CampusBuzzUser({
    required this.userId,
    required this.email,
    required this.isOnline,
    required this.isStaff,
    required this.isAdmin,
    required this.notification,
    required this.createdAt,
    required this.followers,
    required this.following,
    required this.pushToken,
    required this.location,
    required this.isCompleteness,
    required this.isVerified,
    this.lastSeen,
    required this.name,
    this.bio,
    this.imageUrl,
    this.program,
    this.level,
    this.lastUpdatedPassword,
    this.phone,
  });

  CampusBuzzUser copyWith({
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
    List<CampusBuzzUser>? followers,
    List<CampusBuzzUser>? following,
    String? pushToken,
    String? name,
    String? bio,
    String? imageUrl,
    String? program,
    String? level,
    String? phone,
    String? location,
    Timestamp? lastUpdatedPassword,
  }) {
    return CampusBuzzUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
      isStaff: isStaff ?? this.isStaff,
      isAdmin: isAdmin ?? this.isAdmin,
      notification: notification ?? this.notification,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      pushToken: pushToken ?? this.pushToken,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      program: program ?? this.program,
      level: level ?? this.level,
      lastUpdatedPassword: lastUpdatedPassword ?? this.lastUpdatedPassword,
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
      'followers': followers,
      'following': following,
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
    };
  }

  factory CampusBuzzUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CampusBuzzUser.fromMap(data);
  }

  factory CampusBuzzUser.fromMap(Map<String, dynamic> map) {
    return CampusBuzzUser(
      userId: map['userId'] as String,
      email: map['email'] as String,
      isOnline: map['isOnline'] as bool,
      isStaff: map['isStaff'] as bool,
      isAdmin: map['isAdmin'] as bool,
      notification: map['notification'] as bool,
      lastSeen: map['lastSeen'] as Timestamp?,
      createdAt: map['createdAt'] as Timestamp,
      followers: (map['followers'] as List<dynamic>)
          .map((user) => CampusBuzzUser.fromJson(user))
          .toList(),
      following: (map['following'] as List<dynamic>)
          .map((user) => CampusBuzzUser.fromJson(user))
          .toList(),
      pushToken: map['pushToken'] as String,
      bio: map['bio'] as String?,
      imageUrl: map['imageUrl'] as String?,
      program: map['program'] as String?,
      level: map['level'] as String?,
      name: map['name'] as String,
      lastUpdatedPassword: map['lastUpdatedPassword'] as Timestamp?,
      phone: map['phone'] as String?,
      location: map['location'] as String,
      isCompleteness: map['isCompleteness'] as bool,
      isVerified: map['isVerified'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory CampusBuzzUser.fromJson(String source) =>
      CampusBuzzUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CampusBuzzUser(userId: $userId, email: $email, isOnline: $isOnline, isStaff: $isStaff, isAdmin: $isAdmin, notification: $notification, lastSeen: $lastSeen, createdAt: $createdAt, followers: $followers, following: $following, pushToken: $pushToken, name: $name, bio: $bio, imageUrl: $imageUrl, program: $program, level: $level, lastUpdatedPassword: $lastUpdatedPassword, phone:$phone, followers: $followers, following: $following location: $location)';
  }
}
