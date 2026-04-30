import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

/// Input glass reutilizável com design premium dark.
class GlassInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final double? fontSize;
  final double borderRadius;

  const GlassInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.textStyle,
    this.fontSize,
    this.borderRadius = AppTheme.radiusMd,
  });

  factory GlassInput.large({
    TextEditingController? controller,
    String? label,
    String? hint,
    IconData? prefixIcon,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
    TextInputType? keyboardType,
  }) {
    return GlassInput(
      controller: controller, label: label, hint: hint,
      prefixIcon: prefixIcon, onChanged: onChanged, onSubmitted: onSubmitted,
      focusNode: focusNode, autofocus: autofocus, keyboardType: keyboardType,
      fontSize: 22, textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(
            color: AppTheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500,
          )),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller, focusNode: focusNode, autofocus: autofocus,
          readOnly: readOnly, enabled: enabled, obscureText: obscureText,
          maxLines: maxLines, maxLength: maxLength, keyboardType: keyboardType,
          textInputAction: textInputAction, textAlign: textAlign,
          onChanged: onChanged, onFieldSubmitted: onSubmitted, onTap: onTap,
          validator: validator,
          style: textStyle ?? TextStyle(
            color: AppTheme.onBackground, fontSize: fontSize ?? 15, fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint, errorText: errorText,
            filled: true, fillColor: AppTheme.surfaceVariant,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.onSurfaceVariant, size: 20) : null,
            suffixIcon: suffix ?? (suffixIcon != null ? IconButton(
              icon: Icon(suffixIcon, color: AppTheme.onSurfaceVariant, size: 20), onPressed: onSuffixTap,
            ) : null),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: fontSize != null && fontSize! > 18 ? 18 : 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: AppTheme.outline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: AppTheme.outline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: AppTheme.accentRed)),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
