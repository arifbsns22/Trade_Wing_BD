import 'package:flutter/material.dart';

class CheckBoxWithTitle extends StatefulWidget {
  const CheckBoxWithTitle({
    super.key,
    required this.value,
    required this.onChange,
    required this.title,
  });

  final bool value;
  final ValueChanged onChange;
  final Text title;

  @override
  State<CheckBoxWithTitle> createState() => _CheckBoxWithTitleState();
}

class _CheckBoxWithTitleState extends State<CheckBoxWithTitle> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: widget.value, onChanged: widget.onChange),
        widget.title,
      ],
    );
  }
}
