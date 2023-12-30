import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/buzz_enum.dart';
import '../../../model/chat_message_model.dart';
import '../../../model/chat_model.dart';
import '../../../model/notification_model.dart';
import '../../../model/report_buzz.dart';
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

  RxList<WeBuzz> weeBuzzItems = RxList<WeBuzz>([]);

  RxBool isAnimated = RxBool(false);
  late Timer timer;
  double rotate = 0.0;

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
    weeBuzzItems.bindStream(_streamTweetBuzz());
    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      rotate += 0.005;
      update();
    });
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

  Stream<List<WeBuzz>> _streamTweetBuzz() {
    CollectionReference collectionReference =
        FirebaseService.firebaseFirestore.collection(firebaseWeBuzzCollection);

    return collectionReference
        // .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (query) => query.docs
              .map((item) => WeBuzz.fromDocumentSnapshot(item))
              .toList(),
        );
  }

  void updateViews(WeBuzz buzz) async {
    if (FirebaseAuth.instance.currentUser != null) {
      final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;

      // get post owner info
      final targetUser = AppController.instance.weBuzzUsers
          .firstWhere((user) => user.userId == buzz.authorId);

      if (buzz.likes.contains(loggedInUserId)) {
        try {
          await FirebaseService.updateBuzz(buzz.docId, {
            'likes': FieldValue.arrayRemove([loggedInUserId])
          });
          toast('Unliked');
        } catch (e) {
          log('Error unliking the post');
        }
      } else {
        try {
          await FirebaseService.updateBuzz(buzz.docId, {
            'likes': FieldValue.arrayUnion([loggedInUserId])
          }).then((_) {
            // If current user is not equal to the post author, send the notification
            if (buzz.authorId != loggedInUserId) {
              NotificationServices.sendNotification(
                notificationType: NotificationType.postLiking,
                targetUser: targetUser,
              );
            }
          });
          toast('Liked');
        } catch (e) {
          log('Error liking the post');
        }
      }
    }
  }

  // Repost a buzz
  Future reTweetBuzz(WeBuzz webuzz, bool current) async {
    final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
    if (current) {
      // unRebuzz and decrement (rebuzzcounter) the post if user did rebuzz allready
      CustomFullScreenDialog.showDialog();
      try {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .collection(firebaseReBuzzCollection)
            .doc(loggedInUserId)
            .delete()
            .then((value) {
          FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(webuzz.docId)
              .update({
            "reBuzzsCount": FieldValue.increment(-1),
            'rebuzzs':
                FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
          });
        });

        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .where('originalId', isEqualTo: webuzz.docId)
            .where('authorId', isEqualTo: loggedInUserId)
            .get()
            .then((value) {
          // If this query does not return anything, we gonna leave it
          if (value.docs.isEmpty) {
            return;
          }

          // Else we gonna delete it
          FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(value.docs[0].id)
              .delete();
        });

        CustomFullScreenDialog.cancleDialog();
        return;
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        log('Error while trying to unRebuzz the post $e');
      }
    } // webuzz.reBuzzsCount = webuzz.reBuzzsCount + 1;
    WeBuzz retweetedBux = webuzz.copyWith(
      authorId: FirebaseAuth.instance.currentUser!.uid,
      createdAt: Timestamp.now(),
      originalId: webuzz.docId,
      buzzType: BuzzType.rebuzz.name,
      rebuzz: true,
    );

    // rebuzz the post if user hasn't rebuzz the post
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .doc(webuzz.docId)
          .collection(firebaseReBuzzCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({}).then((value) {
        FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .update({
          "reBuzzsCount": FieldValue.increment(1),
          'rebuzzs':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      });

      await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .add(retweetedBux.toJson());
      CustomFullScreenDialog.cancleDialog();
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log('Error while trying to unRebuzz the post $e');
    }
  }

  Future likePost(WeBuzz webuzz, bool current) async {
    if (current) {
      CustomFullScreenDialog.showDialog();
      try {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .collection(firebaseLikesPostCollection)
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .delete()
            .then((value) async {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(webuzz.docId)
              .update({'likesCount': FieldValue.increment(-1)});
        });
        CustomFullScreenDialog.cancleDialog();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        log(e);
      }
    }
    if (!current) {
      CustomFullScreenDialog.showDialog();
      try {
        await FirebaseService.firebaseFirestore
            .collection(firebaseWeBuzzCollection)
            .doc(webuzz.docId)
            .collection(firebaseLikesPostCollection)
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({}).then((value) async {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(webuzz.docId)
              .update({'likesCount': FieldValue.increment(1)});
        });
        CustomFullScreenDialog.cancleDialog();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();

        log(e);
      }
    }
  }

  Stream<bool> getCurrentUserLikes(WeBuzz webuzz) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(webuzz.docId)
        .collection(firebaseLikesPostCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snap) {
      return snap.exists;
    });
  }

  WeBuzz? _getPostSnap(DocumentSnapshot snapshot) {
    return snapshot.exists ? WeBuzz.fromDocumentSnapshot(snapshot) : null;
  }

  Future<WeBuzz> getPostById(String id) async {
    DocumentSnapshot documentSnap = await FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(id)
        .get();
    return _getPostSnap(documentSnap)!;
  }

  Stream<bool> getCurrentUserReBuzz(WeBuzz weBuzz) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(weBuzz.docId)
        .collection(firebaseReBuzzCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snap) => snap.exists);
  }

  Future<void> toggleRetweetPost(WeBuzz webuzz) async {
    // chech if the user has already retweeted
    final retweet = await FirebaseService.firebaseFirestore
        .collection(firebaseReBuzzCollection)
        .where('originalId', isEqualTo: webuzz.docId)
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    final postRef = FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(webuzz.docId);

    if (retweet.docs.isEmpty) {
      // user has not retweet,

      WeBuzz retweetedBux = webuzz.copyWith(
        authorId: FirebaseAuth.instance.currentUser!.uid,
        createdAt: Timestamp.now(),
        originalId: webuzz.docId,
        buzzType: BuzzType.rebuzz.name,
        rebuzz: true,
      );
      await FirebaseService.firebaseFirestore
          .collection(firebaseReBuzzCollection)
          .add(retweetedBux.toJson());

      // increment the retweet count
      postRef.update({"reBuzzsCount": FieldValue.increment(1)});
    } else {
      // user has retweeted, unretweeted
      final retweetId = retweet.docs.first.id;

      // delete the retweet document
      await FirebaseService.firebaseFirestore
          .collection(firebaseReBuzzCollection)
          .doc(retweetId)
          .delete();

      // decrement the retweet count in the original post
      postRef.update({"reBuzzsCount": FieldValue.increment(-1)});
    }
  }

  Stream<bool> postIsRetweeted(String docId) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseReBuzzCollection)
        .where('originalId', isEqualTo: docId)
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((query) => query.docs.map((doc) {
              return doc.exists;
            }).first);
  }

  Future<List<WeBuzz>> getReplies(WeBuzz weBuzz) async {
    QuerySnapshot snapshot = await weBuzz.refrence!
        .collection(firebaseRepliesCollection)
        .orderBy('createdAt', descending: false)
        .get();

    return _getListPostSnap(snapshot);
  }

  List<WeBuzz> _getListPostSnap(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((buzz) => WeBuzz.fromDocumentSnapshot(buzz))
        .toList();
  }

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
          messages.add(MessageModel.fromDocumentSnapshot(chatMessages.docs.first));
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
    final targetUser = AppController.instance.weBuzzUsers
        .firstWhere((user) => user.userId == weBuzz.authorId);
    try {
      await FirebaseService.saveBuzz(weBuzz.docId).then(
        (_) {
          // If current user is not equal to the post author, send the notification
          if (weBuzz.authorId != FirebaseAuth.instance.currentUser!.uid) {
            NotificationServices.sendNotification(
              notificationType: NotificationType.postSaved,
              targetUser: targetUser,
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

  void reportBuzz(String buzzDocID, String reason) async {
    CustomFullScreenDialog.showDialog();
    try {
      Report data = Report(
        reportID: MethodUtils.generatedId,
        reportType: ReportType.buzz,
        reporterID: FirebaseAuth.instance.currentUser!.uid,
        reason: reason,
        createdAt: Timestamp.now(),
      );
      await FirebaseService.reportBuzz(buzzDocID, data.toJson())
          .whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
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
      if (!weBuzz.views.contains(FirebaseAuth.instance.currentUser!.uid)) {
        // if user has already viewed, do not update the
        await Future.delayed(const Duration(milliseconds: 300));
        await FirebaseService.updateBuzz(weBuzz.docId, {
          'views':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
          "viewsCount": FieldValue.increment(1),
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

  @override
  void onClose() {
    super.onClose();
    timer.cancel();
  }
}
