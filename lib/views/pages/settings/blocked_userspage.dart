import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/my_date_utils.dart';
import '../../widgets/chat/custom_list_view.dart';
import '../../widgets/setting/custom_setting_title.dart';
import '../chat/add_users_page/add_users_controller.dart';
import '../chat/add_users_page/components/user_online_condition.dart';
import '../dashboard/my_app_controller.dart';

class BlockedUsersPrivacyPage extends StatelessWidget {
  const BlockedUsersPrivacyPage({super.key});
  static const String routeName = '/blocked-user-privacy-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomSettingTitle(title: 'Blocked Users'),
      ),
      body: Padding(
        padding: kPadding,
        child: _userListView(),
      ),
    );
  }

  Widget _userListView() {
    return GetBuilder<AppController>(
      builder: (controller) {
        if (controller.currentUser == null) return const SizedBox();

        final myBlockedUsersID = controller.currentUser!.blockedUsers;

        if (myBlockedUsersID.isEmpty) {
          return const Text('You haven\t block any user!').center();
        }

        return FirestoreListView(
          query: FirebaseService.queryUsers(myBlockedUsersID),
          itemBuilder: (context, doc) {
            final user = doc.data();

            return CustomListViewTile(
              onlineStatus: shouldDisplayOnlineStatus(user),
              height: MediaQuery.of(context).size.height * 0.10,
              title: user.username,
              subtitle: 'Last Seen: ${MyDateUtil.getLastMessageTime(
                time: user.lastActive,
                showYear: true,
              )}',
              imageUrl:
                  user.imageUrl != null ? user.imageUrl! : defaultProfileImage,
              isOnline: user.isOnline,
              isSelected: false,
              onLongPress: () =>
                  AddUsersController.instance.showDiaologForBlockingUser(user),
            );
          },
        );
      },
    );
  }
}
