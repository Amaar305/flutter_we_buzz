import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/buzz_enum.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/tweet.dart';
import '../../../services/current_user.dart';
import '../../../services/location_services.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/method_utils.dart';

class CreateTweetController extends GetxController {
  TextEditingController? textEditingController;

  // Has the image been picked?
  bool isImagePicked = false;

  // Provides an easy way to pick an image from the image gallery
  ImagePicker? picker;

  // Convert the picked image to file image by using the picker.path property
  File? pickedImagePath;

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
    picker = ImagePicker();
  }

  // Delete the image that has been picked
  void cancleImage() {
    pickedImagePath = null;
    isImagePicked = !isImagePicked;
    update();
  }

  @override
  void onClose() {
    super.onClose();
    picker = null;
    cancleImage();
  }

  String? downloadedImage;

  void selectImage() async {
    // pickedImagePath = null;
    CustomFullScreenDialog.showDialog();
    try {
      final image = await picker!
          .pickImage(source: ImageSource.gallery, imageQuality: 82);

      // Convert the picked image to file image by using the picker.path property
      pickedImagePath = File(image!.path);

      // Set the isImagePicked to true, to update the UI
      isImagePicked = true;

      if (pickedImagePath != null && isImagePicked) {
        downloadedImage =
            await FirebaseService.uploadImage(pickedImagePath!, 'images')
                .whenComplete(() => CustomFullScreenDialog.cancleDialog());
      }
    } catch (e) {
      log(e.toString());
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBAr(
        context: Get.context,
        title: "Image picker",
        message: "You haven't picked an image!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
    }
    update();
  }

  List<String> hashtags = [];

  // Send
  void createTweet() async {
    // Getting user info
    final loggedInUser = CurrentLoggeedInUser.currentUserId;
    String location = await getCurrentCity();
    CustomFullScreenDialog.showDialog();
    if (textEditingController!.text.isNotEmpty && loggedInUser != null) {
      isImagePicked = false;

      final text = textEditingController!.text;
      final hashtagRegx = RegExp(r'#\w+');

      final matches = hashtagRegx.allMatches(text);

      for (var matche in matches) {
        if (matche.group(0) != null) {
          hashtags.add(matche.group(0)!);
          log('${matche.group(0)} the Matches');
        }
      }

      TweetBuzz tweetBuzz = TweetBuzz(
        id: MethodUtils.generatedId,
        docId: '',
        authorId: loggedInUser.uid,
        content: textEditingController!.text.trim(),
        createdAt: Timestamp.now(),
        comments: [],
        reBuzzCount: 0,
        buzzType: BuzzType.origianl,
        hashtags: hashtags,
        location: location,
        source: 'Samsumng',
        imageUrl: downloadedImage,
      );

      try {
        await FirebaseService.createTweetInFirestore(tweetBuzz)
            .whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
          Get.back();
        });
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBAr(
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
      CustomSnackBar.showSnackBAr(
        context: Get.context,
        title: "Warning!",
        message: "The user doesn't logged in, or description is empty",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
    }
  }
}
