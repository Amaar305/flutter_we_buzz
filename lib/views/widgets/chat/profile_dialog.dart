import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../pages/view_profile/view_profile_page.dart';
import '../../utils/constants.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.weBuzzUser});
  final WeBuzzUser weBuzzUser;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .6,
        height: MediaQuery.of(context).size.height * .35,
        child: Stack(
          children: [
            // profile picture
            Positioned(
              top: MediaQuery.of(context).size.height * .075,
              left: MediaQuery.of(context).size.width * .1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.height * .25,
                ),
                child: CachedNetworkImage(
                  imageUrl: weBuzzUser.imageUrl != null
                      ? weBuzzUser.imageUrl!
                      : defaultProfileImage,
                  width: MediaQuery.of(context).size.width * .5,
                  height: MediaQuery.of(context).size.height * .25,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),

            // user name
            Positioned(
              top: MediaQuery.of(context).size.height * .02,
              left: MediaQuery.of(context).size.width * .04,
              width: MediaQuery.of(context).size.width * .55,
              child: Text(
                weBuzzUser.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            // info button
            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: () {
                  Get.back();
                  Get.to(
                    () => ViewProfilePage(weBuzzUser: weBuzzUser),
                  );
                },
                minWidth: 0,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(0),
                child: Icon(
                  Icons.info_outline,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
