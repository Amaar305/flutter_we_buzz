import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/documents/course_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../../utils/method_utils.dart';
import '../../dashboard/my_app_controller.dart';
import '../programs_controller.dart';

class CoursesController extends GetxController {
  // RxList<CourseModel> courses = RxList([]);

  late TextEditingController courseCodeEditingController;
  String _lectureNoteRef = '';

  bool isPastQ = false;
  bool isFreeBook = false;

  void updateIsPastQ(bool isPastQ) {
    this.isPastQ = isPastQ;
    update();
  }

  void updateIsFreeBook(bool isFreeBook) {
    this.isFreeBook = isFreeBook;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    courseCodeEditingController = TextEditingController();
  }

  Query<CourseModel> queryCourse(String programId, String level) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseCoursesCollection)
        .where('programId', isEqualTo: programId)
        .where('level', isEqualTo: level)
        .withConverter<CourseModel>(
          fromFirestore: (snapshot, _) => CourseModel.fromDocument(snapshot),
          toFirestore: (course, _) => course.toJson(),
        );
  }

  List<String> tabTitles = [
    'Lecture Notes',
    'Past Questions',
  ];

  void setLectureNote(String lecture) {
    _lectureNoteRef = lecture;
  }

  String get lecturTitile => _lectureNoteRef;

  void uploadFile(String programId, String level) async {
    CustomFullScreenDialog.showDialog();

    if (FirebaseAuth.instance.currentUser != null) {
      // Check if current user is logged in

      // Get current user info
      final currentUser = AppController.instance.currentUser;
      if (currentUser == null) return;

      if (currentUser.isStaff) {
        // Check if current user is a staff
        try {
          // Create the instance of course model
          CourseModel courseModel = CourseModel(
            courseID: MethodUtils.generatedId,
            programId: programId,
            courseCode: courseCodeEditingController.text.trim(),
            courseName: lecturTitile,
            uploadedBy: currentUser.userId,
            lectureRefrence: ProgramsController.instance.lectureNotes
                .firstWhere((element) => element.title == lecturTitile)
                .id,
            uploadedAt: Timestamp.now(),
            level: level,
            pastQ: isPastQ,
            isFreeBook: isFreeBook,
          );

          // Upload it to the firestorage
          FirebaseService.createCourse(courseModel).whenComplete(() {
            CustomFullScreenDialog.cancleDialog();
            courseCodeEditingController.clear();
            Get.back();
          });
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

  void deleteCourse(CourseModel courseModel) async {
    CustomFullScreenDialog.showDialog();
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        // Check if current user is not null

        // Current user's Id
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;

        // Current user info
        final currentUser = AppController.instance.currentUser!;

        if (courseModel.uploadedBy == currentUserId || currentUser.isAdmin) {
          // Check if currentUser uploaded the course or currentUser is admin

          // Delete the course in firestore
          await FirebaseService.deleteCourse(courseModel.courseID)
              .whenComplete(() => CustomFullScreenDialog.cancleDialog());
        }
      }
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      toast('Something went wrong');
      log('Error trying to delete course');
      log(e);
    }
  }

  void alert(CourseModel courseModel) {
    Get.dialog(AlertDialog(
      title: const Text('Warning'),
      content: const Text(
        'Are you sure you want to delete this course? No one can view or restore it!.',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        MaterialButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        MaterialButton(
          onPressed: () {
            Get.back();
            deleteCourse(courseModel);
          },
          child: const Text(
            'Delete',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        )
      ],
    ));
  }

  // Stream<List<CourseModel>> _streamCourses() {
  //   return FirebaseService.firebaseFirestore
  //       .collection(firebaseCoursesCollection)
  //       .snapshots()
  //       .map(
  //         (query) => query.docs
  //             .map((course) => CourseModel.fromDocument(course))
  //             .toList(),
  //       );
  // }



  @override
  void onClose() {
    super.onClose();
    courseCodeEditingController.dispose();
  }
}





/*



  void uploadFile(String programId) async {
    CustomFullScreenDialog.showDialog();

    if (FirebaseAuth.instance.currentUser != null) {
      // Check if current user is logged in

      // Get current user info
      final currentUser = AppController.instance.currentUser;
      if (currentUser == null) return;

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
                courseID: MethodUtils.generatedId,
                programId: programId,
                courseCode: courseCodeEditingController!.text.trim(),
                courseName: courseTitleEditingController!.text.trim(),
                uploadedBy: currentUser.userId,
                url: fileUrl,
                uploadedAt: Timestamp.now(),
                level: levelName,
                pastQ: isPastQ,
                isFreeBook: isFreeBook,
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



*/ 