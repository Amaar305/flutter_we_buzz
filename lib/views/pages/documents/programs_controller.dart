import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/documents/faculty_model.dart';
import '../../../model/documents/lecture_note_model.dart';
import '../../../model/documents/program_model.dart';
import '../../../model/we_buzz_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/method_utils.dart';
import '../../widgets/home/my_buttons.dart';
import '../../widgets/home/my_drop_button.dart';
import '../../widgets/home/my_textfield.dart';

class ProgramsController extends GetxController {
  static final ProgramsController instance = Get.find();
  late TextEditingController textEditingController;
  late Random _random;

  late GlobalKey<ScaffoldState> scaffoldKey;

  ScrollController scrollController = ScrollController();
  RxList<FacultyModel> faculties = RxList([]);
  RxList<LectureNoteModel> lectureNotes = RxList([]);

  final isVisible = true.obs;

  String? _faculty;

  @override
  void onInit() {
    super.onInit();
    scaffoldKey = GlobalKey<ScaffoldState>();
    _random = Random();

    _fetchSponsors();

    textEditingController = TextEditingController();
    scrollController.addListener(() {
      isVisible.value = scrollController.position.userScrollDirection ==
          ScrollDirection.forward;
    });

    lectureNotes.bindStream(_streamLectureNote());

    faculties.bindStream(_streamfaculties());
  }

  void setFaculty(String faculty) {
    _faculty = faculty;
  }

  List<WeBuzz> sponsors = [];
  String get faculty => _faculty!;
  Future<void> _fetchSponsors() async {
    try {
      final query = await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .where('isSuspended', isEqualTo: false)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      for (var doc in query.docs) {
        final sponsor = WeBuzz.fromDocumentSnapshot(doc);

        if (!sponsor.isPublished) continue;
        if (!sponsor.validSponsor()) continue;

        sponsors.add(sponsor);
      }
    } catch (e) {
      log("error trying to fetch the sponsors");
      log(e);
    }
  }

  int nextNumber(int max) => _random.nextInt(max);

  WeBuzz getRandomAdvert() {
    int index = nextNumber(sponsors.length);
    return sponsors[index];
  }

  void showAlertDialog(String userID) {
    Get.dialog(
      AlertDialog(
        title: const Text('New Programme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyInputField(
              padTop: 0,
              iconData: Icons.title,
              label: 'Program Name',
              controller: textEditingController,
              hintext: 'Program',
            ),
            MyDropDownButtonForm(
              items: faculties.map((element) => element.name).toList(),
              label: 'Faculty',
              hintext: 'Select Faculty',
              onChanged: (p0) => setFaculty(p0!),
            ),
          ],
        ),
        actions: [
          CustomMaterialButton(
            title: 'Cancel',
            onPressed: () {
              Get.back();
            },
          ),
          CustomMaterialButton(
            title: 'Create',
            onPressed: () {
              Get.back();
              if (textEditingController.text.isNotEmpty) {
                createProgram(userID);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.dispose();
    textEditingController.dispose();
  }

  void createProgram(String userID) async {
    CustomFullScreenDialog.showDialog();
    try {
      ProgramModel programModel = ProgramModel(
        programId: MethodUtils.generatedId,
        programName: textEditingController.text.trim(),
        createdBy: userID,
        createdAt: Timestamp.now(),
        faculty: faculty,
      );
      await FirebaseService.createProgram(programModel).whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
        textEditingController.clear();
      });
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log("Error trying to create program");
      log(e);
    }
  }

  Stream<List<FacultyModel>> _streamfaculties() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseFacultyCollection)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => FacultyModel.fromDocument(doc)).toList());
  }

  final tabTitles = [
    'For you',
    'Explore',
    'Bookmark',
  ];

  Stream<List<LectureNoteModel>> _streamLectureNote() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseLectureNotesCollection)
        .snapshots()
        .map(
          (query) => query.docs
              .map((course) => LectureNoteModel.fromDocument(course))
              .toList(),
        );
  }
}
