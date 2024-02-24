import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/widgets/chat/custom_list_view.dart';

import '../../../../model/chat_model.dart';

import '../../../utils/constants.dart';
import '../../../utils/my_date_utils.dart';
import '../add_users_page/components/user_online_condition.dart';
import 'components/body.dart';
import 'group_chat_info_controller.dart';

class GroupChatInfo extends GetView<GroupChatInfoController> {
  const GroupChatInfo({super.key, required this.groupChat});
  final ChatConversation groupChat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group information'),
        actions: [
          if (groupChat.createdBy == FirebaseAuth.instance.currentUser!.uid)
            IconButton(
              onPressed: () {
                showSheet(context);
              },
              icon: const Icon(
                Icons.person_add_alt,
              ),
            )
        ],
      ),
      body: GroupBody(groupChat: groupChat),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentUserIsInTheGroup = groupChat.members
              .where((user) =>
                  user.userId == FirebaseAuth.instance.currentUser!.uid)
              .isNotEmpty;

          final currentUserIsTheAdmin =
              groupChat.createdBy == FirebaseAuth.instance.currentUser!.uid;

          if (currentUserIsTheAdmin) {
            // If current user is the admin of the group

            controller.showDeleteChatDialog(groupChat.uid);
            // show delete group chat option for the admin to delete the chat
          } else if (currentUserIsInTheGroup && !currentUserIsTheAdmin) {
            // else if currentUser is the member of the group and they are not admin

            controller.showExitingChatDialog(
                groupChat.uid, FirebaseAuth.instance.currentUser!.uid);

            // Show exit group chat option for the user to quit being member in the group
          }
        },
        child: Icon(
          groupChat.createdBy == FirebaseAuth.instance.currentUser!.uid
              ? Icons.delete // delete icon if current user is admin
              : Icons.exit_to_app, // exit icon if the current user isn't admin
          size: 30,
        ),
      ),
    );
  }

  void showSheet(context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                vertical: size.height * .015,
                horizontal: size.width * .4,
              ),
              height: 4,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _buildUsers(),
            _addUserButton(),
          ],
        );
      },
    );
  }

  Widget _addUserButton() => GetBuilder<GroupChatInfoController>(
        builder: (_) {
          return controller.selectedUsers.isNotEmpty
              ? TextButton(
                  onPressed: () => controller.addUserInChat(groupChat.uid),
                  child: const Text('Add'),
                )
              : const SizedBox();
        },
      );

  Expanded _buildUsers() {
    var users = controller.myUsers();
    return Expanded(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          var user = users[index];

          return GetBuilder<GroupChatInfoController>(
            builder: (control) {
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
                isSelected: controller.selectedUsers.contains(user),
                onTap: () {
                  controller.addUserInSelectedUsersList(user);
                },
              );
            },
          );
        },
      ),
    );
  }
}
