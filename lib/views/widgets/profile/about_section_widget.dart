import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../pages/dashboard/my_app_controller.dart';
import '../../utils/method_utils.dart';
import 'profile_option_setting.dart';
import 'profile_tab_widget.dart';

class AbouSectionWidget extends StatelessWidget {
  const AbouSectionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 20, right: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleSetting(title: 'Basic Information'),
            const SizedBox(height: 15),
            GetBuilder<AppController>(
              builder: (controll) {
                if (controll.currentUser != null &&
                    controll.currentUser!.program != null) {
                  return BasicInfoWidget(
                    iconData: Icons.school,
                    subtitle: controll.currentUser!.program ?? 'not set',
                    title: 'Program',
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            GetBuilder<AppController>(
              builder: (controll) {
                if (controll.currentUser != null &&
                    controll.currentUser!.level != null) {
                  return BasicInfoWidget(
                    iconData: FontAwesomeIcons.stairs,
                    subtitle: controll.currentUser!.level ?? 'not set',
                    title: 'Level',
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            const TitleSetting(title: 'Contact Information'),
            const SizedBox(height: 15),
            GetBuilder<AppController>(
              builder: (controller) {
                if (controller.currentUser != null) {
                  final email = controller.currentUser!.email;
                  return GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(
                              text: controller.currentUser!.email))
                          .then(
                        (value) {
                          Get.back();
                          toast('Email Copied');
                        },
                      );
                    },
                    child: BasicInfoWidget(
                      iconData: Icons.email,
                      subtitle: email,
                      title: 'Email',
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            GetBuilder<AppController>(
              builder: (controll) {
                if (controll.currentUser != null &&
                    controll.currentUser!.phone != null) {
                  return GestureDetector(
                    onTap: () {
                      MethodUtils.makePhoneCall(
                          controll.currentUser!.phone ?? '');
                    },
                    child: BasicInfoWidget(
                      iconData: FontAwesomeIcons.stairs,
                      subtitle: controll.currentUser!.phone ?? 'not set',
                      title: 'Phone No',
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            GetBuilder<AppController>(
              builder: (controller) {
                return BasicInfoWidget(
                  iconData: FluentSystemIcons.ic_fluent_calendar_date_filled,
                  subtitle: controller.currentUser != null
                      ? MethodUtils.getLastMessageTime(
                          time: controller
                              .currentUser!.createdAt.millisecondsSinceEpoch
                              .toString(),
                          showYear: true,
                        )
                      : 'loading..',
                  title: 'Joined On',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
// BasicInfoWidget(
//                         iconData:
//                             FluentSystemIcons.ic_fluent_calendar_date_filled,
//                         subtitle: MethodUtils.getLastMessageTime(
//                           time: weBuzzUser.createdAt.millisecondsSinceEpoch
//                               .toString(),
//                           showYear: true,
//                         ),
//                         title: 'Joined On',
//                       )