import 'package:flutter/material.dart';

class NoBuzzPage extends StatelessWidget {
  const NoBuzzPage({
    super.key,
    required this.title,
    this.image = 'assets/images/inbox.png',
  });

  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.start,
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 350,
            padding: const EdgeInsets.all(32),
            child: Image.asset(image),
          ),
        ],
      ),
    );
  }
}
