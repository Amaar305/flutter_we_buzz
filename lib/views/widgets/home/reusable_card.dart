import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/user.dart';
import 'package:hi_tweet/services/current_user.dart';
import 'package:hi_tweet/views/pages/dashboard/dashboard_controller.dart';
import 'package:hi_tweet/views/pages/home/home_controller.dart';
import 'package:hi_tweet/views/utils/method_utils.dart';

import '../../../model/tweet.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard({
    super.key,
    required this.tweet,
  });
  final TweetBuzz tweet;

  @override
  Widget build(BuildContext context) {
    CampusBuzzUser campusBuzzUser = AppController.instance.weBuzzLists
        .firstWhere((user) => user.userId == tweet.authorId);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (campusBuzzUser.imageUrl == null)
                      const CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage('assets/images/user.png'),
                      )
                    else
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: CachedNetworkImageProvider(
                            campusBuzzUser.imageUrl!),
                      ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      campusBuzzUser.name,
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
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
                      MethodUtils.formatDate(campusBuzzUser.createdAt),
                      style: Theme.of(context).textTheme.bodyMedium,
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
              tweet.content,
              style: Theme.of(context).textTheme.bodyLarge,
              // maxLines: 6,
            ),
            if (tweet.imageUrl != null && tweet.imageUrl!.isNotEmpty)
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  CachedNetworkImage(
                    imageUrl: tweet.imageUrl!,
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment_outlined),
                    SizedBox(
                      width: 5,
                    ),
                    Text('160K'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.favorite),
                    // GetBuilder<HomeController>(builder: (controller) {
                    //   if (tweet.likes != null) {
                    //     return IconButton(
                    //       icon: Icon(
                    //         tweet.likes!.contains(
                    //                 CurrentLoggeedInUser.currentUserId!.uid)
                    //             ? Icons.favorite
                    //             : Icons.favorite_outline,
                    //         color: tweet.likes!.contains(
                    //                 CurrentLoggeedInUser.currentUserId!.uid)
                    //             ? Colors.red
                    //             : null,
                    //       ),
                    //       onPressed: () {},
                    //     );
                    //   } else {
                    //     return const Icon(Icons.favorite);
                    //   }
                    // }),
                    SizedBox(
                      width: 5,
                    ),
                    Text('48.8K'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined),
                    SizedBox(
                      width: 5,
                    ),
                    Text('12M'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.forward_outlined),
                    SizedBox(
                      width: 5,
                    ),
                    Text('160K'),
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
