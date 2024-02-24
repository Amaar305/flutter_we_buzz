import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../model/we_buzz_user_model.dart';
import '../../../../pages/dashboard/my_app_controller.dart';

WeBuzzUser getWeBuzzUser(String authorId) {
  final owner = AppController.instance.weBuzzUsers.firstWhere(
    (user) => user.userId == authorId,
  );
  return owner;
}

WeBuzzUser getCurrentUser() {
  if (FirebaseAuth.instance.currentUser != null) {
    final owner = AppController.instance.weBuzzUsers.firstWhere(
      (user) => user.userId == FirebaseAuth.instance.currentUser!.uid,
    );
    return owner;
  } else {
    final owner = AppController.instance.weBuzzUsers.firstWhere(
      (user) => user.isOnline,
    );
    return owner;
  }
}
