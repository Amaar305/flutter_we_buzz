import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiver/iterables.dart';

import '../../../model/we_buzz_model.dart';
import '../../pages/dashboard/my_app_controller.dart';
import '../../pages/home/home_controller.dart';
import 'reusable_card.dart';

class Feeds extends StatelessWidget {
  const Feeds({super.key, required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        List<WeBuzz> posts = [];
        if (FirebaseAuth.instance.currentUser != null) {
          final currentUser = AppController.instance.weBuzzUsers.firstWhere(
              (user) => user.userId == FirebaseAuth.instance.currentUser!.uid);

          final following = currentUser.following;

          var splittedUsersFollowing = partition(following, 10);
          for (var i = 0; i < splittedUsersFollowing.length; i++) {
            for (var uid in splittedUsersFollowing.elementAt(i)) {
              posts.addAll(
                controller.weeBuzzItems
                    .where((p0) => p0.authorId == uid)
                    .toList(),
              );
            }
          }

          posts.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return ReusableCard(
                normalWebuzz: posts[index],
              );
            },
          );
        } else {
          return const Center(
            child: Text('User is not logged'),
          );
        }
      },
    );
  }
}
