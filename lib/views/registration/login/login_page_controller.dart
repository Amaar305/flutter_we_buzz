import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/method_utils.dart';

class LoginController extends GetxController {
  late GlobalKey<FormState> formKey;

  FirebaseAuth auth = FirebaseAuth.instance;

  late TextEditingController emailEditingController;
  late TextEditingController passwordEditingController;

  bool obscureText = false;
  bool rememberMe = false;

  bool hasEmailMatched(String value) =>
      MethodUtils.emailValidation.hasMatch(value);

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();

    emailEditingController = TextEditingController();
    passwordEditingController = TextEditingController();
  }

  void canOrCannotSee() {
    obscureText = !obscureText;
    update();
  }

  void updateRememberMe(bool rememberMe) {
    this.rememberMe = rememberMe;
    update();
  }

  void trySubmit() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(Get.context!).unfocus();

    if (isValid) {
      formKey.currentState!.save();

      CustomFullScreenDialog.showDialog();
      try {
        await auth.signInWithEmailAndPassword(
          email: emailEditingController.text.trim(),
          password: passwordEditingController.text.trim(),
        );

        QuerySnapshot<Map<String, dynamic>> result = await FirebaseService
            .firebaseFirestore
            .collection(firebaseWeBuzzUserCollection)
            .where('email', isEqualTo: emailEditingController.text.trim())
            .get();

        if (result.docs.isEmpty) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: 'Warning!',
            message:
                'No user associated to authenticated email ${emailEditingController.text}',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
          debugPrint(
              'No user associated to authenticated email ${emailEditingController.text}');
          return;
        }

        if (result.docs.length != 1) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: 'Warning!',
            message:
                'More than one user associated to email ${emailEditingController.text}',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
          debugPrint(
              'More than one user associated to email ${emailEditingController.text}');
          return;
        }
        update();
      } on FirebaseAuthException catch (err) {
        CustomFullScreenDialog.cancleDialog();

        if (err.code.contains('INVALID_LOGIN_CREDENTIALS')) {
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: "About user",
            message: 'Invalid email address or password',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
        } else {
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: "About user",
            message: err.message.toString(),
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
        }
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "About user",
          message: "Something went wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
    emailEditingController.dispose();
    passwordEditingController.dispose();
  }
}
