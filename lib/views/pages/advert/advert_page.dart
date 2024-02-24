import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/we_buzz_model.dart';
import 'package:hi_tweet/services/firebase_constants.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:hi_tweet/views/widgets/home/cards/sponsor_card_widget.dart';

import '../home/reply/reply_page.dart';

class AdvertPage extends StatefulWidget {
  const AdvertPage(
      {super.key, required this.advert, required this.navigaToPage});
  final WeBuzz advert;
  final void Function() navigaToPage;

  @override
  State<AdvertPage> createState() => _AdvertPageState();
}

class _AdvertPageState extends State<AdvertPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 15), widget.navigaToPage);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _timer.cancel();

        widget.navigaToPage();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: kPadding,
            child: StreamBuilder<WeBuzz>(
                stream: FirebaseService.firebaseFirestore
                    .collection(firebaseWeBuzzCollection)
                    .doc(widget.advert.docId)
                    .snapshots()
                    .map((event) => WeBuzz.fromDocumentSnapshot(event)),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.done:
                    case ConnectionState.active:
                      if (snapshot.data != null) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => Get.toNamed(
                                  RepliesPage.routeName,
                                  arguments: widget.advert,
                                ),
                                child:
                                    SponsorCard(normalWebuzz: snapshot.data!),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => Get.toNamed(
                                  RepliesPage.routeName,
                                  arguments: widget.advert,
                                ),
                                child: SponsorCard(normalWebuzz: widget.advert),
                              ),
                            ],
                          ),
                        );
                      }
                  }
                }),
          ),
        ),
      ),
    );
  }
}
