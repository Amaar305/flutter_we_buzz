import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/constants.dart';
import '../../../widgets/setting/setting_options_widget.dart';
import '../../../widgets/setting/trailing_setting.dart';
import 'bugs/report_bug_page.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});
  static const String routeName = '/help-center-page';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: Padding(
        padding: kPadding,
        child: ListView(
          children: [
            const MySettingOption1(
              iconData: Icons.email_outlined,
              subtitle: 'uthmanameen2003@gmail.com',
              title: 'Contact us',
            ),
            const MySettingOption1(
              iconData: Icons.chat_outlined,
              subtitle: 'Coming soon',
              title: 'Chat with staff',
            ),
            MySettingOption2(
              iconData: Icons.bug_report_outlined,
              title: 'Report a bug',
              trailing: const TrailingIcon(),
              onTap: () => Get.toNamed(ReportBugPage.routeName),
            ),
            20.height,
          ],
        ),
      ),
    );
  }
}
