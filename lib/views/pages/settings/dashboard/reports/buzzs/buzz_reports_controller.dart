import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../../model/report/report.dart';
import '../../../../../../model/we_buzz_model.dart';
import '../../../../../../model/we_buzz_user_model.dart';
import '../../../../../../services/firebase_constants.dart';
import '../../../../../../services/firebase_service.dart';
import '../../../../dashboard/my_app_controller.dart';

class BuzzReportController extends GetxController {
  RxList<Report> reports = RxList([]);
  RxList<WeBuzz> suspendedBuzzs = RxList([]);
  @override
  void onInit() {
    super.onInit();
    reports.bindStream(_streamReports());
    suspendedBuzzs.bindStream(_streamTweetBuzz());
  }

  // WeBuzz getBuzzById(String id) => HomeController.instance.weeBuzzItems
  //     .firstWhere((buzz) => buzz.docId == id);

  Future<WeBuzz> getBuzzById(String id) async {
    final buzz = await FirebaseService.getPostById(id);
    return buzz;
  }

  WeBuzzUser getUserById(String id) => AppController.instance.weBuzzUsers
      .firstWhere((user) => user.userId == id);

  Stream<List<Report>> _streamReports() => FirebaseService.firebaseFirestore
      .collection(firebaseReportCollection)
      .where('reportType', isEqualTo: ReportType.buzz.name)
      .snapshots()
      .map((query) =>
          query.docs.map((item) => Report.fromSnapshot(item)).toList());

  Stream<List<WeBuzz>> _streamTweetBuzz() {
    final collectionReference =
        FirebaseService.firebaseFirestore.collection(firebaseWeBuzzCollection);

    return collectionReference
        .where('isSuspended', isEqualTo: true)
        .snapshots()
        .map((query) => query.docs
            .map((item) => WeBuzz.fromDocumentSnapshot(item))
            .toList());
  }

  void suspendedBuzz(WeBuzz buzz, bool suspend) async {
    try {
      await FirebaseService.updateBuzz(buzz.docId, {"isSuspended": suspend})
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
    update();
  }

  List<String> tabTitles = const [
    'Suspended',
    'Reported',
  ];
}
