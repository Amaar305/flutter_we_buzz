import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../model/we_buzz_model.dart';
import '../../../../../utils/constants.dart';
import '../../../../../utils/method_utils.dart';
import '../../../../../widgets/home/my_buttons.dart';
import '../components/reported_card_widget.dart';
import 'buzz_reports_controller.dart';

class ReportedBuzzPage extends GetView<BuzzReportController> {
  const ReportedBuzzPage({super.key, required this.buzz});
  final WeBuzz buzz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (buzz.isSuspended)
            IconButton(
              onPressed: () {
                controller.suspendedBuzz(buzz, false);
              },
              icon: const Icon(Icons.cancel_outlined),
            )
        ],
      ),
      floatingActionButton: Obx(
        () {
          final reports = controller.reports
              .where((r) => r.reportedItemId == buzz.docId)
              .toList();
          if (reports.length < 30) return const SizedBox();
          return FloatingActionButton(
            onPressed: (reports.length < 30)
                ? null
                : () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Actions'),
                        content: Text(
                          'Are you sure you want to suspend ${buzz.docId} from Webuzz community?',
                          style: const TextStyle(fontSize: 16.5),
                        ),
                        actions: [
                          CustomMaterialButton(
                            title: 'Cancel',
                            onPressed: () => Get.back(),
                          ),
                          CustomMaterialButton(
                            title: 'Confirm',
                            onPressed: () {
                              Get.back();
                              controller.suspendedBuzz(buzz, true);
                            },
                          ),
                        ],
                      ),
                    );
                  },
            child: Icon(
              reports.length < 30 ? Icons.check : Icons.warning,
              size: 35,
            ),
          );
        },
      ),
      body: Padding(
        padding: kPadding,
        child: Obx(
          () {
            final reports = controller.reports
                .where((r) => r.reportedItemId == buzz.docId)
                .toList();
            if (reports.isEmpty) {
              return const Center(
                child: Text(
                  'No reports!',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final reporter = controller.getUserById(report.reporterUserId);
                final date =
                    MethodUtils.formatDateWithMonthAndDay(report.timestamp!);

                return ReportedInfoWidget(
                  reportedBy: reporter.name,
                  reason: report.description,
                  date: date,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
