import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/custom_full_screen_dialog.dart';
import 'package:hi_tweet/views/utils/method_utils.dart';
import 'package:hi_tweet/views/widgets/home/my_textfield.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/documents/program_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';

class ProgramsController extends GetxController {
  RxList<ProgramModel> programs = RxList<ProgramModel>([]);

  late TextEditingController textEditingController;

  @override
  void onInit() {
    super.onInit();
    programs.bindStream(_streamPrograms());
    textEditingController = TextEditingController();
  }

  void showAlertDialog(String userID) {
    Get.dialog(
      AlertDialog(
        title: const Text('New Program'),
        content: MyTextField(
          controller: textEditingController,
          hintext: 'Program Name',
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Get.back();
              if (textEditingController.text.isNotEmpty) {
                createProgram(userID);
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void createProgram(String userID) async {
    CustomFullScreenDialog.showDialog();
    try {
      ProgramModel programModel = ProgramModel(
        programId: MethodUtils.generatedId,
        programName: textEditingController.text.trim(),
        createdBy: userID,
        createdAt: Timestamp.now(),
      );
      await FirebaseService.createProgram(programModel)
          .whenComplete(() => CustomFullScreenDialog.cancleDialog());
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log("Error trying to create program");
      log(e);
    }
  }

  Stream<List<ProgramModel>> _streamPrograms() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseProgramsCollection)
        .orderBy('createdAt')
        .snapshots()
        .map((query) =>
            query.docs.map((item) => ProgramModel.fromDocument(item)).toList());
  }
}
