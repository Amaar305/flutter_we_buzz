import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/buzz_enum.dart';
import '../../../model/notification_model.dart';
import '../../../model/we_buzz_model.dart';
import '../../../services/firebase_service.dart';
import '../../../services/notification_services.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/method_utils.dart';
import '../dashboard/my_app_controller.dart';
import 'hashtag_sytem.dart';

class CreateBuzzController extends GetxController {
  TextEditingController? textEditingController;

  // Has the image been picked?
  bool isImagePicked = false;

  // Provides an easy way to pick an image from the image gallery
  ImagePicker? picker;

  // Convert the picked image to file image by using the picker.path property
  File? pickedImagePath;
  File? pickedGifPath;

  // downloaded image url that has been sent ot cloud storage
  String? downloadedImage;

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
    picker = ImagePicker();
  }

  // Delete the image that has been picked
  void cancleImage(bool deleteImage) async {
    pickedImagePath = null;
    pickedGifPath = null;
    isImagePicked = !isImagePicked;
    if (downloadedImage != null && deleteImage) {
      log("Download image is not null, deleting....");
      await FirebaseService.deleteImage(downloadedImage!);
    }
    update();
  }

  @override
  void onClose() {
    super.onClose();
    picker = null;
    cancleImage(false);
  }

  Future<FilePickerResult?> fileGifPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gif'],
    );
    return result;
  }

  void pickedGIF() async {
    CustomFullScreenDialog.showDialog();
    try {
      cancleImage(true);

      if (FirebaseAuth.instance.currentUser != null) {
        final loggedInUser = FirebaseAuth.instance.currentUser;

        final result = await fileGifPicker();
        if (result != null) {
          pickedGifPath = File(result.files.single.path!);
          isImagePicked = true;

          if (pickedGifPath != null && isImagePicked) {
            downloadedImage = await FirebaseService.uploadImage(
                    pickedGifPath!, 'post_images/gif/${loggedInUser!.uid}/')
                .whenComplete(() => CustomFullScreenDialog.cancleDialog());
          }
        } else {
          CustomFullScreenDialog.cancleDialog();
          log("Null For Gif file");
        }
      }
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Image picker",
        message: "You haven't picked an image!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
      log("Error trying to pick gif");
      log(e);
    }
    update();
  }

  void selectImage() async {
    CustomFullScreenDialog.showDialog();
    if (downloadedImage != null) {
      cancleImage(true);
    }
    // Getting user info
    if (FirebaseAuth.instance.currentUser != null) {
      final loggedInUser = FirebaseAuth.instance.currentUser;

      try {
        final image = await picker!
            .pickImage(source: ImageSource.gallery, imageQuality: 82);

        // Convert the picked image to file image by using the picker.path property
        pickedImagePath = File(image!.path);

        // Set the isImagePicked to true, to update the UI
        isImagePicked = true;

        if (pickedImagePath != null && isImagePicked) {
          downloadedImage = await FirebaseService.uploadImage(
                  pickedImagePath!, 'post_images/${loggedInUser!.uid}/')
              .whenComplete(() => CustomFullScreenDialog.cancleDialog());
        }
      } catch (e) {
        log(e);
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Image picker",
          message: "You haven't picked an image!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
      update();
    }
  }

  // Send
  void createTweet({bool? isStaff}) async {
    CustomFullScreenDialog.showDialog();
    // Getting user info
    final loggedInUser = FirebaseAuth.instance.currentUser;
    String location = AppController.instance.city;
    if (textEditingController!.text.isNotEmpty && loggedInUser != null) {
      isImagePicked = false;

      final hashtags = hashTagSystem(textEditingController!.text);

      WeBuzz tweetBuzz = WeBuzz(
        id: MethodUtils.generatedId,
        docId: '',
        authorId: loggedInUser.uid,
        content: textEditingController!.text.trim(),
        createdAt: Timestamp.now(),
        reBuzzsCount: 0,
        buzzType: BuzzType.origianl.name,
        hashtags: hashtags,
        location: location,
        source: 'Samsumng',
        imageUrl: downloadedImage,
        likes: [],
        replies: [],
        rebuzzs: [],
        originalId: '',
        likesCount: 0,
        isRebuzz: false,
        repliesCount: 0,
        views: [],
        isCampusBuzz: isStaff ?? false,
      );

      try {
        // This is just a dummy, because we do not want use it,
        //and we must pass instance of webuzz user to the sendToNitification method
        final currenttUser = AppController.instance.weBuzzUsers.firstWhere(
          (element) => element.userId == loggedInUser.uid,
        );

        await FirebaseService.createBuzzInFirestore(tweetBuzz).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
          Get.back();
          NotificationServices.sendNotification(
            notificationType: NotificationType.postCreation,
            targetUser: currenttUser,
          );
        });
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }

      log(tweetBuzz.toString());
      textEditingController!.clear();
      update();
    } else {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Warning!",
        message: "The user doesn't logged in, or description is empty",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
    }
  }
}
