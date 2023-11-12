import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../../model/we_buzz_model.dart';
import '../../pages/create/edit/edit_post_page.dart';
import '../../pages/dashboard/my_app_controller.dart';
import '../../pages/home/filters/hashtag_filter_page.dart';
import '../../pages/home/home_controller.dart';
import '../../pages/home/reply/reply_page.dart';
import '../../pages/view_profile/view_profile_page.dart';
import '../../utils/constants.dart';
import '../../utils/method_utils.dart';
import '../bottom_sheet_option.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard({
    super.key,
    required this.normalWebuzz,
    this.snapShotWebuzz,
  });
  final WeBuzz normalWebuzz;
  final WeBuzz? snapShotWebuzz;
  @override
  Widget build(BuildContext context) {
    WeBuzzUser buzzOwner = AppController.instance.weBuzzUsers.firstWhere(
      (user) => user.userId == normalWebuzz.authorId,
    );
    WeBuzzUser currentUser = AppController.instance.weBuzzUsers.firstWhere(
      (user) => user.userId == FirebaseAuth.instance.currentUser!.uid,
    );
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(
        // horizontal: 15,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (normalWebuzz.isRebuzz) const Text('Rebuzzed'),
            if (normalWebuzz.isRebuzz) const SizedBox(height: 10),
            _topCardHeaderInfo(buzzOwner, currentUser),
            const SizedBox(
              height: 10,
            ),
            stylizePostContent(normalWebuzz.content),
            if (normalWebuzz.imageUrl != null &&
                normalWebuzz.imageUrl!.isNotEmpty)
              _postImage(),
            const SizedBox(
              height: 10,
            ),
            // for hiding action buttons in the reply section
            if (snapShotWebuzz == null) _actionButtons(currentUser),
          ],
        ),
      ),
    );
  }

  Widget _postImage() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        CachedNetworkImage(
          imageUrl: normalWebuzz.imageUrl!,
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.image_not_supported),
          ),
          placeholder: (context, url) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            );
          },
          imageBuilder: (context, imageProvider) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: FullScreenWidget(
                disposeLevel: DisposeLevel.High,
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.fitWidth,
                  width: double.maxFinite,
                  height: 300,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _topCardHeaderInfo(WeBuzzUser buzzOwner, WeBuzzUser currentUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (buzzOwner.imageUrl == null)
              FullScreenWidget(
                disposeLevel: DisposeLevel.High,
                child: const CircleAvatar(
                  radius: 15,
                  backgroundImage:
                      CachedNetworkImageProvider(defaultProfileImage),
                ),
              )
            else
              FullScreenWidget(
                disposeLevel: DisposeLevel.High,
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage:
                      CachedNetworkImageProvider(buzzOwner.imageUrl!),
                ),
              ),
            const SizedBox(
              width: 5,
            ),
            TextButton(
              onPressed: () {
                Get.to(
                  () => ViewProfilePage(weBuzzUser: buzzOwner),
                );
              },
              child: Text(
                buzzOwner.name,
                style: Theme.of(Get.context!).textTheme.displayMedium!.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(
              width: 5,
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
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            )
          ],
        ),
        IconButton(
          onPressed: () {
            _showBottomSheet(buzzOwner, currentUser);
          },
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }

  Widget _actionButtons(WeBuzzUser currentUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        Row(
          children: [
            IconButton(
              onPressed: () {
                HomeController.instance.saveBuzz(normalWebuzz.docId);
              },
              icon: Icon(
                currentUser.savedBuzz.contains(normalWebuzz.docId)
                    ? FluentSystemIcons.ic_fluent_bookmark_filled
                    : FluentSystemIcons.ic_fluent_bookmark_regular,
                color: currentUser.savedBuzz.contains(normalWebuzz.docId)
                    ? Theme.of(Get.context!).colorScheme.primary
                    : null,
              ),
            ),
            Text(MethodUtils.formatNumber(normalWebuzz.savedCount)),
          ],
        ),
        Row(
          children: [
            GetBuilder<HomeController>(builder: (cont) {
              if (FirebaseAuth.instance.currentUser != null) {
                final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
                return GestureDetector(
                  onTap: () {
                    cont.updateViews(normalWebuzz, 'likes');
                  },
                  child: Icon(
                    normalWebuzz.likes.contains(loggedInUserId)
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: normalWebuzz.likes.contains(loggedInUserId)
                        ? Colors.red
                        : null,
                  ),
                );
              } else {
                return const Icon(Icons.favorite);
              }
            }),
            const SizedBox(
              width: 5,
            ),
            Text(MethodUtils.formatNumber(normalWebuzz.likes.length)),
          ],
        ),
        // const Row(
        //   children: [
        //     Icon(Icons.remove_red_eye_outlined),
        //     SizedBox(
        //       width: 5,
        //     ),
        //     Text('12M'),
        //   ],
        // ),
        // GetBuilder<HomeController>(
        //   builder: (control) {
        //     return Row(
        //       children: [
        //         IconButton(
        //           onPressed: () {
        //             final bool current = normalWebuzz.rebuzzs
        //                 .contains(FirebaseAuth.instance.currentUser!.uid);
        //             control.reTweetBuzz(normalWebuzz, current);
        //           },
        //           icon: Icon(
        //             normalWebuzz.rebuzzs
        //                     .contains(FirebaseAuth.instance.currentUser!.uid)
        //                 ? Icons.repeat_one
        //                 : Icons.repeat,
        //           ),
        //         ),
        //         const SizedBox(
        //           width: 5,
        //         ),
        //         Text(MethodUtils.formatNumber(normalWebuzz.reBuzzsCount)),
        //       ],
        //     );
        //   },
        // ),
      ],
    );
  }

  void _showBottomSheet(WeBuzzUser buzzOwner, WeBuzzUser currentUser) {
    Get.dialog(
      WillPopScope(
        child: AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Text(
                'Actions',
                style: TextStyle(fontSize: 25),
              ),
            ],
          ),
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (normalWebuzz.authorId ==
                    FirebaseAuth.instance.currentUser!.uid)
                  OptionItem(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(Get.context!).colorScheme.primary,
                    ),
                    name: 'Edit Buzz',
                    onTap: () {
                      Get.to(() => EditPostPage(normalWebuzz));
                    },
                  ),
                if (normalWebuzz.authorId ==
                    FirebaseAuth.instance.currentUser!.uid)
                  OptionItem(
                    icon: Icon(
                      Icons.delete_forever,
                      color: Theme.of(Get.context!).colorScheme.primary,
                    ),
                    name: 'Delete Buzz',
                    onTap: () {
                      Get.back();
                      _showBottomSheetForDeletion(buzzOwner);
                    },
                  ),
                if (normalWebuzz.authorId !=
                    FirebaseAuth.instance.currentUser!.uid)
                  if (shouldDisplayDMButton(buzzOwner))
                    OptionItem(
                      icon: Icon(
                        Icons.chat_bubble,
                        color: Theme.of(Get.context!).colorScheme.primary,
                      ),
                      name: 'DM',
                      onTap: () {
                        HomeController.instance
                            .dmTheAuthor(normalWebuzz.authorId);
                      },
                    ),
                OptionItem(
                  icon: const Icon(
                    Icons.report,
                    color: Colors.red,
                  ),
                  name: 'Report Buzz',
                  onTap: () {
                    Get.back();

                    _showBottomSheetForReporting();
                  },
                ),
              ],
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Cancle',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(Get.context!).colorScheme.primary),
              ),
            ),
          ],
        ),
        onWillPop: () => Future.value(false),
      ),
    );
  }

  void _showBottomSheetForDeletion(
    WeBuzzUser buzzOwner,
  ) {
    Get.dialog(
      AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text(
              'Warning',
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
        content: const SizedBox(
          child: Text(
            'If you delete the buzz you might not get it back. But you can publish/unpublish it.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Get.back();
              HomeController.instance.deleteBuzz(normalWebuzz);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(Get.context!).colorScheme.primary),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Get.back();
              HomeController.instance.publisheAndUnpublisheBuzz(
                  isPublishe: false, weBuzz: normalWebuzz);
            },
            child: Text(
              normalWebuzz.isPublished ? 'Unpublish' : 'Publish',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(Get.context!).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheetForReporting() {
    String? reasons;
    Get.dialog(
      AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text(
              'Report Buzz',
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
        content: SizedBox(
          child: DropdownButtonFormField<String>(
            items: HomeController.instance.reportReasons.map((reason) {
              return DropdownMenuItem<String>(
                value: reason,
                child: Text(reason),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: 'Tap to choose',
            ),
            onChanged: (value) {
              reasons = value!;
            },
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'Cancle',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(Get.context!).colorScheme.primary),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Get.back();
              print(reasons);
              if (reasons != null && reasons!.isNotEmpty) {
                HomeController.instance
                    .reportBuzz(normalWebuzz.docId, reasons!);
              }
            },
            child: Text(
              'Report',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget stylizePostContent(String content) {
  final hashtagRegex = RegExp(r'#\w+');
  final matches = hashtagRegex.allMatches(content);

  final textSpans = <TextSpan>[];
  int currentStart = 0;

  for (final match in matches) {
    // Add the text before the hashtag
    if (match.start > currentStart) {
      textSpans
          .add(TextSpan(text: content.substring(currentStart, match.start)));
    }

    // Stylize the hashtag
    textSpans.add(
      TextSpan(
        text: match.group(0),
        style: TextStyle(
          color: Theme.of(Get.context!)
              .colorScheme
              .primary, // Change to your desired color
          fontWeight: FontWeight.bold,
          // Add other styling as needed
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Get.to(() => HashTagFilterPage(hashtag: match.group(0)!));
            // Handle hashtag click event
            // You can navigate to a hashtag-specific page or perform any other action
          },
      ),
    );

    currentStart = match.end;
  }

  // Add the remaining text after the last hashtag
  if (currentStart < content.length) {
    textSpans.add(TextSpan(text: content.substring(currentStart)));
  }

  return RichText(
    text: TextSpan(
      children: textSpans,
      style: Theme.of(Get.context!).textTheme.bodyLarge,
    ),
  );
}

bool shouldDisplayDMButton(WeBuzzUser targetUser) {
  var dmPrivacy = targetUser.directMessagePrivacy;

  final currentUserID = FirebaseAuth.instance.currentUser!.uid;

  // Display the DM button based on DM privacy settings
  if (dmPrivacy == DirectMessagePrivacy.everyone) {
    return true;
  } else if (dmPrivacy == DirectMessagePrivacy.followers &&
      targetUser.followers.contains(currentUserID)) {
    return true;
  } else if (dmPrivacy == DirectMessagePrivacy.following &&
      targetUser.following.contains(currentUserID)) {
    return true;
  } else if (dmPrivacy == DirectMessagePrivacy.mutual &&
      targetUser.followers.contains(currentUserID) &&
      targetUser.following.contains(currentUserID)) {
    return true;
  }

  return false;
}
