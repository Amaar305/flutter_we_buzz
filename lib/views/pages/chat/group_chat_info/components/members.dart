import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../model/chat_model.dart';
import '../../../../../model/we_buzz_user_model.dart';
import '../../../view_profile/view_profile_page.dart';
import '../group_chat_info_controller.dart';
import 'member_widget.dart';

class BuildMembers extends StatelessWidget {
  const BuildMembers({super.key, required this.groupChat});
  final ChatConversation groupChat;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: GroupChatInfoController.instance.streamChat(groupChat.uid),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case ConnectionState.done:
            case ConnectionState.active:
              if (snapshot.data != null) {
                List<WeBuzzUser> members = snapshot.data!
                    .where((user) => user.userId != groupChat.groupOwner.userId)
                    .toList();

                GroupChatInfoController.instance
                    .updateCurrentGroupMembers(members);

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];

                    return MemberListWidget(
                      isAdmin: false,
                      canShowDeleteAction: groupChat.createdBy ==
                          FirebaseAuth.instance.currentUser!.uid,
                      member: member,
                      height: (MediaQuery.of(context).size.height * 0.10),
                      onTap: () {
                        Get.off(() => ViewProfilePage(weBuzzUser: member));
                      },
                      onPressed: () {
                        if (member.userId !=
                            FirebaseAuth.instance.currentUser!.uid) {
                          if (members.length <= 1) {
                            _showAlert();
                          } else {
                            GroupChatInfoController.instance
                                .removeUserInChat(groupChat.uid, member.userId);
                          }
                        } else {
                          toast('You cannot remove yourself!');
                        }
                      },
                    );
                  },
                );
              } else {
                return const SizedBox();
              }
          }
        },
      ),
    );
  }

  void _showAlert() {
    Get.dialog(
      AlertDialog(
        title: const Text('Warning'),
        content: const Text(
          'You can either delete the group or leave this user, because group members cannot be only one person.',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Okay',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
