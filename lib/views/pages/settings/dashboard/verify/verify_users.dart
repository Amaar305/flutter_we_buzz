import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/chat/custom_list_view.dart';
import '../../../chat/add_users_page/components/user_online_condition.dart';
import 'verify_users_controller.dart';

class VerifyUsersPage extends GetView<VerifyUsersController> {
  const VerifyUsersPage({super.key});

  static const String routeName = '/verify-users-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verified users'),
      ),
      body: Obx(
        () {
          return ListView.builder(
            padding: kPadding,
            itemCount: controller.verifyUsers.length,
            itemBuilder: (context, index) {
              final user = controller.verifyUsers[index];

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
        },
      ),
    );
  }
}
