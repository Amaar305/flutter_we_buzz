import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/message_enum_type.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/message_model.dart';
import '../../../../model/we_buzz_user_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../dashboard/my_app_controller.dart';
import '../add_users_page/add_users_controller.dart';

class GroupChatInfoController extends GetxController {
  static final GroupChatInfoController instance = Get.find();

  RxList<String> currenttUsersFollowers = RxList<String>([]);
  RxList<String> currenttUsersFollowing = RxList<String>([]);

  late List<WeBuzzUser> _selectedUsers;
  late List<WeBuzzUser> _currentMembers;

  @override
  void onInit() {
    super.onInit();

    currenttUsersFollowers.bindStream(FirebaseService.streamFollowers(
        FirebaseAuth.instance.currentUser!.uid));
    currenttUsersFollowing.bindStream(FirebaseService.streamFollowers(
        FirebaseAuth.instance.currentUser!.uid));

    _selectedUsers = [];
    _currentMembers = [];
  }

  // Get current group members
  List<WeBuzzUser> get currentGroupMembers => _currentMembers;

  // Get selected users
  List<WeBuzzUser> get selectedUsers => _selectedUsers;

  void updateCurrentGroupMembers(List<WeBuzzUser> members) {
    for (var user in members) {
      if (_currentMembers.contains(user)) {
        continue;
      }
      _currentMembers.add(user);
    }
  }

  void addUserInSelectedUsersList(WeBuzzUser user) {
    if (_selectedUsers.contains(user)) {
      _selectedUsers.remove(user);
      update();
    } else {
      _selectedUsers.add(user);
      update();
    }
  }

  void addUserInChat(String chatID) async {
    try {
      Get.back(); // close the bottomSheet

      List<String> membersIDs = []; //List of the selected user's ids

      //Determine if the admin can add users in the group due to individual user policies
      bool dmPrivacy = canCreateGroupChat(
        selectedUsers: _selectedUsers,
        membersID: membersIDs,
        currentUserID: FirebaseAuth.instance.currentUser!.uid,
      );

      if (dmPrivacy) {
        for (var user in membersIDs) {
          await FirebaseService.addUserInGroupChat(chatID, user)
              .whenComplete(() => _selectedUsers.clear());
        }
      } else {
        if (selectedUsers.length > 1) {
          toast('You cannot create a Group chat with some of those users');
        }
      }
    } catch (e) {
      toast("Error trying to add user");
      log(e.toString());
    }
  }

  void removeUserInChat(String chatID, String userID) async {
    CustomFullScreenDialog.showDialog();
    try {
      List<MessageModel> messages = [];

      final chatDocs = await FirebaseService.firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .collection(firebaseMessageCollection)
          .where("senderID", isEqualTo: userID)
          .get();

      for (var doc in chatDocs.docs) {
        messages.add(MessageModel.fromDocumentSnapshot(doc));
      }

      // Delete every single message of the user (Images in cloud store)
      // Iterate through messages and delete image files.
      for (var message in messages) {
        if (message.type == MessageType.video ||
            message.type == MessageType.text ||
            message.type == MessageType.audio) {
          // Skip non-image messages.
          continue;
        }
        log("Deleting Images");
        await FirebaseService.deleteImage(message.content);
      }
      // Delete every single text messages of the user
      // After deleting files, delete the messages in Firestore.
      for (var message in messages) {
        log("Deleting text");

        await FirebaseService.deleteChatMessage(message, chatID).then((_) {
          toast("Message deleted");
        });
      }
      // Remove the user in the group
      await FirebaseService.exitGroupChat(chatID, userID).whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
        toast('Removed');
      });

      // Update chat recent_chat in firestore
      FirebaseService.updateChatData(
        chatID,
        {
          "recent_time": FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      toast("Error trying to remove user");
      log(e.toString());
    }
  }

  void deleteChat(String chatID) async {
    CustomFullScreenDialog.showDialog();
    try {
      List<MessageModel> messages = [];

      final chatDocs = await FirebaseService.firebaseFirestore
          .collection(firebaseChatCollection)
          .doc(chatID)
          .collection(firebaseMessageCollection)
          .get();

      for (var doc in chatDocs.docs) {
        messages.add(MessageModel.fromDocumentSnapshot(doc));
      }

      // Delete every single message in the group

      // Iterate through messages and delete image files.
      for (var message in messages) {
        if (message.type == MessageType.video ||
            message.type == MessageType.text ||
            message.type == MessageType.audio) {
          // Skip non-image messages.
          continue;
        }
        log("Deleting Images");
        await FirebaseService.deleteImage(message.content);
      }

      // Delete the group chat
      await FirebaseService.deleteChat(chatID).whenComplete(
        () {
          CustomFullScreenDialog.cancleDialog();
          toast('Successifully deleted');
        },
      );
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log("Error deleting group chat");
      log(e);
    }
  }

  void showDeleteChatDialog(String chatID) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Chat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'If you delete this chat you\'ll no longer gonna restore the chats!',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Get.back(); // Cancel the dialog
              Get.back(); // Close the current screen
              Get.back(); // Close the chat page
              deleteChat(chatID); // delete the group
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showExitingChatDialog(String chatID, String userID) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Exit Chat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'If you exit this chat you\'ll no longer gonna join the chat unless the admin has put you back again',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (userID == FirebaseAuth.instance.currentUser!.uid) {
                // If current user who's not an admin trying to remove theirselves from the group,
                Get.back(); // Cancel the dialog
                Get.back(); // Close the current screen
              }

              // if it's the admin trying to remove a user, cancel the dialog only! and remove the user.
              Get.back();
              removeUserInChat(chatID,
                  userID); // remove the user from the group along with their messages
            },
            child: const Text(
              'Exit',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<WeBuzzUser>> streamChat(String chatId) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseChatCollection)
        .doc(chatId)
        .snapshots()
        .map((query) {
      List<WeBuzzUser> members = [];

      for (var uid in query['members']) {
        // Get user's info using the iterated uid, in list of users
        var user = AppController.instance.weBuzzUsers
            .firstWhere((u) => u.userId == uid);

        // Add them to the members list
        members.add(user);
      }
      return members;
    });
  }

  List<WeBuzzUser> myUsers() {
    // Get IDs of the current members of the group
    var currentMembersID = _currentMembers.map((e) => e.userId).toList();

// Because admin can only add their friends in the group, we gonna get all his mutual friends
    final mutual = AppController.instance.weBuzzUsers
        .where((user) =>
            currenttUsersFollowers.contains(user.userId) ||
            currenttUsersFollowing.contains(user.userId))
        .toList();

    // The sorted list will gonna be all the admin's mutual friends except those that are in the group already
    List<WeBuzzUser> sorted = [];

    // loop through the mutual friends list
    for (var user in mutual) {
      // if (user) is in the currentMembersId list then skip, because the user already in the group
      if (currentMembersID.contains(user.userId)) {
        continue;
      }

      sorted.add(user); // else add the user in the sorted list
    }

    return sorted
        .toSet()
        .toList(); // sort the list by converting the list to set to remove repetitive and then convert it back to list
  }
}
