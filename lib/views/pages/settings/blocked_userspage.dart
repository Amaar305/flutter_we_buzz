import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import '../dashboard/my_app_controller.dart';

late double _deviceHeight;
late double _deviceWidth;

class BlockedUsersPrivacyPage extends StatelessWidget {
  const BlockedUsersPrivacyPage({super.key});
  static const String routeName = '/blocked-user-privacy-page';

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
                'Blocked Users',
                secondaryAction: const BackButton(),
              ),
              _userListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userListView() {
    return Expanded(
      child: GetX<AppController>(
        builder: (controller) {
          return ListView.builder(
            itemCount: controller.weBuzzUsers.length,
            itemBuilder: (context, index) {
              return Text('User $index');
            },
          );
        },
      ),
    );
  }
}
