import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/shimmer/home_page_shimmer.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/home/my_search_bar.dart';
import '../../widgets/home/reusable_card.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});
  static const routeName = '/home-page';

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return _builtUI(deviceWidth, deviceHeight);
  }

  Widget _builtUI(double deviceWidth, double deviceHeight) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: deviceWidth * 0.03,
        vertical: deviceHeight * 0.02,
      ),
      width: deviceWidth * 0.97,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _appBar(),
          _webuzzList(),
        ],
      ),
    );
  }

  Widget _appBar() {
    return GetBuilder<HomeController>(
      builder: (_) {
        return AnimatedCrossFade(
          duration: const Duration(milliseconds: 150),
          crossFadeState: controller.isSearched.isTrue
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: CustomAppBar(
            'WeBuzz',
            primaryAction: IconButton(
              onPressed: () {
                controller.search();
              },
              icon: Icon(
                controller.isSearched.isFalse ? Icons.search : Icons.cancel,
              ),
            ),
          ),
          secondChild: AppbarSearchField(controller: controller),
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeIn,
        );
      },
    );
  }

  Widget _webuzzList() {
    return Expanded(
      child: Obx(
        () {
          if (controller.weeBuzzItems.isNotEmpty) {
            return ListView.builder(
              controller: controller.scrollController,
              itemCount: controller.weeBuzzItems
                  .where((buzz) => buzz.isPublished)
                  .length,
              itemBuilder: (context, index) {
                return ReusableCard(
                  normalWebuzz: controller.weeBuzzItems
                      .where((buzz) => buzz.isPublished)
                      .toList()[index],
                );
                // }
              },
            );
          } else {
            return const HomePageShimmer();
          }
        },
      ),
    );
  }
}
