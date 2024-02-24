import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/announcement/update_annoucement.dart';

import '../../utils/constants.dart';
import '../../widgets/home/animated_annoucement.dart';
import '../../widgets/home/custom_tab_bar.dart';
import '../../widgets/home/my_buttons.dart';
import '../../widgets/home/my_drop_button.dart';
import '../../widgets/home/my_textfield.dart';
import '../home/home_controller.dart';
import 'annoucement_controller.dart';
import 'hours.dart';

class CampusAnnouncementPage extends GetView<CampusAnnouncementController> {
  const CampusAnnouncementPage({super.key});
  static const String routeName = '/annouce-page';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabsTitile.length,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: kPadding,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTabBar(list: controller.tabsTitile),
              const SizedBox(height: 10),
              CustomTabBarView(
                children: [
                  _NewAnnouncementWidget(controller: controller),
                  PreviousAnnouncementWidget(controller: controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewAnnouncementWidget extends StatelessWidget {
  const _NewAnnouncementWidget({
    required this.controller,
  });

  final CampusAnnouncementController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
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
              items: hours.map((e) => e.title).toList(),
              label: 'Select Duration',
              hintext: 'Duration',
              onChanged: (value) {
                final hour = hours.firstWhere((week) => week.title == value!);

                controller.setDuration(hour.hours);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Select a duration';
                }

                return null;
              },
            ),
            GetBuilder<CampusAnnouncementController>(
              builder: (_) {
                return MaterialButton(
                  onPressed: () {
                    controller.seletImages();
                  },
                  child: Text(
                    controller.imagePicked ? 'Image Picked' : 'Select image',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                );
              },
            ),
            MyRegistrationButton(
              title: 'Create',
              onPressed: () {
                final isValid = controller.formKey.currentState!.validate();
                FocusScope.of(context).unfocus();
                if (isValid) {
                  controller.formKey.currentState!.save();
                  controller.submit();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PreviousAnnouncementWidget extends StatelessWidget {
  const PreviousAnnouncementWidget({super.key, required this.controller});
  final CampusAnnouncementController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final announces = HomeController.instance.annouce;
        return ListView.builder(
          itemCount: announces.length,
          itemBuilder: (context, index) {
            final announcement = announces[index];
            if (announcement.image != null) {
              return BannerAnnouncementWidget(
                announcement: announcement,
                onLongPress: () => controller.deleteAnnouncement(announcement),
                onTap: () => Get.to(
                    () => UpdateAnnouncementPage(announcement: announcement)),
              );
            } else {
              return AnimatedAnnouncementWidget(
                announcement: announcement,
                onLongPress: () => controller.deleteAnnouncement(announcement),
                onTap: () => Get.to(
                    () => UpdateAnnouncementPage(announcement: announcement)),
              );
            }
          },
        );
      },
    );
  }
}
