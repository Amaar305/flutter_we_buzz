import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/notification_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_service.dart';
import '../../../services/notification_services.dart';
import '../../utils/custom_snackbar.dart';
import '../dashboard/my_app_controller.dart';

class ViewProfileController extends GetxController {
  static final ViewProfileController instance= Get.find();

  var currentUserID = AppController.instance.auth.currentUser!.uid;

  // final currentWeBuzzUser = Rx(AppController.instance.currentUser);


  // Stream<WeBuzzUser> _streamCurrentWeBuxxUser() {
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(currentUserID)
  //       .snapshots()
  //       .map((query) => WeBuzzUser.fromDocument(query));
  // }

  

  void followUser(WeBuzzUser targetUser) async {
    try {
      await FirebaseService.followUser(targetUser.userId).then((_) async {
        NotificationServices.sendNotification(
          notificationType: NotificationType.userFollows,
          targetUser: targetUser,
          notifiactionRef: targetUser.userId,
        );

        await FirebaseService.updateUserData({
          'followers': FieldValue.increment(1),
        }, targetUser.userId);

        await FirebaseService.updateUserData({
          'following': FieldValue.increment(1),
        }, currentUserID);
      });
    } catch (e) {
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "About user",
        message: "Something went wrong, try again later!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
    }

    // CustomFullScreenDialog.showDialog();
    // try {
    //   final userRef =
    //       FirebaseFirestore.instance.collection('users').doc(currentUserID);
    //   final targetUserRef =
    //       FirebaseFirestore.instance.collection('users').doc(targetUser.userId);

    //   // Add the target user to the "following" list of the current user.
    //   await userRef.update({
    //     'following': FieldValue.arrayUnion([targetUser.userId]),
    //   });

    //   // Add the current user to the "followers" list of the target user.
    //   await targetUserRef.update({
    //     'followers': FieldValue.arrayUnion([currentUserID]),
    //   }).then((_) {
    // NotificationServices.sendNotification(
    //   notificationType: NotificationType.userFollows,
    //   targetUser: targetUser,
    //   notifiactionRef: targetUser.userId,
    // );
    //   });

    //   CustomFullScreenDialog.cancleDialog();
    // } catch (e) {
    //   CustomFullScreenDialog.cancleDialog();
    //   CustomSnackBar.showSnackBar(
    //     context: Get.context,
    //     title: "About user",
    //     message: "Something went wrong, try again later!",
    //     backgroundColor:
    //         Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
    //   );
    // }
  }

  void unfollowUser(String targetUserID) async {
    try {
      await FirebaseService.unfollowUser(targetUserID).then((value) async {
        await FirebaseService.updateUserData({
          'followers': FieldValue.increment(-1),
        }, targetUserID);

        await FirebaseService.updateUserData({
          'following': FieldValue.increment(-1),
        }, currentUserID);
      });
    } catch (e) {
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "About user",
        message: "Something went wrong, try again later!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
    }
    // CustomFullScreenDialog.showDialog();

    // try {
    //   final userRef =
    //       FirebaseFirestore.instance.collection('users').doc(currentUserID);
    //   final targetUserRef =
    //       FirebaseFirestore.instance.collection('users').doc(targetUserID);

    //   // Remove the target user from the "following" list of the current user.
    //   await userRef.update({
    //     'following': FieldValue.arrayRemove([targetUserID]),
    //   });

    //   // Remove the current user from the "followers" list of the target user.
    //   await targetUserRef.update({
    //     'followers': FieldValue.arrayRemove([currentUserID]),
    //   });
    //   CustomFullScreenDialog.cancleDialog();
    // } catch (e) {
    //   CustomFullScreenDialog.cancleDialog();
    //   CustomSnackBar.showSnackBar(
    //     context: Get.context,
    //     title: "About user",
    //     message: "Something went wrong, try again later!",
    //     backgroundColor:
    //         Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
    //   );
    // }
  }
}
