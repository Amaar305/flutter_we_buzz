import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../../model/we_buzz_model.dart';
import '../../pages/dashboard/my_app_controller.dart';
import '../../pages/home/home_controller.dart';
import '../../pages/home/reply/reply_page.dart';
import '../../utils/method_utils.dart';

class ReusableCard extends StatefulWidget {
  const ReusableCard({
    super.key,
    required this.normalWebuzz,
  });
  final WeBuzz normalWebuzz;

  @override
  State<ReusableCard> createState() => _ReusableCardState();
}

class _ReusableCardState extends State<ReusableCard> {
  @override
  Widget build(BuildContext context) {
    WeBuzzUser campusBuzzUser = AppController.instance.weBuzzUsers
        .firstWhere((user) => user.userId == widget.normalWebuzz.authorId);

    if (widget.normalWebuzz.isRebuzz) {
      return FutureBuilder(
        future:
            HomeController.instance.getPostById(widget.normalWebuzz.originalId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const SizedBox();

            case ConnectionState.done:
            case ConnectionState.active:
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
          }
          return mainPost(campusBuzzUser, true, snapshot.data!);
        },
      );
    }
    return mainPost(campusBuzzUser, false, widget.normalWebuzz);
  }

  Widget mainPost(WeBuzzUser weBuzzUser, bool rebuzz, WeBuzz weBuzzSnapshot) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rebuzz || weBuzzSnapshot.isRebuzz) const Text('ReBuzz'),
            if (rebuzz || weBuzzSnapshot.isRebuzz) const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Post owner info
                Row(
                  children: [
                    if (weBuzzUser.imageUrl == null)
                      FullScreenWidget(
                        disposeLevel: DisposeLevel.High,
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/images/user.png'),
                        ),
                      )
                    else
                      FullScreenWidget(
                        disposeLevel: DisposeLevel.High,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundImage:
                              CachedNetworkImageProvider(weBuzzUser.imageUrl!),
                        ),
                      ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      weBuzzUser.name,
                      style: Theme.of(Get.context!)
                          .textTheme
                          .displayMedium!
                          .copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
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
                      MethodUtils.formatDate(weBuzzSnapshot.createdAt),
                      style: Theme.of(Get.context!).textTheme.bodyMedium,
                    )
                  ],
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              weBuzzSnapshot.content,
              style: Theme.of(Get.context!).textTheme.bodyLarge,
              textAlign: TextAlign.start,
              // maxLines: 6,
            ),

            // Post image
            if (weBuzzSnapshot.imageUrl != null &&
                weBuzzSnapshot.imageUrl!.isNotEmpty)
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  CachedNetworkImage(
                    imageUrl: weBuzzSnapshot.imageUrl!,
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                    placeholder: (context, url) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
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
                            fit: BoxFit.cover,
                            width: double.maxFinite,
                            height: 300,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Reply button
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.toNamed(RepliesPage.routeName,
                            arguments: widget.normalWebuzz);
                      },
                      icon: const Icon(Icons.reply_all),
                    ),
                    const Text('160K'),
                  ],
                ),
                Row(
                  children: [
                    // Like button
                    StreamBuilder<bool>(
                      stream: HomeController.instance
                          .getCurrentUserLikes(weBuzzSnapshot),
                      builder: (context, snap) {
                        switch (snap.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();

                          case ConnectionState.done:
                          case ConnectionState.active:
                            if (FirebaseAuth.instance.currentUser != null &&
                                snap.data != null) {
                              return IconButton(
                                onPressed: () {
                                  HomeController.instance
                                      .likePost(weBuzzSnapshot, snap.data!);
                                },
                                icon: Icon(
                                  snap.data!
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color: snap.data! ? Colors.red : null,
                                ),
                              );
                            } else {
                              return const Icon(Icons.favorite);
                            }
                        }
                      },
                    ),
                    Text(MethodUtils.formatNumber(weBuzzSnapshot.likesCount)),
                  ],
                ),
                // Views button
                const Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined),
                    SizedBox(
                      width: 5,
                    ),
                    Text('12M'),
                  ],
                ),

                // Retweet buzz button
                // if (weBuzz.buzzType == BuzzType.origianl.name)
                Row(
                  children: [
                    StreamBuilder<bool>(
                        stream: HomeController.instance
                            .getCurrentUserReBuzz(weBuzzSnapshot),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const SizedBox();

                            case ConnectionState.done:
                            case ConnectionState.active:
                              if (snapshot.hasData || snapshot.data != null) {
                                return IconButton(
                                  onPressed: () {
                                    // control.reTweetBuzz(webuzz);
                                    HomeController.instance.reTweetBuzz(
                                        weBuzzSnapshot, snapshot.data!);
                                  },
                                  icon: Icon(
                                    snapshot.data! &&
                                            widget.normalWebuzz.isRebuzz
                                        ? Icons.repeat_one_outlined
                                        : Icons.repeat,
                                  ),
                                );
                              } else {
                                return const Icon(Icons.repeat);
                              }
                          }
                        }),
                    Text(MethodUtils.formatNumber(
                        widget.normalWebuzz.reBuzzsCount)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
