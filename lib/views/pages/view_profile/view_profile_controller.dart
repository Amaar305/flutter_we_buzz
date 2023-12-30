import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/notification_model.dart';
import 'package:hi_tweet/model/we_buzz_user_model.dart';
import 'package:hi_tweet/views/utils/custom_snackbar.dart';

import 'package:hi_tweet/views/utils/custom_full_screen_dialog.dart';

import '../../../services/notification_services.dart';
import '../dashboard/my_app_controller.dart';

class ViewProfileController extends GetxController {
  static final ViewProfileController viewProfileController = Get.find();

  var currentUserID = AppController.instance.auth.currentUser!.uid;

  // Rx<WeBuzzUser> currentWeBuxxUser =  WeBuzzUser().obs;

  final currentWeBuxxUser = Rx(AppController.instance.currentUser);

  Stream<WeBuzzUser> _streamCurrentWeBuxxUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID)
        .snapshots()
        .map((query) => WeBuzzUser.fromDocument(query));
  }

  @override
  void onInit() {
    super.onInit();
    currentWeBuxxUser.bindStream(_streamCurrentWeBuxxUser());
  }

  Future<void> followUser(WeBuzzUser targetUser) async {
    CustomFullScreenDialog.showDialog();
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserID);
      final targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(targetUser.userId);

      // Add the target user to the "following" list of the current user.
      await userRef.update({
        'following': FieldValue.arrayUnion([targetUser.userId]),
      });

      // Add the current user to the "followers" list of the target user.
      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserID]),
      }).then((_) {
        NotificationServices.sendNotification(
          notificationType: NotificationType.userFollows,
          targetUser: targetUser,
        );
      });

      CustomFullScreenDialog.cancleDialog();
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "About user",
        message: "Something went wrong, try again later!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
    }
  }

  Future<void> unfollowUser(String targetUserID) async {
    CustomFullScreenDialog.showDialog();

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserID);
      final targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(targetUserID);

      // Remove the target user from the "following" list of the current user.
      await userRef.update({
        'following': FieldValue.arrayRemove([targetUserID]),
      });

      // Remove the current user from the "followers" list of the target user.
      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserID]),
      });
      CustomFullScreenDialog.cancleDialog();
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "About user",
        message: "Something went wrong, try again later!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
    }
  }
}
