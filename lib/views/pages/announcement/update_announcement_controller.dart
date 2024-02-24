import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/campus_announcement.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/views/pages/announcement/hours.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constants.dart';
import '../../utils/custom_snackbar.dart';
import '../dashboard/my_app_controller.dart';

class UpdateAnnouncementController extends GetxController {
  late GlobalKey<FormState> formKey;

  TextEditingController textEditingController = TextEditingController();
  TextEditingController urlEditingController = TextEditingController();
  Hours? initialHours;
  late int _duration;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
  }

  void setDuration(int duration) {
    _duration = duration;
  }

  void updateAnnouncement(CampusAnnouncement announcement) async {
    try {
      final currentUser = AppController.instance.currentUser!;

      if (currentUser.userId != announcement.createdBy ||
          !currentUser.isStaff) {
        log('Not your post!');
        return;
      }

      // Creating instance of announcement
      CampusAnnouncement updatedAnnouncement = announcement.copyWith(
        content: textEditingController.text.trim(),
        durationInHours: _duration,
        updatedAt: Timestamp.now(),
        url: urlEditingController.text.trim().isEmpty
            ? null
            : urlEditingController.text.trim(),
      );

      await FirebaseService.updateAnnouncement(
        updatedAnnouncement.id,
        updatedAnnouncement.toMap(),
      ).whenComplete(() {
        toast('Updated');
        Get.back();
      });
    } catch (e) {
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: 'Warning!',
        message: 'Error trying updating the announcement!',
        backgroundColor: kPrimary.withOpacity(0.5),
      );
      log(e);
    }
  }
}
