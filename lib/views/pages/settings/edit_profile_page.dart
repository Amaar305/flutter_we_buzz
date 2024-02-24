import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/home/my_buttons.dart';
import '../../widgets/home/my_drop_button.dart';
import '../../widgets/home/my_textfield.dart';
import '../dashboard/my_app_controller.dart';
import '../documents/levels/levels_list.dart';
import 'controllers/edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});
  static const routeName = '/edit-profile-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: kPadding,
        child: Form(
          key: controller.formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //  Profile image
                  Stack(
                    children: [
                      GetBuilder<EditProfileController>(
                        builder: (_) {
                          if (controller.isImagePicked &&
                              controller.pickedImagePath != null) {
                            return CircleAvatar(
                              backgroundImage:
                                  FileImage(controller.pickedImagePath!),
                              radius: MediaQuery.of(context).size.height * 0.08,
                            );
                          } else {
                            return FullScreenWidget(
                              disposeLevel: DisposeLevel.Medium,
                              backgroundIsTransparent: true,
                              child: CircleAvatar(
                                radius:
                                    MediaQuery.of(context).size.height * 0.08,
                                backgroundImage: CachedNetworkImageProvider(
                                  AppController.instance.currentUser != null
                                      ? AppController.instance.currentUser!
                                                  .imageUrl !=
                                              null
                                          ? AppController
                                              .instance.currentUser!.imageUrl!
                                          : defaultProfileImage
                                      : defaultProfileImage,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            controller.uploadDeleteUpdateUserProfileUrl();
                          },
                          child: const CircleAvatar(
                            child: Icon(Icons.image_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //  Bio field
                  MyInputField(
                    controller: controller.bioEditingController,
                    hintext: 'Bio',
                    iconData: Icons.info,
                    label: 'Bio',
                  ),

                  //  Name field
                  MyInputField(
                    controller: controller.editNameEditingController,
                    hintext: 'Name',
                    label: 'Full Name',
                    iconData: Icons.person,
                    validator: (value) {
                      if (value!.length < 5) {
                        return 'Name must be greather than 5';
                      }

                      if (value.length > 15) {
                        return 'Name must be less than 15';
                      }
                      return null;
                    },
                  ),

                  //  Username field
                  MyInputField(
                    controller: controller.usernameEditingController,
                    hintext: 'Username',
                    label: 'Your Username',
                    iconData: Icons.supervised_user_circle,
                    validator: (value) {
                      if (value!.length < 5) {
                        return 'Username must be greater than 6 characters';
                      }
                      if (value.length > 15) {
                        return 'Username must be less than 20 characters';
                      }

                      final isExit = AppController.instance.weBuzzUsers.any(
                          (user) =>
                              user.username == value &&
                              user.username !=
                                  AppController.instance.currentUser!.username);
                      if (isExit) {
                        return 'Username has been taken';
                      }
                      return null;
                    },
                  ),

                  // Phone no. field
                  MyInputField(
                    controller: controller.phoneEditingController,
                    hintext: 'Phone',
                    label: 'Phone No',
                    iconData: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (!value!.isPhoneNumber) {
                        return 'Not a phone number!';
                      }
                      if (value.length < 11 || value.length > 11) {
                        return 'Invalid phone number!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  //  Select level
                  GetBuilder<AppController>(
                    builder: (control) {
                      final me = control.currentUser!;

                      return MyDropDownButtonForm(
                        initialValue:
                            levels.contains(me.level) ? me.level : null,
                        items: levels,
                        label: 'Lavel',
                        hintext: 'Select Level',
                        onChanged: (value) {
                          controller.lavelEditingController.text = value!;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  //  Update button
                  MyRegistrationButton(
                    title: 'Edit',
                    secondaryColor: Colors.white,
                    onPressed: () {
                      final isValid =
                          controller.formKey.currentState!.validate();
                      FocusScope.of(context).unfocus();

                      if (isValid) {
                        controller.formKey.currentState!.save();
                        controller.editUserInfo();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
