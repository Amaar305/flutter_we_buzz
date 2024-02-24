import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/dashboard/my_app_controller.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/notification_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';

class NotificationController extends GetxController {
  static final NotificationController instance = Get.find();
  RxList<NotificationModel> notifications = RxList([]);

  @override
  void onInit() {
    super.onInit();
    if (AppController.instance.currentUser != null) {
      notifications.bindStream(
          streamNotification(AppController.instance.currentUser!.userId));
    }
  }

  bool isDifferentDay(NotificationModel a, NotificationModel b) {
    return !isSameDay(a.timestamp, b.timestamp);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void updateNotificationRead(String id) async {
    try {
      FirebaseService.updateNotification(id, {
        "isRead": true,
      });
    } catch (e) {
      log(e.toString());
      log("Error trying to create notification in firestore");
    }
  }

  Stream<List<NotificationModel>> streamNotification(String userId) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseNotificationCollection)
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((item) => NotificationModel.fromDocument(item))
            .toList());
  }
}
