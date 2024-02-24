import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../model/transaction/transaction.dart';
import '../../../model/transaction/transaction_type.dart';
import '../../../services/firebase_service.dart';
import '../../../services/paypal_services.dart';
import '../../utils/constants.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/method_utils.dart';
import 'my_app.dart';
import 'my_app_controller.dart';

class GraduentController extends GetxController {
  final control = AppController.instance;
  final double _price = 5000.00;
  var hasPaid = false.obs;

  Future<void> onSuccess(context, ref) async {
    try {
      // Create instance of transaction
      TransactionModel transactionModel = TransactionModel(
        id: MethodUtils.generatedId,
        reference: ref,
        transactionItemId: control.currentUser!.userId,
        amount: _price,
        createdAt: Timestamp.now(),
        transactionType: TransactionType.graduant,
      );

      // Upload it to the firestore
      await FirebaseService.createTransaction(transactionModel);

      // update user data
      await FirebaseService.updateUserData(
        {
          'hasPaid': true,
        },
        control.currentUser!.userId,
      ).whenComplete(() async {
        CustomSnackBar.showSnackBar(
          context: context,
          title: 'Success',
          message:
              'Congratulation You have successifully paid for premium version 🐝.',
          backgroundColor: kPrimary.withOpacity(0.5),
        );
        hasPaid.value = true;
      });
      // update user data
      await control.fetchUserDetails(control.currentUser!.userId);
    } catch (e) {
      CustomSnackBar.showSnackBar(
        context: context,
        title: 'Subscription Failed!',
        message: 'Something went wrong! contact our staff',
        backgroundColor: kPrimary.withOpacity(0.5),
      );
      log(e.toString());
      Get.back();
    }
  }

  void pay(context) async {
    try {
      final user = control.currentUser;
      if (user == null) return;

      final ref = PayStackServices.generateRef();

      PayStackServices.payment(
        ref: ref,
        customerEmail: user.email,
        prizeToPay: (_price * 100).toString(),
        context: context,
        onSuccess: () => onSuccess(context, ref),
      );
    } catch (e) {
      log(e.toString());
      CustomSnackBar.showSnackBar(
        context: context,
        title: 'Subscription Failed!',
        message:
            'Error trying to purchase premium version.\n If you got charged try and contact our staff.',
        backgroundColor: kPrimary.withOpacity(0.5),
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
    if (hasPaid.isTrue) {
      Get.offAll(() => const MyBottomNavBar());
    }
  }
}
