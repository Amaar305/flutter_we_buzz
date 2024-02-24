import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/home/my_drop_button.dart';
import '../../widgets/setting/custom_setting_title.dart';
import '../dashboard/my_app_controller.dart';

class OnlineStatusIndicatorPrivacyPage extends StatelessWidget {
  const OnlineStatusIndicatorPrivacyPage({super.key});
  static const String routeName = '/onlineStatusIndicator-privacy-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomSettingTitle(title: 'Online status'),
      ),
      body: Padding(
        padding: kPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Choose who can see when you\'re online',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            GetBuilder<AppController>(
              builder: (controller) {
                return MyDropDownButtonForm(
                  icon: Icons.online_prediction,
                  items: _dmPrivacySettings,
                  label: 'Choose',
                  initialValue:
                      controller.currentUser!.directMessagePrivacy.name,
                  hintext: 'Choose',
                  onChanged: (value) => controller.updateUserDMPrivacy(value!),
                );
              },
            ),

            // GetBuilder<AppController>(
            //   builder: (controller) {
            //     return DropdownButtonFormField<String>(
            //       value: controller.currentUser!.onlineStatusIndicator.name,
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
            //         controller.updateUserOnlineStatusPrivacy(value!);
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
