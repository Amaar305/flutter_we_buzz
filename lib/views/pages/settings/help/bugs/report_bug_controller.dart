import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:hi_tweet/views/utils/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../model/report/bug_report_model.dart';
import '../../../../../services/firebase_service.dart';
import '../../../../utils/method_utils.dart';

class ReportBugController extends GetxController {
  late TextEditingController textEditingController;

  late GlobalKey<ScaffoldState> scaffoldKey;

  // late ScreenshotController screenshotController;

  File? screenshotFile;

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
    scaffoldKey = GlobalKey<ScaffoldState>();
    // screenshotController = ScreenshotController();
  }

  void submitReportBug() async {
    String bugDescription = textEditingController.text.trim();
    textEditingController.clear();

    try {
      if (FirebaseAuth.instance.currentUser == null) return;
      if (bugDescription.isEmpty) {
        CustomSnackBar.showSnackBar(
          context: Get.context!,
          title: 'Warning!',
          message: 'Description can\'t be empty',
          backgroundColor: kPrimary.withOpacity(0.5),
        );
        return;
      }
      // If user and user is null then quit

      String? imageUrl = screenshotFile != null // if screenshot file isn't null
          ? await FirebaseService.uploadImage(screenshotFile!, 'bug-report/')
          : null;
      // Send the image

      ReportBug reportBug = ReportBug(
        id: MethodUtils.generatedId,
        description: bugDescription,
        user: FirebaseAuth.instance.currentUser!.uid,
        imageUrl: imageUrl,
        createdAt: Timestamp.now(),
      );

      // Send it to the backend
      await FirebaseService.reportBug(reportBug);

      // Show confirmation dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Bug Report Submitted'),
          content: const Text('Thank you for reporting this issue!'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    } catch (e) {
      log("Error trying to send report bug");
      log(e.toString());
    }
  }

  // Future<void> captureScreenshot() async {
  //   try {
  //     Uint8List? capturedImage = await screenshotController.capture(
  //         pixelRatio: 4 / 2, delay: const Duration(milliseconds: 150));

  //     final directory = (await getTemporaryDirectory()).path;
  //     final imageFile = File('$directory/screenshot.png');

  //     imageFile.writeAsBytesSync(capturedImage!);
  //     update();

  //     // Save screenshot to device gallery
  //     final result = await ImageGallerySaver.saveImage(capturedImage);
  //     log('Image saved to device gallery $result');
  //   } catch (e) {
  //     log("Error trying to capture screenshot");
  //     log(e.toString());
  //   }
  // }

  Future<void> pickScreenshot() async {
    try {
      ImagePicker picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) return;
      // If pickedImage is equal to null, quit

      screenshotFile = File(pickedImage.path);
      update();
    } catch (e) {
      log("Error trying to pick screenshot");
      log(e.toString());
    }
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }
}
