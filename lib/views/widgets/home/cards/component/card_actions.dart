import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../model/we_buzz_model.dart';
import '../../../../../model/we_buzz_user_model.dart';
import '../../../../../services/firebase_service.dart';
import '../../../../pages/action/action_users.dart';
import '../../../../pages/action/actions_enum.dart';
import '../../../../pages/home/home_controller.dart';
import '../../../../pages/home/reply/reply_page.dart';
import '../../../../utils/method_utils.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.currentUser,
    required this.normalWebuzz,
  });
  final WeBuzzUser currentUser;
  final WeBuzz normalWebuzz;

  @override
  Widget build(BuildContext context) {
    HomeController().updateBuzzViews(normalWebuzz);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Reply action button
        Row(
          children: [
            IconButton(
              onPressed: () {
                Get.toNamed(RepliesPage.routeName, arguments: normalWebuzz);
              },
              icon: const Icon(FluentSystemIcons.ic_fluent_comment_add_regular),
            ),
            Text(MethodUtils.formatNumber(normalWebuzz.repliesCount)),
          ],
        ),

        //  Likes action button
        StreamBuilder<bool>(
          stream: FirebaseService.getCurrentUserLikes(normalWebuzz),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Show this is snapshot has no data
              return Row(
                children: [
                  const Icon(Icons.favorite_outline),
                  GestureDetector(
                    onTap: () => Get.to(() => ActionUsersPage(
                          buzzID: normalWebuzz.docId,
                          type: ActionUsersPageType.likes,
                          actionCount: normalWebuzz.likesCount,
                        )),
                    child:
                        Text(MethodUtils.formatNumber(normalWebuzz.likesCount)),
                  ),
                ],
              );
            }
            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    FirebaseService.likePost(
                      normalWebuzz,
                      snapshot.data ?? false,
                    );
                  },
                  child: Icon(
                    snapshot.data! ? Icons.favorite : Icons.favorite_outline,
                    color: snapshot.data! ? Colors.red : null,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => Get.to(() => ActionUsersPage(
                        buzzID: normalWebuzz.docId,
                        type: ActionUsersPageType.likes,
                        actionCount: normalWebuzz.likesCount,
                      )),
                  child:
                      Text(MethodUtils.formatNumber(normalWebuzz.likesCount)),
                ),
              ],
            );
          },
        ),

        // Views action button
        Row(
          children: [
            const Icon(Icons.remove_red_eye_outlined),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => Get.to(() => ActionUsersPage(
                    buzzID: normalWebuzz.docId,
                    type: ActionUsersPageType.views,
                    actionCount: normalWebuzz.viewsCount,
                  )),
              child: Text(MethodUtils.formatNumber(normalWebuzz.viewsCount)),
            ),
          ],
        ),

        // Save action button
        StreamBuilder<bool>(
          stream: FirebaseService.getCurrentUserSaved(normalWebuzz),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Show this when snapshot is null
              return Row(
                children: [
                  const Icon(Icons.favorite_outline),
                  GestureDetector(
                    onTap: () => Get.to(() => ActionUsersPage(
                          buzzID: normalWebuzz.docId,
                          type: ActionUsersPageType.saves,
                          actionCount: normalWebuzz.savedCount,
                        )),
                    child: Text(
                      MethodUtils.formatNumber(normalWebuzz.savedCount),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    FirebaseService.savePost(
                      normalWebuzz,
                      snapshot.data ?? false,
                    );
                  },
                  child: Icon(
                    snapshot.data ?? false
                        ? FluentSystemIcons.ic_fluent_bookmark_filled
                        : FluentSystemIcons.ic_fluent_bookmark_regular,
                    color: snapshot.data ?? false
                        ? Theme.of(Get.context!).colorScheme.primary
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => ActionUsersPage(
                          buzzID: normalWebuzz.docId,
                          type: ActionUsersPageType.saves,
                          actionCount: normalWebuzz.savedCount,
                        ));
                  },
                  child: Text(
                    MethodUtils.formatNumber(normalWebuzz.savedCount),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
