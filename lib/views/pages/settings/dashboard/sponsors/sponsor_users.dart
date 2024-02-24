import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/chat/custom_list_view.dart';
import '../../../chat/add_users_page/components/user_online_condition.dart';
import 'sponsor_controller.dart';

class SponsorUsersPage extends GetView<SponsorDashboadController> {
  const SponsorUsersPage({super.key});
  static const String routeName = '/sponsors-users-pages';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsor users'),
      ),
      body: Obx(() {
        return ListView.builder(
          padding: kPadding,
          itemCount: controller.sponsorUsers.length,
          itemBuilder: (context, index) {
            final user = controller.sponsorUsers[index];

            return CustomListViewTile(
              onlineStatus: shouldDisplayOnlineStatus(user),
              height: MediaQuery.sizeOf(context).height * 0.10,
              title: user.name,
              subtitle: user.username,
              imageUrl: user.imageUrl ?? defaultProfileImage,
              isOnline: user.isOnline,
              isSelected: false,
            );
          },
        );
      }),
    );
  }
}
