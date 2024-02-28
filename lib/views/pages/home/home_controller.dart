import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/campus_announcement.dart';
import '../../../model/chat_model.dart';
import '../../../model/message_model.dart';
import '../../../model/notification_model.dart';
import '../../../model/report/report.dart';
import '../../../model/save_buzz.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../model/we_buzz_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../../services/notification_services.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/method_utils.dart';
import '../chat/messages/messages_page.dart';
import '../dashboard/my_app_controller.dart';

class HomeController extends GetxController {
  static final HomeController instance = Get.find();

  final queryBuzz = FirebaseService.firebaseFirestore
      .collection(firebaseWeBuzzCollection)
      .where('isSuspended', isEqualTo: false)
      .where('isPublished', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .withConverter(
        fromFirestore: (snapshot, options) => WeBuzz.fromJson(
          snapshot.data()!,
          snapshot.id,
          snapshot.reference,
        ),
        toFirestore: (buzz, options) => buzz.toJson(),
      );

  RxList<CampusAnnouncement> annouce = RxList<CampusAnnouncement>([]);

  RxList<String> currenttUsersFollowers = RxList<String>([]);
  RxList<String> currenttUsersFollowing = RxList<String>([]);

  // ScrollController exploreScrollController = ScrollController();
  // ScrollController feedScrollController = ScrollController();
  final isVisible = true.obs;
  final isVisible1 = true.obs;

  RxBool isAnimated = RxBool(false);
  late Timer timer;
  double rotate = 0.0;

  int activeIndex = 0;

  void updateActiveIndex(int index) {
    activeIndex = index;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message: $message');
      if (FirebaseAuth.instance.currentUser != null) {
        if (message.toString().contains('pause')) {
          FirebaseService.updateActiveStatus(false);
        }
        if (message.toString().contains('resume')) {
          FirebaseService.updateActiveStatus(true);
        }
      }
      return Future.value(message);
    });

    // exploreScrollController.addListener(() {
    //   isVisible.value = exploreScrollController.position.userScrollDirection ==
    //       ScrollDirection.forward;
    // });
    // feedScrollController.addListener(() {
    //   isVisible1.value = feedScrollController.position.userScrollDirection ==
    //       ScrollDirection.forward;
    // });
    currenttUsersFollowers.bindStream(FirebaseService.streamFollowers(
        FirebaseAuth.instance.currentUser!.uid));
    currenttUsersFollowing.bindStream(FirebaseService.streamFollowing(
        FirebaseAuth.instance.currentUser!.uid));

    annouce.bindStream(_streamAnnouce());
    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      rotate += 0.005;
      update();
    });
  }

  // WeBuzzUser get currentUser => AppController.instance.weBuzzUsers.firstWhere(
  //     (user) => user.userId == FirebaseAuth.instance.currentUser!.uid);

  WeBuzzUser currentUser() {
    try {
      final user = AppController.instance.weBuzzUsers.firstWhere((element) =>
          element.userId == FirebaseAuth.instance.currentUser!.uid);
      return user;
    } catch (e) {
      log("error getting current user's info");
      return AppController.instance.currentUser!;
      //FIXME: may be null sometime or cant reflect changes
    }
  }

  Future<WeBuzz> getPostWithAdditionalData(WeBuzz weBuzz) async {
    late WeBuzz post;
    // if the post is rebuzz, fetch additional informations
    if (weBuzz.isRebuzz && weBuzz.originalId.isNotEmpty) {
      DocumentSnapshot originalPostSnapshot = await FirebaseService
          .firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(weBuzz.originalId)
          .get();

      if (originalPostSnapshot.exists) {
        post = WeBuzz.fromDocumentSnapshot(originalPostSnapshot);
      }
    }
    return post;
  }

  // ignore: unused_element
  Stream<List<WeBuzz>> _allWeeBuzzItems() {
    List<WeBuzz> weBuzzs = [];
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshot = FirebaseService
        .firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return snapshot.asyncMap(
      (QuerySnapshot query) async {
        for (var doc in query.docs) {
          WeBuzz weBuzz = WeBuzz.fromDocumentSnapshot(doc);
          if (weBuzz.isRebuzz && weBuzz.originalId.isNotEmpty) {
            weBuzzs.add(await getPostWithAdditionalData(weBuzz));
          } else {
            weBuzzs.add(weBuzz);
          }
        }

        return weBuzzs;
      },
    );
  }

  // Stream<List<WeBuzz>> _streamTweetBuzz() {
  //   return FirebaseService.firebaseFirestore
  //       .collection(firebaseWeBuzzCollection)
  //       .where('isSuspended', isEqualTo: false)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map((query) => query.docs
  //           .map((item) => WeBuzz.fromDocumentSnapshot(item))
  //           .toList());
  // }

  // List<WeBuzz> _getListPostSnap(QuerySnapshot snapshot) {
  //   return snapshot.docs
  //       .map((buzz) => WeBuzz.fromDocumentSnapshot(buzz))
  //       .toList();
  // }

  void dmTheAuthor(String authorId) async {
    CustomFullScreenDialog.showDialog();
    try {
      List<String> membersIDs = [authorId];
      membersIDs.add(FirebaseAuth.instance.currentUser!.uid);

      //get list of chat where current user and selected user are only included
      final matchingChats = await FirebaseService.getOrCreateChat(authorId);

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
        QuerySnapshot chatMessages = await FirebaseService()
            .getLastMessageForChat(chatDocument.id)
            .whenComplete(() => CustomFullScreenDialog.cancleDialog());
        if (chatMessages.docs.isNotEmpty) {
          messages
              .add(MessageModel.fromDocumentSnapshot(chatMessages.docs.first));
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

        // Navigate to the chat page
        Get.to(() => MessagesPage(chat: chatConversation));
      } else {
        log('Chat does not exists.');
        // Creating chat conversation data in firestore database for new chat
        DocumentReference? doc = await FirebaseService.createChat(
          {
            "is_group": false,
            "is_activity": false,
            "members": membersIDs,
            "recent_time": FieldValue.serverTimestamp(),
            "created_at": Timestamp.now(),
            "created_by": FirebaseAuth.instance.currentUser!.uid,
            "group_title": null,
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
        MessagesPage chatPage = MessagesPage(
          chat: ChatConversation(
            group: false,
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

        CustomFullScreenDialog.cancleDialog();

        // Navigate to the chat page
        Get.to(() => chatPage);
      }
    } catch (e) {
      log(e);
      log("Error creating chat");
    }
  }

  void deleteBuzz(WeBuzz weBuzz) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.deleteBuzz(weBuzz)
          .whenComplete(() => CustomFullScreenDialog.cancleDialog());
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log("Error deleting post");
      log(e);
    }
  }

  void saveBuzz(WeBuzz weBuzz) async {
    // final targetUser = AppController.instance.weBuzzUsers
    //     .firstWhere((user) => user.userId == weBuzz.authorId);
    try {
      final targetUser = await FirebaseService.userByID(weBuzz.authorId);
      if (targetUser == null) return;
      SaveBuzz saveBuzz = SaveBuzz(
        id: MethodUtils.generatedId,
        buzzId: weBuzz.docId,
        userId: targetUser.userId,
        createdAt: Timestamp.now(),
      );
      await FirebaseService.saveBuzz(saveBuzz).then(
        (_) {
          // If current user is not equal to the post author, send the notification
          if (weBuzz.authorId != FirebaseAuth.instance.currentUser!.uid) {
            NotificationServices.sendNotification(
              notificationType: NotificationType.postSaved,
              targetUser: targetUser,
              notifiactionRef: weBuzz.docId,
            );
          }
        },
      );
    } catch (e) {
      log("Error saving post");
      log(e);
    }
  }

  void publisheAndUnpublisheBuzz({
    required bool isPublishe,
    required WeBuzz weBuzz,
  }) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.publisheAndUnpublisheBuzz(
        isPublishe: isPublishe,
        weBuzz: weBuzz,
      ).whenComplete(() => CustomFullScreenDialog.cancleDialog());
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log(e);
    }
  }

  void reportBuzz(String buzzDocID, String reason, ReportType type) async {
    try {
      Report data = Report(
        id: MethodUtils.generatedId,
        reporterUserId: FirebaseAuth.instance.currentUser!.uid,
        reportedItemId: buzzDocID,
        reportType: ReportType.buzz,
        description: reason,
        lastThreeMessages: [],
        timestamp: Timestamp.now(),
      );

      await FirebaseService.reportBuzz(buzzDocID, data, true).whenComplete(() {
        Get.back();
        toast('Successifully reported');
      });
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log("Error reporting post");
      log(e);
    }
  }

// update post views
  void updateBuzzViews(WeBuzz weBuzz) async {
    try {
      // if (!weBuzz.views.contains(FirebaseAuth.instance.currentUser!.uid)) {
      //   // if user has already viewed, do not update the
      //   await Future.delayed(const Duration(milliseconds: 300));
      //   await FirebaseService.updateBuzz(weBuzz.docId, {
      //     'views':
      //         FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      //     "viewsCount": FieldValue.increment(1),
      //   });
      // }

      final doc = await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(weBuzz.docId)
          .collection(firebaseViewsCollection)
          .doc(currentUser().userId)
          .get();

          1.delay();

      if (!doc.exists) {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(weBuzz.docId)
            .collection(firebaseViewsCollection)
            .doc(currentUser().userId)
            .set({'userId': currentUser().userId}).then((value) async {
          await Future.delayed(const Duration(milliseconds: 300));
          await FirebaseService.updateBuzz(
            weBuzz.docId,
            {
              "viewsCount": FieldValue.increment(1),
            },
          );
        });
      }
    } catch (e) {
      log("Error updating buzz views");
      log(e);
    }
  }

  List<String> reportReasons = [
    'Inappropriate Content',
    'Harassment or Bullying',
    'False Information',
    'Spam or Unwanted Advertising',
    'Violence or Threats',
    'Hate Speech or Discrimination',
    'Intellectual Property Violation',
  ];

  Stream<List<CampusAnnouncement>> _streamAnnouce() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseAnnouncementCollection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((item) => CampusAnnouncement.fromDocument(item))
            .toList());
  }

 

  @override
  void onClose() {
    super.onClose();
    // exploreScrollController.dispose();
    // feedScrollController.dispose();
    timer.cancel();
  }
}
