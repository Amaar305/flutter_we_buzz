import 'package:cloud_firestore/cloud_firestore.dart';

class WeBuzzUser {
  final String userId;
  final String email;
  final String name;
  final String username;
  final String lastActive;
  late String pushToken;
  final String bio;
  final String location;

  final String? imageUrl;
  final String? program;
  final String? level;
  final String? phone;
  final String? lastBook;

  final bool isOnline;
  final bool isStaff;
  final bool isAdmin;
  final bool isSuspended;
  final bool isUndergraduate;
  final bool notification;
  final bool postNotifications;
  final bool likeNotifications;
  final bool commentNotifications;
  final bool saveNotifications;
  final bool followNotifications;
  final bool userBlockNotifications;
  final bool chatMessageNotifications;
  final bool sponsor;
  final bool bot;
  final bool premium;
  final bool isCompleteness;
  final bool isClassRep;
  final bool hasPaid;
  final bool isVerified;

  final int followers;
  final int following;

  final List<String> blockedUsers;
  final List<String> reportUsers;
  final List<String> bookmarks;

  final Timestamp createdAt;
  final Timestamp? lastUpdatedPassword;

  final DirectMessagePrivacy directMessagePrivacy;
  final DirectMessagePrivacy onlineStatusIndicator;
  WeBuzzUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.isOnline,
    required this.isStaff,
    required this.isAdmin,
    required this.isUndergraduate,
    required this.notification,
    required this.premium,
    required this.isVerified,
    required this.createdAt,
    required this.lastActive,
    required this.location,
    required this.username,
    this.bot = false,
    this.isClassRep = false,
    this.isCompleteness = false,
    this.pushToken = '',
    this.blockedUsers = const [],
    this.bookmarks = const [],
    this.bio = 'Hey, I\'m using We Buzz!',
    this.directMessagePrivacy = DirectMessagePrivacy.everyone,
    this.onlineStatusIndicator = DirectMessagePrivacy.everyone,
    this.isSuspended = false,
    this.sponsor = false,
    this.postNotifications = true,
    this.likeNotifications = true,
    this.commentNotifications = true,
    this.saveNotifications = true,
    this.followNotifications = true,
    this.userBlockNotifications = true,
    this.chatMessageNotifications = true,
    this.reportUsers = const [],
    this.imageUrl,
    this.program,
    this.level,
    this.phone,
    this.lastUpdatedPassword,
    this.hasPaid = false,
    this.lastBook,
    this.followers = 0,
    this.following = 0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'email': email,
      'name': name,
      'username': username,
      'lastActive': lastActive,
      'pushToken': pushToken,
      'bio': bio,
      'location': location,
      'isOnline': isOnline,
      'isStaff': isStaff,
      'isAdmin': isAdmin,
      'isSuspended': isSuspended,
      'notification': notification,
      'postNotifications': postNotifications,
      'likeNotifications': likeNotifications,
      'commentNotifications': commentNotifications,
      'saveNotifications': saveNotifications,
      'followNotifications': followNotifications,
      'userBlockNotifications': userBlockNotifications,
      'chatMessageNotifications': chatMessageNotifications,
      'premium': premium,
      'isVerified': isVerified,
      'followers': followers,
      'following': following,
      'blockedUsers': blockedUsers,
      'createdAt': createdAt,
      'directMessagePrivacy': directMessagePrivacy.name,
      'onlineStatusIndicator': onlineStatusIndicator.name,
      'imageUrl': imageUrl,
      'program': program,
      'level': level,
      'phone': phone,
      'lastUpdatedPassword': lastUpdatedPassword,
      'sponsor': sponsor,
      'reportUsers': reportUsers,
      'bot': bot,
      'isClassRep': isClassRep,
      'isCompleteness': isCompleteness,
      'isUndergraduate': isUndergraduate,
      'hasPaid': hasPaid,
      'lastBook': lastBook,
      'bookmarks': bookmarks,
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

    List<String> bookmarks = List<String>.from(map['bookmarks']);
    List<String> blockedUsers = List<String>.from(map['blockedUsers']);
    List<String> reportUsers = List<String>.from(map['reportUsers']);

    return WeBuzzUser(
      userId: map['userId'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      isOnline: map['isOnline'] as bool,
      isStaff: map['isStaff'] as bool,
      isAdmin: map['isAdmin'] as bool,
      notification: map['notification'] as bool,
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
      premium: map['premium'] as bool,
      isVerified: map['isVerified'] as bool,
      followers: map['followers'] as int,
      following: map['following'] as int,
      blockedUsers: blockedUsers,
      directMessagePrivacy: directMessagePrivacy,
      onlineStatusIndicator: onlineStatusIndicator,
      chatMessageNotifications: map['chatMessageNotifications'] as bool,
      commentNotifications: map['commentNotifications'] as bool,
      followNotifications: map['followNotifications'] as bool,
      isSuspended: map['isSuspended'] as bool,
      likeNotifications: map['likeNotifications'] as bool,
      postNotifications: map['postNotifications'] as bool,
      saveNotifications: map['saveNotifications'] as bool,
      userBlockNotifications: map['userBlockNotifications'] as bool,
      bot: map['bot'] as bool,
      hasPaid: map['hasPaid'] as bool,
      sponsor: map['sponsor'] as bool,
      reportUsers: reportUsers,
      isClassRep: map['isClassRep'] as bool,
      isUndergraduate: map['isUndergraduate'] as bool,
      lastBook: map['lastBook'] as String?,
      bookmarks: bookmarks,
       
    );
  }

  @override
  String toString() {
    return 'CampusBuzzUser(userId: $userId, email: $email, isOnline: $isOnline, isStaff: $isStaff, isAdmin: $isAdmin, notification: $notification,  createdAt: $createdAt, followers: pushToken: $pushToken, name: $name, bio: $bio, imageUrl: $imageUrl, program: $program, level: $level, lastUpdatedPassword: $lastUpdatedPassword, phone:$phone, location: $location, username: $username)';
  }
}

enum DirectMessagePrivacy {
  everyone,
  followers,
  following,
  mutual,
  unknown,
}
