import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../dashboard/dashboard_controller.dart';
import 'edit_profile_page.dart';
import 'settings_controller.dart';

class SettingPage extends GetView<SettingsController> {
  const SettingPage({super.key});
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GetBuilder<AppController>(builder: (controll) {
                            return MySettingOption1(
                              iconData: Icons.person,
                              subtitle: controll.currentUser!.name,
                              title: 'Edit Profile',
                              trailing: GestureDetector(
                                onTap: () =>
                                    Get.toNamed(EditProfilePage.routeName),
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            );
                          }),
                          MySettingOption1(
                            iconData: Icons.email,
                            subtitle:
                                FirebaseAuth.instance.currentUser!.email ??
                                '',
                            title: 'Email',
                          ),
                          const MySettingOption1(
                            iconData: Icons.key,
                            subtitle: 'updated 2 weeks ago',
                            title: 'Password',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GetBuilder<SettingsController>(
                            builder: (_) {
                              return MySettingOption2(
                                iconData: Icons.sunny,
                                title: controller.isSavedDarkMode
                                    ? 'DarkMode'
                                    : 'LightMode',
                                trailing: Switch(
                                  value: controller.isSavedDarkMode,
                                  onChanged: (value) {
                                    controller.changeThemeMode();
                                  },
                                ),
                              );
                            },
                          ),
                          GetBuilder<AppController>(builder: (controll) {
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
                          }),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MySettingOption2(
                            iconData: Icons.help,
                            title: 'Help Center',
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          MySettingOption2(
                            iconData: Icons.security,
                            title: 'Privacy & Terms',
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          MySettingOption2(
                            iconData: Icons.chat_bubble,
                            title: 'Contact us',
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => AppController.instance.logOut(),
                      child: const Text(
                        'LOG OUT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Version: 1.0.1'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MySettingOption1 extends StatelessWidget {
  const MySettingOption1({
    super.key,
    required this.iconData,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData iconData;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                child: Icon(iconData),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (trailing != null) trailing!
        ],
      ),
    );
  }
}

class MySettingOption2 extends StatelessWidget {
  const MySettingOption2({
    super.key,
    required this.iconData,
    required this.trailing,
    required this.title,
  });

  final IconData iconData;
  final String title;
  final Widget trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                child: Icon(iconData),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing
        ],
      ),
    );
  }
}
