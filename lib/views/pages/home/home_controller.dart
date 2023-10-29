import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/buzz_enum.dart';
import '../../../model/webuzz_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';

class HomeController extends GetxController {
  static final HomeController homeController = Get.find();
  RxBool isSearched = RxBool(false);

  RxList<WeBuzz> tweetBuzz = RxList<WeBuzz>([]);
  RxList<WeBuzz> searchItems = RxList<WeBuzz>([]);

  RxBool isTyping = RxBool(false);
  RxBool isAnimated = RxBool(false);

  late TextEditingController searchEditingController;

  @override
  void onInit() {
    super.onInit();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message: $message');
      if (FirebaseAuth.instance.currentUser != null) {
        if (message.toString().contains('pause')) {
          FirebaseService.updateActiveStatus(false);
        }
        if (message.toString().contains('resume')) {
          FirebaseService.updateActiveStatus(true);
        }
      }
      return Future.value(message);
    });
    tweetBuzz.bindStream(_streamTweetBuzz());
    searchEditingController = TextEditingController();
  }

  void searchTweet() {
    isTyping.value = true;
    searchItems.value = tweetBuzz
        .where((tweet) => tweet.content.toLowerCase().contains(
            searchEditingController.text.removeAllWhitespace.toLowerCase()))
        .toList();
  }

  void clearAndSearch() {
    isTyping.value = false;
    searchEditingController.clear();
    update();
  }

  void search() {
    if (isSearched.isFalse) {
      isSearched.value = true;
      if (kDebugMode) {
        print('Search!!!');
      }
    } else {
      isSearched.value = false;

      if (kDebugMode) {
        print('Unsearch!!!');
      }
    }

    update();
  }

  Stream<List<WeBuzz>> _streamTweetBuzz() {
    CollectionReference collectionReference =
        FirebaseService.firebaseFirestore.collection(firebaseWeBuzz);

    return collectionReference
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((item) => WeBuzz.fromDocumentSnapshot(item))
            .toList());
  }

  void updateViews(WeBuzz buzz, String field) async {
    if (FirebaseAuth.instance.currentUser != null) {
      final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
      CustomFullScreenDialog.showDialog();

      if (buzz.likes.contains(loggedInUserId)) {
        try {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzz)
              .doc(buzz.docId)
              .update({
            field: FieldValue.arrayRemove([loggedInUserId])
          }).whenComplete(() => CustomFullScreenDialog.cancleDialog());
          log('Successifully removedddddddddddddddddddddddddddddddddddddddddddddddd');
        } catch (e) {
          CustomFullScreenDialog.cancleDialog();
          log('errorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');
        }
      } else {
        try {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzz)
              .doc(buzz.docId)
              .update({
            field: FieldValue.arrayUnion([loggedInUserId])
          }).whenComplete(() => CustomFullScreenDialog.cancleDialog());
          log('Successifully likessssssssssssssssssssssssssssssssssssssssss');
        } catch (e) {
          CustomFullScreenDialog.cancleDialog();
          log('errorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');
        }
      }
    }
  }

  // Repost a buzz
  void reTweetBuzz(WeBuzz currentBuzz) async {
    // Checking if currentuser is logged In
    if (FirebaseAuth.instance.currentUser != null) {
      // Getting currentuser info
      final currentUser = FirebaseAuth.instance.currentUser;

      // Creating copy of the currentBuzz (Post)
      WeBuzz repost = currentBuzz.copyWith(
        originalId: currentUser!.uid,
        buzzType: 'rebuzz',
        createdAt: Timestamp.now(),
      );

      // Checking if currentuser's Id is contain in the current post, so that user can delete his tweet
      if (currentBuzz.reposts.contains(currentUser.uid)) {
        // Checking if currentuser's Id is
        if (repost.originalId == currentUser.uid) {
          CustomFullScreenDialog.showDialog();
          try {
            await FirebaseService.firebaseFirestore
                .collection(firebaseWeBuzz)
                .doc(repost.docId)
                .delete();

            await Future.delayed(const Duration(milliseconds: 300));

            await FirebaseService.firebaseFirestore
                .collection(firebaseWeBuzz)
                .doc(currentBuzz.docId)
                .update({
              'reBuzzCount': currentBuzz.reBuzzCount - 1,
              'reposts': FieldValue.arrayRemove([currentUser.uid])
            }).whenComplete(() => CustomFullScreenDialog.cancleDialog());
          } catch (e) {
            CustomFullScreenDialog.cancleDialog();
            CustomSnackBar.showSnackBAr(
              context: Get.context,
              title: "Warning!",
              message: "Something wen't wrong, try again later!",
              backgroundColor:
                  Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
            );
          }
        }
      } else {
        CustomFullScreenDialog.showDialog();
        try {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzz)
              .add(repost.toJson());

          await Future.delayed(const Duration(milliseconds: 300));

          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzz)
              .doc(currentBuzz.docId)
              .update({
            'reBuzzCount': FieldValue.increment(1),
            'reposts': FieldValue.arrayUnion([currentUser.uid])
          }).whenComplete(() {
            CustomFullScreenDialog.cancleDialog();
          });
        } catch (e) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBAr(
            context: Get.context,
            title: "Warning!",
            message: "Something wen't wrong, try again later!",
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
        }
      }
    }
  }

  Future reBuzz(WeBuzz webuzz, bool current) async {
    final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
    if (current) {
      webuzz.reBuzzCount = webuzz.reBuzzCount - 1;

      await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzz)
          .doc(webuzz.docId)
          .collection(firebaseReBuzz)
          .doc(loggedInUserId)
          .delete();

      await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzz)
          .where('originalId', isEqualTo: webuzz.docId)
          .where('authorId', isEqualTo: loggedInUserId)
          .get()
          .then((value) {
        if (value.docs.isEmpty) {
          return;
        }

        FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzz)
            .doc(value.docs[0].id)
            .delete();
      });

      // Todo remove the post

      return;
    }
    webuzz.reBuzzCount = webuzz.reBuzzCount - 1;

    await FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzz)
        .doc(webuzz.docId)
        .collection(firebaseReBuzz)
        .doc(loggedInUserId)
        .set({});

    await FirebaseService.firebaseFirestore.collection(firebaseWeBuzz).add({
      'authorId': loggedInUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'originalId': webuzz.docId,
      'buzzType': BuzzType.rebuzz.name,
    });
  }
}
