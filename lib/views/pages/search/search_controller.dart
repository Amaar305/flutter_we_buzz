import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/we_buzz_user_model.dart';
import '../dashboard/my_app_controller.dart';

class SearchUsersController extends GetxController {
  RxList<WeBuzzUser> users = RxList([]);

  late TextEditingController searchEditingController;
  late double deviceHeight;

  @override
  void onInit() {
    super.onInit();
    searchEditingController = TextEditingController();
    deviceHeight = MediaQuery.of(Get.context!).size.height;
  }

  void searchUser(String name) {
    // convert the name to lowercase
    name = name.toLowerCase();
    if (name.length > 1) {
      final filteredUserLists = AppController.instance.weBuzzUsers
          .where(
            (user) =>
                user.name.toLowerCase().contains(name) ||
                user.username.toLowerCase().contains(name),
          )
          .toList();

      users.value = filteredUserLists;
    }
  }

  @override
  void onClose() {
    super.onClose();
    searchEditingController.dispose();
  }
}
