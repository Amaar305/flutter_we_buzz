import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constants.dart';
import '../../widgets/setting/first_three_setting_tiles.dart';
import '../../widgets/setting/second_three_setting_tiles.dart';
import '../../widgets/setting/third_setting_tiles.dart';
import '../dashboard/my_app_controller.dart';
import 'settings_controller.dart';

class SettingPage extends GetView<SettingsController> {
  const SettingPage({super.key});
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: kPadding.copyWith(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              8.height,
              const FirstThreeSettingTiles(),
              10.height,
              SecondThreeSettingTiles(controller: controller),
              const ThirdThreeSettingTiles(),
              TextButton(
                onPressed: () => AppController.instance.logOut(),
                child: const Text(
                  'LOG OUT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Version: 1.2.0'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
