// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:hi_tweet/model/documents/faculty_model.dart';
import 'package:hi_tweet/model/save_buzz.dart';

// Models
import '../model/buzz_enum.dart';
import '../model/campus_announcement.dart';
import '../model/chat_model.dart';
import '../model/documents/lecture_note_model.dart';
import '../model/message_model.dart';
import '../model/documents/course_model.dart';
import '../model/documents/program_model.dart';
import '../model/notification_model.dart';
import '../model/report/bug_report_model.dart';
import '../model/report/report.dart';
import '../model/transaction/transaction.dart';
import '../model/we_buzz_user_model.dart';
import '../model/we_buzz_model.dart';

// Controller
import '../views/pages/chat/messages/messages_page.dart';
import '../views/pages/dashboard/my_app_controller.dart';

// Constants Utils
import '../views/pages/home/reply/reply_page.dart';
import '../views/pages/staff/staff_congrat_page.dart';
import '../views/pages/view_profile/view_profile_page.dart';
import '../views/registration/login_page.dart';
import 'firebase_constants.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {}

class FirebaseService {
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // for handling push notification
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Impoortance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    if (FirebaseAuth.instance.currentUser == null) {
      // if user is null then navigate to the login page
      Get.offAllNamed(MyLoginPage.routeName);
    }

    if (message.data.containsKey('type') &&
        message.data.containsKey('messageRef')) {
      NotificationType notificationType;
      String messageRef = message.data['messageRef'];

      // Convert the type to notificationType
      switch (message.data['type']) {
        case 'postCreation':
          notificationType = NotificationType.postComment;
          break;
        case 'postLiking':
          notificationType = NotificationType.postLiking;
          break;
        case 'postComment':
          notificationType = NotificationType.postComment;
          break;
        case 'postSaved':
          notificationType = NotificationType.postSaved;
          break;
        case 'userFollows':
          notificationType = NotificationType.userFollows;
          break;
        case 'groupChat':
          notificationType = NotificationType.groupChat;
          break;

        case 'chat':
          notificationType = NotificationType.chat;
          break;
        case 'staff':
          notificationType = NotificationType.staff;
          break;
        case 'classRep':
          notificationType = NotificationType.classRep;
          break;
        default:
          notificationType = NotificationType.unknown;
      }

      switch (notificationType) {
        case NotificationType.postCreation:
          // Navigate to the new post
          final buzz = await getBuzz(messageRef);
          if (buzz == null) break;

          Get.toNamed(RepliesPage.routeName, arguments: buzz);
          break;
        case NotificationType.postLiking:
          // Navigate to the liked post

          final buzz = await getBuzz(messageRef);
          if (buzz == null) break;

          Get.toNamed(RepliesPage.routeName, arguments: buzz);

          break;
        case NotificationType.postComment:
          // Navigate to the commented post

          final buzz = await getBuzz(messageRef);
          if (buzz == null) break;

          Get.toNamed(RepliesPage.routeName, arguments: buzz);

          break;
        case NotificationType.postSaved:
          // Navigate to the saved post

          final buzz = await getBuzz(messageRef);
          if (buzz == null) break;

          Get.toNamed(RepliesPage.routeName, arguments: buzz);
          break;
        case NotificationType.userFollows:
          // Navigate to the followers list page

          final targetUser = await userByID(messageRef);
          if (targetUser == null) return;

          Get.to(() => ViewProfilePage(weBuzzUser: targetUser));

          break;
        case NotificationType.groupChat:
          // Navigate to the the groupchat page
          final chatConversation = await retreiveChatConversation(messageRef);

          if (chatConversation == null) break;
          Get.to(() => MessagesPage(chat: chatConversation));
          break;

        case NotificationType.chat:
          // Navigate to the the chat page

          final chatConversation = await retreiveChatConversation(messageRef);

          if (chatConversation == null) break;
          Get.to(() => MessagesPage(chat: chatConversation));
          break;
        case NotificationType.staff:
          // Navigate to the the congratulation you're staff now page
          Get.toNamed(StaffCongratulationPage.routeName);
          break;
        case NotificationType.classRep:
          // Navigate to the the congratulation you're staff now page
          Get.toNamed(StaffCongratulationPage.routeName);
          break;
        case NotificationType.unknown:
          // Do nothing
          break;
      }
    }

    // Get.toNamed(NotificationsScreen.routeName, arguments: message);
  }

  Future initPushNotification() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _firebaseMessaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) {
        final notification = message.notification;
        if (notification == null || FirebaseAuth.instance.currentUser == null) {
          return;
        }

        final type = message.data['type'];

        // If we're in foreground, meanig in the app and we receive a notification of a chat, don't notify
        if (type == 'chat' || type == 'groupChat') return;

        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      },
    );
  }

  Future iniLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
        handleMessage(message);
      },
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }

// for getting firebase messaging token
  Future<void> getFirebaseMessagingToken() async {
    await _firebaseMessaging.requestPermission();

    await _firebaseMessaging.getToken().then((f) {
      if (f != null) {
        log("Push Token: $f");
        AppController.instance.currentUser!.pushToken = f;
        initPushNotification();
        iniLocalNotifications();
      }
    });

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  ///*User CRUDES*///

  //Create user data in firestore
  static Future createUserInFirestore(
    WeBuzzUser campusBuzzUser,
    String userId,
  ) async {
    try {
      await firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(userId)
          .set(campusBuzzUser.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // change password
  Future<bool?> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        FirebaseAuth auth = FirebaseAuth.instance;
        User user = auth.currentUser!;

        // Reauthenticate the user by confirming their current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(newPassword);

        log("Password updated successfully");
        return true;
      } on FirebaseAuthException catch (e) {
        // Handle errors, such as wrong current password or network issues
        // Provide feedback to the user
        log("Error updating password: $e");

        if (e.code.contains('INVALID_LOGIN_CREDENTIALS')) {
          toast('Current password is not current');
        } else {
          toast(e.message);
        }

        return false;
      }
    } else {
      return null;
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  // Make user a staff
  static Future<void> makeMeStaff(WeBuzzUser user, bool staff) async {
    try {
      await updateUserData(
        {
          "isStaff": staff,
        },
        user.userId,
      );
    } catch (e) {
      log("Error trying to make ${user.name} a staff");
      log(e);
    }
  }

  // get user DocumentSnapshot by uid
  static Future<DocumentSnapshot> getUserByID(String uid) async {
    DocumentSnapshot userSnapshot = await firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .doc(uid)
        .get();
    return userSnapshot;
  }

  // get user by uid
  static Future<WeBuzzUser?> userByID(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(uid)
          .get();
      return WeBuzzUser.fromDocument(userSnapshot);
    } catch (e) {
      log(e);
      log("Error trying to get user by id");
      return null;
    }
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    try {
      await firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'isOnline': isOnline,
        'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
        'pushToken': AppController.instance.currentUser!.pushToken,
      });
    } catch (e) {
      log(e);
    }
  }

  // update user data
  static Future<void> updateUserData(
      Map<String, dynamic> userData, String userId) async {
    FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .doc(userId)
        .update(userData);
  }

  // Block user
  static Future<void> blockedUser(String targetUser) async {
    await updateUserData({
      "blockedUsers": FieldValue.arrayUnion([targetUser]),
    }, FirebaseAuth.instance.currentUser!.uid);
  }

  // Unblock user
  static Future<void> unBlockedUser(String targetUser) async {
    await updateUserData({
      "blockedUsers": FieldValue.arrayRemove([targetUser]),
    }, FirebaseAuth.instance.currentUser!.uid);
  }

// Follow a user
  static Future<void> followUser(String followedUserID) async {
    try {
      await firebaseFirestore.collection(firebaseFollowersCollection).add({
        'followerId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser!.uid,
        'followingId': followedUserID,
      });
    } catch (e) {
      log('Error trying to follow user');
      log(e);
    }
  }

// Unfollow a user
  static Future<void> unfollowUser(String followedUserID) async {
    try {
      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection(firebaseFollowersCollection)
          .where(
            'followerId',
            isEqualTo: FirebaseAuth.instance.currentUser == null
                ? ''
                : FirebaseAuth.instance.currentUser!.uid,
          )
          .where('followingId', isEqualTo: followedUserID)
          .get();

      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    } catch (e) {
      log('Error trying to unfollow user');
      log(e);
    }
  }

// Check if a user is already followed
  Future<bool?> isUserFollowed(String followedUserID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .where(
            'followerId',
            isEqualTo: FirebaseAuth.instance.currentUser == null
                ? ''
                : FirebaseAuth.instance.currentUser!.uid,
          )
          .where('followingId', isEqualTo: followedUserID)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error trying to get is followed');
      log(e);
      return null;
    }
  }

// Current users following
  static Stream<List<String>> streamFollowing(String userId) {
    return firebaseFirestore
        .collection(
            firebaseFollowersCollection) // Replace with your collection name
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> event) {
      return event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final data = doc.data();
        return data['followingId'] as String;
      }).toList();
    });
  }

// Current users followers
  static Stream<List<String>> streamFollowers(String userId) {
    return firebaseFirestore
        .collection(
            firebaseFollowersCollection) // Replace with your collection name
        .where('followingId', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> event) {
      return event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final data = doc.data();
        return data['followerId'] as String;
      }).toList();
    });
  }

  static Future<List<String>> getFollowersList(String userId) async {
    List<String> followersList = [];
    try {
      final QuerySnapshot querySnapshot = await firebaseFirestore
          .collection(firebaseFollowersCollection)
          .where('followingId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        followersList.add(doc['followerId']);
      }
    } catch (e) {
      log('Error trying to get followers list');
      log(e);
    }
    return followersList;
  }

  static Future<List<String>> getFollowingList(String userId) async {
    List<String> followingList = [];
    try {
      final QuerySnapshot querySnapshot = await firebaseFirestore
          .collection(firebaseFollowersCollection)
          .where('followerId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        followingList.add(doc['followingId']);
      }
    } catch (e) {
      log('Error trying to get followers list');
      log(e);
    }
    return followingList;
  }

  static Stream<List<WeBuzzUser>> streamWeBuzzUsers() {
    return firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .snapshots()
        .map((query) => query.docs.map((user) {
              return WeBuzzUser.fromDocument(user);
            }).toList());
  }

  static Query<WeBuzzUser> queryUsers(List<String> ids) => firebaseFirestore
      .collection(firebaseWeBuzzUserCollection)
      .where('userId', whereIn: ids)
      .withConverter(
        fromFirestore: (snapshot, options) => WeBuzzUser.fromDocument(snapshot),
        toFirestore: (user, d) => user.toMap(),
      );

  ///*Buzz (Post) CRUDES*///

  // Create buzz
  static Future<String?> createBuzzInFirestore(WeBuzz weBuzz) async {
    try {
      final result = await firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .add(weBuzz.toJson());
      return result.id;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

// Update buzz
  static Future<void> updateBuzz(
    String docID,
    Map<String, dynamic> data,
  ) async {
    firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(docID)
        .update(data);
  }

// Update Reply
  static Future<void> updateReply(
    WeBuzz weBuzz,
  ) async {
    if (weBuzz.refrence == null) return;
    await weBuzz.refrence!
        .collection(firebaseRepliesCollection)
        .doc(weBuzz.docId)
        .update(weBuzz.toJson());
  }

// Delete buzz
  static Future<void> deleteBuzz(WeBuzz weBuzz) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (currentUser.uid == weBuzz.authorId) {
      String doc = weBuzz.docId;
      await firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(weBuzz.docId)
          .delete()
          .then((_) async {
        await _deleteBuzzDocument(doc);
      });
      if (weBuzz.imageUrl != null) {
        await deleteImage(weBuzz.imageUrl!);
      }

      if (weBuzz.images != null) {
        for (var image in weBuzz.images!) {
          await deleteImage(image);
        }
      }
    }
  }

// Delete buzz id for saved, report, and notification after deleting the actual post
  static Future<void> _deleteBuzzDocument(String doc) async {
    try {
      // Initialize lists to store users who saved the post and reports related to the post
      List<WeBuzzUser> savesUsers = [];
      List<Report> reporters = [];

      // Query to get users who saved the post
      final userQuery = await firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .where('savedBuzz', arrayContains: doc)
          .get();

      // Query to get reports related to the post
      final reportQuery = await firebaseFirestore
          .collection(firebaseReportCollection)
          .where('reportedItemId', isEqualTo: doc)
          .get();

      // Populate savesUsers list with users who saved the post
      for (var documentSnapshot in userQuery.docs) {
        savesUsers.add(WeBuzzUser.fromDocument(documentSnapshot));
      }

      // Iterate through savesUsers list and update each user's savedBuzz list
      for (var user in savesUsers) {
        await updateUserData({
          'savedBuzz': FieldValue.arrayRemove([doc]),
        }, user.userId);
      }

      // Populate reporters list with reports related to the post
      for (var report in reportQuery.docs) {
        reporters.add(Report.fromSnapshot(report));
      }

      // Iterate through reporters list and delete each report related to the post
      for (var report in reporters) {
        await firebaseFirestore
            .collection(firebaseReportCollection)
            .doc(report.id)
            .delete();
      }
    } catch (e) {
      // Handle errors
      log('Error trying to remove the buzz doc from firestore');
      log(e.toString());
    }
  }

// Save buzz
  static Future<void> saveBuzz(SaveBuzz saveBuzz) async {
    final QuerySnapshot snapshot = await firebaseFirestore
        .collection(firebaseSavedBuzzCollection)
        .where('buzzId', isEqualTo: saveBuzz.buzzId)
        .where('userId', isEqualTo: saveBuzz.userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Unsave
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
      // Decrement the savedCount
      updateBuzz(saveBuzz.buzzId, {
        'savedCount': FieldValue.increment(-1),
      });
    } else {
      // Save
      await firebaseFirestore
          .collection(firebaseSavedBuzzCollection)
          .add(saveBuzz.toMap())
          .then((_) async {
        // Increment the savedCount
        await updateBuzz(saveBuzz.buzzId, {
          'savedCount': FieldValue.increment(1),
        });
      });
    }
  }

/*
  static Future<void> saveBuzz(String buzzDoc) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final currentUser = AppController.instance.weBuzzUsers
        .firstWhere((user) => user.userId == userId);

    // DocumentReference for the buzz
    final buzzDocRef =
        firebaseFirestore.collection(firebaseWeBuzzCollection).doc(buzzDoc);
    /*
    if user liked the post already
      - remove it from the saves if user (Post ID)
      -remove it from the saves of the post (UserID)
    else:
      - add the post document to the user's list (Post ID)
      - add the usersid to the post's list  (UserID)
    */
    if (currentUser.savedBuzz.contains(buzzDoc)) {
      //  if user liked the post already

      // remove it from the saves if user (Post ID)
      await firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(currentUser.userId)
          .update({
        'savedBuzz': FieldValue.arrayRemove([buzzDoc])
      }).then((value) async {
        // remove it from the saves of the post (UserID)
        await buzzDocRef.update({
          'saves': FieldValue.arrayRemove([currentUser.userId]),
        });
      });
    } else {
      // add the post document to the user's list (Post ID)
      await firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(currentUser.userId)
          .update({
        'savedBuzz': FieldValue.arrayUnion([buzzDoc])
      }).then((value) async {
        // add the usersid to the post's list  (UserID)
        await buzzDocRef.update({
          'saves': FieldValue.arrayUnion([currentUser.userId]),
        });
      });
    }

    // if (currentUser.savedBuzz.contains(buzzDoc)) {
    //   await firebaseFirestore
    //       .collection(firebaseWeBuzzUserCollection)
    //       .doc(currentUser.userId)
    //       .update({
    //     'savedBuzz': FieldValue.arrayRemove([buzzDoc])
    //   }).then((value) async {
    //     await buzzDocRef.update({'savedCount': FieldValue.increment(-1)});
    //     log('Successssss remove');
    //   });
    // } else {
    //   log("not contain");
    //   await firebaseFirestore
    //       .collection(firebaseWeBuzzUserCollection)
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .update({
    //     'savedBuzz': FieldValue.arrayUnion([buzzDoc])
    //   }).then((value) async {
    //     await buzzDocRef.update({'savedCount': FieldValue.increment(1)});
    //     log('Successssss add');
    //   });
    // }
  }
*/

  // Repost a buzz
  static Future reTweetBuzz(WeBuzz webuzz, bool current) async {
    final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
    if (current) {
      // unRebuzz and decrement (rebuzzcounter) the post if user did rebuzz allready

      try {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .collection(firebaseReBuzzCollection)
            .doc(loggedInUserId)
            .delete()
            .then((value) {
          FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(webuzz.docId)
              .update({
            "reBuzzsCount": FieldValue.increment(-1),
            'rebuzzs':
                FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
          });
        });

        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .where('originalId', isEqualTo: webuzz.docId)
            .where('authorId', isEqualTo: loggedInUserId)
            .get()
            .then((value) {
          // If this query does not return anything, we gonna leave it
          if (value.docs.isEmpty) {
            return;
          }

          // Else we gonna delete it
          FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(value.docs[0].id)
              .delete();
        });

        return;
      } catch (e) {
        log('Error while trying to unRebuzz the post $e');
      }
    } // webuzz.reBuzzsCount = webuzz.reBuzzsCount + 1;
    WeBuzz retweetedBux = webuzz.copyWith(
      authorId: FirebaseAuth.instance.currentUser!.uid,
      createdAt: Timestamp.now(),
      originalId: webuzz.docId,
      buzzType: BuzzType.rebuzz.name,
    );

    // rebuzz the post if user hasn't rebuzz the post

    try {
      await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(webuzz.docId)
          .collection(firebaseReBuzzCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({}).then((value) {
        FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .update({
          "reBuzzsCount": FieldValue.increment(1),
          'rebuzzs':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      });

      await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .add(retweetedBux.toJson());
    } catch (e) {
      log('Error while trying to unRebuzz the post $e');
    }
  }

  static Future<void> likePost(WeBuzz webuzz, bool current) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    if (current) {
      try {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .collection(firebaseLikesPostCollection)
            .doc(userId)
            .delete()
            .then((value) async {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(webuzz.docId)
              .update({'likesCount': FieldValue.increment(-1)});
        });
      } catch (e) {
        log(e);
      }
    }
    if (!current) {
      try {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .collection(firebaseLikesPostCollection)
            .doc(userId)
            .set({'userId': userId}).then((value) async {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(webuzz.docId)
              .update({'likesCount': FieldValue.increment(1)});
        });
      } catch (e) {
        log(e);
      }
    }
  }

  static Future<void> savePost(WeBuzz webuzz, bool current) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    if (current) {
      try {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .collection(firebaseSavedBuzzCollection)
            .doc(userId)
            .delete()
            .then((value) async {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(webuzz.docId)
              .update({'savedCount': FieldValue.increment(-1)});
        });
      } catch (e) {
        log(e);
      }
    }
    if (!current) {
      try {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .collection(firebaseSavedBuzzCollection)
            .doc(userId)
            .set({'userId': userId}).then((value) async {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(webuzz.docId)
              .update({'savedCount': FieldValue.increment(1)});
        });
      } catch (e) {
        log(e);
      }
    }
  }

  static Stream<bool> getCurrentUserLikes(WeBuzz webuzz) {
    try {
      return FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(webuzz.docId)
          .collection(firebaseLikesPostCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .map((snap) {
        return snap.exists;
      });
    } catch (e) {
      return const Stream.empty();
    }
  }

  static Stream<bool> getCurrentUserSaved(WeBuzz webuzz) {
    try {
      return FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(webuzz.docId)
          .collection(firebaseSavedBuzzCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .map((snap) {
        return snap.exists;
      });
    } catch (e) {
      return Stream.value(false);
    }
  }

  static WeBuzz? _getPostSnap(DocumentSnapshot snapshot) {
    return snapshot.exists ? WeBuzz.fromDocumentSnapshot(snapshot) : null;
  }

  static Future<WeBuzz> getPostById(String id) async {
    DocumentSnapshot documentSnap = await FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(id)
        .get();
    return _getPostSnap(documentSnap)!;
  }

  static Stream<bool> getCurrentUserReBuzz(WeBuzz weBuzz) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(weBuzz.docId)
        .collection(firebaseReBuzzCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snap) => snap.exists);
  }

  static Future<void> toggleRetweetPost(WeBuzz webuzz) async {
    // chech if the user has already retweeted
    final retweet = await FirebaseService.firebaseFirestore
        .collection(firebaseReBuzzCollection)
        .where('originalId', isEqualTo: webuzz.docId)
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    final postRef = FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(webuzz.docId);

    if (retweet.docs.isEmpty) {
      // user has not retweet,

      WeBuzz retweetedBux = webuzz.copyWith(
        authorId: FirebaseAuth.instance.currentUser!.uid,
        createdAt: Timestamp.now(),
        originalId: webuzz.docId,
        buzzType: BuzzType.rebuzz.name,
      );
      await FirebaseService.firebaseFirestore
          .collection(firebaseReBuzzCollection)
          .add(retweetedBux.toJson());

      // increment the retweet count
      postRef.update({"reBuzzsCount": FieldValue.increment(1)});
    } else {
      // user has retweeted, unretweeted
      final retweetId = retweet.docs.first.id;

      // delete the retweet document
      await FirebaseService.firebaseFirestore
          .collection(firebaseReBuzzCollection)
          .doc(retweetId)
          .delete();

      // decrement the retweet count in the original post
      postRef.update({"reBuzzsCount": FieldValue.increment(-1)});
    }
  }

  static Stream<bool> postIsRetweeted(String docId) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseReBuzzCollection)
        .where('originalId', isEqualTo: docId)
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((query) => query.docs.map((doc) {
              return doc.exists;
            }).first);
  }

  static Stream<List<WeBuzz>> getReplies(WeBuzz weBuzz) {
    return weBuzz.refrence!
        .collection(firebaseRepliesCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((e) => e.docs.map((e) => WeBuzz.fromDocumentSnapshot(e)).toList());

    // return _getListPostSnap(snapshot);
  }

// Report buzz
  static Future<void> reportBuzz(
    String docID,
    Report report,
    bool isBuzz,
  ) async {
    await firebaseFirestore
        .collection(firebaseReportCollection)
        .add(report.toMap())
        .then((value) async {
      if (report.reportType == ReportType.buzz || isBuzz) {
        await firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(docID)
            .update({
          "reportCount": FieldValue.increment(1),
          'reportBuzz': FieldValue.arrayUnion([report.reporterUserId]),
        });
      } else if (report.reportType == ReportType.user) {
        await updateUserData({
          'reportUsers': FieldValue.arrayUnion([report.reportedItemId])
        }, report.reporterUserId);
      }
    });
  }

  // Publishe/Unpublishe a buzz
  static Future<void> publisheAndUnpublisheBuzz({
    required bool isPublishe,
    required WeBuzz weBuzz,
  }) async {
    // checking if current user own the post
    if (FirebaseAuth.instance.currentUser!.uid == weBuzz.authorId) {
      log(weBuzz.isPublished);
      if (!weBuzz.isPublished) {
        await updateBuzz(weBuzz.docId, {'isPublished': true});
      } else {
        await updateBuzz(weBuzz.docId, {'isPublished': false});
      }
    }
  }

  // Get Post
  Future<WeBuzz?> getBuzz(String buzzID) async {
    try {
      final doc = await firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(buzzID)
          .get();
      final buzz = WeBuzz.fromDocumentSnapshot(doc);

      return buzz;
    } catch (e) {
      log("Error trying to get post by id");
      log(e);
      return null;
    }
  }

  ///*Image CRUDES*///

  //Upload image
  static Future<String?> uploadImage(File imageFile, String folderName) async {
    String imageUrl;

    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("$folderName/${DateTime.now()}.jpg");
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      log("Error uploading image: $e");
      return null;
    }
  }

  // Upload file
  static Future<String?> uploadFile(
    File doc,
    String folderName,
    String format,
  ) async {
    String docUrl;

    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("$folderName/${DateTime.now()}.$format");
      UploadTask uploadTask = storageReference.putFile(doc);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      docUrl = await taskSnapshot.ref.getDownloadURL();
      return docUrl;
    } catch (e) {
      log("Error uploading file: $e");
      return null;
    }
  }

  // Delete image
  static Future<void> deleteImage(String imageUrl) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.refFromURL(imageUrl);
      await storageReference.delete();
      log("Image deleted successfully");
    } catch (e) {
      log("Error deleting image: $e");
    }
  }

  ///* Chat CRUDES*///

  //Get last Message
  Future<QuerySnapshot> getLastMessageForChat(String chatID) async {
    return firebaseFirestore
        .collection(firebaseChatCollection)
        .doc(chatID)
        .collection(firebaseMessageCollection)
        .orderBy('sentTime', descending: true)
        .limit(1)
        .get();
  }

  // Stream Last Message
  Stream<QuerySnapshot> streamLastMessageForChat(String chatID) {
    return firebaseFirestore
        .collection(firebaseChatCollection)
        .doc(chatID)
        .collection(firebaseMessageCollection)
        .orderBy('sentTime', descending: true)
        .limit(1)
        .snapshots();
  }

  // Get Or Create Chat
  static Future<List<QueryDocumentSnapshot>> getOrCreateChat(
      String userId) async {
    final querySnapshot = await FirebaseService.firebaseFirestore
        .collection(firebaseChatCollection)
        .where('members', arrayContains: userId)
        .get();

    // Handle the result
    List<QueryDocumentSnapshot> matchingChats = querySnapshot.docs
        .where(
          (doc) =>
              doc['members'].length == 2 &&
              doc['members'].contains(FirebaseAuth.instance.currentUser!.uid) &&
              doc['members'].contains(userId),
        )
        .toList();
    return matchingChats;
  }

  // Send chat message
  static Future<String?> sendChatMessageToChat(
      MessageModel message, String chatID) async {
    try {
      var result = await firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .collection(firebaseMessageCollection)
          .add(message.toMap());
      return result.id;
    } catch (e) {
      log(e);
      return null;
    }
  }

  // Delete a specific chat
  static Future<void> deleteChat(String chatID) async {
    try {
      await firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .delete();
    } catch (e) {
      log(e);
    }
  }

  // Exit a group chat
  static Future<void> exitGroupChat(String chatID, String userID) async {
    try {
      await updateChatData(chatID, {
        'members': FieldValue.arrayRemove([userID])
      });
    } catch (e) {
      log(e);
    }
  }

  // Add a user in group chat
  static Future<void> addUserInGroupChat(String chatID, String userID) async {
    try {
      final members = await firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .get();

      if (members['members'].contains(userID)) {
        toast('Users already exist');
      }

      await updateChatData(chatID, {
        'members': FieldValue.arrayUnion([userID])
      });
    } catch (e) {
      log(e);
    }
  }

  // Delete a specific chat message
  static Future<void> deleteChatMessage(
    MessageModel message,
    String chatID,
  ) async {
    try {
      await firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .collection(firebaseMessageCollection)
          .doc(message.docID)
          .delete();
    } catch (e) {
      log(e);
    }
  }

  // Update a specific chat
  static Future<void> updateChatData(
    String chatID,
    Map<String, dynamic> chatData,
  ) async {
    try {
      await firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .update(chatData);
    } catch (e) {
      log(e);
    }
  }

  // Update a specific chat message
  static Future<void> updateChatMessageData(
    String chatID,
    String messageDoc,
    Map<String, dynamic> chatData,
  ) async {
    try {
      await firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .collection(firebaseMessageCollection)
          .doc(messageDoc)
          .update(chatData);
    } catch (e) {
      log(e);
    }
  }

  // Create Chat Message
  static Future<DocumentReference?> createChat(
    Map<String, dynamic> data,
  ) async {
    try {
      DocumentReference chat =
          await firebaseFirestore.collection(firebaseChatCollection).add(data);
      return chat;
    } catch (e) {
      log(e);
      return null;
    }
  }

  // Read Chat Conversation
  Future<ChatConversation?> retreiveChatConversation(String chatID) async {
    try {
      // Get Users in chat
      List<WeBuzzUser> members = [];
      final chatData = await firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .get();

      // iterate through all members uids
      for (var uid in chatData['members']) {
        // Get user's info using the iterated uid, in firestore
        DocumentSnapshot userSnapshot = await FirebaseService.getUserByID(uid);

        // Add them to the members list
        members.add(WeBuzzUser.fromDocument(userSnapshot));
      }

      // last message
      List<MessageModel> messages = [];
      QuerySnapshot chatMessages =
          await FirebaseService().getLastMessageForChat(chatData.id);
      if (chatMessages.docs.isNotEmpty) {
        messages
            .add(MessageModel.fromDocumentSnapshot(chatMessages.docs.first));
      }

      ChatConversation conversation = ChatConversation(
        uid: chatData.id,
        currentUserId: FirebaseAuth.instance.currentUser != null
            ? FirebaseAuth.instance.currentUser!.uid
            : '',
        group: chatData['is_group'],
        activity: chatData['is_activity'],
        members: members,
        createdAt: chatData['created_at'],
        messages: messages,
        groupTitle: chatData['group_title'],
        createdBy: chatData['created_by'],
        recentTime: Timestamp.now(),
      );
      return conversation;
    } catch (e) {
      log("Error trying to get conversation chat");
      log(e);
      return null;
    }
  }

  ///* Courses And Lecture Notes CRUDES *///

  // Create course
  static Future<void> createCourse(CourseModel courseModel) async {
    try {
      await firebaseFirestore
          .collection(firebaseCoursesCollection)
          .add(courseModel.toJson());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Delete course
  static Future<void> deleteCourse(String coursesID) async {
    try {
      await firebaseFirestore
          .collection(firebaseCoursesCollection)
          .doc(coursesID)
          .delete();
    } catch (e) {
      log('Error trying to delete a course');
      log(e);
    }
  }

  // Delete Program
  static Future<void> deleteProgram(String programID) async {
    try {
      await firebaseFirestore
          .collection(firebaseProgramsCollection)
          .doc(programID)
          .delete();
    } catch (e) {
      log('Error trying to delete a program');
      log(e);
    }
  }

  // Create Program
  static Future<void> createProgram(ProgramModel programModel) async {
    try {
      await firebaseFirestore
          .collection(firebaseProgramsCollection)
          .add(programModel.toJson());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Create Lecture Note
  static Future<void> createLectureNote(
      LectureNoteModel lectureNoteModel) async {
    await firebaseFirestore
        .collection(firebaseLectureNotesCollection)
        .add(lectureNoteModel.toMap());
  }

  // Create Faculty
  static Future<void> createFaculty(FacultyModel facultyModel) async {
    await firebaseFirestore
        .collection(firebaseFacultyCollection)
        .add(facultyModel.toMap());
  }

  // Delete Lecture Note
  static Future<void> deleteLectureNote(String id) async {
    await firebaseFirestore
        .collection(firebaseLectureNotesCollection)
        .doc(id)
        .delete();
  }

  ///* Announcement CRUDES*///

  // Create Announcement
  static Future<void> createAnnouncement(
      CampusAnnouncement campusAnnouncement) async {
    await firebaseFirestore
        .collection(firebaseAnnouncementCollection)
        .add(campusAnnouncement.toMap());
  }

  // Update Announcement
  static Future<void> updateAnnouncement(
    String id,
    Map<String, dynamic> data,
  ) async {
    await firebaseFirestore
        .collection(firebaseAnnouncementCollection)
        .doc(id)
        .update(data);
  }

  // Delete Announcement
  static Future<void> deleteAnnouncement(String id) async {
    await firebaseFirestore
        .collection(firebaseAnnouncementCollection)
        .doc(id)
        .delete();
  }

  ///* Notification CRUDES*///

  // Create Notification
  static Future<void> createNotification(
      NotificationModel notificationModel) async {
    try {
      await firebaseFirestore
          .collection(firebaseNotificationCollection)
          .add(notificationModel.toMap());
    } catch (e) {
      log(e.toString());
      log("Error trying to create notification in firestore");
    }
  }

  // Update Notification
  static Future<void> updateNotification(
      String id, Map<String, dynamic> notifiactionMap) async {
    try {
      await firebaseFirestore
          .collection(firebaseNotificationCollection)
          .doc(id)
          .update(notifiactionMap);
    } catch (e) {
      log(e.toString());
      log("Error trying to create notification in firestore");
    }
  }

  ///* Transaction CRUDES *///

  //  Create Transaction
  static Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await firebaseFirestore
          .collection(firebaseTransactionCollection)
          .add(transaction.toMap());
    } catch (e) {
      log("Error tyring to create a transaction");
      log(e);
    }
  }

  //  Delete Transaction
  static Future<void> deleteTransaction(String id) async {
    try {
      await firebaseFirestore
          .collection(firebaseTransactionCollection)
          .doc(id)
          .delete();
    } catch (e) {
      log("Error tyring to create a transaction");
      log(e);
    }
  }

  static Future<void> reportBug(ReportBug reportBug) async {
    try {
      await firebaseFirestore
          .collection(firebaseReportBugsCollection)
          .add(reportBug.toMap());
    } catch (e) {
      log('Error trying to create report bug');
      log(e);
    }
  }

  static Future<void> sponsorTracker(SponsorTracker sponsorTracker) async {
    try {
      await firebaseFirestore
          .collection(firebaseSponsorTrackerCollection)
          .add(sponsorTracker.toMap());
    } catch (e) {
      log('Error trying to create report bug');
      log(e);
    }
  }

  static Future<void> chatWithStaff() async {
    try {
      await firebaseFirestore
          .collection(firebaseChatWithStaffCollection)
          .add({});
    } catch (e) {
      log('Error trying to create report bug');
      log(e);
    }
  }
}

class SponsorTracker {
  final String id;
  final String sponsorId;
  final String userId;

  final bool isWhatsapp;
  final Timestamp createdAt;

  SponsorTracker({
    required this.id,
    required this.sponsorId,
    required this.userId,
    required this.isWhatsapp,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sponsorId': sponsorId,
      'userId': userId,
      'isWhatsapp': isWhatsapp,
      'createdAt': createdAt,
    };
  }

  factory SponsorTracker.fromMap(Map<String, dynamic> map, String id) {
    return SponsorTracker(
      id: id,
      sponsorId: map['sponsorId'] as String,
      userId: map['userId'] as String,
      isWhatsapp: map['isWhatsapp'] as bool,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  factory SponsorTracker.fromDocument(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return SponsorTracker.fromMap(data, snapshot.id);
  }
}
