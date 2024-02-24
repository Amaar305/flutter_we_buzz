import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/message_model.dart';
import '../../../../model/chat_model.dart';
import '../../../../model/notification_model.dart';
import '../../../../model/we_buzz_user_model.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/notification_services.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../dashboard/my_app_controller.dart';
import '../messages/messages_page.dart';

class AddUsersController extends GetxController {
  static final AddUsersController instance = Get.find();
  // for searching users
  late TextEditingController searchEditingController;

  late List<WeBuzzUser> _selectedUser;
  // ignore: non_constant_identifier_names
  late RxList<WeBuzzUser> WeBuzzUsers;

  RxList<String> currenttUsersFollowers = RxList<String>([]);
  RxList<String> currenttUsersFollowing = RxList<String>([]);

  String _groupTitle = '';

  var isShearch = false.obs;

  int index = 2;

  List<String> tabTitles = [
    'Mutual',
    'Following',
    'Followers',
  ];

  void updateIndex(int index) {
    this.index = index;
    update();
  }

  @override
  void onInit() {
    super.onInit();

    searchEditingController = TextEditingController();
    WeBuzzUsers = AppController.instance.weBuzzUsers;
    currenttUsersFollowers.bindStream(FirebaseService.streamFollowers(
        FirebaseAuth.instance.currentUser!.uid));
    currenttUsersFollowing.bindStream(FirebaseService.streamFollowing(
        FirebaseAuth.instance.currentUser!.uid));
    _selectedUser = [];
  }

  List<WeBuzzUser> get selectedUser => _selectedUser;

  String get chatGroupTitle => _groupTitle;

  void setGroupTitle(String name) {
    _groupTitle = name;
  }

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
      // current user's id
      String currentUserID = FirebaseAuth.instance.currentUser!.uid;

      List<String> membersIDs = [];

      bool dmPrivacy = canCreateGroupChat(
        selectedUsers: _selectedUser,
        membersID: membersIDs,
        currentUserID: currentUserID,
      );

      // Add current user's id to the membersIDs list
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
            List<MessageModel> messages = [];
            QuerySnapshot chatMessages =
                await FirebaseService().getLastMessageForChat(chatDocument.id);
            if (chatMessages.docs.isNotEmpty) {
              messages.add(
                  MessageModel.fromDocumentSnapshot(chatMessages.docs.first));
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
              createdBy: chatDocument['created_by'],
              createdAt: chatDocument['created_at'],
            );
            log('Successs Alhamdulillah');
            // set selected users to empty list
            _selectedUser = [];
            update();
            CustomFullScreenDialog.cancleDialog();

            // Navigate to the chat page
            Get.to(() => MessagesPage(chat: chatConversation));
          } else {
            log('Chat does not exists.');
            // Creating chat conversation data in firestore database for new chat
            DocumentReference? doc = await FirebaseService.createChat(
              {
                "is_group": isGroup,
                "is_activity": false,
                "members": membersIDs,
                "recent_time": FieldValue.serverTimestamp(),
                "created_at": Timestamp.now(),
                "created_by": FirebaseAuth.instance.currentUser!.uid,
                "group_title": null,
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
            MessagesPage chatPage = MessagesPage(
              chat: ChatConversation(
                group: isGroup,
                members: members,
                activity: false,
                currentUserId: FirebaseAuth.instance.currentUser!.uid,
                uid: doc!.id,
                messages: [],
                recentTime: Timestamp.now(),
                createdBy: FirebaseAuth.instance.currentUser!.uid,
                createdAt: Timestamp.now(),
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
          _showAlertDialog(
            onChanged: setGroupTitle,
            onPressed: () async {
              CustomFullScreenDialog.showDialog();
              // Creating chat conversation data in firestore database
              DocumentReference? doc = await FirebaseService.createChat(
                {
                  "is_group": isGroup,
                  "created_at": Timestamp.now(),
                  "members": membersIDs,
                  "recent_time": FieldValue.serverTimestamp(),
                  "group_title": chatGroupTitle,
                  "created_by": FirebaseAuth.instance.currentUser!.uid,
                  "is_activity": false,
                },
              ).whenComplete(() => CustomFullScreenDialog.cancleDialog());

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

              for (var user in members) {
                NotificationServices.sendNotification(
                  targetUser: user,
                  notificationType: NotificationType.groupChat,
                  notifiactionRef: doc!.id,
                  groupChat: chatGroupTitle,
                );
              }

              // Preparing the chat page before navigating
              MessagesPage chatPage = MessagesPage(
                chat: ChatConversation(
                  group: isGroup,
                  members: members,
                  activity: false,
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  uid: doc!.id,
                  messages: [],
                  recentTime: Timestamp.now(),
                  groupTitle: chatGroupTitle,
                  createdBy: currentUserID,
                  createdAt: Timestamp.now(),
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
        if (selectedUser.length > 1) {
          toast('You cannot create a Group chat with some of those users');
        }
      }
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log('Error creating user');
      log(e);
    }
  }

// Block user
  void blockedUsers(WeBuzzUser targetUser) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.blockedUser(targetUser.userId).whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
        toast(' Successifully blocked ${targetUser.name}');
      });
    } catch (e) {
      log("Error blocking user");
      log(e);
    }
  }

// Unblock user
  void unBlockedUsers(WeBuzzUser targetUser) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.unBlockedUser(targetUser.userId).whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
        toast(' Successifully unblocked ${targetUser.name}');
      });
    } catch (e) {
      log("Error blocking user");
      log(e);
    }
  }

  void showDiaologForBlockingUser(
    WeBuzzUser targetUser, {
    void Function()? onPressed,
  }) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Block User',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        content: Text(
          'By blocking ${targetUser.name} you\'ll no longer gonna recieve massegas and any notifications from this user!.',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          
          GetBuilder<AppController>(
            builder: (controller) {
              var unblocked = controller.currentUser!.blockedUsers
                  .contains(targetUser.userId);
              return MaterialButton(
                onPressed: () {
                  Get.back();
                  if (unblocked) {
                    unBlockedUsers(targetUser);
                  } else {
                    blockedUsers(targetUser);
                  }
                  if (onPressed != null) {
                    onPressed();
                  }

                  AppController.instance
                      .fetchUserDetails(FirebaseAuth.instance.currentUser!.uid);
                },
                child: Text(
                  unblocked ? 'Unblock' : 'Block',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  void _showAlertDialog({
    required void Function()? onPressed,
    void Function(String)? onChanged,
  }) {
    Get.dialog(
      WillPopScope(
        child: AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  color: Theme.of(Get.context!).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        onWillPop: () => Future.value(false),
      ),
    );
  }
}

bool canCreateGroupChat({
  required List<WeBuzzUser> selectedUsers,
  required List<String> membersID,
  required String currentUserID,
}) {
  var currenttUsersFollowers =
      AddUsersController.instance.currenttUsersFollowers;
  var currenttUsersFollowing =
      AddUsersController.instance.currenttUsersFollowing;

  for (WeBuzzUser user in selectedUsers) {
    // Check DM privacy settings for each selected user
    if (user.directMessagePrivacy == DirectMessagePrivacy.everyone) {
      // if selected user's dm settings is everyone
      membersID.add(user.userId);
    } else if (user.directMessagePrivacy == DirectMessagePrivacy.followers &&
        currenttUsersFollowing.contains(user.userId)) {
      // if selected user's dm settings is only followers

      membersID.add(user.userId);
    } else if (user.directMessagePrivacy == DirectMessagePrivacy.following &&
        currenttUsersFollowers.contains(user.userId)) {
      // if selected user's dm settings is only following

      membersID.add(user.userId);
    } else if (user.directMessagePrivacy == DirectMessagePrivacy.mutual &&
        currenttUsersFollowing.contains(user.userId) &&
        currenttUsersFollowers.contains(user.userId)) {
      // if selected user's dm settings is only mutual

      membersID.add(user.userId);
    } else {
      // Handle the case where the user doesn't meet the DM privacy criteria
      if (selectedUsers.length == 1) {
        toast('You cannot DM ${user.username}');
      }
      return false;
    }
  }

  return true;
}
