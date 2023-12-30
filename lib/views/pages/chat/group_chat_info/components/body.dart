import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../model/chat_model.dart';
import '../../../view_profile/view_profile_page.dart';
import 'header.dart';
import 'member_widget.dart';
import 'members.dart';

class GroupBody extends StatelessWidget {
  const GroupBody({super.key, required this.groupChat});
  final ChatConversation groupChat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Header(groupChat: groupChat),
        MemberListWidget(
          isAdmin: true,
          member: groupChat.groupOwner,
          height: (MediaQuery.of(context).size.height * 0.10),
          onTap: () =>
              Get.off(() => ViewProfilePage(weBuzzUser: groupChat.groupOwner)),
        ),
        BuildMembers(groupChat: groupChat),
      ],
    );
  }
}
