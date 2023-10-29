import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_binding.dart';
import 'views/pages/create/create_page.dart';
import 'views/pages/dashboard/my_dashboard.dart';
import 'views/pages/settings/edit_profile_page.dart';
import 'views/pages/settings/setting_page.dart';
import 'views/pages/settings/settings_controller.dart';
import 'views/registration/login_page.dart';
import 'views/registration/signup_page.dart';
import 'views/splash/splash_page.dart';
import 'views/theme/app_themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hi Tweet',
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
          name: MyBottomNavBar.routeName,
          page: () => const MyBottomNavBar(),
          transition: Transition.circularReveal,
        ),
        GetPage(
          name: LoginPage.routeName,
          page: () => const LoginPage(),
        ),
        GetPage(
          name: SignUpPage.routeName,
          page: () => const SignUpPage(),
        ),
        GetPage(
          name: CreateTweetPage.routeName,
          page: () => const CreateTweetPage(),
          transition: Transition.downToUp,
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
      ],
    );
  }
}
