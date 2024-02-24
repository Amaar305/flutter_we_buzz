import 'package:get/get.dart';

import '../../../../../model/we_buzz_model.dart';
import '../../../../../model/we_buzz_user_model.dart';
import '../../../../../services/firebase_constants.dart';
import '../../../../../services/firebase_service.dart';

class SponsorDashboadController extends GetxController {
  RxList<WeBuzzUser> sponsorUsers = RxList([]);
  RxList<WeBuzz> sponsorproducts = RxList([]);

  @override
  void onInit() {
    super.onInit();

    sponsorUsers.bindStream(_streamUsers());
    sponsorproducts.bindStream(_streamProduct());
  }

  Stream<List<WeBuzzUser>> _streamUsers() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .where('sponsor', isEqualTo: true)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => WeBuzzUser.fromDocument(doc)).toList());
  }

  Stream<List<WeBuzz>> _streamProduct() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .where('isSponsor', isEqualTo: true)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => WeBuzz.fromDocumentSnapshot(doc)).toList());
  }


   List<String> tabTitles = [
    'Ongoing',
    'Expired',
    'Not Paid',
  ];
}
