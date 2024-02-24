import '../../../../../model/we_buzz_user_model.dart';
import '../add_users_controller.dart';

bool shouldDisplayOnlineStatus(WeBuzzUser targetUser) {
  var onlineStatusIndicator = targetUser.onlineStatusIndicator;
  var currenttUsersFollowers =
      AddUsersController.instance.currenttUsersFollowers;
  var currenttUsersFollowing =
      AddUsersController.instance.currenttUsersFollowing;

  // Display the DM button based on DM privacy settings
  if (onlineStatusIndicator == DirectMessagePrivacy.everyone) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.followers &&
      currenttUsersFollowing.contains(targetUser.userId)) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.following &&
      currenttUsersFollowers.contains(targetUser.userId)) {
    return true;
  } else if (onlineStatusIndicator == DirectMessagePrivacy.mutual &&
      currenttUsersFollowing.contains(targetUser.userId) &&
      currenttUsersFollowers.contains(targetUser.userId)) {
    return true;
  }

  return false;
}
