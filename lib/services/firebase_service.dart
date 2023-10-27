import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:io';

import '../model/tweet.dart';
import '../model/user.dart';
import 'firebase_constants.dart';

class FirebaseService {
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static Future createUserInFirestore(
    CampusBuzzUser campusBuzzUser,
    String userId,
  ) async {
    try {
      await firebaseFirestore
          .collection(firebaseCampusBuzzUser)
          .doc(userId)
          .set(campusBuzzUser.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future createTweetInFirestore(TweetBuzz tweet) async {
    try {
      await firebaseFirestore.collection(firebaseCampusBuzz).add(tweet.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<String?> uploadImage(File imageFile, String folderName) async {
    String imageUrl;

    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child("$folderName/${DateTime.now()}.jpg");
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
}
