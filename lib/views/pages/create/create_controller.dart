import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/buzz_enum.dart';
import '../../../model/notification_model.dart';
import '../../../model/we_buzz_model.dart';
import '../../../services/firebase_service.dart';
import '../../../services/image_picker_services.dart';
import '../../../services/notification_services.dart';
import '../../utils/constants.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/method_utils.dart';
import '../dashboard/my_app_controller.dart';
import 'hashtag_sytem.dart';

class CreateBuzzController extends GetxController {
  late TextEditingController textEditingController;

  // Has the image been picked?
  bool isImagePicked = false;

  // Provides an easy way to pick an image from the image gallery
  ImagePicker? picker;

  // Convert the picked image to file image by using the picker.path property
  File? pickedImagePath;
  // File? pickedGifPath;

  // downloaded image url that has been sent to cloud storage
  // String? downloadedImage;

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
    picker = ImagePicker();
  }

  // Delete the image that has been picked
  void cancleImage() async {
    pickedImagePath = null;
    // pickedGifPath = null;
    isImagePicked = !isImagePicked;
    // if (downloadedImage != null && deleteImage) {
    //   log("Download image is not null, deleting....");
    //   await FirebaseService.deleteImage(downloadedImage!);
    // }
    update();
  }

  @override
  void onClose() {
    super.onClose();
    picker = null;
    textEditingController.dispose();
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
    cancleImage(); //Set null for the selected images gif or not
    try {
      final gifFile = await fileGifPicker()
          .whenComplete(() => CustomFullScreenDialog.cancleDialog());

      if (gifFile == null) return; //Exit if the return image is null
      pickedImagePath = File(gifFile.files.single.path!);
      isImagePicked = true;
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Image picker",
        message: "You haven't picked an image!",
        backgroundColor: kPrimary.withOpacity(0.5),
      );
      log("Error trying to pick gif");
      log(e);
    }
    update();
  }

  void selectImage() async {
    CustomFullScreenDialog.showDialog();
    cancleImage();

    // Picking the image
    final image = await ImagePickerService()
        .imagePicker(
          source: ImageSource.gallery,
          cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        )
        .whenComplete(() => CustomFullScreenDialog.cancleDialog());

    if (image == null) return;

    // Convert the picked image to file image by using the picker.path property
    pickedImagePath = File(image.path);

    // Set the isImagePicked to true, to update the UI
    isImagePicked = true;
    update();
  }

  // Send
  void createTweet({bool? isStaff}) async {
    // if user is null return
    if (FirebaseAuth.instance.currentUser == null) return;

    CustomFullScreenDialog.showDialog();

    // Getting user info
    final loggedInUser = FirebaseAuth.instance.currentUser;
    String location = AppController.instance.city;

    if (textEditingController.text.isNotEmpty) {
      final hashtags = hashTagSystem(textEditingController.text);
      final urls = extractUrls(textEditingController.text);

      // downloaded image url that has been sent to cloud storage
      String? imageUrl;

      // Upload the image to the cloud storage;
      if (pickedImagePath != null && isImagePicked) {
        imageUrl = await FirebaseService.uploadImage(
          pickedImagePath!,
          'post_images/${loggedInUser!.uid}/',
        );
      }

      WeBuzz tweetBuzz = WeBuzz(
        id: MethodUtils.generatedId,
        docId: '',
        authorId: loggedInUser!.uid,
        content: textEditingController.text.trim(),
        createdAt: Timestamp.now(),
        reBuzzsCount: 0,
        buzzType: BuzzType.origianl.name,
        hashtags: hashtags,
        location: location,
        source: Platform.isAndroid ? 'Android' : 'IOS',
        imageUrl: imageUrl,
        originalId: '',
        likesCount: 0,
        isRebuzz: false,
        repliesCount: 0,
        isCampusBuzz: isStaff ?? false,
        links: urls,
      );

      try {
        // This is just a dummy, because we do not want to use it,
        //and we must pass instance of current user to the sendToNitification method
        final currenttUser = AppController.instance.currentUser;
        if (currenttUser == null) return;

        await FirebaseService.createBuzzInFirestore(tweetBuzz).then((value) {
          CustomFullScreenDialog.cancleDialog();
          isImagePicked = false;
          Get.back();
          if (value == null) return;
          NotificationServices.sendNotification(
            notificationType: NotificationType.postCreation,
            targetUser: currenttUser,
            notifiactionRef: value,
          );
        });
      } catch (e) {
        log("Error trying to create a buzz");
        log(e);
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor: kPrimary.withOpacity(0.5),
        );
      }

      textEditingController.clear();
    } else {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Warning!",
        message: "The description cannot be empty",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
    }
  }
}
