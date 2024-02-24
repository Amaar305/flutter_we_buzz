import 'package:get/get.dart';

import '../../../../../model/we_buzz_user_model.dart';
import '../../../../../services/firebase_constants.dart';
import '../../../../../services/firebase_service.dart';

class VerifyUsersController extends GetxController {
  RxList<WeBuzzUser> verifyUsers = RxList([]);

  @override
  void onInit() {
    super.onInit();

    verifyUsers.bindStream(_streamUsers());
  }

  Stream<List<WeBuzzUser>> _streamUsers() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => WeBuzzUser.fromDocument(doc)).toList());
  }

}
