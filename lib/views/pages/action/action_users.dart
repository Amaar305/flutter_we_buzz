import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../widgets/home/my_buttons.dart';
import '../../widgets/rounded_image_network.dart';
import '../chat/add_users_page/components/user_online_condition.dart';
import '../view_profile/view_profile_page.dart';
import 'action_users_controller.dart';
import 'actions_enum.dart';

class ActionUsersPage extends GetView<ActionUsersController> {
  ActionUsersPage(
      {super.key,
      required this.type,
      required this.buzzID,
      this.actionCount = 0}) {
    controller.fetchUsersId(buzzID, type);
  }

  final ActionUsersPageType type;
  final String buzzID;
  final int actionCount;
  @override
  Widget build(BuildContext context) {
    String title() {
      switch (type) {
        case ActionUsersPageType.likes:
          return 'Likes';

        case ActionUsersPageType.views:
          return 'Viewers';

        case ActionUsersPageType.saves:
          return 'Saved';

        default:
          return '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title()),
      ),
      body: Padding(
        padding: kPadding,
        child: GetBuilder<ActionUsersController>(
          builder: (_) {
            if (actionCount == 0) return Text('0 ${title()}').center();
            if (controller.ids.isEmpty) {
              return const CircularProgressIndicator(strokeWidth: 0.5).center();
            }

            if (FirebaseAuth.instance.currentUser == null) {
              return const SizedBox();
            }
            return FirestoreListView(
              query: FirebaseService.queryUsers(controller.ids),
              itemBuilder: (context, doc) {
                final user = doc.data();

                if (user.userId == FirebaseAuth.instance.currentUser!.uid) {
                  return const SizedBox();
                } else {
                  return ActionUserTile(
                    member: user,
                    height: MediaQuery.sizeOf(context).height * 0.10,
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class ActionUserTile extends StatelessWidget {
  const ActionUserTile({
    super.key,
    this.onTap,
    required this.member,
    required this.height,
  });

  final void Function()? onTap;
  final WeBuzzUser member;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        onlineStatus: shouldDisplayOnlineStatus(member),
        key: UniqueKey(),
        size: height / 2,
        imageUrl:
            member.imageUrl != null ? member.imageUrl! : defaultProfileImage,
        isOnline: member.isOnline,
      ),
      title: Text(member.name),
      subtitle: Text(member.username),
      trailing: Obx(
        () => followButton(
          ActionUsersController.instance.currenttUsersFollowing
              .contains(member.userId),
          member,
        ),
      ),
      onTap: () {
        Get.to(() => ViewProfilePage(weBuzzUser: member));
      },
    );
  }
}
