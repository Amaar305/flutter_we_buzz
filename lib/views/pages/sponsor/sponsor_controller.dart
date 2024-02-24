import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/buzz_enum.dart';
import '../../../model/transaction/transaction.dart';
import '../../../model/transaction/transaction_type.dart';
import '../../../model/we_buzz_model.dart';
import '../../../services/firebase_service.dart';
import '../../../services/paypal_services.dart';
import '../../utils/constants.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/method_utils.dart';
import '../create/hashtag_sytem.dart';
import '../dashboard/my_app_controller.dart';

const double _price = 500.0;

class SponsorController extends GetxController {
  late GlobalKey<FormState> formKey;

  late TextEditingController textEditingController;
  late TextEditingController webUrlEditingController;
  late TextEditingController phoneEditingController;

  bool hasPaid = false;
  void updatePaid() {
    hasPaid = true;
    update();
  }

  @override
  void onInit() {
    super.onInit();

    formKey = GlobalKey<FormState>();

    textEditingController = TextEditingController();
    webUrlEditingController = TextEditingController();
    phoneEditingController = TextEditingController();
  }

  double amount = 0.0;
  int duration = 1;

  bool imagePicked = false;

  List<String> urlImages = [];
  List<File> fileImages = [];

  void seletImages() async {
    CustomFullScreenDialog.showDialog();
    try {
      fileImages = await pickImages().whenComplete(() {
        CustomFullScreenDialog.cancleDialog();
        imagePicked = true;
      });
      if (fileImages.isEmpty) imagePicked = false;
      update();
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      toast('Error picking images');
    }
  }

  void setAmount(int duration) {
    double actualAmount = _price * duration;
    amount = actualAmount;
    this.duration = duration;
    update();
  }

  void submit(context) async {
    CustomFullScreenDialog.showDialog();
    // Getting user info
    final loggedInUser = FirebaseAuth.instance.currentUser;
    String location = AppController.instance.city;

    try {
      if (fileImages.length > 3 || fileImages.length < 3) {
        CustomFullScreenDialog.cancleDialog();
        toast('Images must only be 3');
        fileImages.clear();
        return;
      }

      if (amount < 500) {
        CustomFullScreenDialog.cancleDialog();
        toast('Pick duration please');
        return;
      }
      String ref = PayStackServices.generateRef();

      final id = MethodUtils.generatedId;

      PayStackServices.payment(
        ref: ref,
        context: context,
        prizeToPay: (amount * 100).toString(),
        customerEmail: AppController.instance.currentUser!.email,
        onSuccess: () async {
          updatePaid();
          if (!hasPaid) return;
          log('Payment successful');

          try {
            // Upload the images to the cloud storage
            for (File image in fileImages) {
              final downloadedFile = await FirebaseService.uploadImage(image,
                  "sponsor/${DateTime.now().millisecondsSinceEpoch}/$id/");

              if (downloadedFile != null) {
                urlImages.add(downloadedFile);
              }
            }

            final hashtags = hashTagSystem(textEditingController.text);
            final urls = extractUrls(textEditingController.text);

            WeBuzz buzz = WeBuzz(
              id: id,
              docId: '',
              authorId: loggedInUser!.uid,
              content: textEditingController.text.trim(),
              createdAt: Timestamp.now(),
              reBuzzsCount: 0,
              buzzType: BuzzType.sponsor.name,
              hashtags: hashtags,
              location: location,
              source: Platform.isAndroid ? 'Android' : 'IOS',
              imageUrl: null,
              originalId: '',
              likesCount: 0,
              isRebuzz: false,
              repliesCount: 0,
              isCampusBuzz: false,
              links: urls,
              amount: amount,
              duration: duration,
              websiteUrl: webUrlEditingController.text.trim(),
              isSponsor: true,
              whatsapp: phoneEditingController.text.trim(),
              images: urlImages,
              expired: false,
              hasPaid: hasPaid,
            );

            final docId = await FirebaseService.createBuzzInFirestore(buzz)
                .whenComplete(() => CustomFullScreenDialog.cancleDialog());

            CustomSnackBar.showSnackBar(
              context: context,
              title: 'Success',
              message: 'Payment complete! Reference: $ref',
              backgroundColor: kPrimary.withOpacity(0.7),
            );

            if (docId != null) {
              TransactionModel transactionModel = TransactionModel(
                id: MethodUtils.generatedId,
                reference: ref,
                transactionItemId: docId,
                amount: amount,
                createdAt: Timestamp.now(),
                transactionType: TransactionType.sponsor,
              );

              await FirebaseService.createTransaction(transactionModel);
            }
            Get.back();
            Get.back();
          } catch (e) {
            CustomFullScreenDialog.cancleDialog();
            log(e);
            toast('Something went wrong! try again or contact our staff');
          }
        },
      );
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log('Error trying to create a sponsor');
      toast('Error trying to create a sponsor');
      log(e.toString());
    }
  }

  List<Weeks> weeks = [
    Weeks(title: ' One Week', duration: 1),
    Weeks(title: 'Two Weeks', duration: 2),
    Weeks(title: 'Three Weeks', duration: 3),
    Weeks(title: 'Four Weeks', duration: 4),
    Weeks(title: 'Five Weeks', duration: 5),
  ];

  Future<List<File>> pickImages() async {
    List<File> images = [];

    try {
      // Clearing the file images before assigning it again
      fileImages.clear();
      imagePicked = !imagePicked;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        for (PlatformFile file in result.files) {
          images.add(File(file.path!));
        }
      }
    } catch (e) {
      log('Error picking images: $e');
    }

    return images;
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
    webUrlEditingController.dispose();
    phoneEditingController.dispose();
  }

  void updateSponsor(context, WeBuzz sponsor) async {
    try {
      final hashtags = hashTagSystem(textEditingController.text);
      final urls = extractUrls(textEditingController.text);

      String ref = PayStackServices.generateRef();

      PayStackServices.payment(
        ref: ref,
        context: context,
        prizeToPay: (amount * 100).toString(),
        customerEmail: AppController.instance.currentUser!.email,
        onSuccess: () async {
          updatePaid();
          if (!hasPaid) return;
          log('Payment successful');

          TransactionModel transaction = TransactionModel(
            id: MethodUtils.generatedId,
            reference: ref,
            transactionItemId: sponsor.docId,
            amount: (sponsor.amount! + amount),
            createdAt: Timestamp.now(),
            transactionType: TransactionType.sponsor,
          );

          try {
            await FirebaseService.createTransaction(transaction).whenComplete(
              () async {
                await FirebaseService.updateBuzz(
                  sponsor.docId,
                  {
                    'content': textEditingController.text.trim(),
                    if (webUrlEditingController.text.isNotEmpty)
                      "websiteUrl": webUrlEditingController.text.trim(),
                    "whatsapp": phoneEditingController.text.trim(),
                    "expired": false,
                    "amount": (sponsor.amount! + amount),
                    "duration": (sponsor.duration! + duration),
                    'hashtags': hashtags,
                    'links': urls,
                    "hasPaid": true,
                  },
                );

                CustomSnackBar.showSnackBar(
                  context: context,
                  title: 'Success',
                  message: 'Payment complete! Reference: $ref',
                  backgroundColor: kPrimary.withOpacity(0.7),
                );
              },
            );
          } catch (e) {
            log(e);
            toast('Something went try again or contact our staff');
          }
        },
      );
    } catch (e) {
      CustomSnackBar.showSnackBar(
        context: context,
        title: 'Error',
        message: 'Error trying to update a sponsor',
        backgroundColor: kPrimary.withOpacity(0.7),
      );
      log("Error trying to update a sponsor");
      log(e);
    }
  }
}

class Weeks {
  final String title;
  final int duration;

  Weeks({required this.title, required this.duration});
}
