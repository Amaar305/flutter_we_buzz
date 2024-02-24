import 'package:flutter/material.dart';

class CreateBuzzTextFormField extends StatelessWidget {
  const CreateBuzzTextFormField({super.key, required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Start a buzz...',
      ),
      maxLength: 250,
      maxLines: 4,
    );
  }
}
