import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/home/home_controller.dart';
import '../../shimmer/home_page_shimmer.dart';
import 'animated_annoucement.dart';
import 'reusable_card.dart';

class ExploreBuzz extends StatelessWidget {
  const ExploreBuzz({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.weeBuzzItems.isNotEmpty) {
          final publishedBuzzList = controller.weeBuzzItems
              .where((buzz) => buzz.isPublished && !buzz.isCampusBuzz)
              .toList();

          return ListView.builder(
            itemCount: publishedBuzzList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const AnimatedAnnouncementWidget();
              }
              return ReusableCard(
                normalWebuzz: publishedBuzzList[index - 1],
              );
            },
          );
        } else {
          return const HomePageShimmer();
        }
      },
    );
  }
}
