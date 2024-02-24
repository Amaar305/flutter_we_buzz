import 'package:get/get.dart';

import 'buzzs/buzz_reports.dart';
import 'users/user_reports.dart';

class ReportsController extends GetxController {
  void navigate(int to) {
    if (to == 0) {
      Get.toNamed(UsersReport.routeName);
    } else {
      Get.toNamed(BuzzReportPage.routeName);
    }
  }

  List<String> reportsType = [
    'Users',
    'Buzzs',
  ];
}
