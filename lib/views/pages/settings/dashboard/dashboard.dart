import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/constants.dart';
import '../../../widgets/setting/setting_options_widget.dart';
import '../../../widgets/setting/trailing_setting.dart';
import '../../users/users._list_page.dart';
import 'dashboard_controller.dart';
import 'issues/bug.report_issues_page.dart';
import 'note/upload_lecture_note_page.dart';
import 'reports/report_center.dart';
import 'sponsors/sponsor_products.dart';
import 'sponsors/sponsor_users.dart';
import 'verify/verify_users.dart';

class DashBoardPage extends GetView<DashboardController> {
  const DashBoardPage({super.key});
  static const String routeName = '/dashboad-staff-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: controller.showDialog,
            child: const Text(
              'Faculty',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: kPadding,
        child: ListView(
          children: [
            MySettingOption2(
              onTap: () {
                Get.toNamed(ReportCenterPage.routeName);
              },
              iconData: Icons.security,
              title: 'Report/Suspend',
              trailing: const TrailingIcon(),
            ),
            MySettingOption2(
              onTap: () => Get.toNamed(BugReportIssuesPage.routeName),
              iconData: Icons.bug_report_outlined,
              title: 'Bugs issues',
              trailing: const TrailingIcon(),
            ),
            MySettingOption2(
              onTap: () {
                Get.toNamed(VerifyUsersPage.routeName);
              },
              iconData: Icons.verified_outlined,
              title: 'Verify users',
              trailing: const TrailingIcon(),
            ),
            MySettingOption2(
              onTap: () {
                // Get.toNamed(VerifyUsersPage.routeName);
              },
              iconData: Icons.verified_outlined,
              title: 'Premium users',
              trailing: const TrailingIcon(),
            ),
            MySettingOption2(
              onTap: () {
                Get.toNamed(UsersPageList.routeName);
              },
              iconData: Icons.person_outline,
              title: 'Webuzz users',
              trailing: const TrailingIcon(),
            ),
            20.height,
            MySettingOption2(
              onTap: () {
                Get.toNamed(SponsorProductsPage.routeName);
              },
              iconData: Icons.sell_outlined,
              title: 'Sponsors',
              trailing: const TrailingIcon(),
            ),
            MySettingOption2(
              onTap: () {
                Get.toNamed(SponsorUsersPage.routeName);
              },
              iconData: FluentSystemIcons.ic_fluent_person_accounts_regular,
              title: 'Sponsor users',
              trailing: const TrailingIcon(),
            ),
            20.height,
            MySettingOption2(
              iconData: Icons.book_outlined,
              title: 'Upload lecture note',
              trailing: const TrailingIcon(),
              onTap: () => Get.toNamed(UploadLectureNote.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
