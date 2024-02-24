import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/services/paypal_services.dart';
import 'package:hi_tweet/views/pages/dashboard/my_app_controller.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/transaction/transaction.dart';
import '../model/transaction/transaction_type.dart';
import '../views/utils/constants.dart';
import '../views/utils/custom_snackbar.dart';
import '../views/utils/method_utils.dart';

const double _price = 2000.0;

class VerifyUserController extends GetxController {
  final control = AppController.instance;
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
        transactionType: TransactionType.verifyMe,
      );

      // Upload it to the firestore
      await FirebaseService.createTransaction(transactionModel);

      // update user data
      await FirebaseService.updateUserData(
        {
          'isVerified': true,
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
      log(e);
      toast('Something went wrong! try again or contact our staff');
      Get.back();
    }
  }

  void verifyMe(context) async {
    try {
      if (control.currentUser == null) return;
      if (control.currentUser!.isVerified) return;

      // Payment refrence
      String ref = PayStackServices.generateRef();

      // Pay with paypal
      PayStackServices.payment(
        ref: ref,
        customerEmail: control.currentUser!.email,
        prizeToPay: (_price * 100).toString(),
        context: context,
        onSuccess: () => onSuccess(context, ref),
      );
    } catch (e) {
      log(e);
      CustomSnackBar.showSnackBar(
        context: context,
        title: 'Subscription Failed!',
        message:
            'Error trying to purchase premium version.\n If you got charged try and contact our staff.',
        backgroundColor: kPrimary.withOpacity(0.5),
      );
    }
  }
}
