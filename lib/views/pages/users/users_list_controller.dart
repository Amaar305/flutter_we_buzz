import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/notification_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_service.dart';
import '../../../services/notification_services.dart';
import '../dashboard/my_app_controller.dart';

class UserListController extends GetxController {
   RxList<WeBuzzUser> allUsers = RxList([]);

  @override
  void onInit() {
    super.onInit();
    allUsers = AppController.instance.weBuzzUsers;
    
  }

  void makeMeStaff(WeBuzzUser user, bool staff) {
    Get.dialog(
      AlertDialog(
        title: const Text('Staff?'),
        content: Text(
          'Are you sure to make ${user.name} a staff of Webuzz? They\'ll be able to delete and supend any buzz and user.',
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'No',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              Get.back();

              await FirebaseService.makeMeStaff(user, staff).whenComplete(() {
                if (staff) {
                  NotificationServices.sendNotification(
                      targetUser: user,
                      notificationType: NotificationType.staff);
                  toast('${user.name} is successifully a staff now.');
                }
              });
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
