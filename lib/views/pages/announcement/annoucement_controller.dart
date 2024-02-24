import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/campus_announcement.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/services/notification_services.dart';
import 'package:hi_tweet/views/utils/custom_snackbar.dart';
import 'package:hi_tweet/views/utils/method_utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/image_picker_services.dart';
import '../../utils/constants.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../dashboard/my_app_controller.dart';

class CampusAnnouncementController extends GetxController {
  late GlobalKey<FormState> formKey;

  late TextEditingController textEditingController;
  late TextEditingController urlEditingController;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();

    textEditingController = TextEditingController();
    urlEditingController = TextEditingController();
  }

  String? _image;
  int _duration = 0;
  bool imagePicked = false;
  File? _fileImage;

  void setImage(String downloadUrl) {
    _image = downloadUrl;
    update();
  }

  void setDuration(int duration) {
    _duration = duration;
  }

  void seletImages() async {
    CustomFullScreenDialog.showDialog();
    try {
      _fileImage = await getImage().whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
        imagePicked = true;
      });

      if (_fileImage == null) imagePicked = false;
      update();
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      toast('Error picking images');
    }
  }

  void submit() async {
    CustomFullScreenDialog.showDialog();
    try {
      if (_fileImage != null) {
        // if selected image is not null

        // upload the file to the cloud storage
        final downloadedUrl = await FirebaseService.uploadImage(_fileImage!,
            "announcement/${DateTime.now().millisecondsSinceEpoch}/");

        if (downloadedUrl != null) {
          // if downloadedUrl is not null, assign it to the image link
          setImage(downloadedUrl);
        }
      }

      // Creating instance of announcement
      CampusAnnouncement campusAnnouncement = CampusAnnouncement(
        content: textEditingController.text,
        timestamp: Timestamp.now(),
        durationInHours: _duration,
        image: _image,
        url: urlEditingController.text.trim().isEmpty
            ? null
            : urlEditingController.text.trim(),
        id: MethodUtils.generatedId,
        updatedAt: Timestamp.now(),
        createdBy: FirebaseAuth.instance.currentUser!.uid,
      );
      await FirebaseService.createAnnouncement(campusAnnouncement).whenComplete(
        () async {
          CustomFullScreenDialog.cancleDialog();
          Get.back();

          final users = AppController.instance.weBuzzUsers;
          for (var user in users) {
            await NotificationServices.notifiactionRequest(
              pushToken: user.pushToken,
              notificationBody: textEditingController.text,
              title: 'Campus Announcement',
              messageRef: '',
              type: '',
            );
          }
        },
      );
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: 'Warning!',
        message: 'Error trying to create announcement',
        backgroundColor: kPrimary.withOpacity(0.5),
      );
      log(e);
    }
  }

  void deleteAnnouncement(CampusAnnouncement announcement) {
    final currentUser = AppController.instance.currentUser;
    if (currentUser == null) return;

    if (currentUser.userId != announcement.createdBy || !currentUser.isStaff) {
      return;
    }

    alert(
      title: 'Deletion!',
      content: const Text('Are you sure to delete the annoucement?'),
      action: () async {
        try {
          if (currentUser.userId != announcement.createdBy) {
            return;
          }

          await FirebaseService.deleteAnnouncement(announcement.id).then((_) {
            toast('Deleted');
            if (announcement.image != null) {
              FirebaseService.deleteImage(announcement.image!);
            }
          });
          Get.back();
        } catch (e) {
          Get.back();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: 'Warning!',
            message: 'Error deleting the announcement!',
            backgroundColor: kPrimary.withOpacity(0.5),
          );
          log(e);
        }
      },
    );
  }

  void alert({
    required String title,
    required Widget content,
    void Function()? action,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          MaterialButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: action,
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  List<String> tabsTitile = [
    'New',
    'Previous',
  ];

  Future<File?> getImage() async {
    try {
      final image = await ImagePickerService().imagePicker(
        source: ImageSource.gallery,
        cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      log('Error picking images: $e');
      return null;
    }
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
    urlEditingController.dispose();
  }
}
