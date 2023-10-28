import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';

import '../../../model/user.dart';
import '../../../model/webuzz_model.dart';
import '../../../services/current_user.dart';
import '../../pages/dashboard/dashboard_controller.dart';
import '../../pages/home/home_controller.dart';
import '../../utils/method_utils.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard({
    super.key,
    required this.tweet,
  });
  final WeBuzz tweet;

  @override
  Widget build(BuildContext context) {
    WeBuzzUser campusBuzzUser = AppController.instance.weBuzzLists
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  if (campusBuzzUser.imageUrl == null)
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
                        backgroundImage: CachedNetworkImageProvider(
                            campusBuzzUser.imageUrl!),
                      ),
                    ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    campusBuzzUser.name,
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
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
                    MethodUtils.formatDate(tweet.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
              const Icon(Icons.more_horiz),
            ]),
            const SizedBox(
              height: 10,
            ),
            Text(
              tweet.content,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.start,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Row(
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
                    GetBuilder<HomeController>(builder: (cont) {
                      if (CurrentLoggeedInUser.currenLoggedIntUser != null) {
                        final loggedInUserId =
                            CurrentLoggeedInUser.currenLoggedIntUser!.uid;
                        return GestureDetector(
                          onTap: () {
                            cont.updateViews(tweet, 'likes');
                          },
                          child: Icon(
                            tweet.likes.contains(loggedInUserId)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: tweet.likes.contains(loggedInUserId)
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
                    Text(MethodUtils.formatNumber(tweet.likes.length)),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined),
                    SizedBox(
                      width: 5,
                    ),
                    Text('12M'),
                  ],
                ),
                if (tweet.buzzType == 'original')
                  GetBuilder<HomeController>(builder: (control) {
                    return Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              control.reTweetBuzz(tweet);
                            },
                            icon: const Icon(Icons.refresh)),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(MethodUtils.formatNumber(tweet.reBuzzCount)),
                      ],
                    );
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
