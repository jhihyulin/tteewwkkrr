import 'dart:async';

import 'package:flutter/material.dart';
import '../widget/text_field.dart';

class CustomAutocomplete extends StatefulWidget {
  const CustomAutocomplete({
    Key? key,
    required this.optionsBuilder,
    this.onSelected,
    this.hintText,
    this.labelText,
  }) : super(key: key);

  final FutureOr<Iterable<String>> Function(TextEditingValue) optionsBuilder;
  final void Function(String)? onSelected;
  final String? hintText;
  final String? labelText;

  @override
  State<CustomAutocomplete> createState() => _CustomAutocomplete();
}

class _CustomAutocomplete extends State<CustomAutocomplete> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: widget.optionsBuilder,
      onSelected: widget.onSelected,
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return CustomTextField(
          controller: textEditingController,
          focusNode: focusNode,
          hintText: widget.hintText,
          labelText: widget.labelText,
          onSubmitted: (String value) {
            onFieldSubmitted();
            widget.onSelected?.call(value);
          },
        );
      },
    );
  }
}