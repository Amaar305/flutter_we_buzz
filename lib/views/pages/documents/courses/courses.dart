import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/documents/view/doc_view.dart';
import 'package:hi_tweet/views/widgets/home/my_button.dart';
import 'package:hi_tweet/views/widgets/home/my_textfield.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../dashboard/my_app_controller.dart';
import '../components/course_widget.dart';
import '../levels_list.dart';
import 'courses_controller.dart';

class CoursesView extends GetView<CoursesController> {
  const CoursesView({
    super.key,
    required this.programId,
    required this.programName,
    required this.level,
  });
  final String programName;
  final String programId;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(programName),
        actions: [
          GetX<AppController>(
            builder: (controller) {
              if (FirebaseAuth.instance.currentUser != null) {
                final currentLoggedInUser = controller.weBuzzUsers.firstWhere(
                    (user) =>
                        user.userId == FirebaseAuth.instance.currentUser!.uid);

                if (currentLoggedInUser.isStaff) {
                  return IconButton(
                    tooltip: 'upload file',
                    onPressed: () {
                      _showBottomSheet(context);
                    },
                    icon: const Icon(Icons.add),
                  );
                } else {
                  return const SizedBox();
                }
              } else {
                return const SizedBox();
              }
            },
          )
        ],
      ),
      body: Obx(
        () {
          // Filter the courses base on level and programid
          final courses = controller.courses
              .where(
                (course) => course.level == level,
              )
              .toList();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var course = courses[index];

              return CoursesTile(
                title: course.courseName,
                url: course.url,
                onTap: () {
                  Get.to(
                    () => DocumentView(
                      url: course.url,
                      title: course.courseName,
                    ),
                  );
                },
              );
            },
          );
        },
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
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            // black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * .015,
                horizontal: MediaQuery.of(context).size.width * .4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            MyTextField(
              controller: controller.courseCodeEditingController,
              hintext: 'Course Code',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Course Code should not be empty';
                }
                return null;
              },
            ),
            MyTextField(
              controller: controller.courseTitleEditingController,
              hintext: 'Course Name',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Course name should not be empty';
                } else if (value.length <= 8) {
                  return 'Course name should be not be less than 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              isExpanded: true,
              items: levels.map((lvl) {
                return DropdownMenuItem<String>(
                  value: lvl,
                  child: Text(lvl),
                );
              }).toList(),
              decoration: InputDecoration(
                hintText: 'Select level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (value) {
                controller.setLevelName(value!);
              },
            ),
            const SizedBox(height: 20),
            MyButton(
              text: 'Upload',
              onPressed: () {
                if (controller.courseCodeEditingController!.text.isNotEmpty &&
                    controller.courseTitleEditingController!.text.isNotEmpty &&
                    controller.levelName.isNotEmpty) {
                  controller.uploadFile(programId);
                } else {
                  toast('Fields should not empty');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
