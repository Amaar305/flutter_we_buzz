import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import 'actions_enum.dart';

class ActionUsersController extends GetxController {
  static final ActionUsersController instance = Get.find();
  RxList<String> currenttUsersFollowers = RxList<String>([]);
  RxList<String> currenttUsersFollowing = RxList<String>([]);
  List<String> ids = [];

  @override
  void onInit() {
    super.onInit();
    currenttUsersFollowers.bindStream(FirebaseService.streamFollowers(
        FirebaseAuth.instance.currentUser!.uid));
    currenttUsersFollowing.bindStream(FirebaseService.streamFollowing(
        FirebaseAuth.instance.currentUser!.uid));
  }

  String _collection(type) {
    switch (type) {
      case ActionUsersPageType.likes:
        return firebaseLikesPostCollection;

      case ActionUsersPageType.views:
        return firebaseViewsCollection;

      case ActionUsersPageType.saves:
        return firebaseSavedBuzzCollection;

      default:
        return firebaseViewsCollection;
    }
  }

  void fetchUsersId(String id, ActionUsersPageType type) async {
    try {
      final d = await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(id)
          .get();

      final likesDoc = await d.reference.collection(_collection(type)).get();

      for (var element in likesDoc.docs) {
        ids.add(element.id);
      }
    } catch (e) {
      log("Error trying to fetch buzz likea iinfo");
      log(e.toString());
    }
    update();
  }

 
}
