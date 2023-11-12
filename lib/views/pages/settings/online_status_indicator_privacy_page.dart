import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import '../dashboard/my_app_controller.dart';

late double _deviceHeight;
late double _deviceWidth;

class OnlineStatusIndicatorPrivacyPage extends StatelessWidget {
  const OnlineStatusIndicatorPrivacyPage({super.key});
  static const String routeName = '/onlineStatusIndicator-privacy-page';

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.height;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomAppBar(
                'Online status',
                secondaryAction: const BackButton(),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose who can see when you\'re online',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GetBuilder<AppController>(
                builder: (controller) {
                  return DropdownButtonFormField<String>(
                    value: controller.currentUser!.onlineStatusIndicator.name,
                    items: _dmPrivacySettings.map((privacy) {
                      return DropdownMenuItem<String>(
                        value: privacy,
                        child: Text(privacy),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) {
                      controller.updateUserOnlineStatusPrivacy(value!);
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

final List<String> _dmPrivacySettings = [
  'everyone',
  'followers',
  'following',
  'mutual',
];
