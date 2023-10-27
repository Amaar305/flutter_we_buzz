import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void showSnackBAr({
    required BuildContext? context,
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    Get.snackbar(title, message,
        backgroundColor: backgroundColor,
        titleText: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        messageText: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16));
  }

  // static customAlertDialoag(
  //     String title, String body, String action, void Function() onPressed) {
  //   Get.dialog(
  //     WillPopScope(
  //       child: Center(
  //         child: AlertDialog(
  //           title: Text(title.toUpperCase(), style: titleTextStyle),
  //           content: Text(
  //             body,
  //             style: descriptionTextStyle,
  //             // maxLines: 2,
  //           ),
  //           actions: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextButton(
  //                   onPressed: () {
  //                     Get.back();
  //                   },
  //                   child: Text(
  //                     'Cancle',
  //                     style: titleTextStyle.copyWith(color: Colors.black),
  //                   ),
  //                 ),
  //                 TextButton(
  //                   onPressed: () {
  //                     Get.back();
  //                     onPressed();
  //                   },
  //                   child: Text(
  //                     action,
  //                     style: titleTextStyle.copyWith(color: Colors.black),
  //                   ),
  //                 ),
  //               ],
  //             )
  //           ],
  //         ),
  //       ),
  //       onWillPop: () => Future.value(false),
  //     ),
  //   );

  // }
}
