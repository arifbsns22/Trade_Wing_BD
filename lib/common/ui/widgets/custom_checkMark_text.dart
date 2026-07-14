import 'package:flutter/material.dart';

class CustomCheckMarkText extends StatelessWidget {
  const CustomCheckMarkText({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(text),
      ],
    );
  }
}
