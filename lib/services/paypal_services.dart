
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../views/utils/constants.dart';
import '../views/utils/custom_snackbar.dart';
import '../views/utils/method_utils.dart';
import 'api_keys.dart';
// import 'api_keys.dart';

class PayStackServices {
  static void payment({
    required String ref,
    required String customerEmail,
    required String prizeToPay,
    required BuildContext context,
    required void Function() onSuccess,
  }) async {
    try {
      return await FlutterPaystackPlus.openPaystackPopup(
        publicKey: publicKey,
        // publicKey: 'pk_test_02fcd69542c9add7b5daf2c0970892ae9d26380a',
        context: context,
        secretKey: secretKey,
        // secretKey: 'sk_test_03fab301ee5491bbda48aa00b6834abc0b3d4fc7',
        currency: 'NGN',
        customerEmail: customerEmail,
        amount: prizeToPay,
        reference: ref,
        callBackUrl: "https://google.com",
        onClosed: () {
          log('Could\'nt finish payment');
          Get.back();
          CustomSnackBar.showSnackBar(
            context: context,
            title: 'Error',
            message: 'Could\'nt finish payment',
            backgroundColor: kPrimary.withOpacity(0.7),
          );
        },
        onSuccess: onSuccess,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  static String generateRef() {
    return MethodUtils.generatedId;
  }
}
