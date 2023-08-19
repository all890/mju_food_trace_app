import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'custom_text_form_field_widget.dart';

class AutoCompleteStateful extends StatefulWidget {
  final List<String> itemList;
  final ValueChanged<String> onItemChanged;
  const AutoCompleteStateful({super.key, required this.itemList, required this.onItemChanged});

  @override
  State<AutoCompleteStateful> createState() => _AutoCompleteStatefulState();
}

class _AutoCompleteStatefulState extends State<AutoCompleteStateful> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          return widget.itemList.where((String option) {
            return option.contains(textEditingValue.text.toLowerCase());
          });
        },
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        controller: textEditingController,
        focusNode: focusNode,
        onEditingComplete: onFieldSubmitted,
        decoration: InputDecoration(
          labelText: "ชื่อผู้รับผลผลิตปลายทาง",
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(Icons.person),
          prefixIconColor: Colors.black,
        ),
        
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 18
        ),
      ),
    );
        },
        onSelected: (String selection) {
          widget.onItemChanged(selection);
        },
      );
  }
}