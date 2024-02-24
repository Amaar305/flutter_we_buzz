import 'package:get/get.dart';

import 'controllers/forgot_password_controller.dart';
import 'controllers/update_password_controller.dart';
import 'controllers/verify_user_controller.dart';
import 'views/pages/action/action_users_controller.dart';
import 'views/pages/announcement/annoucement_controller.dart';
import 'views/pages/announcement/update_announcement_controller.dart';
import 'views/pages/chart/users_sponsor_chart_controller.dart';
import 'views/pages/chat/add_users_page/add_users_controller.dart';
import 'views/pages/chat/group_chat_info/group_chat_info_controller.dart';
import 'views/pages/chat/messages/messages_controller.dart';
import 'views/pages/chat/recent_chat_controller.dart';
import 'views/pages/create/create_controller.dart';
import 'views/pages/create/edit/edit_post_controller.dart';
import 'views/pages/dashboard/graduent_controller.dart';
import 'views/pages/documents/courses/courses_controller.dart';
import 'views/pages/documents/levels/level_page_controller.dart';
import 'views/pages/documents/programs_controller.dart';
import 'views/pages/documents/view/doc_view_controller.dart';
import 'views/pages/home/filters/hashtag_filter_controller.dart';
import 'views/pages/home/home_controller.dart';
import 'views/pages/home/reply/reply_controller.dart';
import 'views/pages/notification/notification_controller.dart';
import 'views/pages/search/search_controller.dart';
import 'views/pages/settings/controllers/edit_profile_controller.dart';
import 'views/pages/settings/controllers/save_page_controller.dart';
import 'views/pages/settings/dashboard/dashboard_controller.dart';
import 'views/pages/settings/dashboard/note/upload_lecture_note_controller.dart';
import 'views/pages/settings/dashboard/reports/buzzs/buzz_reports_controller.dart';
import 'views/pages/settings/dashboard/reports/report_controller.dart';
import 'views/pages/settings/dashboard/reports/users/user_reports_controller.dart';
import 'views/pages/settings/dashboard/sponsors/sponsor_controller.dart';
import 'views/pages/settings/dashboard/verify/verify_users_controller.dart';
import 'views/pages/settings/help/bugs/report_bug_controller.dart';
import 'views/pages/settings/settings_controller.dart';
import 'views/pages/sponsor/sponsor_controller.dart';
import 'views/pages/users/users_list_controller.dart';
import 'views/pages/view_profile/view_profile_controller.dart';
import 'views/registration/login/login_page_controller.dart';
import 'views/registration/signup/signup_page_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => RecentChatController(), fenix: true);
    Get.lazyPut(() => CreateBuzzController(), fenix: true);
    Get.lazyPut(() => SearchUsersController(), fenix: true);
    Get.lazyPut(() => EditPostController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => EditProfileController(), fenix: true);
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
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => SponsorController(), fenix: true);
    Get.lazyPut(() => CampusAnnouncementController(), fenix: true);
    Get.lazyPut(() => ActionUsersController(), fenix: true);
    Get.lazyPut(() => SponsorChartController(), fenix: true);
    Get.lazyPut(() => UpdateAnnouncementController(), fenix: true);
    Get.lazyPut(() => UserReportsController(), fenix: true);
    Get.lazyPut(() => ReportsController(), fenix: true);
    Get.lazyPut(() => BuzzReportController(), fenix: true);
    Get.lazyPut(() => VerifyUsersController(), fenix: true);
    Get.lazyPut(() => SponsorDashboadController(), fenix: true);
    Get.lazyPut(() => VerifyUserController(), fenix: true);
    Get.lazyPut(() => GraduentController(), fenix: true);
    Get.lazyPut(() => SaveBuzzController(), fenix: true);
    Get.lazyPut(() => UploadLectureNoteCOntroller(), fenix: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => ReportBugController(), fenix: true);
  }
}
