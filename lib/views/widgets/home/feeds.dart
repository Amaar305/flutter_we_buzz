import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import 'package:hi_tweet/views/widgets/home/cards/reusable_card.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../pages/dashboard/my_app_controller.dart';
import '../../pages/home/home_controller.dart';
import 'cards/sponsor_card_widget.dart';

class Feeds extends StatelessWidget {
  const Feeds({super.key, required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Text('No Feeds For You!').center();
    }

    final currentUser = AppController.instance.weBuzzUsers.firstWhere(
        (user) => user.userId == FirebaseAuth.instance.currentUser!.uid);

    final following = controller.currenttUsersFollowing;

    if (following.isEmpty) {
      return const Text('Have not follow any user yet!').center();
    }

    return FirestoreListView(
      controller: controller.feedScrollController,
      query: controller.queryBuzz,
      itemBuilder: (context, doc) {
        final buzz = doc.data();
        if (!following.contains(buzz.authorId)) return const SizedBox();
        if (buzz.authorId == currentUser.userId) return const SizedBox();
        if (buzz.validSponsor()) {
          return SponsorCard(
            normalWebuzz: buzz,
          );
        }

        if (!buzz.isSponsor) {
          if (currentUser.blockedUsers.contains(buzz.authorId)) {
            return const SizedBox();
          } else {
            return ReusableCard(
              normalWebuzz: buzz,
            );
          }
        }

        return const SizedBox();
      },
    );
    // return Obx(
    //   () {
    //     List<WeBuzz> posts = [];
    // if (FirebaseAuth.instance.currentUser != null) {
    //   final currentUser = AppController.instance.weBuzzUsers.firstWhere(
    //       (user) => user.userId == FirebaseAuth.instance.currentUser!.uid);

    //       final following = AppController.instance.currenttUsersFollowing;

    //       var splittedUsersFollowing = partition(following, 10);

    // for (var i = 0; i < splittedUsersFollowing.length; i++) {
    //   for (var uid in splittedUsersFollowing.elementAt(i)) {
    //     posts.addAll(
    //       controller.weeBuzzItems
    //           .where((p0) => p0.authorId == uid)
    //           .toList(),
    //     );
    //   }
    // }

    //       posts.sort((a, b) {
    //         return b.createdAt.compareTo(a.createdAt);
    //       });

    //       return ListView.builder(
    //         controller: controller.feedScrollController,
    //         itemCount: posts.length,
    //         itemBuilder: (context, index) {
    // if (posts[index].validSponsor()) {
    //   return SponsorCard(
    //     normalWebuzz: posts[index],
    //   );
    // }

    // if (!posts[index].isSponsor) {
    //   if (currentUser.blockedUsers.contains(posts[index].authorId)) {
    //     return const SizedBox();
    //   } else {
    //     return ReusableCard(
    //       normalWebuzz: posts[index],
    //     );
    //   }
    // }
    //           return null;
    //         },
    //       );
    //     } else {
    //       return const Center(
    //         child: Text('User is not logged'),
    //       );
    //     }
    //   },
    // );
  }
}
