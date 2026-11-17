import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.label,
    this.hint,
    this.search = false,
    this.trailing,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? hint;
  final bool search;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final border = search ? AppTheme.searchBorder : AppTheme.fieldBorder;
    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: search ? TextInputAction.search : null,
      style: AppTheme.fieldText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: search
            ? const Padding(
                padding: EdgeInsetsDirectional.only(start: 16, end: 10),
                child: Icon(Icons.search, size: 20, color: AppTheme.muted),
              )
            : null,
        prefixIconConstraints: search
            ? const BoxConstraints(minWidth: 46)
            : null,
        suffixIcon: trailing,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: search ? 16 : 14,
          vertical: 14,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
    if (label case final text?) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Text(
              text,
              style: AppTheme.bodyStrong.copyWith(fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Semantics(label: text, child: field),
        ],
      );
    }
    return field;
  }
}
