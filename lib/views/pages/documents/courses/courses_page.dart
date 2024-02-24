import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/constants.dart';
import '../../../widgets/home/custom_tab_bar.dart';
import '../../../widgets/home/my_buttons.dart';
import '../../../widgets/home/my_drop_button.dart';
import '../../../widgets/home/my_textfield.dart';
import '../../dashboard/my_app_controller.dart';
import '../components/lecture_note_widget.dart';
import '../components/past_question_widget.dart';
import '../programs_controller.dart';
import 'courses_controller.dart';

class CoursesView extends GetView<CoursesController> {
  const CoursesView({
    super.key,
    required this.programId,
    required this.programName,
    required this.level,
    required this.faculty,
  });
  final String programName;
  final String programId;
  final String level;
  final String faculty;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(programName),
          actions: [
            GetBuilder<AppController>(
              builder: (controller) {
                if (FirebaseAuth.instance.currentUser == null ||
                    controller.currentUser == null) {
                  // if user is null
                  return const SizedBox();
                }

                if (controller.currentUser!.isClassRep &&
                    controller.currentUser!.program == programName &&
                    controller.currentUser!.level == level) {
                  // if user is class rep and user's program == page's program name and user's level == page's level
                  return IconButton(
                    tooltip: 'upload file',
                    onPressed: () {
                      _showBottomSheet(context);
                    },
                    icon: const Icon(Icons.add),
                  ).paddingAll(8);
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
        body: Padding(
          padding: kPadding,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTabBar(list: controller.tabTitles),
              Expanded(
                child: TabBarView(
                  children: [
                    LectureNotesWidget(
                      controller: controller,
                      programId: programId,
                      level: level,
                    ),
                    PastQuestionsWidget(
                      controller: controller,
                      level: level,
                      programId: programId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: kPadding,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // black divider
                Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .015,
                    horizontal: MediaQuery.of(context).size.width * .4,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                MyInputField(
                  controller: controller.courseCodeEditingController,
                  iconData: Icons.numbers,
                  label: 'Course code',
                  hintext: 'Enter Course Code',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Course Code should not be empty';
                    }
                    return null;
                  },
                ),

                Obx(
                  () {
                    return MyDropDownButtonForm(
                      items: ProgramsController.instance.lectureNotes
                          .where(
                            (note) =>
                                note.programName == programName ||
                                note.faculty == faculty && note.level == level,
                          )
                          .toList()
                          .map((e) => e.title)
                          .toList(),
                      label: 'Lecture Note',
                      onChanged: (value) => controller.setLectureNote(value!),
                      hintext: 'Select Lecture Notes',
                    );
                  },
                ),

                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GetBuilder<CoursesController>(
                          builder: (_) {
                            return Checkbox(
                              value: controller.isPastQ,
                              onChanged: (value) {
                                controller.updateIsPastQ(value!);
                              },
                            );
                          },
                        ),
                        const Text('Past Question?'),
                      ],
                    ),
                    Row(
                      children: [
                        GetBuilder<CoursesController>(
                          builder: (_) {
                            return Checkbox(
                              value: controller.isFreeBook,
                              onChanged: (value) {
                                controller.updateIsFreeBook(value!);
                              },
                            );
                          },
                        ),
                        const Text('Free Book?'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                MyRegistrationButton(
                  title: 'Upload',
                  secondaryColor: Colors.white,
                  onPressed: () {
                    if (controller
                            .courseCodeEditingController.text.isNotEmpty &&
                        controller.lecturTitile.isNotEmpty) {
                      controller.uploadFile(programId, level);
                    } else {
                      toast('Fields should not empty');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
