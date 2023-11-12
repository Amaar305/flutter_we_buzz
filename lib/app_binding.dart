import 'package:get/get.dart';

import 'views/pages/chat/add_users_page/add_users_controller.dart';
import 'views/pages/chat/chat_page_controller.dart';
import 'views/pages/chat/recent_chat_controller.dart';
import 'views/pages/create/create_controller.dart';
import 'views/pages/create/edit/edit_post_controller.dart';
import 'views/pages/home/filters/hashtag_filter_controller.dart';
import 'views/pages/home/home_controller.dart';
import 'views/pages/home/reply/reply_controller.dart';
import 'views/pages/settings/settings_controller.dart';
import 'views/pages/view_profile/view_profile_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => RecentChatController(), fenix: true);
    Get.lazyPut(() => CreateBuzzController(), fenix: true); 
    Get.lazyPut(() => EditPostController(), fenix: true); 
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => ViewProfileController(), fenix: true);
    Get.lazyPut(() => ChatPageController(), fenix: true);
    Get.lazyPut(() => HashTagFilterController(), fenix: true);
    Get.lazyPut(() => ReplyController(), fenix: true);
    Get.lazyPut(() => AddUsersController(), fenix: true);
  }
}
