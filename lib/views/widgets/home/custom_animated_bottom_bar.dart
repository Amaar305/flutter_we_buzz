import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/chat/recent_chat_controller.dart';
import '../../pages/create/create_page.dart';
import '../../pages/dashboard/my_app_controller.dart';
import '../../pages/documents/programs_controller.dart';
import '../../pages/home/home_controller.dart';

class CustomAnimatedBottomBar extends StatelessWidget {
  const CustomAnimatedBottomBar({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      child: Obx(
        () {
          final chatVisible = RecentChatController.instance.isVisible.isTrue;
          final courseVisible = ProgramsController.instance.isVisible.isTrue;
          final exploreVisible = HomeController.instance.isVisible.isTrue;
          final feedVisible = HomeController.instance.isVisible1.isTrue;

          final visible =
              courseVisible && exploreVisible && feedVisible && chatVisible;
          return AnimatedCrossFade(
            firstChild: CustomBottomBar(controller: controller),
            secondChild: const SizedBox(),
            firstCurve: Curves.easeIn,
            crossFadeState:
                visible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 100),
          );
        },
      ),
    );
  }
}

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .85,
      child: Card(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,

        elevation: 5.0,
        clipBehavior: Clip.antiAlias,
        // margin: const EdgeInsets.symmetric(horizontal: 70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // This will take space as minimum as posible(to center)
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GetBuilder<AppController>(
                builder: (_) {
                  return IconButton(
                    icon: Icon(
                      controller.tabIndex == 0
                          ? FluentSystemIcons.ic_fluent_home_filled
                          : FluentSystemIcons.ic_fluent_home_regular,
                      size: 25,
                    ),
                    onPressed: () => controller.changeTabIndex(0),
                  );
                },
              ),
              GetBuilder<AppController>(
                builder: (_) {
                  return IconButton(
                    icon: Icon(
                      controller.tabIndex == 1
                          ? FluentSystemIcons.ic_fluent_chat_filled
                          : FluentSystemIcons.ic_fluent_chat_regular,
                      size: 25,
                    ),
                    onPressed: () => controller.changeTabIndex(1),
                  );
                },
              ),
              GetBuilder<AppController>(
                builder: (_) {
                  return IconButton(
                    icon: Icon(
                      controller.tabIndex == 2
                          ? FluentSystemIcons.ic_fluent_collections_filled
                          : FluentSystemIcons.ic_fluent_collections_regular,
                      size: 25,
                    ),
                    onPressed: () => controller.changeTabIndex(2),
                  );
                },
              ),
              GetBuilder<AppController>(
                builder: (_) {
                  return IconButton(
                    icon: Icon(
                      controller.tabIndex == 3
                          ? Icons.person
                          : Icons.person_outline,
                      size: 25,
                    ),
                    onPressed: () => controller.changeTabIndex(3),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 30,
                ),
                onPressed: () => Get.toNamed(CreateBuzzPage.routeName),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
