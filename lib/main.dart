import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'views/pages/dashboard/my_app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android)
        .then((value) async {
      Get.put(AppController());

      var result = await FlutterNotificationChannel.registerNotificationChannel(
        id: "chats",
        name: "Chats",
        description: "For Showing Message Notification",
        importance: NotificationImportance.IMPORTANCE_HIGH,
        // visibility: NotificationVisibility.VISIBILITY_PUBLIC,
        // allowBubbles: true,
        // enableSound: true,
        // enableVibration: true,
        // showBadge: true,
      );
      log("\nNotification Channel Result: $result");
    });
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    }
  }

  // // for setting oriantation
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  runApp(const MyApp());

  // runApp(
  //   // Enable device preview only in debug mode
  //   kDebugMode
  //       ? DevicePreview(
  //           builder: (context) => const MyApp(),
  //         )
  //       : const MyApp(),
  // );
}
