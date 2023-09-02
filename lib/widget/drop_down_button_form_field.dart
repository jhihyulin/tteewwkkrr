import 'package:flutter/material.dart';

class CustomDropdownButtonFormField extends StatefulWidget {
  const CustomDropdownButtonFormField({
    Key? key,
    this.items,
    this.hint,
    this.value,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  final Widget? hint;
  final String? value;
  final void Function(dynamic)? onChanged;
  final List<DropdownMenuItem>? items;
  final String? Function(dynamic)? validator;

  @override
  State<CustomDropdownButtonFormField> createState() =>
      _CustomDropdownButtonFormField();
}

class _CustomDropdownButtonFormField
    extends State<CustomDropdownButtonFormField> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      hint: widget.hint,
      value: widget.value,
      onChanged: widget.onChanged,
      items: widget.items,
      validator: widget.validator,
    );
  }
}