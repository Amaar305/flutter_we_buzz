import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/home/my_drop_button.dart';
import '../../widgets/setting/custom_setting_title.dart';
import '../dashboard/my_app_controller.dart';

class DirectMessagePrivacyPage extends StatelessWidget {
  const DirectMessagePrivacyPage({super.key});
  static const String routeName = '/dm-privacy-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomSettingTitle(title: 'DM Privacy'),
      ),
      body: Padding(
        padding: kPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              'Choose who can send you a DMs',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            GetBuilder<AppController>(
              builder: (controller) {
                return MyDropDownButtonForm(
                  icon: FontAwesomeIcons.message,
                  items: _dmPrivacySettings,
                  label: 'Choose',
                  initialValue:
                      controller.currentUser!.directMessagePrivacy.name,
                  hintext: '',
                  onChanged: (value) => controller.updateUserDMPrivacy(value!),
                );
              },
            ),

            // GetBuilder<AppController>(
            //   builder: (controller) {
            //     return DropdownButtonFormField<String>(
            //       value: controller.currentUser!.directMessagePrivacy.name,
            //       items: _dmPrivacySettings.map((privacy) {
            //         return DropdownMenuItem<String>(
            //           value: privacy,
            //           child: Text(privacy),
            //         );
            //       }).toList(),
            //       decoration: InputDecoration(
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //       ),
            //       onChanged: (value) {
            //         controller.updateUserDMPrivacy(value!);
            //       },
            //     );
            //   },
            // )
          ],
        ),
      ),
    );
  }
}

final List<String> _dmPrivacySettings = [
  'everyone',
  'followers',
  'following',
  'mutual',
];
