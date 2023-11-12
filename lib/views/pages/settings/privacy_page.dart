import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/dashboard/my_app_controller.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/setting/setting_options_widget.dart';
import 'blocked_userspage.dart';
import 'direct_message_privacy_page.dart';
import 'online_status_indicator_privacy_page.dart';

late double _deviceHeight;
late double _deviceWidth;

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  static const String routeName = '/privacy-page';

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.height;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar('Privacy'),
              MySettingOption1(
                onTap: () => Get.toNamed(DirectMessagePrivacyPage.routeName),
                iconData: Icons.chat_bubble,
                subtitle: 'Who can send you DMs',
                title: 'Direct Message Privacy',
              ),
              GetX<AppController>(
                builder: (controll) {
                  return MySettingOption1(
                    onTap: () => Get.toNamed(BlockedUsersPrivacyPage.routeName),
                    iconData: Icons.app_blocking,
                    subtitle:
                        '${controll.weBuzzUsers.firstWhere((user) => user.userId == FirebaseAuth.instance.currentUser!.uid).blockedUsers.length}',
                    title: 'Blocked users',
                  );
                },
              ),
              MySettingOption1(
                onTap: () =>
                    Get.toNamed(OnlineStatusIndicatorPrivacyPage.routeName),
                iconData: Icons.online_prediction,
                subtitle: 'Who can see me online',
                title: 'Online status',
              ),
              const SizedBox(height: 30),
              const Text(
                'We Buzz\'s Unyielding Commitment.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'By using the App, you acknowledge and agree to the terms of our Privacy Policy. We collect and use your location, push notification preferences, and device information in accordance with our Privacy Policy.',
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
