import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../model/we_buzz_user_model.dart';
import '../../../pages/chat/add_users_page/components/user_online_condition.dart';
import '../../../pages/chat/messages/messages_controller.dart';
import '../../../pages/view_profile/view_profile_page.dart';
import '../../../utils/constants.dart';
import '../../../utils/my_date_utils.dart';

class PrivateChatAppBar extends StatelessWidget {
  const PrivateChatAppBar({
    super.key,
    required this.controller,
  });

  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => Get.to(
        () => ViewProfilePage(
          weBuzzUser: controller.otherChatUser,
        ),
        transition: Transition.rightToLeftWithFade,
        curve: Curves.easeIn,
      ),
      child: StreamBuilder<WeBuzzUser>(
        stream: controller.getUserInfo(controller.otherChatUser),
        builder: (context, snapshot) {
          final data = snapshot.data;
          return Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(size.height * .03),
                child: CachedNetworkImage(
                  width: size.height * .05,
                  height: size.height * .05,
                  fit: BoxFit.fill,
                  imageUrl: data != null // if stream data is not null
                      ? data.imageUrl !=
                              null // if stream data image is not null
                          ? data
                              .imageUrl! // then display the streaming user data image
                          : defaultProfileImage // else display the default image

                      : controller.otherChatUser.imageUrl !=
                              null // else stream data is null, check if otherChatUser's image is not null
                          ? controller.otherChatUser
                              .imageUrl! // then display the otherChatUser   image
                          : defaultProfileImage, // else display the default image
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data != null // if stream data is not null
                        ? data.name // then display stream data' name
                        : controller.otherChatUser
                            .name, // else display otherChatUser's name
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      // color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data != null // if stream data is not null
                        ? shouldDisplayOnlineStatus(
                                data) // if the user allow online status
                            ? data.isOnline // if user is online
                                ? 'Online' // then display Online
                                : MyDateUtil.getLastMessageTime(
                                    // else display user's last seen
                                    time: data.lastActive,
                                    showYear: true,
                                  )
                            : '' // else user doesn't allow online indicatoor, then show empty '
                        : MyDateUtil.getLastMessageTime(
                            // else stream data is null, then duaplay user last seen
                            time: controller.otherChatUser.lastActive,
                            showYear: true,
                          ),
                    style: const TextStyle(fontSize: 13),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
