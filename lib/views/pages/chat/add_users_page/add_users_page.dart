import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../model/we_buzz_user_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/my_date_utils.dart';
import '../../../widgets/chat/custom_list_view.dart';
import '../../../widgets/chat/custom_text_form_field.dart';
import '../../../widgets/custom_app_bar.dart';
import 'add_users_controller.dart';

class AddUsersPage extends GetView<AddUsersController> {
  const AddUsersPage({super.key});
  static const String routeName = '/add-users';
  @override
  Widget build(BuildContext context) {
    return _buldUI();
  }

  Widget _buldUI() {
    return Scaffold(
      body: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: controller.deviceWidth * 0.03,
          vertical: controller.deviceHeight * 0.02,
        ),
        height: controller.deviceHeight * 0.98,
        width: controller.deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAppBar(
              'Users',
              secondaryAction: const BackButton(),
              primaryAction: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
            ),
            CustomTextField(
              onEditingComplete: (value) {
                controller.getUser(name: value);
                //  TODO IMPLEMENT USER SEARCH
              },
              hintText: 'Search...',
              obscureText: false,
              controller: controller.searchEditingController,
              iconData: Icons.search,
            ),
            _buildUsers(),
            _createChatButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsers() {
    return Expanded(
      child: Obx(
        () {
          return ListView.builder(
            itemCount: controller.WeBuzzUsers.where((user) =>
                user.userId != FirebaseAuth.instance.currentUser!.uid).length,
            itemBuilder: (context, index) {
              final user = controller.WeBuzzUsers.where(
                (user) => user.userId != FirebaseAuth.instance.currentUser!.uid,
              ).toList()[index];
              return GetBuilder<AddUsersController>(
                builder: (_) {
                  return CustomListViewTile(
                    onlineStatus: shouldDisplayOnlineStatus(user),
                    height: controller.deviceHeight * 0.10,
                    title: user.username,
                    subtitle: 'Last Seen: ${MyDateUtil.getLastMessageTime(
                      time: user.lastActive,
                      showYear: true,
                    )}',
                    imageUrl: user.imageUrl != null
                        ? user.imageUrl!
                        : defaultProfileImage,
                    isOnline: user.isOnline,
                    isSelected: controller.selectedUser.contains(user),
                    onTap: () {
                      controller.updateSelectedUser(user);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _createChatButton() {
    return GetBuilder<AddUsersController>(
      builder: (_) {
        if (controller.selectedUser.isNotEmpty) {
          return TextButton(
            onPressed: () {
              controller.createChat();
            },
            child: Text(
              controller.selectedUser.length > 1
                  ? "Create Group Chat"
                  : "Chat With ${controller.selectedUser.first.username}",
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

bool shouldDisplayOnlineStatus(WeBuzzUser targetUser) {
  var onlineStatusIndicator = targetUser.onlineStatusIndicator;

  final currentUserID = FirebaseAuth.instance.currentUser!.uid;

  // Display the DM button based on DM privacy settings
  if (onlineStatusIndicator == DirectMessagePrivacy.everyone) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.followers &&
      targetUser.followers.contains(currentUserID)) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.following &&
      targetUser.following.contains(currentUserID)) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.mutual &&
      targetUser.followers.contains(currentUserID) &&
      targetUser.following.contains(currentUserID)) {
    return true;
  }

  return false;
}
