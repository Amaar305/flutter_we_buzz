import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hi_tweet/firebase_options.dart';

import 'app_binding.dart';
import 'views/pages/create/create_page.dart';
import 'views/pages/dashboard/dashboard_controller.dart';
import 'views/pages/dashboard/my_dashboard.dart';
import 'views/pages/settings/edit_profile_page.dart';
import 'views/pages/settings/setting_page.dart';
import 'views/registration/login_page.dart';
import 'views/registration/signup_page.dart';
import 'views/splash/splash_page.dart';
import 'views/theme/app_themes.dart';
import 'views/pages/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android).then(
      (value) => Get.put(AppController()),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetStorage box = GetStorage();
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
