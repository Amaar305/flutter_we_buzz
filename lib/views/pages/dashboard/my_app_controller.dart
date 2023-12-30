import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../../services/location_services.dart';
import '../../registration/login_page.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';
import 'my_app.dart';

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

  bool obscureText = false;

  // email, password and name..
  late Rx<User?> _user;

  RxList<WeBuzzUser> weBuzzUsers = RxList<WeBuzzUser>([]);

  WeBuzzUser? currentUser;

  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }

  // username generator by currentuser email
  String usernameGenerator(String email) {
    final username = email.split('@');
    return username.first;
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

  void canOrCannotSee() {
    obscureText = !obscureText;
    update();
  }

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
    update();

    Future.delayed(const Duration(seconds: 2), () {
      if (currentUser != null) {
        bioEditingController!.text = currentUser!.bio;
        editNameEditingController!.text = currentUser!.name;
        lavelEditingController!.text = currentUser!.level ?? '';
        phoneEditingController!.text = currentUser!.phone ?? '';
      }
    });
  }

  // Navigations configuration
  void _initialScreensSettings(User? user) async {
    if (user == null) {
      debugPrint("LOGGING");
      Get.offAll(() => const LoginPage());
    } else {
      await Future.delayed(const Duration(milliseconds: 200))
          .whenComplete(() async {
        await fetchUserDetails(_user.value!.uid);
      });

      debugPrint("WELCOME");
      Get.offAll(() => const MyBottomNavBar());
      update();
    }
  }

// Get current user info
  Future<void> fetchUserDetails(String currentId) async {
    try {
      final result = await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(currentId)
          .get();

      if (result.data() != null) {
        currentUser = WeBuzzUser.fromDocument(result);
        update();
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
          isCompleteness: false,
          isVerified: false,
          createdAt: Timestamp.now(),
          lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
          location: city,
          pushToken: '',
          followers: [],
          following: [],
          savedBuzz: [],
          blockedUsers: [],
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
  }

  void logOut() async {
    CustomFullScreenDialog.showDialog();
    changeTabIndex(0);
    // for updating user status isOnline to false

    await FirebaseService.updateActiveStatus(false);
    // ChatController.instance.weBuzzLists.value = [];

    try {
      await auth.signOut().then((_) {
        auth = FirebaseAuth.instance;
        CustomFullScreenDialog.cancleDialog();
      });
      obscureText = false;
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Warning!",
        message: "Something wen't wrong, try again later!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
      Get.offAllNamed(LoginPage.routeName);
    }
    update();
  }

  void clearTextControllers() {
    emailEditingController.clear();
    passwordEditingController.clear();
    nameEditingController.clear();

    phoneEditingController!.clear();
    lavelEditingController!.clear();
    bioEditingController!.clear();
    obscureText = false;
  }

  void registration(int provider) async {
    if (provider == 0) {
      // Login
      CustomFullScreenDialog.showDialog();
      try {
        await auth.signInWithEmailAndPassword(
          email: emailEditingController.text.trim(),
          password: passwordEditingController.text.trim(),
        );
        QuerySnapshot<Map<String, dynamic>> result = await FirebaseService
            .firebaseFirestore
            .collection(firebaseWeBuzzUserCollection)
            .where('email', isEqualTo: emailEditingController.text.trim())
            .get();

        if (result.docs.isEmpty) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: 'Warning!',
            message:
                'No user associated to authenticated email ${emailEditingController.text}',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
          debugPrint(
              'No user associated to authenticated email ${emailEditingController.text}');
          return;
        }

        if (result.docs.length != 1) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: 'Warning!',
            message:
                'More than one user associated to email ${emailEditingController.text}',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
          debugPrint(
              'More than one user associated to email ${emailEditingController.text}');
          return;
        }
        clearTextControllers();
        update();
      } on FirebaseAuthException catch (err) {
        CustomFullScreenDialog.cancleDialog();

        if (err.code.contains('INVALID_LOGIN_CREDENTIALS')) {
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: "About user",
            message: 'Invalid email address or password',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
        } else {
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: "About user",
            message: err.message.toString(),
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
        }
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "About user",
          message: "Something went wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      }
    } else if (provider == 1) {
      // register
      CustomFullScreenDialog.showDialog();
      // get city name

      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: emailEditingController.text.trim(),
          password: passwordEditingController.text.trim(),
        );
        if (credential.user == null) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: 'Warning!',
            message: 'We can\'t register you at the moment!',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
          return;
        }
        final campusBuzzUser = WeBuzzUser(
          userId: credential.user!.uid,
          email: emailEditingController.text.trim(),
          username: usernameGenerator(emailEditingController.text.trim()),
          isOnline: true,
          isStaff: false,
          isAdmin: false,
          notification: true,
          createdAt: Timestamp.now(),
          pushToken: '',
          isCompleteness: false,
          isVerified: false,
          location: city,
          name: nameEditingController.text.trim(),
          lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
          followers: [],
          following: [],
          savedBuzz: [],
          blockedUsers: [],
        );

        await FirebaseService.createUserInFirestore(
                campusBuzzUser, credential.user!.uid)
            .then((val) {
          clearTextControllers();
        });

        update();
      } on FirebaseAuthException catch (err) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "About user",
          message: err.message.toString(),
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      } catch (e) {
        CustomSnackBar.showSnackBar(
          context: Get.context,
          title: "About user",
          message: "Something went wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
        CustomFullScreenDialog.cancleDialog();
      }
    } else {
      return;
    }
  }

// Edit user profile
  void editUserInfo() async {
    if (editNameEditingController!.text.isEmpty) {
      Get.snackbar(
        'Warning',
        'Name cannot be empty!',
        duration: const Duration(seconds: 2),
      );
    } else {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(auth.currentUser!.uid).update({
          'bio': bioEditingController!.text.isEmpty
              ? currentUser!.bio
              : bioEditingController!.text.trim(),
          'name': editNameEditingController!.text.isEmpty
              ? currentUser!.name
              : editNameEditingController!.text.trim(),
          'phone': phoneEditingController!.text.isEmpty
              ? currentUser!.phone
              : phoneEditingController!.text.trim(),
          'level': lavelEditingController!.text.isEmpty
              ? currentUser!.level
              : lavelEditingController!.text.trim(),
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
          Get.back();
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

// update user level
  void updateUserLevel(String level) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.updateUserData(
        {
          "level": level,
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

  // Has the image been picked?
  bool isImagePicked = false;

// Provides an easy way to pick an image from the image gallery
  final ImagePicker _picker = ImagePicker();

  // Convert the picked image to file image by using the picker.path property
  File? pickedImagePath;

  Future<File?> _selectImage() async {
    try {
      final image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 82);

      // Convert the picked image to file image by using the picker.path property
      pickedImagePath = File(image!.path);

      // Set the isImagePicked to true, to update the UI
      isImagePicked = true;

      return pickedImagePath;
    } catch (e) {
      log(e.toString());
      CustomFullScreenDialog.cancleDialog();
      CustomSnackBar.showSnackBar(
        context: Get.context,
        title: "Image picker",
        message: "You haven't picked an image!",
        backgroundColor:
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
      );
      return null;
    }
  }

// Upload/Delete/Update user profule
  void uploadDeleteUpdateUserProfileUrl() async {
    if (currentUser != null) {
      // check if userimage is null
      if (currentUser!.imageUrl == null) {
        CustomFullScreenDialog.showDialog();
        try {
          // pick image from gallery
          File? pickedImagePath = await _selectImage();

          // upload image to storage
          if (pickedImagePath != null && isImagePicked && currentUser != null) {
            final downloadedImage = await FirebaseService.uploadImage(
                pickedImagePath, 'users/${currentUser!.userId}');

            // update the user image field in firestore
            await _collectionReference.doc(auth.currentUser!.uid).update({
              'imageUrl': downloadedImage,
            }).whenComplete(() {
              CustomFullScreenDialog.cancleDialog();
            });
          }

          // update the user image field in firestore
          await fetchUserDetails(auth.currentUser!.uid);

          isImagePicked = false;
          pickedImagePath = null;
          update();
        } catch (e) {
          log(e.toString());
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: "Error",
            message: "Something went wrong try again later!",
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
        }
      } else {
        CustomFullScreenDialog.showDialog();
        try {
          // delete the current user image from storage
          await FirebaseService.deleteImage(currentUser!.imageUrl!);

          // await Future.delayed(const Duration(milliseconds: 100));

          // pick image from gallery
          File? pickedImagePath = await _selectImage();

          if (pickedImagePath != null && isImagePicked && currentUser != null) {
            // upload image to storage
            final downloadedImage = await FirebaseService.uploadImage(
                pickedImagePath, 'users/${currentUser!.userId}');

            // update the user image field in firestore
            await _collectionReference.doc(auth.currentUser!.uid).update({
              'imageUrl': downloadedImage,
            }).whenComplete(() {
              CustomFullScreenDialog.cancleDialog();
            });
          }

          await fetchUserDetails(auth.currentUser!.uid);
          isImagePicked = false;
          pickedImagePath = null;
          update();
        } catch (e) {
          log(e.toString());
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBar(
            context: Get.context,
            title: "Error",
            message: "Something went wrong try again later!",
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
        }
      }
    }

    // fetch user info again!
  }

  @override
  void onClose() {
    super.onClose();
    clearTextControllers();
  }

  Stream<List<WeBuzzUser>> _streamWeBuzzUsers() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .snapshots()
        .map((query) => query.docs.map((user) {
              return WeBuzzUser.fromDocument(user);
            }).toList());
  }
}
