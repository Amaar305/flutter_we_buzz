import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../pages/view_profile/view_profile_controller.dart';
import '../../utils/constants.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: kblack,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class MyRegistrationButton extends StatelessWidget {
  const MyRegistrationButton({
    super.key,
    required this.title,
    this.onPressed,
    this.primaryColor = kblack,
    this.secondaryColor = kPrimary,
    this.toUpperCase = true,
  });

  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final void Function()? onPressed;
  final bool toUpperCase;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          toUpperCase ? title.toUpperCase() : title.capitalize!,
          style: TextStyle(
            fontSize: 18,
            color: secondaryColor,
          ),
        ),
      ),
    );
  }
}

class CustomMaterialButton extends StatelessWidget {
  const CustomMaterialButton({
    super.key,
    required this.title,
    this.onPressed,
  });

  final String title;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, color: kPrimary),
      ),
    );
  }
}



Widget followButton(isUserFollowed, WeBuzzUser user) {
  if (isUserFollowed) {
    return Container(
      height: 25,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: OutlinedButton(
        onPressed: () {
          ViewProfileController().unfollowUser(user.userId);
        },
        style: OutlinedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Following',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    );
  } else {
    return Container(
      height: 25,
      // width: 100,
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: kPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          ViewProfileController().followUser(user);
        },
        child: const Text(
          'Follow',
          style: TextStyle(color: kblack, fontSize: 13),
        ),
      ),
    );
  }
}
