import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../services/firebase_service.dart';

class SettingsController extends GetxController {
  final _getStorage = GetStorage();
  final storageKey = 'isDarkMode';

  final _auth = FirebaseAuth.instance;

  ThemeMode getThemeMode() {
    return isSavedDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isSavedDarkMode => _getStorage.read(storageKey) ?? false;

  void savedDarkMode(bool isDarkMode) {
    _getStorage.write(storageKey, isDarkMode);
  }

  void changeThemeMode() {
    Get.changeThemeMode(isSavedDarkMode ? ThemeMode.light : ThemeMode.dark);
    savedDarkMode(!isSavedDarkMode);
    update();
  }

  void logout() async {
    await FirebaseService.updateActiveStatus(false);

    await _auth.signOut();
    update();
  }
}
