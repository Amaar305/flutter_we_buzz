import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/home/home_controller.dart';
import '../../utils/constants.dart';

// ignore: must_be_immutable
class AppbarSearchField extends StatelessWidget {
  AppbarSearchField({
    super.key,
    required this.controller,
  });

  final HomeController controller;
  late double _deviceHeight;
  late double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: _deviceWidth,
      height: _deviceHeight * 0.10,
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
                // TODO bug in here
                suffixIcon: GetBuilder<HomeController>(
                  builder: (_) {
                    return controller.isTyping.isTrue
                        ? GestureDetector(
                            onTap: () => controller.clearAndSearch(),
                            child: const Icon(
                              Icons.clear,
                            ),
                          )
                        : const SizedBox();
                  },
                ),
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

              // onFieldSubmitted: (value) {
              //   controller.search();
              // },
            ),
          ),
          // TODO bug in here
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
