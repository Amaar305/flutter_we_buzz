import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/sponsor/sponsor_page.dart';

import '../../utils/constants.dart';
import '../../widgets/home/custom_tab_bar.dart';
import 'products_widget.dart';
import 'users_sponsor_chart_controller.dart';

class UsersSponsorChartPage extends GetView<SponsorChartController> {
  const UsersSponsorChartPage({super.key});
  static const String routeName = '/sponsor-chart-page';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your products'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Get.toNamed(SponsorPage.routeName),
        ),
        body: Padding(
          padding: kPadding,
          child: Column(
            children: [
              CustomTabBar(list: controller.tabTitles),
              const CustomTabBarView(children: [
                MyProducts(productType: ProductType.ongoing),
                MyProducts(productType: ProductType.expired),
                MyProducts(productType: ProductType.notPaid),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}




// PieChart(
//                       PieChartData(
//                         sectionsSpace: 0,
//                         centerSpaceRadius: 40,
//                         sections: controller.getChartSections(sponsor),
//                         borderData: FlBorderData(show: false),
//                         centerSpaceColor: Colors.white,
//                         pieTouchData: PieTouchData(
//                           touchCallback: (p0, p1) {},
//                         ),
//                       ),
//                     )