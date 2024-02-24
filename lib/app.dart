import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_binding.dart';
import 'views/pages/announcement/announcement_page.dart';
import 'views/pages/chart/users_sponsor_chart_page.dart';
import 'views/pages/chat/add_users_page/add_users_page.dart';
import 'views/pages/create/create_page.dart';
import 'views/pages/dashboard/graduent_page.dart';
import 'views/pages/dashboard/my_app.dart';
import 'views/pages/dashboard/suspended_user_page.dart';
import 'views/pages/documents/programs_page.dart';
import 'views/pages/home/reply/reply_page.dart';
import 'views/pages/notification/notification_screen.dart';
import 'views/pages/search/search_page.dart';
import 'views/pages/settings/blocked_userspage.dart';
import 'views/pages/settings/dashboard/dashboard.dart';
import 'views/pages/settings/dashboard/issues/bug.report_issues_page.dart';
import 'views/pages/settings/dashboard/note/upload_lecture_note_page.dart';
import 'views/pages/settings/dashboard/sponsors/sponsor_products.dart';
import 'views/pages/settings/dashboard/sponsors/sponsor_users.dart';
import 'views/pages/settings/dashboard/verify/verify_users.dart';
import 'views/pages/settings/direct_message_privacy_page.dart';
import 'views/pages/settings/edit_profile_page.dart';
import 'views/pages/settings/help/bugs/report_bug_page.dart';
import 'views/pages/settings/help/help_center_page.dart';
import 'views/pages/settings/notification_setting_page.dart';
import 'views/pages/settings/online_status_indicator_privacy_page.dart';
import 'views/pages/settings/privacy_page.dart';
import 'views/pages/settings/dashboard/reports/buzzs/buzz_reports.dart';
import 'views/pages/settings/dashboard/reports/report_center.dart';
import 'views/pages/settings/dashboard/reports/users/user_reports.dart';
import 'views/pages/settings/save_buzz_page.dart';
import 'views/pages/settings/setting_page.dart';
import 'views/pages/settings/settings_controller.dart';
import 'views/pages/settings/verify_user_page.dart';
import 'views/pages/sponsor/sponsor_agreement_page.dart';
import 'views/pages/sponsor/sponsor_page.dart';
import 'views/pages/staff/staff_congrat_page.dart';
import 'views/pages/users/users._list_page.dart';
import 'views/registration/forget_password.dart';
import 'views/registration/login_page.dart';
import 'views/registration/signup_page.dart';
import 'views/registration/update_password.dart';
import 'views/registration/welcome_page.dart';
import 'views/splash/splash_page.dart';
import 'views/theme/app_themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Webuzz',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: SettingsController().getThemeMode(),
      initialBinding: AppBinding(),
      initialRoute: SplashScreen.routeName,
      getPages: [
        GetPage(
          name: SplashScreen.routeName,
          page: () => const SplashScreen(),
          transition: Transition.circularReveal,
        ),
        GetPage(
          name: WelcomePage.routeName,
          page: () => const WelcomePage(),
          transition: Transition.circularReveal,
        ),
        GetPage(
          name: MyBottomNavBar.routeName,
          page: () => const MyBottomNavBar(),
          transition: Transition.circularReveal,
        ),
        GetPage(
          name: MyLoginPage.routeName,
          page: () => const MyLoginPage(),
        ),
        GetPage(
          name: SignUpPage.routeName,
          page: () => const SignUpPage(),
        ),
        GetPage(
          name: CreateBuzzPage.routeName,
          page: () => const CreateBuzzPage(),
          transition: Transition.downToUp,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: SearcUserhPage.routeName,
          page: () => const SearcUserhPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: RepliesPage.routeName,
          page: () => const RepliesPage(),
          transition: Transition.leftToRightWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: SettingPage.routeName,
          page: () => const SettingPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: EditProfilePage.routeName,
          page: () => const EditProfilePage(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: AddUsersPage.routeName,
          page: () => const AddUsersPage(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: PrivacyPage.routeName,
          page: () => const PrivacyPage(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: DirectMessagePrivacyPage.routeName,
          page: () => const DirectMessagePrivacyPage(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: BlockedUsersPrivacyPage.routeName,
          page: () => const BlockedUsersPrivacyPage(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: OnlineStatusIndicatorPrivacyPage.routeName,
          page: () => const OnlineStatusIndicatorPrivacyPage(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: SaveBuzzPage.routeName,
          page: () => const SaveBuzzPage(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: NotificationSettingsPage.routeName,
          page: () => const NotificationSettingsPage(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: UsersPageList.routeName,
          page: () => const UsersPageList(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: ProgramsPage.routeName,
          page: () => const ProgramsPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: DashBoardPage.routeName,
          page: () => const DashBoardPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: ForgotPasswordPage.routeName,
          page: () => const ForgotPasswordPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: UpdatePasswordPage.routeName,
          page: () => const UpdatePasswordPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: NotificationsScreen.routeName,
          page: () => const NotificationsScreen(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: SponsorPage.routeName,
          page: () => SponsorPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: UsersSponsorChartPage.routeName,
          page: () => const UsersSponsorChartPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: CampusAnnouncementPage.routeName,
          page: () => const CampusAnnouncementPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: SponsorAgreementPage.routeName,
          page: () => const SponsorAgreementPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: UsersReport.routeName,
          page: () => const UsersReport(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: SuspendedUserPage.routeName,
          page: () => const SuspendedUserPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: GraduantPage.routeName,
          page: () => const GraduantPage(),
          transition: Transition.circularReveal,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: StaffCongratulationPage.routeName,
          page: () => const StaffCongratulationPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: ReportCenterPage.routeName,
          page: () => const ReportCenterPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: HelpCenterPage.routeName,
          page: () => const HelpCenterPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: BuzzReportPage.routeName,
          page: () => const BuzzReportPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: UploadLectureNote.routeName,
          page: () => const UploadLectureNote(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: VerifyUsersPage.routeName,
          page: () => const VerifyUsersPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: SponsorUsersPage.routeName,
          page: () => const SponsorUsersPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: SponsorProductsPage.routeName,
          page: () => const SponsorProductsPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: VerifyUserPage.routeName,
          page: () => const VerifyUserPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: ReportBugPage.routeName,
          page: () => const ReportBugPage(),
          transition: Transition.zoom,
          curve: Curves.easeIn,
        ),
        GetPage(
          name: BugReportIssuesPage.routeName,
          page: () => const BugReportIssuesPage(),
          transition: Transition.zoom,
          curve: Curves.easeIn,
        ),
      ],
    );
  }
}
