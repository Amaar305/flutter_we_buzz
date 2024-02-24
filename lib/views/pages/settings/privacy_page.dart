import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/setting/setting_options_widget.dart';
import '../dashboard/my_app_controller.dart';
import 'blocked_userspage.dart';
import 'direct_message_privacy_page.dart';
import 'online_status_indicator_privacy_page.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  static const String routeName = '/privacy-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: ListView(
        padding: kPadding,
        children: [
          MySettingOption1(
            onTap: () => Get.toNamed(DirectMessagePrivacyPage.routeName),
            iconData: Icons.chat_bubble_outline,
            subtitle: 'Who can send you DMs',
            title: 'Direct Message Privacy',
          ),
          GetX<AppController>(
            builder: (controll) {
              if (FirebaseAuth.instance.currentUser == null) {
                return const SizedBox();
              }

              final user = controll.weBuzzUsers.firstWhere((user) =>
                  user.userId == FirebaseAuth.instance.currentUser!.uid);

              return MySettingOption1(
                onTap: () => Get.toNamed(BlockedUsersPrivacyPage.routeName),
                iconData: FluentSystemIcons.ic_fluent_person_block_regular,
                subtitle: '${user.blockedUsers.length}',
                title: 'Blocked users',
              );
            },
          ),
          MySettingOption1(
            onTap: () =>
                Get.toNamed(OnlineStatusIndicatorPrivacyPage.routeName),
            iconData: Icons.online_prediction_outlined,
            subtitle: 'Who can see me online',
            title: 'Online status',
          ),
        ],
      ),
    );
  }
}
