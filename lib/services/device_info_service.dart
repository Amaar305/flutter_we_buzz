import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  void getDeviceInfo() async {
    var device = DeviceInfoPlugin();

    // check user's device platform
    if (Platform.isAndroid) {
      var androidInfo = await device.androidInfo;
      androidInfo.serialNumber;
    }
  }
}
