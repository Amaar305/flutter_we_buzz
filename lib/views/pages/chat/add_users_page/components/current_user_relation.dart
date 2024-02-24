import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../../utils/my_date_utils.dart';
import '../../../../widgets/chat/custom_list_view.dart';
import '../add_users_controller.dart';
import 'user_online_condition.dart';

class CurrentUserRelations extends StatelessWidget {
  const CurrentUserRelations({
    super.key,
    required this.controller,
    required this.currentUserFriends,
  });

  final AddUsersController controller;
  final CurrentUserFriends currentUserFriends;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Obx(
      () {
        final mutuals = controller.WeBuzzUsers.where((user) {
          if (currentUserFriends == CurrentUserFriends.mutual) {
            return controller.currenttUsersFollowers.contains(user.userId) &&
                controller.currenttUsersFollowing.contains(user.userId);

            // user.followers
            //         .contains(FirebaseAuth.instance.currentUser!.uid) &&
            //     user.following.contains(FirebaseAuth.instance.currentUser!.uid);
          } else if (currentUserFriends == CurrentUserFriends.followers) {
            return controller.currenttUsersFollowers.contains(user.userId);
            //  user.following
            //     .contains(FirebaseAuth.instance.currentUser!.uid);
          } else {
            return controller.currenttUsersFollowing.contains(user.userId);
            // user.followers
            //     .contains(FirebaseAuth.instance.currentUser!.uid);
          }
        }).toList();
        return ListView.builder(
          itemCount: mutuals.length,
          itemBuilder: (context, index) {
            final user = mutuals[index];

            return GetBuilder<AddUsersController>(
              builder: (_) {
                return CustomListViewTile(
                  onlineStatus: shouldDisplayOnlineStatus(user),
                  height: size.height * 0.10,
                  title: user.username,
                  subtitle: 'Last Seen: ${MyDateUtil.getLastMessageTime(
                    time: user.lastActive,
                    showYear: true,
                  )}',
                  onLongPress: () =>
                      controller.showDiaologForBlockingUser(user),
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
    );
  }
}

enum CurrentUserFriends { mutual, followers, following }
