import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../../utils/custom_snackbar.dart';
import '../hashtag_sytem.dart';

class EditPostController extends GetxController {
  late TextEditingController textEditingController;
  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
  }

  void updateBuzz(WeBuzz weBuzz) async {
    CustomFullScreenDialog.showDialog();
    try {
      if (textEditingController.text.isNotEmpty &&
          weBuzz.authorId == FirebaseAuth.instance.currentUser!.uid) {
        await FirebaseService.updateBuzz(weBuzz.docId, weBuzz.toJson())
            .whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
          toast('updated');

          Get.back();
          Get.back();
        });
      } else {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "The buzz doesn't belong to you, or description is empty!",
          backgroundColor: kPrimary.withOpacity(0.5),
        );
      }
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Warning!",
        message: "Something wen't wrong, try again later!",
        backgroundColor: kPrimary.withOpacity(0.5),
      );

      log("Error while updating buzz");
      log(e);
    }
  }

  void updateReply(WeBuzz weBuzz, String id) async {
    CustomFullScreenDialog.showDialog();
    try {
      if (textEditingController.text.isNotEmpty &&
          weBuzz.authorId == FirebaseAuth.instance.currentUser!.uid) {
        // await FirebaseService.updateReply(weBuzz).whenComplete(() {
        //   CustomFullScreenDialog.cancleDialog();
        //   Get.back();
        // });
        final hashtags = hashTagSystem(textEditingController.text);
        final urls = extractUrls(textEditingController.text);

        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(id)
            .collection(firebaseRepliesCollection)
            .doc(weBuzz.docId)
            .update({
          'content': textEditingController.text.trim(),
          'hashtags': hashtags,
          'links': urls,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
          toast('updated');
          Get.back();
          Get.back();
        });
      } else {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "The buzz doesn't belong to you, or description is empty!",
          backgroundColor: kPrimary.withOpacity(0.5),
        );
      }
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Warning!",
        message: "Something wen't wrong, try again later!",
        backgroundColor: kPrimary.withOpacity(0.5),
      );

      log(e);
      log("Error while updating buzz");
    }
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }
}
