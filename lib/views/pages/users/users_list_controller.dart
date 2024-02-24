import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_constants.dart';
import 'package:hi_tweet/views/widgets/home/my_buttons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/notification_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_service.dart';
import '../../../services/notification_services.dart';

class UserListController extends GetxController {
  RxList<WeBuzzUser> allUsers = RxList([]);

  static final currentUserId = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.uid
      : '';

  bool asc = true;

  final query = FirebaseService.firebaseFirestore
      .collection(firebaseWeBuzzUserCollection)
      .where('userId', isNotEqualTo: currentUserId)
      .withConverter<WeBuzzUser>(
        fromFirestore: (snapshot, options) => WeBuzzUser.fromDocument(snapshot),
        toFirestore: (value, options) => value.toMap(),
      );

  @override
  void onInit() {
    super.onInit();
    allUsers.bindStream(FirebaseService.streamWeBuzzUsers());
  }

  void makeMeStaff(WeBuzzUser user, bool staff) {
    Get.dialog(
      AlertDialog(
        title: const Text('Staff?'),
        content: Text(
          'Are you sure to make ${user.name} a staff of Webuzz? They\'ll be able to delete and supend any buzz and user.',
        ),
        actions: [
          CustomMaterialButton(
            title: 'Class Monitor',
            onPressed: () async {
              Get.back();

              await FirebaseService.updateUserData(
                      {'isClassRep': !user.isClassRep}, user.userId)
                  .whenComplete(() {
                if (staff) {
                  NotificationServices.sendNotification(
                    targetUser: user,
                    notificationType: NotificationType.staff,
                    notifiactionRef: 'classRep',
                  );
                  toast('${user.name} is successifully a classRep now.');
                }
              });
            },
          ),
          CustomMaterialButton(
            title: 'Yes',
            onPressed: () async {
              Get.back();

              await FirebaseService.makeMeStaff(user, staff).whenComplete(() {
                if (staff) {
                  NotificationServices.sendNotification(
                    targetUser: user,
                    notificationType: NotificationType.staff,
                    notifiactionRef: 'staff',
                  );
                  toast('${user.name} is successifully a staff now.');
                }
              });
            },
          ),
          CustomMaterialButton(
            title: 'Cancel',
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  final tabLists = ['All', 'Class Reps'];
}
