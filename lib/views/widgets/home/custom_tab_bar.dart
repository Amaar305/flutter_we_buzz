import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.list,
    this.onTap,
  });

  final List<String> list;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
      ),
      child: TabBar(
        onTap: onTap,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        tabs: list.map((e) => Tab(text: e)).toList(),
      ),
    );
  }
}

class CustomTabBarView extends StatelessWidget {
  const CustomTabBarView({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(children: children),
    );
  }
}
