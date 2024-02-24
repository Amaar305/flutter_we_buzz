import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/campus_announcement.dart';
import '../../widgets/home/my_buttons.dart';
import '../../widgets/home/my_drop_button.dart';
import '../../widgets/home/my_textfield.dart';
import 'hours.dart';
import 'update_announcement_controller.dart';

class UpdateAnnouncementPage extends GetView<UpdateAnnouncementController> {
  UpdateAnnouncementPage({super.key, required this.announcement}) {
    controller.textEditingController.text = announcement.content;
    controller.urlEditingController.text = announcement.url ?? '';
    controller.initialHours =
        hours.firstWhere((hour) => hour.hours == announcement.durationInHours);
  }
  final CampusAnnouncement announcement;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update'),
      ),
      body: Padding(
        padding: kPadding,
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: controller.textEditingController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'type...',
                  ),
                  maxLength: 200,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Content cannot be null';
                    }
                    return null;
                  },
                ),
                MyInputField(
                  controller: controller.urlEditingController,
                  hintext: 'Website Url',
                  iconData: FontAwesomeIcons.link,
                  label: 'Official Website',
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      if (!value.isURL) {
                        return 'Invalid Url';
                      }
                    }
                    return null;
                  },
                ),
                MyDropDownButtonForm(
                  initialValue: controller.initialHours!.title,
                  items: hours.map((e) => e.title).toList(),
                  label: 'Select Duration',
                  hintext: 'Duration',
                  onChanged: (value) {
                    final hour =
                        hours.firstWhere((week) => week.title == value!);

                    controller.setDuration(hour.hours);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Select a duration';
                    }

                    return null;
                  },
                ),
                20.height,
                MyRegistrationButton(
                  title: 'Update',
                  secondaryColor: Colors.white,
                  onPressed: () {
                    final isValid = controller.formKey.currentState!.validate();
                    FocusScope.of(context).unfocus();
                    if (isValid) {
                      controller.formKey.currentState!.save();
                      controller.updateAnnouncement(announcement);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
