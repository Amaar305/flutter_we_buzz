import 'package:flutter/material.dart';

class MyDropDownButtonForm extends StatelessWidget {
  const MyDropDownButtonForm({
    super.key,
    required this.items,
    required this.label,
    this.onChanged,
    this.validator,
    this.initialValue,
    required this.hintext,
    this.icon = Icons.work,
  });

  final String label;
  final String hintext;
  final String? initialValue;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: DropdownButtonFormField(
              value: initialValue,
              items: items.map((p) {
                return DropdownMenuItem<String>(
                  value: p,
                  child: Text(p),
                );
              }).toList(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintext,
                errorStyle: const TextStyle(fontSize: 14, color: Colors.black),
                prefixIcon: Icon(icon),
              ),
              isExpanded: true,
              onChanged: onChanged,
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
