import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/setting/setting_options_widget.dart';
import '../dashboard/my_app_controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});
  static const String routeName = '/notification-page';

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.height;
    return _buildUI(deviceHeight, deviceWidth);
  }

  Widget _buildUI(double deviceHeight, double deviceWidth) {
    return Scaffold(
      body: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: deviceWidth * 0.03,
          vertical: deviceHeight * 0.02,
        ),
        height: deviceHeight * 0.98,
        width: deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAppBar(
              'Notification Settings',
              secondaryAction: const BackButton(),
            ),
            _buildNotifications(),
          ],
        ),
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
                iconData: Icons.notifications_active,
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
                iconData: Icons.notifications_active,
                title: 'Chat Notification',
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
                iconData: Icons.notifications_active,
                title: 'Buzz Notification',
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
                iconData: Icons.notifications_active,
                title: 'Likes Notification',
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
                iconData: Icons.notifications_active,
                title: 'Comments Notification',
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
                iconData: Icons.notifications_active,
                title: 'Saved Notification',
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
                iconData: Icons.notifications_active,
                title: 'Follows Notification',
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
