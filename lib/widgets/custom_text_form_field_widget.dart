import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText,
    this.numberOnly,
    this.validator,
    this.enabled,
    this.maxLength,
    this.maxLines,
    this.icon,
    this.hT
  });

  final TextEditingController controller;
  final bool? obscureText;
  final bool? numberOnly;
  final bool? enabled;
  final String hintText;
  final String? hT;
  final int? maxLength;
  final int? maxLines;
  final Icon? icon;
  final String? Function(String?) ? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        enabled: enabled,
        maxLines: maxLines,
        obscureText: obscureText ?? false,
        keyboardType: numberOnly == true? TextInputType.number : TextInputType.text,
        validator: validator,
        decoration: InputDecoration(
          labelText: hintText,
          hintText: hT,
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
          prefixIcon: icon,
          prefixIconColor: Colors.black,
        ),
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 18
        ),
      ),
    );
  }
}