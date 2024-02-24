import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/documents/faculty_model.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../../utils/method_utils.dart';
import '../../../widgets/home/my_buttons.dart';
import '../../../widgets/home/my_textfield.dart';

class DashboardController extends GetxController {
  late TextEditingController textEditingController;

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
  }

  void showDialog() {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => Padding(
        padding: kPadding,
        child: Column(
          children: [
            MyInputField(
              controller: textEditingController,
              hintext: 'Enter Faculty Title',
              iconData: Icons.book_outlined,
              label: 'Faculty Title',
            ),
            30.height,
            MyRegistrationButton(
              title: 'Upload',
              secondaryColor: Colors.white,
              onPressed: tryf,
            )
          ],
        ),
      ),
    );
  }

  void tryf() async {
    if (textEditingController.text.isEmpty) return;
    if (FirebaseAuth.instance.currentUser == null) return;

    CustomFullScreenDialog.showDialog();
    try {
      FacultyModel facultyModel = FacultyModel(
        id: MethodUtils.generatedId,
        name: textEditingController.text.trim(),
        createdBy: FirebaseAuth.instance.currentUser!.uid,
        createdAt: Timestamp.now(),
      );
      await FirebaseService.createFaculty(facultyModel).whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
        textEditingController.clear();
        toast('Created');
        Get.back();
      });
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log("Error trying to upload faculty");
      log(e);
    }
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }
}
