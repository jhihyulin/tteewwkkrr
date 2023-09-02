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
    this.optionsMaxWidth,
  }) : super(key: key);

  final FutureOr<Iterable<String>> Function(TextEditingValue) optionsBuilder;
  final void Function(String)? onSelected;
  final String? hintText;
  final String? labelText;
  final double? optionsMaxWidth;

  @override
  State<CustomAutocomplete> createState() => _CustomAutocomplete();
}

class _CustomAutocomplete extends State<CustomAutocomplete> {
  @override
  Widget build(BuildContext context) {
    // TODO: 方向鍵選擇
    return Autocomplete<String>(
      optionsBuilder: widget.optionsBuilder,
      onSelected: widget.onSelected,
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            child: Container(
              height: 200.0,
              constraints: BoxConstraints(
                  maxWidth: widget.optionsMaxWidth ?? double.infinity),
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                      widget.onSelected?.call(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(option),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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
          onChanged: (String value) {
            widget.onSelected?.call(value);
          },
        );
      },
    );
  }
}
