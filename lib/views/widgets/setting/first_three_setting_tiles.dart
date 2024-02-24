import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/dashboard/my_app_controller.dart';
import '../../pages/settings/edit_profile_page.dart';
import '../../registration/update_password.dart';
import '../../utils/constants.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/method_utils.dart';
import 'setting_options_widget.dart';
import 'trailing_setting.dart';

class FirstThreeSettingTiles extends StatelessWidget {
  const FirstThreeSettingTiles({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetBuilder<AppController>(
          builder: (controll) {
            return MySettingOption1(
              iconData: Icons.person_outline,
              subtitle: controll.currentUser!.name,
              onTap: () => Get.toNamed(EditProfilePage.routeName),
              title: 'Edit Profile',
              trailing: const TrailingIcon(),
            );
          },
        ),
        MySettingOption1(
          iconData: Icons.email_outlined,
          subtitle: FirebaseAuth.instance.currentUser!.email ?? '',
          title: 'Email',
        ),
        GetX<AppController>(
          init: AppController.instance,
          builder: (_) {
            if (FirebaseAuth.instance.currentUser != null) {
              bool canUpdate = false;
              final currentUser = AppController.instance.weBuzzUsers.firstWhere(
                  (element) =>
                      element.userId == FirebaseAuth.instance.currentUser!.uid);

              Timestamp? lastUpdatedPassword = currentUser.lastUpdatedPassword;

              // Check if the last update was more than two weeks ago
              if (lastUpdatedPassword != null) {
                DateTime lastUpdateDateTime = lastUpdatedPassword.toDate();
                DateTime now = DateTime.now();
                Duration difference = now.difference(lastUpdateDateTime);

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
                iconData: Icons.key_outlined,
                subtitle: currentUser.lastUpdatedPassword != null
                    ? 'update ${MethodUtils.formatDate(currentUser.lastUpdatedPassword!)}'
                    : 'tap to change',
                title: 'Password',
                trailing: const TrailingIcon(),
                onTap: () {
                  if (canUpdate) {
                    Get.toNamed(UpdatePasswordPage.routeName);
                  } else {
                    CustomSnackBar.showSnackBar(
                      context: context,
                      title: 'Waring!',
                      message:
                          'You can only update your password once every two weeks.',
                      backgroundColor: kPrimary.withOpacity(0.5),
                    );
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
    );
  }
}
