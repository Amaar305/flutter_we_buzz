import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/views/utils/custom_full_screen_dialog.dart';
import 'package:nb_utils/nb_utils.dart';

class UpdatePasswordController extends GetxController {
  late TextEditingController currentPassEditingController;
  late TextEditingController newPassEditingController;

  late GlobalKey<FormState> formKey;

  bool obscureText = false;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
    currentPassEditingController = TextEditingController();
    newPassEditingController = TextEditingController();
  }

  void canOrCannotSee() {
    obscureText = !obscureText;
    update();
  }

  void change(BuildContext context) async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      formKey.currentState!.save();
      CustomFullScreenDialog.showDialog();
      try {
        var result = await FirebaseService()
            .updatePassword(currentPassEditingController.text.trim(),
                newPassEditingController.text.trim())
            .whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });

        if (result!) {
          toast('Password Successifull Changed');
          await FirebaseService.updateUserData({
            'lastUpdatedPassword': FieldValue.serverTimestamp(),
          }, FirebaseAuth.instance.currentUser!.uid);
        }
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        log(e);
      }
    }
  }
}
