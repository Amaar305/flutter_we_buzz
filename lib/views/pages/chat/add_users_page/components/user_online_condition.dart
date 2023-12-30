import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../model/we_buzz_user_model.dart';

bool shouldDisplayOnlineStatus(WeBuzzUser targetUser) {
  var onlineStatusIndicator = targetUser.onlineStatusIndicator;

  final currentUserID = FirebaseAuth.instance.currentUser!.uid;

  // Display the DM button based on DM privacy settings
  if (onlineStatusIndicator == DirectMessagePrivacy.everyone) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.followers &&
      targetUser.followers.contains(currentUserID)) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.following &&
      targetUser.following.contains(currentUserID)) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.mutual &&
      targetUser.followers.contains(currentUserID) &&
      targetUser.following.contains(currentUserID)) {
    return true;
  }

  return false;
}
