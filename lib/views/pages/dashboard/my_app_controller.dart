import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/documents/program_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../../services/location_services.dart';
import '../../registration/login_page.dart';
import '../../registration/welcome_page.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';
import 'graduent_page.dart';
import 'my_app.dart';
import 'suspended_user_page.dart';

class AppController extends GetxController {
  static AppController instance = Get.find();

  FirebaseAuth auth = FirebaseAuth.instance;

  final CollectionReference _collectionReference = FirebaseService
      .firebaseFirestore
      .collection(firebaseWeBuzzUserCollection);

  int tabIndex = 0;

  late TextEditingController emailEditingController;
  late TextEditingController passwordEditingController;
  late TextEditingController nameEditingController;

  TextEditingController? bioEditingController;
  TextEditingController? editNameEditingController;

  TextEditingController? phoneEditingController;
  TextEditingController? lavelEditingController;

  // email, password and name.. of the logged In user
  late Rx<User?> _user;

  RxList<WeBuzzUser> weBuzzUsers = RxList<WeBuzzUser>([]);
  RxList<ProgramModel> programs = RxList<ProgramModel>([]);

  // Current user instance
  WeBuzzUser? currentUser;

  // Rx<WeBuzzUser>? loggedInUser;

  // Stream<WeBuzzUser> _streamCurrentUser(String id) {
  //   return FirebaseService.firebaseFirestore
  //       .collection(firebaseWeBuzzUserCollection)
  //       .doc(id)
  //       .snapshots()
  //       .map((doc) => WeBuzzUser.fromDocument(doc));
  // }

  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }

  String city = '';

  void getUserLocation() async {
    try {
      String city = await getCurrentCity();
      this.city = city;
    } catch (e) {
      debugPrint('Error while tyring to get the location $e');
    }
  }

  // ScreenshotController screenshotController = ScreenshotController();
  // late ShakeDetector shakeDetector;
  // late GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void onInit() {
    super.onInit();

    emailEditingController = TextEditingController();
    passwordEditingController = TextEditingController();
    nameEditingController = TextEditingController();
    editNameEditingController = TextEditingController();
    bioEditingController = TextEditingController();
    phoneEditingController = TextEditingController();
    lavelEditingController = TextEditingController();

    // For getting current user location
    getUserLocation();

    weBuzzUsers.bindStream(_streamWeBuzzUsers());
  }

  @override
  void onReady() {
    super.onReady();

    // Casting to the value of _user to Rx value
    _user = Rx<User?>(auth.currentUser);

    // Whatever happen with user, will be notify
    _user.bindStream(auth.userChanges());

    // ever function takes a listener (Firebase user),
    // and callback method, anytime something changes, the method will be notified
    ever(_user, _initialScreensSettings);
    Future.delayed(const Duration(seconds: 1), () {
      if (currentUser != null) {
        bioEditingController!.text = currentUser!.bio;
        editNameEditingController!.text = currentUser!.name;
        lavelEditingController!.text = currentUser!.level ?? '';
        phoneEditingController!.text = currentUser!.phone ?? '';
      }
    });

    programs.bindStream(_streamPrograms());

    // Future.delayed(
    //   const Duration(seconds: 10),
    //   () {
    //     try {
    //       shakeDetector = ShakeDetector.waitForStart(
    //         onPhoneShake: () {
    //           // Do stuff on phone shake
    //           captureAndReportBug();
    //         },
    //         minimumShakeCount: 1,
    //         shakeSlopTimeMS: 500,
    //         shakeCountResetTime: 3000,
    //         shakeThresholdGravity: 2.7,
    //       );
    //       shakeDetector.startListening();
    //     } catch (e) {
    //       log('Error trying to register the shake detecter');
    //       log(e);
    //     }
    //   },
    // );
  }

  // Navigations configuration
  void _initialScreensSettings(User? user) async {
    if (user == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      _navigateToWelcomePage();
    } else {
      final logginResult = await fetchUserDetails(user.uid);
      await Future.delayed(const Duration(milliseconds: 300));

      if (logginResult) _navigateToHomePage();
    }
  }

  _navigateToWelcomePage() {
    bool isSuspended = currentUser != null ? currentUser!.isSuspended : false;

    // bool isUndergraduate =
    //     currentUser != null ? currentUser!.isUndergraduate : false;

    // bool hasPaid = currentUser != null ? currentUser!.hasPaid : false;

    if (isSuspended) {
      Get.offAllNamed(SuspendedUserPage.routeName);
    } 
    
    // else if (isUndergraduate == false && hasPaid == false) {
    //   Get.offAllNamed(GraduantPage.routeName);
    // } 
    
    else {
      Get.offAllNamed(WelcomePage.routeName);
    }
  }

  _navigateToHomePage() {
    bool isSuspended = currentUser != null ? currentUser!.isSuspended : false;
    // bool isUndergraduate =
    //     currentUser != null ? currentUser!.isUndergraduate : false;
    // bool hasPaid = currentUser != null ? currentUser!.hasPaid : false;

    if (isSuspended) {
      Get.offAllNamed(SuspendedUserPage.routeName);
    // } else if (isUndergraduate == false && hasPaid == false) {
    //   Get.offAllNamed(GraduantPage.routeName);
    }
     else {
      Get.offAll(() => const MyBottomNavBar());
    }
  }

  // username generator by currentuser email
  String usernameGenerator(String email) {
    final username = email.split('@');
    return username.first;
  }

// Get current user info
  Future<bool> fetchUserDetails(String currentId) async {
    try {
      final result = await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(currentId)
          .get();

      if (result.data() != null) {
        currentUser = WeBuzzUser.fromDocument(result);

        await FirebaseService().getFirebaseMessagingToken();

        FirebaseService.updateActiveStatus(true);
      } else {
        //  autonatically create user in firestore
        WeBuzzUser weBuzzUser = WeBuzzUser(
          userId: auth.currentUser!.uid,
          email: auth.currentUser!.email!,
          name: 'New User',
          username: usernameGenerator(auth.currentUser!.email!),
          isOnline: true,
          isStaff: false,
          isAdmin: false,
          notification: true,
          premium: false,
          isVerified: false,
          createdAt: Timestamp.now(),
          lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
          location: city,
          isUndergraduate: true,
        );
        await FirebaseService.createUserInFirestore(
                weBuzzUser, auth.currentUser!.uid)
            .then((value) {
          fetchUserDetails(auth.currentUser!.uid);
        });
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: 'Warning!',
          message:
              'No user associated to email ${auth.currentUser!.email} in our database!, however, we automatically registerred you. You might change your details in profile page.',
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
        debugPrint(
          'No user associated to email ${auth.currentUser!.email} in our database!, you might try to create another account.',
        );
      }
      update();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: 'Error',
        message:
            'Something Went wrong! while trying to sign ${auth.currentUser!.email} please try agin later',
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
      logOut();
    }

    return false;
  }

  void logOut() async {
    CustomFullScreenDialog.showDialog();
    changeTabIndex(0);
    // for updating user status isOnline to false

    await FirebaseService.updateActiveStatus(false);
    // await FirebaseService.updateActiveStatus(false);
    // ChatController.instance.weBuzzLists.value = [];

    try {
      await auth.signOut().then((_) {
        auth = FirebaseAuth.instance;
        CustomFullScreenDialog.cancleDialog();
      });
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Warning!",
        message: "Something wen't wrong, try again later!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
      Get.offAllNamed(MyLoginPage.routeName);
    }
    update();
  }

// update user dm privacy
  void updateUserDMPrivacy(String directMessagePrivacy) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.updateUserData(
        {
          "directMessagePrivacy": directMessagePrivacy,
        },
        FirebaseAuth.instance.currentUser!.uid,
      ).whenComplete(() => CustomFullScreenDialog.cancleDialog());
      await fetchUserDetails(auth.currentUser!.uid);
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log(e);
      log("Error updating user privacy");
    }
    update();
  }

// update user online status
  void updateUserOnlineStatusPrivacy(String onlineStatusIndicator) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.updateUserData(
        {
          "onlineStatusIndicator": onlineStatusIndicator,
        },
        FirebaseAuth.instance.currentUser!.uid,
      ).whenComplete(() => CustomFullScreenDialog.cancleDialog());
      await fetchUserDetails(auth.currentUser!.uid);
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();

      log(e);
      log("Error updating user privacy");
    }
    update();
  }

// update if user likes or doesn't like push notification
  void updateNotification() async {
    if (currentUser != null) {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(auth.currentUser!.uid).update({
          'notification': currentUser!.notification ? false : true,
          'chatMessageNotifications': currentUser!.notification ? false : true,
          'postNotifications': currentUser!.notification ? false : true,
          'likeNotifications': currentUser!.notification ? false : true,
          'commentNotifications': currentUser!.notification ? false : true,
          'followNotifications': currentUser!.notification ? false : true,
          'userBlockNotifications': currentUser!.notification ? false : true,
          'saveNotifications': currentUser!.notification ? false : true,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });
        await fetchUserDetails(auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
      update();
    }
  }

// update if user likes or doesn't like push notification for new post
  void updatePostNotifications() async {
    if (currentUser != null) {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(auth.currentUser!.uid).update({
          'notification': true,
          'postNotifications': currentUser!.postNotifications ? false : true,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });
        await fetchUserDetails(auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
      update();
    }
  }

// update if user likes or doesn't like push notification for post likes
  void updateLikeNotifications() async {
    if (currentUser != null) {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(auth.currentUser!.uid).update({
          'notification': true,
          'likeNotifications': currentUser!.likeNotifications ? false : true,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });
        await fetchUserDetails(auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
      update();
    }
  }

// update if user likes or doesn't like push notification for post comment
  void updateCommentNotifications() async {
    if (currentUser != null) {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(auth.currentUser!.uid).update({
          'notification': true,
          'commentNotifications':
              currentUser!.commentNotifications ? false : true,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });
        await fetchUserDetails(auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
      update();
    }
  }

// update if user likes or doesn't like push notification for follows
  void updateFollowNotifications() async {
    if (currentUser != null) {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(auth.currentUser!.uid).update({
          'notification': true,
          'followNotifications':
              currentUser!.followNotifications ? false : true,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });
        await fetchUserDetails(auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
      update();
    }
  }

// update if user likes or doesn't like push notification for post saved
  void updateSaveNotifications() async {
    if (currentUser != null) {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(auth.currentUser!.uid).update({
          'notification': true,
          'saveNotifications': currentUser!.saveNotifications ? false : true,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });
        await fetchUserDetails(auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
      update();
    }
  }

// update if user likes or doesn't like push notification for post saved
  void updateChatMessageNotifications() async {
    if (currentUser != null) {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(auth.currentUser!.uid).update({
          'notification': true,
          'chatMessageNotifications':
              currentUser!.chatMessageNotifications ? false : true,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });
        await fetchUserDetails(auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "Warning!",
          message: "Something wen't wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
      update();
    }
  }

  void updateLastBook(String lastBook) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) return;
      // user is null? quit

      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseService.updateUserData({'lastBook': lastBook}, userId);

      fetchUserDetails(userId);
    } catch (e) {
      log('Error trying to update the last book of a user');
      log(e);
    }
  }

  Stream<List<WeBuzzUser>> _streamWeBuzzUsers() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .snapshots()
        .map((query) => query.docs.map((user) {
              return WeBuzzUser.fromDocument(user);
            }).toList());
  }

  Stream<List<ProgramModel>> _streamPrograms() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseProgramsCollection)
        .orderBy('createdAt')
        .snapshots()
        .map((query) =>
            query.docs.map((item) => ProgramModel.fromDocument(item)).toList());
  }

  @override
  void onClose() {
    super.onClose();
    editNameEditingController!.dispose();
    nameEditingController.dispose();
    lavelEditingController!.dispose();
    passwordEditingController.dispose();
    phoneEditingController!.dispose();
    editNameEditingController!.dispose();
    // shakeDetector.stopListening();
  }

  // void captureAndReportBug() async {
  //   try {
  //     Uint8List? capturedImage = await screenshotController.capture(
  //         pixelRatio: 4 / 2, delay: const Duration(milliseconds: 150));

  //     final directory = (await getTemporaryDirectory()).path;
  //     final imageFile = File('$directory/screenshot.png');

  //     imageFile.writeAsBytesSync(capturedImage!);

  //     // Save screenshot to device gallery
  //     // final result = await ImageGallerySaver.saveImage(capturedImage);
  //     // log('Image saved to device gallery $result');

  //     showReportDialog(imageFile);
  //     imageFile.delete();
  //   } catch (e) {
  //     log("Error trying to take screenshot");
  //     log(e);
  //   }
  // }

  // void showReportDialog(File imageFile) async {
  //   Get.dialog(
  //     WillPopScope(
  //       child: AlertDialog(
  //         title: const Text('Report Bug'),
  //         content: const Text('Do you want to report this issue?'),
  //         actions: [
  //           CustomMaterialButton(
  //             title: 'Cancel',
  //             onPressed: () => Get.back(),
  //           ),
  //           CustomMaterialButton(
  //             title: 'Report',
  //             onPressed: () {
  //               Get.back();
  //               Get.to(() => ReportBugPage(screenshot: imageFile));
  //             },
  //           )
  //         ],
  //       ),
  //       onWillPop: () => Future.value(false),
  //     ),
  //     barrierDismissible: false,
  //     barrierColor: kPrimary.withOpacity(0.03),
  //     useSafeArea: true,
  //   );
  // }
}
