import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../utils/constants.dart';

class ActiveUser extends StatelessWidget {
  const ActiveUser({
    super.key,
    required this.weBuzzUser,
  });

  final WeBuzzUser weBuzzUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        // onTap: () => Get.to(() => const ChatPage()),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(
                  weBuzzUser.imageUrl != null
                      ? weBuzzUser.imageUrl!
                      : defaultProfileImage,
                ),
              ),
            ),
            // if (!weBuzzUser.isOnline)
            Positioned(
              top: 50,
              left: 32,
              right: 0,
              child: Icon(
                Icons.circle,
                size: 15,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
