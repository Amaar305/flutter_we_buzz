import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../dashboard/my_app_controller.dart';

class HashTagFilterController extends GetxController {




final currentUser = AppController.instance.currentUser;
  Query<WeBuzz> getFilterPosts(String hashtag) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .where('hashtags', arrayContains: hashtag)
        .orderBy('createdAt', descending: true)
        .withConverter<WeBuzz>(
          fromFirestore: (snapshot, _) => WeBuzz.fromJson(
            snapshot.data()!,
            snapshot.id,
            snapshot.reference,
          ),
          toFirestore: (buzz, _) => buzz.toJson(),
        );
  }
}
