import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/chat/add_users_page/add_users_controller.dart';

import '../../utils/constants.dart';
import '../../utils/my_date_utils.dart';
import '../../widgets/chat/custom_list_view.dart';
import '../../widgets/custom_app_bar.dart';
import '../chat/add_users_page/components/user_online_condition.dart';
import '../dashboard/my_app_controller.dart';

late double _deviceHeight;
late double _deviceWidth;

class BlockedUsersPrivacyPage extends StatelessWidget {
  const BlockedUsersPrivacyPage({super.key});
  static const String routeName = '/blocked-user-privacy-page';

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.height;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomAppBar(
                'Blocked Users',
                secondaryAction: const BackButton(),
              ),
              _userListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userListView() {
    return Expanded(
      child: GetX<AppController>(
        builder: (controller) {
          final myBlockedUsersID = controller.weBuzzUsers
              .firstWhere((user) =>
                  user.userId == FirebaseAuth.instance.currentUser!.uid)
              .blockedUsers;
          final myBlockedUsers = myBlockedUsersID
              .map((id) => controller.weBuzzUsers
                  .firstWhere((user) => user.userId == id))
              .toList();

          return ListView.builder(
            itemCount: myBlockedUsers.length,
            itemBuilder: (context, index) {
              final user = myBlockedUsers[index];
              return CustomListViewTile(
                onlineStatus: shouldDisplayOnlineStatus(user),
                height: MediaQuery.of(context).size.height * 0.10,
                title: user.username,
                subtitle: 'Last Seen: ${MyDateUtil.getLastMessageTime(
                  time: user.lastActive,
                  showYear: true,
                )}',
                imageUrl: user.imageUrl != null
                    ? user.imageUrl!
                    : defaultProfileImage,
                isOnline: user.isOnline,
                isSelected: false,
                onLongPress: () => AddUsersController.instance
                    .showDiaologForBlockingUser(user),
              );
            },
          );
        },
      ),
    );
  }
}
