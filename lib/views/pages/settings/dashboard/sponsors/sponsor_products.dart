import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/home/cards/sponsor_card_widget.dart';
import '../../../../widgets/home/custom_tab_bar.dart';
import '../../../chart/products_widget.dart';
import 'sponsor_controller.dart';

class SponsorProductsPage extends GetView<SponsorDashboadController> {
  const SponsorProductsPage({super.key});
  static const String routeName = '/sponsor-products-page';
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All sponsors'),
        ),
        body: Padding(
          padding: kPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTabBar(list: controller.tabTitles),
              CustomTabBarView(children: [
                DashboadSponsorWidget(
                  controller: controller,
                  productType: ProductType.ongoing,
                ),
                DashboadSponsorWidget(
                  controller: controller,
                  productType: ProductType.expired,
                ),
                DashboadSponsorWidget(
                  controller: controller,
                  productType: ProductType.notPaid,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboadSponsorWidget extends StatelessWidget {
  const DashboadSponsorWidget({
    super.key,
    required this.controller,
    required this.productType,
  });

  final SponsorDashboadController controller;
  final ProductType productType;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // list of sponsors that's belong to the current user
        final sponsors = controller.sponsorproducts.where((webuzz) {
          if (productType == ProductType.ongoing) {
            return webuzz.validSponsor();
          } else if (productType == ProductType.expired) {
            return webuzz.isSponsor && webuzz.expired;
          } else if (productType == ProductType.notPaid) {
            return webuzz.isSponsor && !webuzz.hasPaid;
          } else {
            return webuzz.isSponsor == true;
          }
        }).toList();

        return ListView.builder(
          itemCount: sponsors.length,
          itemBuilder: (context, index) {
            final buzz = sponsors[index];
            return SponsorCard(
              normalWebuzz: buzz,
              chart: true,
            );
          },
        );
      },
    );
  }
}
