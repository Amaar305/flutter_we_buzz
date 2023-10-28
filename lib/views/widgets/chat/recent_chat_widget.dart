import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:hi_tweet/model/message_enum_type.dart';
import 'package:hi_tweet/model/message_model.dart';
import 'package:hi_tweet/model/user.dart';
import 'package:hi_tweet/services/current_user.dart';
import 'package:hi_tweet/views/pages/chat/chat_controller.dart';

import '../../utils/method_utils.dart';

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
        stream: ChatController.instance.getLastMessage(weBuzzUser),
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
                FullScreenWidget(
                  disposeLevel: DisposeLevel.High,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.height * .03),
                    child: CachedNetworkImage(
                      width: size.height * .05,
                      height: size.height * .05,
                      fit: BoxFit.fill,
                      imageUrl: weBuzzUser.imageUrl != null
                          ? weBuzzUser.imageUrl!
                          : 'https://firebasestorage.googleapis.com/v0/b/my-hi-tweet.appspot.com/o/933-9332131_profile-picture-default-png.png?alt=media&token=7c98e0e7-c3bf-454e-8e7b-b0ec4b2ec900&_gl=1*1w37gdj*_ga*MTUxNDc4MTA2OC4xNjc1OTQwOTc4*_ga_CW55HF8NVT*MTY5ODMxOTk3Mi42MS4xLjE2OTgzMjAwMzEuMS4wLjA.',
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
              weBuzzUser.name,
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
                        message!.fromId !=
                            CurrentLoggeedInUser.currenLoggedIntUser!.uid
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
        });
  }
}
