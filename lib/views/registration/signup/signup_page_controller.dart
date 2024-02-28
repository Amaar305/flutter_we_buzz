import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_service.dart';
import '../../pages/dashboard/my_app_controller.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/method_utils.dart';

class SignUpController extends GetxController {
  late GlobalKey<FormState> formKey;

  FirebaseAuth auth = FirebaseAuth.instance;

  late TextEditingController nameEditingController;
  late TextEditingController emailEditingController;
  late TextEditingController passwordEditingController;

  String? _programName;
  String? _currentLevel;

  bool obscureText = false;
  bool rememberMe = false;

  bool hasEmailMatched(String value) =>
      MethodUtils.emailValidation.hasMatch(value);

  void setProgramName(String? program) {
    _programName = program;
    update();
  }

  void setCurrentLevel(String? level) {
    _currentLevel = level;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();

    nameEditingController = TextEditingController();
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

      try {
        CustomFullScreenDialog.showDialog();
        final credential = await auth.createUserWithEmailAndPassword(
          email: emailEditingController.text.trim(),
          password: passwordEditingController.text.trim(),
        );
        if (credential.user == null) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: 'Warning!',
            message: 'We can\'t register you at the moment!',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
          return;
        }

        // Creating instance of the current user before uploading to firestore
        final campusBuzzUser = WeBuzzUser(
          userId: credential.user!.uid,
          email: emailEditingController.text.trim(),
          username: AppController.instance
              .usernameGenerator(emailEditingController.text.trim()),
          isOnline: true,
          isStaff: false,
          isAdmin: false,
          notification: true,
          createdAt: Timestamp.now(),
          premium: false,
          isVerified: false,
          location: AppController.instance.city,
          name: nameEditingController.text.trim(),
          lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
          program: _programName,
          level: _currentLevel,
          isUndergraduate:
              _currentLevel != null && _currentLevel!.contains('Graduated')
                  ? false
                  : true,
        );

        await FirebaseService.createUserInFirestore(
          campusBuzzUser,
          credential.user!.uid,
        );
      } on FirebaseAuthException catch (err) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "About user",
          message: err.message.toString(),
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
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
    nameEditingController.dispose();
    emailEditingController.dispose();
    passwordEditingController.dispose();
    _programName = null;
    _currentLevel = null;
  }
}
