import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/sponsor/sponsorship.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:io';

// Models
import '../model/chat_message_model.dart';
import '../model/documents/course_model.dart';
import '../model/documents/program_model.dart';
import '../model/sponsor/user_sponsor.dart';
import '../model/we_buzz_user_model.dart';
import '../model/we_buzz_model.dart';

// Controller
import '../views/pages/dashboard/my_app_controller.dart';

// Constants Utils
import '../views/pages/notification/notification_screen.dart';
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
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    Get.toNamed(NotificationsScreen.routeName, arguments: message);
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

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) {
        final notification = message.notification;
        if (notification == null) return;
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
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

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

// Create buzz
  static Future createBuzzInFirestore(WeBuzz weBuzz) async {
    try {
      await firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .add(weBuzz.toJson());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// Update buzz
  static Future<void> updateBuzz(
      String docID, Map<String, dynamic> data) async {
    firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(docID)
        .update(data);
  }

// Delete buzz
  static Future<void> deleteBuzz(WeBuzz weBuzz) async {
    if (FirebaseAuth.instance.currentUser!.uid == weBuzz.authorId) {
      await firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(weBuzz.docId)
          .delete();
    }
  }

// Save buzz
  static Future<void> saveBuzz(String buzzDoc) async {
    // user id as the doc id
    final userID = FirebaseAuth.instance.currentUser!.uid;

    WeBuzzUser currentUser = AppController.instance.weBuzzUsers.firstWhere(
      (user) => user.userId == FirebaseAuth.instance.currentUser!.uid,
    );

    final buzzDocRef =
        firebaseFirestore.collection(firebaseWeBuzzCollection).doc(buzzDoc);

    if (currentUser.savedBuzz.contains(buzzDoc)) {
      await firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(userID)
          .update({
        'savedBuzz': FieldValue.arrayRemove([buzzDoc])
      }).then((value) async {
        await buzzDocRef.update({'savedCount': FieldValue.increment(-1)});
        log('Successssss remove');
      });
    } else {
      log("not contain");
      await firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'savedBuzz': FieldValue.arrayUnion([buzzDoc])
      }).then((value) async {
        await buzzDocRef.update({'savedCount': FieldValue.increment(1)});
        log('Successssss add');
      });
    }
  }

// Report buzz
  static Future<void> reportBuzz(
      String buzzDocID, Map<String, dynamic> data) async {
    await firebaseFirestore
        .collection(firebaseReportBuzzCollection)
        .add(data)
        .then((value) async {
      await firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(buzzDocID)
          .update({
        "reportCount": FieldValue.increment(1),
      });
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

// get all webuzz users
  static Future<QuerySnapshot> getAllUsers({String? name}) {
    Query query = firebaseFirestore.collection(firebaseWeBuzzUserCollection);
    if (name != null) {
      query = query
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: "${name}z");
    }
    return query.get();
  }

// get user by uid
  static Future<DocumentSnapshot> getUserByID(String uid) async {
    DocumentSnapshot userSnapshot = await firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .doc(uid)
        .get();
    return userSnapshot;
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

  Stream<QuerySnapshot> getChatForUser(String uid) {
    return firebaseFirestore
        .collection(firebaseChatCollection)
        .where('members', arrayContains: uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageForChat(String chatID) async {
    return firebaseFirestore
        .collection(firebaseChatCollection)
        .doc(chatID)
        .collection(firebaseMessageCollection)
        .orderBy('sentTime', descending: true)
        .limit(1)
        .get();
  }

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

// update message read
  Future<void> updateMessageReadStatus(
      String chatID, ChatMessage message) async {
    await FirebaseService.firebaseFirestore
        .collection(firebaseChatCollection)
        .doc(chatID)
        .collection(firebaseMessageCollection)
        .doc(message.docID)
        .update({
      'read': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

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

  static Future<void> createSponsorUser(UserSponsor userSponsor) async {
    await firebaseFirestore
        .collection(firebaseSponsorUserCollection)
        .add(userSponsor.toMap());
  }

  static Future<void> createSponsorship(Sponsorship sponsorship) async {
    await firebaseFirestore
        .collection(firebaseSponsorshipCollection)
        .add(sponsorship.toMap());
  }
}
