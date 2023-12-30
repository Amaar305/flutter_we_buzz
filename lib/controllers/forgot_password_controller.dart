import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/firebase_service.dart';
import '../views/utils/custom_full_screen_dialog.dart';

class ForgotPasswordController extends GetxController {
  late TextEditingController textEditingController;

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
  }

  void passwordReset() async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.resetPassword(
        textEditingController.text.trim(),
      ).then((_) {
        CustomFullScreenDialog.cancleDialog();
        toast('Password reset link sent! Check your email');
        Get.back();
      });
    } on FirebaseAuthException catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log('Error trying to reset password');
      toast(e.message);
    }
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }
}
