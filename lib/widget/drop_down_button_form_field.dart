import 'package:flutter/material.dart';

class CustomDropdownButtonFormField extends StatefulWidget {
  const CustomDropdownButtonFormField({
    Key? key,
    this.items,
    this.hint,
    this.label,
    this.value,
    this.onChanged,
    this.validator,
    this.suffixIcon,
  }) : super(key: key);

  final Widget? hint;
  final String? value;
  final Widget? label;
  final void Function(dynamic)? onChanged;
  final List<DropdownMenuItem>? items;
  final String? Function(dynamic)? validator;
  final Widget? suffixIcon;

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
      borderRadius: BorderRadius.circular(16.0),
      menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
      decoration: InputDecoration(
        label: widget.value == null ? null : widget.label,
        suffixIcon: widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}
