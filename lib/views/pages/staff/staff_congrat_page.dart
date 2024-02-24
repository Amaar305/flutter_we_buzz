import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constants.dart';

class StaffCongratulationPage extends StatelessWidget {
  const StaffCongratulationPage({super.key});

  static const String routeName = '/staff-c-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: kPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/sdtrophy.png', height: 300),
            32.height,
            Text('Yah! Staff', style: boldTextStyle(size: 20)),
            16.height,
            Text(
              'Congratulation, you are now a saff of Webuzz!, yeah, you can suspend a user and buzz!',
              style: secondaryTextStyle(),
              textAlign: TextAlign.center,
            ).paddingSymmetric(vertical: 8, horizontal: 60),
            50.height,
          ],
        ),
      ),
    );
  }
}
