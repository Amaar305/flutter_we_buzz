import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintext,
    this.obscure,
    this.validator,
    this.onTap,
    this.keyboardType,
  });
  final TextEditingController? controller;
  final String hintext;
  final bool? obscure;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: obscure!
      //     ? const EdgeInsets.symmetric(vertical: 15)
      //     : const EdgeInsets.fromLTRB(0, 30, 0, 0),
      margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintext,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          suffix: obscure != null
              ? GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    obscure!
                        ? Icons.remove_red_eye_outlined
                        : Icons.highlight_off_rounded,
                  ),
                )
              : null,
        ),
        obscureText: obscure ?? false,
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }
}
