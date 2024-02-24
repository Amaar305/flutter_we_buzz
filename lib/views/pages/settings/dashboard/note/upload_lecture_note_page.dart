import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/widgets/home/my_buttons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/home/my_drop_button.dart';
import '../../../../widgets/home/my_textfield.dart';
import '../../../documents/levels/levels_list.dart';
import 'upload_lecture_note_controller.dart';

class UploadLectureNote extends GetView<UploadLectureNoteCOntroller> {
  const UploadLectureNote({super.key});

  static const String routeName = '/upload-Lecture-note';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload lecture note')),
      body: Padding(
        padding: kPadding,
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CoverImage thumbnail
                // GetBuilder<UploadLectureNoteCOntroller>(
                //   builder: (_) {
                //     return AnimatedContainer(
                //       duration: const Duration(milliseconds: 300),
                //       height: 200,
                //       width: 150,
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10),
                //         border: Border.all(width: 0.5, color: kPrimary),
                //       ),
                //       child: controller.coverImage != null &&
                //               controller.pickedFile != null
                //           ? Image.file(
                //               controller.coverImage!,
                //               fit: BoxFit.fitHeight,
                //             )
                //           : const Icon(Icons.picture_as_pdf_outlined).center(),
                //     );
                //   },
                // ),

                // Title field
                MyInputField(
                  controller: controller.titleEditingController,
                  hintext: 'Enter Lecture Title',
                  iconData: Icons.book_outlined,
                  label: 'Lecture Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please lecture title';
                    }
                    if (value.length < 5) {
                      return 'Title must be greather than 5';
                    }

                    return null;
                  },
                ),

                // Coursecode Field
                MyInputField(
                  controller: controller.courseCodeEditingController,
                  hintext: 'Enter Course Code',
                  iconData: Icons.code,
                  label: 'Course Code',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter course code';
                    }
                    if (value.length < 5) {
                      return 'course code must be greather than 5';
                    }

                    return null;
                  },
                ),

                // Prgram DropdownButtonField
                MyDropDownButtonForm(
                  items: controller.programs,
                  label: 'Course',
                  hintext: 'Select Course',
                  onChanged: (p0) => controller.setProgram(p0!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select course title';
                    }

                    return null;
                  },
                ),

                // level DropdownButtonField
                MyDropDownButtonForm(
                  items: levels,
                  label: 'Level',
                  hintext: 'Select Level',
                  onChanged: (p0) => controller.setLevel(p0!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select level';
                    }

                    return null;
                  },
                ),

                // Faculty DropdownButtonField
                MyDropDownButtonForm(
                  items: controller.faculties,
                  label: 'Faculty',
                  hintext: 'Select Faculty',
                  onChanged: (p0) => controller.setFaculty(p0!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select faculty';
                    }

                    return null;
                  },
                ),

                //  File picker button
                GetBuilder<UploadLectureNoteCOntroller>(
                  builder: (_) {
                    return TextButton(
                      onPressed: () {
                        controller.pickFile();
                      },
                      child: controller.pickedFile != null
                          ? const Text(
                              'File Picked',
                              style: TextStyle(fontSize: 16),
                            )
                          : const Text(
                              'Pick File',
                              style: TextStyle(fontSize: 16),
                            ),
                    ).paddingAll(5);
                  },
                ).center(),

                // Submit Button
                MyRegistrationButton(
                  title: 'Upload',
                  secondaryColor: Colors.white,
                  onPressed: () {
                    final isValid = controller.formKey.currentState!.validate();
                    FocusScope.of(Get.context!).unfocus();
                    if (isValid) {
                      controller.formKey.currentState!.save();
                      controller.upload();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
