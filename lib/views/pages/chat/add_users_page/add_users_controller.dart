import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/chat_message.dart';
import '../../../../model/chat_model.dart';
import '../../../../model/we_buzz_user_model.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../dashboard/my_app_controller.dart';
import '../chat_page.dart';

class AddUsersController extends GetxController {
  // for searching users
  late TextEditingController searchEditingController;

// device size
  late double deviceHeight;
  late double deviceWidth;

  late List<WeBuzzUser> _selectedUser;
  // ignore: non_constant_identifier_names
  late RxList<WeBuzzUser> WeBuzzUsers;

  String _groupTitle = '';

  @override
  void onInit() {
    super.onInit();
    deviceHeight = MediaQuery.of(Get.context!).size.height;
    deviceWidth = MediaQuery.of(Get.context!).size.width;

    searchEditingController = TextEditingController();
    WeBuzzUsers = AppController.instance.weBuzzUsers;
    _selectedUser = [];
  }

  List<WeBuzzUser> get selectedUser => _selectedUser;

  String get chatGroupTitle => _groupTitle;

  void setGroupTitle(String name) {
    _groupTitle = name;
  }

  void getUser({String? name}) async {}

  void updateSelectedUser(WeBuzzUser user) {
    if (_selectedUser.contains(user)) {
      _selectedUser.remove(user);
      update();
    } else {
      _selectedUser.add(user);
      update();
    }
  }

  void createChat() async {
    try {
      final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
      // create chat
      // List<String> membersIDs =
      //     _selectedUser.map((user) => user.userId).toList();

      List<String> membersIDs = [];

      bool dmPrivacy = canCreateGroupChat(
        selectedUsers: _selectedUser,
        membersID: membersIDs,
        currentUserID: currentUserID,
      );
      membersIDs.add(currentUserID);

      if (dmPrivacy) {
        //Determinig whether is a group chat or not
        bool isGroup = _selectedUser.length > 1;

        if (!isGroup) {
          CustomFullScreenDialog.showDialog();
          // get the selected user id
          final userID = _selectedUser.first.userId;

          //get list of chat where current user and selected user are only included
          final matchingChats = await FirebaseService.getOrCreateChat(userID);

          if (matchingChats.isNotEmpty) {
            // Chat already exists, retrieve chat data
            DocumentSnapshot chatDocument = matchingChats.first;
            // Access chat data using chatDocument.data()
            log('Chat already exists. Retrieve chat data: ${chatDocument.data()}');

            // Get Users in chat
            List<WeBuzzUser> members = [];

            // iterate through all members uids
            for (var uid in chatDocument['members']) {
              // Get user's info using the iterated uid, in firestore
              DocumentSnapshot userSnapshot =
                  await FirebaseService.getUserByID(uid);

              // Add them to the members list
              members.add(WeBuzzUser.fromDocument(userSnapshot));
              log("I am trying!");
            }

            // last message
            List<ChatMessage> messages = [];
            QuerySnapshot chatMessages = await FirebaseService()
                .getLastMessageForChat(chatDocument.id)
                .whenComplete(() => CustomFullScreenDialog.cancleDialog());
            if (chatMessages.docs.isNotEmpty) {
              messages.add(ChatMessage.fromDocument(chatMessages.docs.first));
            }

            ChatConversation chatConversation = ChatConversation(
              uid: chatDocument.id,
              currentUserId: FirebaseAuth.instance.currentUser!.uid,
              group: chatDocument['is_group'],
              activity: chatDocument['is_activity'],
              members: members,
              messages: messages,
              recentTime: chatDocument['recent_time'],
              groupTitle: chatDocument['group_title'],
            );
            log('Successs Alhamdulillah');
            // set selected users to empty list
            _selectedUser = [];
            update();

            // Navigate to the chat page
            Get.to(() => ChatPage(chat: chatConversation));
          } else {
            log('Chat does not exists.');
            // Creating chat conversation data in firestore database for new chat
            DocumentReference? doc = await FirebaseService.createChat(
              {
                "is_group": isGroup,
                "is_activity": false,
                "members": membersIDs,
                "recent_time": FieldValue.serverTimestamp(),
                "group_title": null
              },
            );
            log(isGroup);

            // Navigate to Chat Page
            List<WeBuzzUser> members = [];

            // looping through all the users' ID
            for (var userId in membersIDs) {
              // Querying all the users by there ID's
              DocumentSnapshot userSnapshot =
                  await FirebaseService.getUserByID(userId);

              // Adding all the selected users to the members' list
              members.add(WeBuzzUser.fromDocument(userSnapshot));
            }

            // Preparing the chat page before navigating
            ChatPage chatPage = ChatPage(
              chat: ChatConversation(
                group: isGroup,
                members: members,
                activity: false,
                currentUserId: FirebaseAuth.instance.currentUser!.uid,
                uid: doc!.id,
                messages: [],
                recentTime: Timestamp.now(),
              ),
            );

            // set selected users to empty list
            _selectedUser = [];
            update();

            CustomFullScreenDialog.cancleDialog();

            // Navigate to the chat page
            Get.to(() => chatPage);
          }
        } else {
          _showBottomSheet(
            onChanged: setGroupTitle,
            onPressed: () async {
              // Creating chat conversation data in firestore database
              DocumentReference? doc = await FirebaseService.createChat(
                {
                  "is_group": isGroup,
                  "is_activity": false,
                  "members": membersIDs,
                  "recent_time": FieldValue.serverTimestamp(),
                  "group_title": chatGroupTitle,
                },
              );

              // Navigate to Chat Page
              List<WeBuzzUser> members = [];

              // looping through all the users' ID
              for (var userId in membersIDs) {
                // Querying all the users by there ID's
                DocumentSnapshot userSnapshot =
                    await FirebaseService.getUserByID(userId);

                // Adding all the selected users to the members' list
                members.add(WeBuzzUser.fromDocument(userSnapshot));
              }

              // Preparing the chat page before navigating
              ChatPage chatPage = ChatPage(
                chat: ChatConversation(
                  group: isGroup,
                  members: members,
                  activity: false,
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  uid: doc!.id,
                  messages: [],
                  recentTime: Timestamp.now(),
                  groupTitle: chatGroupTitle,
                ),
              );

              Get.back();
              // set selected users to empty list
              _selectedUser = [];
              update();

              // Navigate to the chat page
              Get.to(() => chatPage);
            },
          );
        }
      } else {
        toast('You cannot DM or create Group chat with those users');
      }
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log('Error creating user');
      log(e);
    }
  }

  void _showBottomSheet(
      {required void Function()? onPressed, void Function(String)? onChanged}) {
    Get.dialog(WillPopScope(
      child: AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.message,
              color: Theme.of(Get.context!).colorScheme.primary,
            ),
            const Text('Group Title'),
          ],
        ),
        content: TextFormField(
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Group title cannot be null';
            } else if (value.length > 15) {
              return 'Maximum of 15 characters only';
            }
            return null;
          },
        ),
        actions: [
          MaterialButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancle',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(Get.context!).colorScheme.primary),
            ),
          ),
          MaterialButton(
            onPressed: onPressed,
            child: Text(
              'Create',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(Get.context!).colorScheme.primary),
            ),
          ),
        ],
      ),
      onWillPop: () => Future.value(false),
    ));
  }
}

bool canCreateGroupChat({
  required List<WeBuzzUser> selectedUsers,
  required List<String> membersID,
  required String currentUserID,
}) {
  for (WeBuzzUser user in selectedUsers) {
    // Check DM privacy settings for each selected user
    if (user.directMessagePrivacy == DirectMessagePrivacy.everyone) {
      membersID.add(user.userId);
    } else if (user.directMessagePrivacy == DirectMessagePrivacy.followers &&
        user.followers.contains(currentUserID)) {
      membersID.add(user.userId);
    } else if (user.directMessagePrivacy == DirectMessagePrivacy.following &&
        user.following.contains(currentUserID)) {
      membersID.add(user.userId);
    } else if (user.directMessagePrivacy == DirectMessagePrivacy.mutual &&
        user.followers.contains(currentUserID) &&
        user.following.contains(currentUserID)) {
      membersID.add(user.userId);
    } else {
      // Handle the case where the user doesn't meet the DM privacy criteria
      toast('the user doesn\'t meet the DM ');
      return false;
    }
  }

  return true;
}
