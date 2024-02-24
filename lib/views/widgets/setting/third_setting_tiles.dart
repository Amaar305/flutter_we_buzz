import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/chart/users_sponsor_chart_page.dart';
import '../../pages/dashboard/my_app_controller.dart';
import '../../pages/settings/dashboard/dashboard.dart';
import '../../pages/settings/help/help_center_page.dart';
import '../../pages/settings/privacy_page.dart';
import 'setting_options_widget.dart';
import 'trailing_setting.dart';

class ThirdThreeSettingTiles extends StatelessWidget {
  const ThirdThreeSettingTiles({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<AppController>(
            builder: (control) {
              if (control.currentUser == null) return const SizedBox();
              if (!control.currentUser!.isStaff) return const SizedBox();
              return MySettingOption2(
                onTap: () {
                  Get.toNamed(DashBoardPage.routeName);
                },
                iconData: Icons.dashboard_outlined,
                title: 'Dashboard',
                trailing: const TrailingIcon(),
              );
            },
          ),
          GetBuilder<AppController>(
            builder: (control) {
              if (control.currentUser == null) return const SizedBox();
              if (!control.currentUser!.sponsor) return const SizedBox();
              return MySettingOption2(
                onTap: () {
                  Get.toNamed(UsersSponsorChartPage.routeName);
                },
                iconData: Icons.sell_outlined,
                title: 'Sponsorship Center',
                trailing: const TrailingIcon(),
              );
            },
          ),
          GetBuilder<AppController>(
            builder: (control) {
              if (control.currentUser == null) return const SizedBox();

              if (control.currentUser!.isVerified) return const SizedBox();
              // return MySettingOption2(
              //   iconData: Icons.star_outline,
              //   title: 'Premium Version',
              //   trailing: const TrailingIcon(),
              //   onTap: () => Get.toNamed(VerifyUserPage.routeName),
              // );
              return const SizedBox();
            },
          ),
          MySettingOption2(
            onTap: () {
              Get.toNamed(PrivacyPage.routeName);
            },
            iconData: Icons.security_outlined,
            title: 'Privacy & Terms',
            trailing: const TrailingIcon(),
          ),
          MySettingOption2(
            iconData: Icons.help_outline,
            title: 'Help Center',
            trailing: const TrailingIcon(),
            onTap: () => Get.toNamed(HelpCenterPage.routeName),
          ),
        ],
      ),
    );
  }
}
