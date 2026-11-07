import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextFormField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final String hintText;
  final bool? isObscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final EdgeInsets scrollPadding;

  const AppTextFormField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.inputTextStyle,
    this.hintStyle,
    required this.hintText,
    this.isObscureText,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.controller,
    this.textInputAction,
    // Extra room below the field when it is scrolled into view so the
    // focused input settles fully above the software keyboard instead of
    // right at its top edge.
    this.scrollPadding = const EdgeInsets.only(bottom: 120),
  });

  @override
  Widget build(BuildContext context) {
    // Phone (<600) keeps the original scaled defaults exactly.
    // Wide screens use compact fixed values so fields stay small.
    final compact = MediaQuery.sizeOf(context).width < 600;
    final radius = compact ? 16.0.r : 12.0;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: isObscureText ?? false,
      readOnly: readOnly,
      validator: validator,
      scrollPadding: scrollPadding,
      style:
          inputTextStyle ??
          (compact
              ? TextStyle(fontSize: 14.sp, color: Colors.black)
              : const TextStyle(fontSize: 14, color: Colors.black)),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            contentPadding ??
            (compact
                ? EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
        focusedBorder:
            focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
        enabledBorder:
            enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.3),
              borderRadius: BorderRadius.circular(radius),
            ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.3),
          borderRadius: BorderRadius.circular(radius),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.3),
          borderRadius: BorderRadius.circular(radius),
        ),
        hintStyle:
            hintStyle ??
            (compact
                ? TextStyle(fontSize: 14.sp, color: Colors.grey)
                : const TextStyle(fontSize: 13, color: Colors.grey)),
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
