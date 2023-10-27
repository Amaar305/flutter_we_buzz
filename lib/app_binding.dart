import 'package:get/get.dart';

import 'views/pages/chat/recent_chat_controller.dart';
import 'views/pages/create/create_controller.dart';
import 'views/pages/home/home_controller.dart';
import 'views/pages/settings/settings_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RecentChatController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => CreateTweetController(), fenix: true);
  }
}
