import 'dart:async';

import 'package:get/get.dart';

import '../documents/programs_page.dart';


class AdvertController extends GetxController {
  late Timer timer;

  @override
  void onInit() {
    super.onInit();
    timer = Timer(const Duration(seconds: 5), navigaToPage);
    
  }

  void navigaToPage() {
    Get.offNamed(ProgramsPage.routeName);
  }
}
