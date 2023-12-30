import 'package:get/get.dart';

import 'controllers/forgot_password_controller.dart';
import 'controllers/update_password_controller.dart';
import 'views/pages/chat/add_users_page/add_users_controller.dart';
import 'views/pages/chat/group_chat_info/group_chat_info_controller.dart';
import 'views/pages/chat/messages/messages_controller.dart';
import 'views/pages/chat/recent_chat_controller.dart';
import 'views/pages/create/create_controller.dart';
import 'views/pages/create/edit/edit_post_controller.dart';
import 'views/pages/documents/courses/courses_controller.dart';
import 'views/pages/documents/level_page_controller.dart';
import 'views/pages/documents/programs_controller.dart';
import 'views/pages/documents/view/doc_view_controller.dart';
import 'views/pages/home/filters/hashtag_filter_controller.dart';
import 'views/pages/home/home_controller.dart';
import 'views/pages/home/reply/reply_controller.dart';
import 'views/pages/search/search_controller.dart';
import 'views/pages/settings/settings_controller.dart';
import 'views/pages/users/users_list_controller.dart';
import 'views/pages/view_profile/view_profile_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => RecentChatController(), fenix: true);
    Get.lazyPut(() => CreateBuzzController(), fenix: true);
    Get.lazyPut(() => SearchUsersController(), fenix: true);
    Get.lazyPut(() => EditPostController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => ViewProfileController(), fenix: true);
    Get.lazyPut(() => MessageController(), fenix: true);
    Get.lazyPut(() => HashTagFilterController(), fenix: true);
    Get.lazyPut(() => ReplyController(), fenix: true);
    Get.lazyPut(() => AddUsersController(), fenix: true);
    Get.lazyPut(() => UserListController(), fenix: true);
    Get.lazyPut(() => GroupChatInfoController(), fenix: true);
    Get.lazyPut(() => CoursesController(), fenix: true);
    Get.lazyPut(() => ProgramsController(), fenix: true);
    Get.lazyPut(() => DocumentViewController(), fenix: true);
    Get.lazyPut(() => ForgotPasswordController(), fenix: true);
    Get.lazyPut(() => UpdatePasswordController(), fenix: true);
    Get.lazyPut(() => LevelPageController(), fenix: true);
  }
}
