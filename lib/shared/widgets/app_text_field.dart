import 'package:flutter/material.dart';

/// Shared input field with common variants used across the app.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    super.key,
    this.label,
    this.hint,
    this.validator,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
  });

  const AppTextField.password({
    required TextEditingController controller,
    Key? key,
    String? label,
    String? hint,
    FormFieldValidator<String>? validator,
    Widget? prefix,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) : this(
         controller: controller,
         key: key,
         label: label,
         hint: hint,
         validator: validator,
         prefix: prefix,
         suffix: suffix,
         onChanged: onChanged,
         obscureText: true,
         enabled: enabled,
       );

  const AppTextField.search({
    required TextEditingController controller,
    Key? key,
    String? hint,
    Widget? prefix,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) : this(
         controller: controller,
         key: key,
         hint: hint,
         prefix: prefix,
         suffix: suffix,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         textInputAction: TextInputAction.search,
       );

  const AppTextField.multiline({
    required TextEditingController controller,
    Key? key,
    String? label,
    String? hint,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    int minLines = 3,
    int maxLines = 5,
  }) : this(
         controller: controller,
         key: key,
         label: label,
         hint: hint,
         validator: validator,
         onChanged: onChanged,
         minLines: minLines,
         maxLines: maxLines,
       );

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      readOnly: readOnly,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? null : minLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );
  }
}
