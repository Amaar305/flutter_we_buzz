import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hi_tweet/views/pages/dashboard/my_app_controller.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:io';

import '../model/chat_message.dart';
import '../model/we_buzz_user_model.dart';
import '../model/we_buzz_model.dart';
import 'firebase_constants.dart';

class FirebaseService {
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

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
  Future<QuerySnapshot> getUser({String? name}) {
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
  static Future<void> updateUserData(Map<String, dynamic> userData) async {
    FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(userData);
  }

// Block user
  static Future<void> blockedUser(String targetUser) async {
    await updateUserData({
      "blockedUsers": FieldValue.arrayUnion([targetUser]),
    });
  }

// Unblock user
  static Future<void> unBlockedUser(String targetUser) async {
    await updateUserData({
      "blockedUsers": FieldValue.arrayRemove([targetUser]),
    });
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
  static Future<void> sendChatMessageToChat(
      ChatMessage message, String chatID) async {
    try {
      await firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .collection(firebaseMessageCollection)
          .add(message.toMap());
    } catch (e) {
      log(e);
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

// Delete a specific chat
  static Future<void> deleteChatMessage(
      ChatMessage message, String chatID) async {
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
      Map<String, dynamic> data) async {
    try {
      DocumentReference chat =
          await firebaseFirestore.collection(firebaseChatCollection).add(data);
      return chat;
    } catch (e) {
      log(e);
      return null;
    }
  }
}
