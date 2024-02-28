import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constants.dart';

class ClassCongratulationPage extends StatelessWidget {
  const ClassCongratulationPage({super.key});

  static const String routeName = '/class-c-page';

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
            Text('Yah! Class Rep', style: boldTextStyle(size: 20)),
            16.height,
            Text(
              'Congratulation, you are class rep on Webuzz!, yeah, you can assign lecture notes and past questions!',
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
