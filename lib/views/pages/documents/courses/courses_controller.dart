// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../model/documents/course_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../dashboard/my_app_controller.dart';

class CoursesController extends GetxController {
  RxList<CourseModel> courses = RxList([]);

  TextEditingController? courseCodeEditingController;
  TextEditingController? courseTitleEditingController;
  String _level = '';

  @override
  void onInit() {
    super.onInit();
    courses.bindStream(_streamCourses());
    courseCodeEditingController = TextEditingController();
    courseTitleEditingController = TextEditingController();
  }

  void setLevelName(String level) {
    _level = level;
  }

  String get levelName => _level;

  void uploadFile(
    String programId,
  ) async {
    CustomFullScreenDialog.showDialog();

    if (FirebaseAuth.instance.currentUser != null) {
      // Check if current user is logged in

      // Get current user info
      final currentUser = AppController.instance.weBuzzUsers.firstWhere(
          (u) => u.userId == FirebaseAuth.instance.currentUser!.uid);
      if (currentUser.isStaff) {
        // Check if current user is a staff
        try {
          // Pick the file in Phone files
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            // allowMultiple: true
          );

          if (result != null) {
            // Check if the picked file isn't null

            // Get the file
            PlatformFile file = result.files.first;

            //Convert to file
            File newFile = File(file.path!);

            var fileName = basename(file.path!);

            // Getting the file extension
            var splitted = fileName.split('.');

            // Get the files extension
            String fileExtension = splitted.last;

            // Upload the file in cloud storage and return the downloaded url
            String? fileUrl = await FirebaseService.uploadFile(
              newFile,
              'pdf/$programId/courses/',
              fileExtension,
            );

            if (fileUrl != null && _level.isNotEmpty) {
              // Check if the downloaded url isn't null and level isn't empty

              // Create the instance of course model
              CourseModel courseModel = CourseModel(
                programId: programId,
                courseCode: courseCodeEditingController!.text.trim(),
                courseName: courseTitleEditingController!.text.trim(),
                uploadedBy: currentUser.userId,
                url: fileUrl,
                uploadedAt: Timestamp.now(),
                level: levelName,
              );

              // Upload it to the firestorage
              FirebaseService.createCourse(courseModel).whenComplete(() {
                CustomFullScreenDialog.cancleDialog();
                courseCodeEditingController!.clear();
                courseTitleEditingController!.clear();
                Get.back();
              });
            } else {
              // Else if downloaded file is null
              CustomFullScreenDialog.cancleDialog();
              toast('File url is null and level, try again');
            }
          }
        } catch (e) {
          CustomFullScreenDialog.cancleDialog();

          log("Error trying to upload file");
          log(e);
        }
      }
    } else {
      // Else user is not logged in, cancel loading spinner
      CustomFullScreenDialog.cancleDialog();
    }
  }

  Stream<List<CourseModel>> _streamCourses() =>
      FirebaseService.firebaseFirestore
          .collection(firebaseCoursesCollection)
          .snapshots()
          .map(
            (query) => query.docs
                .map((course) => CourseModel.fromDocument(course))
                .toList(),
          );

  Future<bool> isFileDownloaded(String fileName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/$fileName';
    return File(filePath).existsSync();
  }
}

class DownloadService {
  final Dio _dio = Dio();

  Future<void> downloadFile(String url, String fileName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savePath = '${appDocDir.path}/$fileName';

    await _dio.download(url, savePath);
  }
}
