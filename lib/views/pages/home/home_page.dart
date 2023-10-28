import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/home/reusable_card.dart';
import '../create/create_page.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // For hiding keyboad when tap is detected
      onTap: () => Focus.of(context).unfocus(),
      child: WillPopScope(
        // if searching is on and back button is pressed then close search
        // else close the current page on back button
        onWillPop: () {
          // TODO willpopscoope might not work!
          controller.clearAndSearch();
          return Future.value(false);
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: GetBuilder<HomeController>(
              builder: (_) {
                return AnimatedCrossFade(
                  duration: const Duration(milliseconds: 150),
                  crossFadeState: controller.isSearched.isTrue
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: MyAppBar(controller: controller),
                  secondChild: AppbarSearchField(controller: controller),
                  firstCurve: Curves.easeInOut,
                  secondCurve: Curves.easeIn,
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.toNamed(CreateTweetPage.routeName),
            tooltip: 'Create',
            child: const Icon(Icons.add),
          ),
          body: Obx(
            () {
              return controller.tweetBuzz.isNotEmpty
                  ? ListView.builder(
                      itemCount: controller.isTyping.isTrue
                          ? controller.searchItems.length
                          : controller.tweetBuzz.length,
                      itemBuilder: (context, index) => ReusableCard(
                        tweet: controller.isTyping.isTrue
                            ? controller.searchItems[index]
                            : controller.tweetBuzz[index],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            },
          ),
        ),
      ),
    );
  }
}

class AppbarSearchField extends StatelessWidget {
  const AppbarSearchField({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.searchEditingController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon: controller.isTyping.isTrue
                    ? GestureDetector(
                        onTap: () => controller.clearAndSearch(),
                        child: const Icon(
                          Icons.clear,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kDefaultGrey),
                  borderRadius: BorderRadius.circular(50),
                ),
                fillColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                filled: true,
                hintText: "Search..",
              ),
              onChanged: (value) {
                controller.searchTweet();
              },
              onFieldSubmitted: (value) {
                controller.search();
              },
            ),
          ),
          IconButton(
            onPressed: () {
              controller.search();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class MyAppBar extends StatelessWidget {
  const MyAppBar({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('H I, T W E E T'),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () => controller.search(),
          icon:
              Icon(controller.isSearched.isFalse ? Icons.search : Icons.cancel),
        ),
      ],
    );
  }
}
