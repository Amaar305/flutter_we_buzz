import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintext,
    this.obscureText,
    this.validator,
    this.onTap,
    this.keyboardType,
  });
  final TextEditingController? controller;
  final String hintext;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          suffix: GestureDetector(
            onTap: onTap,
            child: obscureText != null
                ? obscureText!
                    ? const Icon(Icons.highlight_off_rounded)
                    : const Icon(Icons.remove_red_eye_outlined)
                : const SizedBox(),
          ),
        ),
        obscureText: obscureText != null && !obscureText!,
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }
}

class MyInputField extends StatelessWidget {
  const MyInputField({
    super.key,
    required this.controller,
    required this.hintext,
    required this.iconData,
    this.obscureText,
    this.validator,
    this.onTap,
    this.keyboardType,
    required this.label,
    this.padTop = 25.0, this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hintext;
  final IconData iconData;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final double padTop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padTop),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                errorStyle: const TextStyle(fontSize: 14, color: Colors.black),
                border: InputBorder.none,
                prefixIcon: Icon(iconData),
                suffix: GestureDetector(
                  onTap: onTap,
                  child: obscureText != null
                      ? obscureText!
                          ? const Icon(Icons.highlight_off_rounded)
                          : const Icon(Icons.remove_red_eye_outlined)
                      : const SizedBox(),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                hintText: hintext,
              ),
              obscureText: obscureText != null && !obscureText!,
              validator: validator,
              keyboardType: keyboardType,
            ),
          ),
        ],
      ),
    );
  }
}
