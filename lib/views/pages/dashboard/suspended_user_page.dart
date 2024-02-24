import 'package:flutter/material.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class SuspendedUserPage extends StatelessWidget {
  const SuspendedUserPage({super.key});
  static const String routeName = '/suspended-user-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: kPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Suspended!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              10.height,
              const Text(
                'You are suspended from using Webuzz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
