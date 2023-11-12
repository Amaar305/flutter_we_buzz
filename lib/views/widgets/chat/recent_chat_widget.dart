import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/message_enum_type.dart';
import 'package:hi_tweet/model/message_model.dart';
import 'package:hi_tweet/model/we_buzz_user_model.dart';
import 'package:hi_tweet/views/utils/constants.dart';

import '../../pages/chat/chat_controller_old.dart';
import '../../utils/method_utils.dart';
import 'profile_dialog.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({
    super.key,
    required this.weBuzzUser,
    this.onTap,
  });
  final void Function()? onTap;
  final WeBuzzUser weBuzzUser;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    Message? message;
    return StreamBuilder(
      stream: ChatControllerOld.instance.getLastMessage(weBuzzUser),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          message = snapshot.data;
          // log(snapshot.data!.message);
        }

        return ListTile(
          onTap: onTap,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(size.height * .03),
                onTap: () {
                  Get.dialog(
                    Center(
                      child: ProfileDialog(weBuzzUser: weBuzzUser),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size.height * .03),
                  child: CachedNetworkImage(
                    width: size.height * .05,
                    height: size.height * .05,
                    fit: BoxFit.fill,
                    imageUrl: weBuzzUser.imageUrl != null
                        ? weBuzzUser.imageUrl!
                        : defaultProfileImage,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
              ),
              if (weBuzzUser.isOnline)
                Positioned(
                  top: size.height * .035,
                  left: size.width * .08,
                  // right: 0,
                  child: Icon(
                    Icons.circle,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
          title: Text(
            weBuzzUser.username,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Text(
            message != null
                ? message!.type == MessageType.image
                    ? 'Image'
                    : message!.message
                : weBuzzUser.bio,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: message == null
              ? null
              : message!.read.isEmpty &&
                      message!.fromId != FirebaseAuth.instance.currentUser!.uid
                  ? Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                  : Text(
                      MethodUtils.getLastMessageTime(time: message!.sent),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
          horizontalTitleGap: 10,
        );
      },
    );
  }
}
