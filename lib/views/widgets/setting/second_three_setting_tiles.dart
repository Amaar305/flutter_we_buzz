import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/settings/notification_setting_page.dart';
import '../../pages/settings/save_buzz_page.dart';
import '../../pages/settings/settings_controller.dart';
import 'setting_options_widget.dart';
import 'trailing_setting.dart';

class SecondThreeSettingTiles extends StatelessWidget {
  const SecondThreeSettingTiles({
    super.key,
    required this.controller,
  });

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<SettingsController>(
            builder: (_) {
              return MySettingOption2(
                iconData: Icons.wb_sunny_outlined,
                title: controller.isSavedDarkMode ? 'DarkMode' : 'LightMode',
                trailing: Switch(
                  value: controller.isSavedDarkMode,
                  onChanged: (value) {
                    controller.changeThemeMode();
                  },
                ),
              );
            },
          ),
          MySettingOption2(
            iconData: Icons.notifications_active_outlined,
            title: 'Notification Settings',
            trailing: const TrailingIcon(),
            onTap: () => Get.toNamed(NotificationSettingsPage.routeName),
          ),
          MySettingOption2(
            iconData: Icons.bookmark_outline,
            title: 'Saved',
            trailing: const TrailingIcon(),
            onTap: () => Get.toNamed(SaveBuzzPage.routeName),
          )
        ],
      ),
    );
  }
}
