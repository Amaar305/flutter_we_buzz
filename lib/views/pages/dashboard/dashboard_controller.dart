import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/custom_full_screen_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/user.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../../services/location_services.dart';
import '../../registration/login_page.dart';
import '../../utils/custom_snackbar.dart';
import 'my_dashboard.dart';

class AppController extends GetxController {
  static AppController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _collectionReference =
      FirebaseService.firebaseFirestore.collection(firebaseCampusBuzzUser);

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

  RxList<CampusBuzzUser> weBuzzLists = RxList([]);

  CampusBuzzUser? currentUser;

  void changeTabIndex(int index) {
    tabIndex = index;
    update();
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

    weBuzzLists.bindStream(_streamTweetBuzz());
  }

  @override
  void onReady() {
    super.onReady();

    // Casting to the value of _user to Rx value
    _user = Rx<User?>(_auth.currentUser);

    // Whatever happen with user, will be notify
    _user.bindStream(_auth.userChanges());

    // ever function takes a listener (Firebase user),
    // and callback method, anytime something changes, the method will be notified
    ever(_user, _initialScreensSettings);
    update();

    Future.delayed(const Duration(seconds: 2), () {
      if (currentUser != null) {
        bioEditingController!.text = currentUser!.bio ?? '';
        editNameEditingController!.text = currentUser!.name;
        lavelEditingController!.text = currentUser!.level ?? '';
        phoneEditingController!.text = currentUser!.phone ?? '';
      }
    });
  }

  // Navigations configuration
  _initialScreensSettings(User? user) async {
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
          .collection(firebaseCampusBuzzUser)
          .doc(currentId)
          .get();

      if (result.data() != null) {
        currentUser = CampusBuzzUser.fromDocument(result);
      } else {
        logOut();
        CustomSnackBar.showSnackBAr(
          context: Get.context,
          title: 'Warning!',
          message:
              'No user associated to email ${_auth.currentUser!.email} in our database!, you might try to create another account.',
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
        debugPrint(
          'No user associated to email ${_auth.currentUser!.email} in our database!, you might try to create another account.',
        );
      }

      update();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void logOut() async {
    await _auth.signOut();
    obscureText = false;
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
        await _auth.signInWithEmailAndPassword(
          email: emailEditingController.text.trim(),
          password: passwordEditingController.text.trim(),
        );
        QuerySnapshot<Map<String, dynamic>> result = await FirebaseService
            .firebaseFirestore
            .collection(firebaseCampusBuzzUser)
            .where('email', isEqualTo: emailEditingController.text.trim())
            .get();

        if (result.docs.isEmpty) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBAr(
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
          CustomSnackBar.showSnackBAr(
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
        // currentUser = CampusBuzzUser.fromDocument(result.docs.first);
      } on FirebaseAuthException catch (err) {
        CustomFullScreenDialog.cancleDialog();
        // debugPrint(err.message);
        CustomSnackBar.showSnackBAr(
          context: Get.context,
          title: "About user",
          message: err.message.toString(),
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      } catch (e) {
        CustomSnackBar.showSnackBAr(
          context: Get.context,
          title: "About user",
          message: "Something went wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
        CustomFullScreenDialog.cancleDialog();
      }
      update();
    } else if (provider == 1) {
      // register
      CustomFullScreenDialog.showDialog();
      // get city name
      String city = await getCurrentCity();

      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: emailEditingController.text.trim(),
          password: passwordEditingController.text.trim(),
        );
        if (credential.user == null) {
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBAr(
            context: Get.context,
            title: 'Warning!',
            message: 'We can\'t register you at the moment!',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
          return;
        }
        final campusBuzzUser = CampusBuzzUser(
          userId: credential.user!.uid,
          email: emailEditingController.text.trim(),
          isOnline: true,
          isStaff: false,
          isAdmin: false,
          notification: true,
          createdAt: Timestamp.now(),
          followers: [],
          following: [],
          pushToken: '',
          isCompleteness: false,
          isVerified: false,
          location: city,
          name: nameEditingController.text.trim(),
        );

        await FirebaseService.createUserInFirestore(
                campusBuzzUser, credential.user!.uid)
            .whenComplete(() async {});

        update();
      } on FirebaseAuthException catch (err) {
        CustomFullScreenDialog.cancleDialog();
        debugPrint(
            'this is the error codedeeeeeeeeeeeeeeeeeeeeeeeeeee ${err.code}');
        if (err.code == 'INVALID_LOGIN_CREDENTIALS') {
          CustomSnackBar.showSnackBAr(
            context: Get.context,
            title: "About user",
            message: 'Your email or password is incorrect!',
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
          );
        }
        CustomSnackBar.showSnackBAr(
          context: Get.context,
          title: "About user",
          message: err.message.toString(),
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
      } catch (e) {
        CustomSnackBar.showSnackBAr(
          context: Get.context,
          title: "About user",
          message: "Something went wrong, try again later!",
          backgroundColor:
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
        );
        CustomFullScreenDialog.cancleDialog();
      }
      update();
    } else {
      return;
    }
    clearTextControllers();
    update();
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
        await _collectionReference.doc(_auth.currentUser!.uid).update({
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
              ? currentUser!.bio
              : lavelEditingController!.text.trim(),
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
          Get.back();
        });
        await fetchUserDetails(_auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBAr(
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

// update if user likes or doesn't like push notification
  void updateNotification() async {
    if (currentUser != null) {
      CustomFullScreenDialog.showDialog();
      try {
        await _collectionReference.doc(_auth.currentUser!.uid).update({
          'notification': currentUser!.notification ? false : true,
        }).whenComplete(() {
          CustomFullScreenDialog.cancleDialog();
        });
        await fetchUserDetails(_auth.currentUser!.uid);
        update();
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        CustomSnackBar.showSnackBAr(
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
      CustomSnackBar.showSnackBAr(
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
            await _collectionReference.doc(_auth.currentUser!.uid).update({
              'imageUrl': downloadedImage,
            }).whenComplete(() {
              CustomFullScreenDialog.cancleDialog();
            });
          }

          // update the user image field in firestore
          await fetchUserDetails(_auth.currentUser!.uid);

          isImagePicked = false;
          pickedImagePath = null;
          update();
        } catch (e) {
          log(e.toString());
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBAr(
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
            await _collectionReference.doc(_auth.currentUser!.uid).update({
              'imageUrl': downloadedImage,
            }).whenComplete(() {
              CustomFullScreenDialog.cancleDialog();
            });
          }

          await fetchUserDetails(_auth.currentUser!.uid);
          isImagePicked = false;
          pickedImagePath = null;
          update();
        } catch (e) {
          log(e.toString());
          CustomFullScreenDialog.cancleDialog();
          CustomSnackBar.showSnackBAr(
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

  Stream<List<CampusBuzzUser>> _streamTweetBuzz(){
    return _collectionReference.snapshots().map((query) => query.docs.map((user) => CampusBuzzUser.fromDocument(user)).toList());
  }

  
}
