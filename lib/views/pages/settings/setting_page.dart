import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/method_utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../registration/update_password.dart';
import '../../widgets/setting/setting_options_widget.dart';
import '../dashboard/my_app_controller.dart';
import 'edit_profile_page.dart';
import 'notification_setting_page.dart';
import 'privacy_page.dart';
import 'save_buzz_page.dart';
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
                          GetBuilder<AppController>(
                            builder: (controll) {
                              return MySettingOption1(
                                iconData: Icons.person,
                                subtitle: controll.currentUser!.name,
                                onTap: () =>
                                    Get.toNamed(EditProfilePage.routeName),
                                title: 'Edit Profile',
                                trailing: IconButton(
                                  onPressed: () =>
                                      Get.toNamed(EditProfilePage.routeName),
                                  icon: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              );
                            },
                          ),
                          MySettingOption1(
                            iconData: Icons.email,
                            subtitle:
                                FirebaseAuth.instance.currentUser!.email ?? '',
                            title: 'Email',
                          ),
                          GetX<AppController>(
                            init: AppController.instance,
                            builder: (context) {
                              if (FirebaseAuth.instance.currentUser != null) {
                                bool canUpdate = false;
                                final currentUser = AppController
                                    .instance.weBuzzUsers
                                    .firstWhere((element) =>
                                        element.userId ==
                                        FirebaseAuth.instance.currentUser!.uid);

                                Timestamp? lastUpdatedPassword =
                                    currentUser.lastUpdatedPassword;

                                // Check if the last update was more than two weeks ago
                                if (lastUpdatedPassword != null) {
                                  DateTime lastUpdateDateTime =
                                      lastUpdatedPassword.toDate();
                                  DateTime now = DateTime.now();
                                  Duration difference =
                                      now.difference(lastUpdateDateTime);

                                  if (difference.inDays >= 14) {
                                    // Allow the user to update their password
                                    canUpdate = true;
                                  } else {
                                    // Inform the user that they can only update their password once in two weeks
                                    canUpdate = false;
                                  }
                                } else {
                                  // If it is null, that mean user has never change their password
                                  // Allow them to change
                                  canUpdate = true;
                                }
                                return MySettingOption1(
                                  iconData: Icons.key,
                                  subtitle: currentUser.lastUpdatedPassword !=
                                          null
                                      ? 'update ${MethodUtils.formatDate(currentUser.lastUpdatedPassword!)}'
                                      : 'tap to change',
                                  title: 'Password',
                                  onTap: () {
                                    if (canUpdate) {
                                      Get.toNamed(UpdatePasswordPage.routeName);
                                    } else {
                                      toast(
                                          "You can only update your password once every two weeks.");
                                    }
                                  },
                                );
                              } else {
                                // user is not logged in
                                return const SizedBox();
                              }
                            },
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
                          MySettingOption2(
                            iconData: Icons.notifications_active,
                            title: 'Notification Settings',
                            trailing: IconButton(
                              onPressed: () => Get.toNamed(
                                  NotificationSettingsPage.routeName),
                              icon: Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            onTap: () =>
                                Get.toNamed(NotificationSettingsPage.routeName),
                          ),
                          MySettingOption2(
                            iconData: Icons.bookmark,
                            title: 'Saved Buzzes',
                            trailing: IconButton(
                              onPressed: () =>
                                  Get.toNamed(SaveBuzzPage.routeName),
                              icon: Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            onTap: () => Get.toNamed(SaveBuzzPage.routeName),
                          )
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
                            onTap: () {
                              Get.toNamed(PrivacyPage.routeName);
                            },
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
