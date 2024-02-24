import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/we_buzz_model.dart';
import '../../utils/constants.dart';

class SponsorChartController extends GetxController {
  static final SponsorChartController instance = Get.find();
  List<PieChartSectionData> getChartSections(List<WeBuzz> sponsors) {
    List<PieChartSectionData> sections = [];

    for (WeBuzz sponsor in sponsors) {
      if (sponsor.hasPaid) {
        DateTime currentDate = DateTime.now();
        DateTime sponsorEndDate = sponsor.createdAt
            .toDate()
            .add(Duration(days: sponsor.duration! * 7));

        if (sponsorEndDate.isBefore(currentDate)) {
          // Expired
          sections.add(PieChartSectionData(
            color: Colors.red,
            value: 1,
            title: 'Expired',
            radius: 60,
          ));
        } else {
          // Active
          double remainingDays =
              sponsorEndDate.difference(currentDate).inDays.toDouble();
          double expiredPercentage =
              (sponsor.duration! * 7 - remainingDays) / (sponsor.duration! * 7);

          sections.add(PieChartSectionData(
            color: kPrimary,
            value: expiredPercentage,
            title: 'Remaining: ${remainingDays.round()} days',
            radius: 60,
          ));
        }
      } else {
        // Unpaid
        sections.add(PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'Unpaid',
          radius: 60,
        ));
      }
    }

    return sections;
  }

  List<String> tabTitles = [
    'Ongoing',
    'Expired',
    'Not Paid',
  ];
}
