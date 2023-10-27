import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/tweet.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';

class HomeController extends GetxController {
  RxBool isSearched = RxBool(false);
 

  RxList<TweetBuzz> tweetBuzz = RxList<TweetBuzz>([]);
  RxList<TweetBuzz> searchItems = RxList<TweetBuzz>([]);

  RxBool isTyping = RxBool(false);
  RxBool isAnimated = RxBool(false);

  late TextEditingController searchEditingController;

  @override
  void onInit() {
    super.onInit();
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


  Stream<List<TweetBuzz>> _streamTweetBuzz() {
    CollectionReference collectionReference =
        FirebaseService.firebaseFirestore.collection(firebaseCampusBuzz);

    return collectionReference.snapshots().map((query) =>
        query.docs.map((item) => TweetBuzz.fromSnaption(item)).toList());
  }
}
