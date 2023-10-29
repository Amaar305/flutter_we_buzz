import 'package:get/get.dart';

import 'views/pages/chat/chat_controller.dart';
import 'views/pages/create/create_controller.dart';
import 'views/pages/home/home_controller.dart';
import 'views/pages/settings/settings_controller.dart';
import 'views/pages/view_profile/view_profile_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => CreateTweetController(), fenix: true);
    Get.lazyPut(() => ViewProfileController(), fenix: true);
  }
}
