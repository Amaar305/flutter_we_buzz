import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../model/we_buzz_model.dart';
import '../../../../../model/we_buzz_user_model.dart';
import '../../../../pages/view_profile/view_profile_page.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/method_utils.dart';
import 'alert_dialog.dart';

class TopCardHeader extends StatelessWidget {
  const TopCardHeader({
    super.key,
    required this.buzzOwner,
    required this.currentUser,
    required this.normalWebuzz,
    required this.isReply,
    required this.originalId,
  });
  final WeBuzzUser buzzOwner;
  final WeBuzzUser currentUser;
  final WeBuzz normalWebuzz;
  final bool isReply;
  final String originalId;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.83,
              child: Row(
                children: [
                  FullScreenWidget(
                    disposeLevel: DisposeLevel.High,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: CachedNetworkImageProvider(
                        buzzOwner.imageUrl == null
                            ? defaultProfileImage
                            : buzzOwner.imageUrl!,
                      ),
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: () {
                        Get.to(() => ViewProfilePage(weBuzzUser: buzzOwner));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  buzzOwner.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              if (buzzOwner.isVerified) ...[
                                2.width,
                                const Icon(Icons.verified, size: 12)
                              ],
                            ],
                          ),
                          Text(
                            '@${buzzOwner.username}',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.circle,
                    size: 5,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    MethodUtils.formatDate(normalWebuzz.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showBAlertDialog(
                  buzzOwner: buzzOwner,
                  currentUser: currentUser,
                  normalWebuzz: normalWebuzz,
                  isReply: isReply,
                  originalId: originalId,
                );
              },
              icon: const Icon(Icons.more_horiz),
            ),
          ],
        );
      },
    );
  }
}
