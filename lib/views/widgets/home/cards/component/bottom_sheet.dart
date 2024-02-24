import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/we_buzz_model.dart';
import 'package:hi_tweet/views/widgets/home/my_buttons.dart';

import '../../../../../model/report/report.dart';
import '../../../../../model/we_buzz_user_model.dart';
import '../../../../pages/home/home_controller.dart';

void showBottomSheetForReporting(normalWebuzz, bool isReply) {
  String? reasons;
  Get.dialog(
    AlertDialog(
      contentPadding:
          const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Text(
            'Report Buzz',
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
      content: SizedBox(
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          items: HomeController.instance.reportReasons.map((reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(reason),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            hintText: 'Tap to choose',
          ),
          onChanged: (value) {
            reasons = value!;
          },
        ),
      ),
      actions: [
        CustomMaterialButton(
          title: 'Cancel',
          onPressed: () {
            Get.back();
          },
        ),
        CustomMaterialButton(
          title: 'Report',
          onPressed: () {
            Get.back();
            if (reasons != null && reasons!.isNotEmpty) {
              HomeController.instance.reportBuzz(normalWebuzz.docId, reasons!,
                  isReply ? ReportType.buzzReply : ReportType.buzz);
            }
          },
        ),
      ],
    ),
  );
}

void showBottomSheetForDeletion(
  WeBuzzUser buzzOwner,
  WeBuzz normalWebuzz,
) {
  Get.dialog(
    AlertDialog(
      contentPadding:
          const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Text(
            'Warning',
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
      content: const SizedBox(
        child: Text(
          'If you delete the buzz you might not get it back. But you can publish/unpublish it.',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        ),
      ),
      actions: [
        CustomMaterialButton(
          title: 'Delete',
          onPressed: () {
            Get.back();
            HomeController.instance.deleteBuzz(normalWebuzz);
          },
        ),
        CustomMaterialButton(
          title: normalWebuzz.isPublished ? 'Unpublish' : 'Publish',
          onPressed: () {
            Get.back();
            HomeController.instance.publisheAndUnpublisheBuzz(
                isPublishe: false, weBuzz: normalWebuzz);
          },
        ),
      ],
    ),
  );
}
