import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/we_buzz_model.dart';

import '../../../model/we_buzz_user_model.dart';
import '../dashboard/my_app_controller.dart';

class SearchUsersController extends GetxController {
  RxList<WeBuzzUser> users = RxList([]);
  var isSearch = false.obs;
  late TextEditingController searchEditingController;
  late double deviceHeight;

  @override
  void onInit() {
    super.onInit();
    searchEditingController = TextEditingController();
    deviceHeight = MediaQuery.of(Get.context!).size.height;
  }

  void searchUser(String name) {
    isSearch.value = true;

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
    } else {
      isSearch.value = false;
    }
  }

  List<SponsorItem> sponsorImages() {
    List<SponsorItem> images = [];
    List<WeBuzz> sponsors = [];

       

    for (var sponsor in sponsors) {
      for (var image in sponsor.images!) {
        images.add(SponsorItem(
          image: image,
          docId: sponsor.docId,
          created: sponsor.createdAt,
        ));
      }
    }
    return images;
  }

  @override
  void onClose() {
    super.onClose();
    searchEditingController.dispose();
  }
}

class SponsorItem {
  final String image;
  final String docId;
  final Timestamp created;

  SponsorItem({
    required this.image,
    required this.docId,
    required this.created,
  });
}
