import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/home/my_button.dart';
import '../../widgets/home/my_textfield.dart';
import '../dashboard/my_app_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  static const routeName = '/edit-profile-page';

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: kDefaultAppPadding,
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GetBuilder<AppController>(builder: (_) {
                    if (controller.isImagePicked &&
                        controller.pickedImagePath != null) {
                      return CircleAvatar(
                        backgroundImage: FileImage(controller.pickedImagePath!),
                        radius: MediaQuery.of(context).size.height * 0.08,
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          controller.uploadDeleteUpdateUserProfileUrl();
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: MediaQuery.of(context).size.height * 0.08,
                              backgroundImage: CachedNetworkImageProvider(
                                controller.currentUser != null
                                    ? controller.currentUser!.imageUrl != null
                                        ? controller.currentUser!.imageUrl!
                                        : 'https://firebasestorage.googleapis.com/v0/b/my-hi-tweet.appspot.com/o/933-9332131_profile-picture-default-png.png?alt=media&token=7c98e0e7-c3bf-454e-8e7b-b0ec4b2ec900&_gl=1*1w37gdj*_ga*MTUxNDc4MTA2OC4xNjc1OTQwOTc4*_ga_CW55HF8NVT*MTY5ODMxOTk3Mi42MS4xLjE2OTgzMjAwMzEuMS4wLjA.'
                                    : 'https://firebasestorage.googleapis.com/v0/b/my-hi-tweet.appspot.com/o/933-9332131_profile-picture-default-png.png?alt=media&token=7c98e0e7-c3bf-454e-8e7b-b0ec4b2ec900&_gl=1*1w37gdj*_ga*MTUxNDc4MTA2OC4xNjc1OTQwOTc4*_ga_CW55HF8NVT*MTY5ODMxOTk3Mi42MS4xLjE2OTgzMjAwMzEuMS4wLjA.',
                              ),
                            ),
                            const Positioned(
                              child: CircleAvatar(
                                child: Icon(Icons.image_outlined),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  }),
                  MyTextField(
                    controller: controller.bioEditingController!,
                    hintext: 'Bio',
                  ),
                  MyTextField(
                    controller: controller.editNameEditingController,
                    hintext: 'Name',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name cannot be empty!';
                      }
                      if (value.length < 6 || value.length > 12) {
                        return 'Name should be > 6 and < 12 characters';
                      }
                      return null;
                    },
                  ),
                  MyTextField(
                    controller: controller.phoneEditingController!,
                    hintext: 'Phone',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone cannot be empty!';
                      }
                      if (value.length < 11 || value.length > 11) {
                        return 'Invalid phone number!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GetBuilder<AppController>(
                    builder: (controller) {
                      final me = controller.weBuzzUsers.firstWhere((user) =>
                          user.userId ==
                          FirebaseAuth.instance.currentUser!.uid);
                      return DropdownButtonFormField<String>(
                        value: me.level == null
                            ? null
                            : _levels.contains(me.level)
                                ? me.level
                                : null,
                        items: _levels.map((level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: (value) {
                          controller.lavelEditingController!.text = value!;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  MyButton(
                    text: 'Edit',
                    onPressed: () {
                      final isValid = _formKey.currentState!.validate();
                      FocusScope.of(context).unfocus();

                      if (isValid) {
                        _formKey.currentState!.save();
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

final List<String> _levels = [
  '100',
  '200',
  '300',
  '400',
  '500',
];
