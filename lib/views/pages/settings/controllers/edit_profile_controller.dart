import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/image_picker_services.dart';
import 'package:hi_tweet/views/pages/dashboard/my_app_controller.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/we_buzz_user_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../../utils/custom_snackbar.dart';

class EditProfileController extends GetxController {
  late GlobalKey<FormState> formKey;
  late TextEditingController bioEditingController;
  late TextEditingController editNameEditingController;
  late TextEditingController usernameEditingController;

  late TextEditingController phoneEditingController;
  late TextEditingController lavelEditingController;

  FirebaseAuth auth = FirebaseAuth.instance;

  final CollectionReference _collectionReference = FirebaseService
      .firebaseFirestore
      .collection(firebaseWeBuzzUserCollection);

  @override
  void onInit() {
    super.onInit();
    WeBuzzUser? currentUser = AppController.instance.currentUser;

    formKey = GlobalKey<FormState>();

    bioEditingController = TextEditingController();
    editNameEditingController = TextEditingController();
    usernameEditingController = TextEditingController();
    phoneEditingController = TextEditingController();
    lavelEditingController = TextEditingController();

    // Assigning Value to the controller
    bioEditingController.text = currentUser!.bio;
    editNameEditingController.text = currentUser.name;
    usernameEditingController.text = currentUser.username;
    phoneEditingController.text = currentUser.phone ?? '';
    lavelEditingController.text = currentUser.level ?? '';
  }

  // Has the image been picked?
  bool isImagePicked = false;

// // Provides an easy way to pick an image from the image gallery
//   final ImagePicker _picker = ImagePicker();

  // Convert the picked image to file image by using the picker.path property
  File? pickedImagePath;

  Future<File?> _selectImage() async {
    try {
      final image = await ImagePickerService().imagePicker(
        source: ImageSource.gallery,
        cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      );
      // Convert the picked image to file image by using the picker.path property
      pickedImagePath = File(image!.path);

      // Set the isImagePicked to true, to update the UI
      isImagePicked = true;
      update();
      return pickedImagePath;
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log("Error trying to pick an image");
      log(e);

      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Image picker",
        message: "You haven't picked an image!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );

      return null;
    }
  }

// Upload/Delete/Update user profule
  void uploadDeleteUpdateUserProfileUrl() async {
    // check if user is null
    if (AppController.instance.currentUser == null) return;

    if (AppController.instance.currentUser!.imageUrl == null) {
      // check if userimage is null

      CustomFullScreenDialog.showDialog();
      try {
        // pick image from gallery
        File? pickedImagePath = await _selectImage();

        if (pickedImagePath != null && isImagePicked) {
          // upload image to storage
          final downloadedImage = await FirebaseService.uploadImage(
              pickedImagePath,
              'users/${AppController.instance.currentUser!.userId}');

          // update the user image field in firestore
          await _collectionReference.doc(auth.currentUser!.uid).update({
            'imageUrl': downloadedImage,
          }).whenComplete(() {
            CustomFullScreenDialog.cancleDialog();
          });
        }

        //  Re-fetch the user info
        await AppController.instance.fetchUserDetails(auth.currentUser!.uid);

        isImagePicked = false;
        pickedImagePath = null;
      } catch (e) {
        log('Error trying to upload/pick image');
        log(e);
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Error",
          message: "Something went wrong try again later!",
          backgroundColor: kPrimary.withOpacity(0.5),
        );
      }
    } else {
      CustomFullScreenDialog.showDialog();
      try {
        // delete the current user image from storage
        await FirebaseService.deleteImage(
            AppController.instance.currentUser!.imageUrl!);

        // pick image from gallery
        File? pickedImagePath = await _selectImage();

        if (pickedImagePath != null && isImagePicked) {
          // upload image to storage
          final downloadedImage = await FirebaseService.uploadImage(
              pickedImagePath,
              'users/${AppController.instance.currentUser!.userId}');

          // update the user image field in firestore
          await _collectionReference.doc(auth.currentUser!.uid).update({
            'imageUrl': downloadedImage,
          }).whenComplete(() {
            CustomFullScreenDialog.cancleDialog();
          });
        }
        // fetch user info again!
        await AppController.instance.fetchUserDetails(auth.currentUser!.uid);

        isImagePicked = false;
        pickedImagePath = null;
      } catch (e) {
        log(e.toString());
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Error",
          message: "Something went wrong try again later!",
          backgroundColor: kPrimary.withOpacity(0.5),
        );
      }
    }
    update();
  }

  // Edit user profile
  void editUserInfo() async {
    CustomFullScreenDialog.showDialog();
    try {
      await _collectionReference.doc(auth.currentUser!.uid).update({
        'bio': bioEditingController.text.isEmpty
            ? AppController.instance.currentUser!.bio
            : bioEditingController.text.trim(),
        'name': editNameEditingController.text.isEmpty
            ? AppController.instance.currentUser!.name
            : editNameEditingController.text.trim(),
        'username': editNameEditingController.text.isEmpty
            ? AppController.instance.currentUser!.username
            : usernameEditingController.text.trim(),
        'phone': phoneEditingController.text.isEmpty
            ? AppController.instance.currentUser!.phone
            : phoneEditingController.text.trim(),
        'level': lavelEditingController.text.isEmpty
            ? AppController.instance.currentUser!.level
            : lavelEditingController.text.trim(),
      }).whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
        Get.back();
      });
      await AppController.instance.fetchUserDetails(auth.currentUser!.uid);
      update();
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Warning!",
        message: "Something wen't wrong, try again later!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );

      update();
    }
  }

// update user level
  void updateUserLevel(String level) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.updateUserData(
        {
          "level": level,
        },
        FirebaseAuth.instance.currentUser!.uid,
      ).whenComplete(() => CustomFullScreenDialog.cancleDialog());
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log(e);
      log("Error updating user privacy");
    }
    update();
  }
}
