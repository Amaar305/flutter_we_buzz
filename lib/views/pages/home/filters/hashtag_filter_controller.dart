import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/home/home_controller.dart';

import '../../../../model/we_buzz_model.dart';

class HashTagFilterController extends GetxController {
  static final HashTagFilterController instance = Get.find();
  var weeBuzzItems = <WeBuzz>[].obs;

  void getFilterPosts(String hashtag) {
    weeBuzzItems.value = HomeController.instance.weeBuzzItems
        .where((buzz) => buzz.hashtags.contains(hashtag))
        .toList();
  }
}
