import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/setting/custom_setting_title.dart';
import '../../widgets/setting/setting_options_widget.dart';
import '../dashboard/my_app_controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});
  static const String routeName = '/notification-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomSettingTitle(title: 'Notifications'),
      ),
      body: Padding(
        padding: kPadding,
        child: _buildNotifications(),
      ),
    );
  }

  Widget _buildNotifications() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GetBuilder<AppController>(
            builder: (controll) {
              return MySettingOption2(
                iconData: Icons.notifications_active_outlined,
                title: 'Notification',
                trailing: Switch(
                  value: controll.currentUser != null
                      ? controll.currentUser!.notification
                      : true,
                  onChanged: (value) {
                    controll.updateNotification();
                  },
                ),
              );
            },
          ),
          GetBuilder<AppController>(
            builder: (controll) {
              return MySettingOption2(
                iconData: Icons.notifications_active_outlined,
                title: 'Chat',
                trailing: Switch(
                  value: controll.currentUser != null
                      ? controll.currentUser!.chatMessageNotifications
                      : true,
                  onChanged: (value) {
                    controll.updateChatMessageNotifications();
                  },
                ),
              );
            },
          ),
          GetBuilder<AppController>(
            builder: (controll) {
              return MySettingOption2(
                iconData: Icons.notifications_active_outlined,
                title: 'Buzz ',
                trailing: Switch(
                  value: controll.currentUser != null
                      ? controll.currentUser!.postNotifications
                      : true,
                  onChanged: (value) {
                    controll.updatePostNotifications();
                  },
                ),
              );
            },
          ),
          GetBuilder<AppController>(
            builder: (controll) {
              return MySettingOption2(
                iconData: Icons.notifications_active_outlined,
                title: 'Likes ',
                trailing: Switch(
                  value: controll.currentUser != null
                      ? controll.currentUser!.likeNotifications
                      : true,
                  onChanged: (value) {
                    controll.updateLikeNotifications();
                  },
                ),
              );
            },
          ),
          GetBuilder<AppController>(
            builder: (controll) {
              return MySettingOption2(
                iconData: Icons.notifications_active_outlined,
                title: 'Comments ',
                trailing: Switch(
                  value: controll.currentUser != null
                      ? controll.currentUser!.commentNotifications
                      : true,
                  onChanged: (value) {
                    controll.updateCommentNotifications();
                  },
                ),
              );
            },
          ),
          GetBuilder<AppController>(
            builder: (controll) {
              return MySettingOption2(
                iconData: Icons.notifications_active_outlined,
                title: 'Saved ',
                trailing: Switch(
                  value: controll.currentUser != null
                      ? controll.currentUser!.saveNotifications
                      : true,
                  onChanged: (value) {
                    controll.updateSaveNotifications();
                  },
                ),
              );
            },
          ),
          GetBuilder<AppController>(
            builder: (controll) {
              return MySettingOption2(
                iconData: Icons.notifications_active_outlined,
                title: 'Follows ',
                trailing: Switch(
                  value: controll.currentUser != null
                      ? controll.currentUser!.followNotifications
                      : true,
                  onChanged: (value) {
                    controll.updateFollowNotifications();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
