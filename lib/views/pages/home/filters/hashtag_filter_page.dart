import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/home/reusable_card.dart';
import '../home_controller.dart';

late double _deviceHeight;
late double _deviceWidth;

class HashTagFilterPage extends StatelessWidget {
  final String hashtag;
  const HashTagFilterPage({super.key, required this.hashtag});

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAppBar(
              hashtag,
              secondaryAction: const BackButton(),
            ),
            _webuzzList(),
          ],
        ),
      ),
    );
  }

  Widget _webuzzList() {
    // RxList<WeBuzz> buzzes = RxList(HomeController.homeController.weeBuzzItems
    //     .where((buzz) => buzz.hashtags.contains(hashtag))
    //     .toList());

    return Expanded(
      child: Obx(
        () {
          return ListView.builder(
            itemCount: HomeController.instance.weeBuzzItems
                .where((buzz) => buzz.hashtags.contains(hashtag))
                .length,
            itemBuilder: (context, index) => ReusableCard(
              normalWebuzz: HomeController.instance.weeBuzzItems
                  .where((buzz) => buzz.hashtags.contains(hashtag))
                  .toList()[index],
            ),
          );
        },
      ),
    );
  }
}
