import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../../utils/custom_snackbar.dart';

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
           Get.back();
        });
      } else {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "The buzz doesn't belong to you, or description is empty!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Warning!",
        message: "Something wen't wrong, try again later!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
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
