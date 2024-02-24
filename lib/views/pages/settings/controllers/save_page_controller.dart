import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';

class SaveBuzzController extends GetxController {
  List<String> ids = [];

  @override
  void onInit() {
    super.onInit();
    _fetchSavedBuzzIds();
  }

  void _fetchSavedBuzzIds() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) return;

      final query = await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .where('isSuspended', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      query.docs.forEach(_ann);
      update();
    } catch (e) {
      log('Error tyring to fetch current user\'s saved buzz');
      log(e.toString());
    }
  }

  void _ann(QueryDocumentSnapshot element) async {
    try {
      final check = await element.reference
          .collection(firebaseSavedBuzzCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (check.exists) {
        ids.add(element.id);
      }
    } catch (e) {
      log('Error iterating over the saved buzz snapshot');
      log(e.toString());
    }
    update();
  }

  Stream<WeBuzz> streamBuzz(String id) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(id)
        .snapshots()
        .map((doc) => WeBuzz.fromDocumentSnapshot(doc));
  }
}
