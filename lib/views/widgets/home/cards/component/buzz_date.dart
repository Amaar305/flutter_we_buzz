import 'package:flutter/material.dart';

import '../../../../../model/we_buzz_model.dart';
import '../../../../utils/method_utils.dart';

class BuzzDate extends StatelessWidget {
  const BuzzDate({
    super.key,
    required this.normalWebuzz,
  });

  final WeBuzz normalWebuzz;

  @override
  Widget build(BuildContext context) {
    return Text(
      MethodUtils.formatDate(normalWebuzz.createdAt),
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
    );
  }
}
