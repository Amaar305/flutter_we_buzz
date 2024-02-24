import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../pages/home/home_controller.dart';
import '../../utils/constants.dart';
import 'animated_annoucement.dart';

class CustomCarouselAnnouncementBuilderWidget extends StatelessWidget {
  const CustomCarouselAnnouncementBuilderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        final announces =
            controller.annouce.where((a) => a.shouldDisplay()).toList();
        if (announces.isEmpty) return const SizedBox();
        return CarouselSlider.builder(
          itemCount: announces.length,
          itemBuilder: (context, index, realIndex) {
            if (announces[index].image != null) {
              return BannerAnnouncementWidget(
                announcement: announces[index],
              );
            }
            return AnimatedAnnouncementWidget(
              announcement: announces[index],
            );
          },
          options: CarouselOptions(
            height: MediaQuery.sizeOf(context).height * 0.22,
            autoPlay: true,
            reverse: true,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            autoPlayInterval: const Duration(seconds: 6),
            onPageChanged: (index, reason) =>
                controller.updateActiveIndex(index),
          ),
        );
      },
    );
  }
}

Widget buildIndicator() => GetBuilder<HomeController>(
      builder: (controller) {
        return AnimatedSmoothIndicator(
          activeIndex: controller.activeIndex,
          count: controller.annouce.where((a) => a.shouldDisplay()).length,
          effect: const JumpingDotEffect(
            dotWidth: 10,
            dotHeight: 10,
            activeDotColor: kPrimary,
            dotColor: kDefaultGrey,
          ),
        );
      },
    );
