import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../../model/report/report.dart';
import '../../../../../../model/we_buzz_user_model.dart';
import '../../../../../../services/firebase_constants.dart';
import '../../../../../../services/firebase_service.dart';
import '../../../../dashboard/my_app_controller.dart';

class UserReportsController extends GetxController {
  RxList<Report> reports = RxList([]);
  RxList<WeBuzzUser> suspendedUsers = RxList([]);

  @override
  void onInit() {
    super.onInit();
    reports.bindStream(_streamReports());
    // suspendedUsers.bindStream(_streamUser());
  }

  WeBuzzUser getUserById(String id) => AppController.instance.weBuzzUsers
      .firstWhere((user) => user.userId == id);

  Stream<List<Report>> _streamReports() => FirebaseService.firebaseFirestore
      .collection(firebaseReportCollection)
      .where('reportType', isEqualTo: ReportType.user.name)
      .snapshots()
      .map((query) =>
          query.docs.map((item) => Report.fromSnapshot(item)).toList());

  // ignore: unused_element
  Stream<List<WeBuzzUser>> _streamUser() {
    final collectionReference = FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection);

    return collectionReference
        .where('isSuspended', isEqualTo: true)
        .snapshots()
        .map((query) =>
            query.docs.map((item) => WeBuzzUser.fromDocument(item)).toList());
  }

  void suspendedUser(WeBuzzUser user, bool suspend) async {
    try {
      await FirebaseService.updateUserData(
              {"isSuspended": suspend}, user.userId)
          .whenComplete(
        () {
          if (suspend) {
            toast('Successifully suspended');
          }
          toast('Successifully unsuspended');
        },
      );
    } catch (e) {
      log(e);
    }
  }

  List<String> tabTitles = const [
    'Suspended',
    'Reported',
  ];
}
