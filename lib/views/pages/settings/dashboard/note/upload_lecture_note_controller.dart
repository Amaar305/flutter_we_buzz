// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../../../../../model/documents/lecture_note_model.dart';
import '../../../../../services/firebase_service.dart';
import '../../../../utils/custom_full_screen_dialog.dart';
import '../../../../utils/method_utils.dart';
import '../../../dashboard/my_app_controller.dart';
import '../../../documents/programs_controller.dart';

class UploadLectureNoteCOntroller extends GetxController {
  late GlobalKey<FormState> formKey;
  late TextEditingController titleEditingController;
  late TextEditingController courseCodeEditingController;

  String? program;
  String? level;
  String? faculty;

  File? pickedFile;
  File? coverImage;

  String? fileExtension;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
    titleEditingController = TextEditingController();
    courseCodeEditingController = TextEditingController();
  }

  void setProgram(String program) {
    this.program = program;
  }

  void setLevel(String level) {
    this.level = level;
  }

  void setFaculty(String faculty) {
    this.faculty = faculty;
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;
      // Check if the picked file isn't null

      // Get the file
      PlatformFile file = result.files.first;

      //Convert to file
      pickedFile = File(file.path!);
      // _extractCoverImage();

      var fileName = basename(file.path!);

      // Getting the file extension
      var splitted = fileName.split('.');

      // Get the files extension
      fileExtension = splitted.last;
    } catch (e) {
      log(e.toString());
      log('Error trying to pick file');
    }
    update();
  }

  void upload() async {
    try {
      if (pickedFile == null) return;
      if (FirebaseAuth.instance.currentUser == null) return;

      CustomFullScreenDialog.showDialog();

      final id = MethodUtils.generatedId;

      // Upload the file in cloud storage and return the downloaded url
      String? fileUrl = await FirebaseService.uploadFile(
        pickedFile!,
        'pdf/$id/lecture-note/',
        fileExtension!,
      );

      if (fileUrl == null) return;

      LectureNoteModel lectureNoteModel = LectureNoteModel(
        id: id,
        courseCode: courseCodeEditingController.text.trim(),
        title: titleEditingController.text.trim(),
        level: level!,
        url: fileUrl,
        createdBy: FirebaseAuth.instance.currentUser!.uid,
        createdAt: Timestamp.now(),
        faculty: faculty!,
        programName: program!,
      );
      await FirebaseService.createLectureNote(lectureNoteModel)
          .whenComplete(() => CustomFullScreenDialog.cancleDialog());
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log('Error trying to upload lecture note');
      log(e.toString());
    }
  }

  // Future<void> _extractCoverImage() async {
  //   if (pickedFile == null) return;
  //   final pdfThumbnail =
  //       PdfThumbnail.fromFile(pickedFile!.path, currentPage: 1);

  //   log('thisssssssssssssssss ${pdfThumbnail.cacher}');
  //   update();
  // }

  final programs =
      AppController.instance.programs.map((p) => p.programName).toList();
  final faculties =
      ProgramsController.instance.faculties.map((f) => f.name).toList();
}
