import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../utils/constants.dart';
import '../../../../../widgets/home/custom_tab_bar.dart';
import '../../../../dashboard/my_app_controller.dart';
import 'reported_user_page.dart';
import 'user_reports_controller.dart';

class UsersReport extends GetView<UserReportsController> {
  const UsersReport({super.key});
  static const String routeName = '/report-user-page';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabTitles.length,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users Action Center'),
        ),
        body: Padding(
          padding: kPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTabBar(list: controller.tabTitles),
              CustomTabBarView(
                children: [
                  CustomSuspendedUserWidget(controller: controller),
                  CustomReportUserWidget(controller: controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSuspendedUserWidget extends StatelessWidget {
  const CustomSuspendedUserWidget({
    super.key,
    required this.controller,
    this.onTap,
  });

  final UserReportsController controller;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final suspendedUsers = AppController.instance.weBuzzUsers
            .where((user) => user.isSuspended)
            .toList();

        if (suspendedUsers.isEmpty) {
          return const Text('No suspended user').center();
        }

        return ListView.builder(
          itemCount: suspendedUsers.length,
          itemBuilder: (context, index) {
            final user = suspendedUsers[index];
            final suspendedUsersCount = controller.reports
                .where((report) => report.reportedItemId == user.userId)
                .length;

            return ListTile(
              onTap: () => Get.to(() => ReportedUserPage(user: user)),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  user.imageUrl ?? defaultProfileImage,
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '$suspendedUsersCount reports',
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomReportUserWidget extends StatelessWidget {
  const CustomReportUserWidget({
    super.key,
    required this.controller,
    this.onTap,
  });

  final UserReportsController controller;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return ListView.builder(
          itemCount: controller.reports.length,
          itemBuilder: (context, index) {
            final reportedUsers = controller.reports[index];

            final user = controller.getUserById(reportedUsers.reportedItemId);

            final reportedCount = controller.reports
                .where((r) => r.reportedItemId == user.userId)
                .length;

            return ListTile(
              onTap: () => Get.to(() => ReportedUserPage(user: user)),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  user.imageUrl ?? defaultProfileImage,
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '$reportedCount reports',
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
