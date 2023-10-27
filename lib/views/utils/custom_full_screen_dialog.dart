import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constants.dart';

class CustomFullScreenDialog {
  static void showDialog() {
    Get.dialog(
      WillPopScope(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      barrierColor: kPrimary.withOpacity(0.03),
      useSafeArea: true,
    );
  }

  static void cancleDialog() {
    Get.back();
  }

  // static Future<dynamic> showAlertDialog(void Function() onPressed) {
  //   return Get.dialog(
  //     WillPopScope(
  //       child: Center(
  //         child: AlertDialog(
  //           title: Text("Deleting Article!", style: titleTextStyle),
  //           content: Text(
  //             'Are you sure you want to delete this post?! if you delete it you may not undo it.',
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
  //                   onPressed: () => onPressed(),
  //                   child: Text(
  //                     'Delete',
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
