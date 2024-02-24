import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/we_buzz_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../utils/constants.dart';
import '../../../../../widgets/home/cards/reusable_card.dart';
import '../../../../../widgets/home/custom_tab_bar.dart';
import 'buzz_reports_controller.dart';
import 'reported_buzz.dart';

class BuzzReportPage extends GetView<BuzzReportController> {
  const BuzzReportPage({super.key});

  static const String routeName = '/reports-buzz-page';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabTitles.length,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: kPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTabBar(list: controller.tabTitles),
              CustomTabBarView(
                children: [
                  Obx(
                    () {
                      if (controller.suspendedBuzzs.isEmpty) {
                        return const Text(
                          'No suspended buzz',
                          style: TextStyle(fontSize: 18),
                        ).center();
                      }
                      return ListView.builder(
                        itemCount: controller.suspendedBuzzs.length,
                        itemBuilder: (context, index) {
                          final buzz = controller.suspendedBuzzs[index];

                          return GestureDetector(
                            onTap: () =>
                                Get.to(() => ReportedBuzzPage(buzz: buzz)),
                            child: ReusableCard(
                              normalWebuzz: buzz,
                              isReport: true,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Obx(
                    () {
                      return ListView.builder(
                        itemCount: controller.reports.length,
                        itemBuilder: (context, index) {
                          final report = controller.reports[index];

                          WeBuzz? buzz;

                          controller
                              .getBuzzById(report.reportedItemId)
                              .then((value) => buzz = value);

                          return GestureDetector(
                            onTap: () {
                              if (buzz == null) return;
                              Get.to(() => ReportedBuzzPage(buzz: buzz!));
                            },
                            child: buzz == null
                                ? const SizedBox()
                                : ReusableCard(
                                    normalWebuzz: buzz!,
                                    isReport: true,
                                  ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
