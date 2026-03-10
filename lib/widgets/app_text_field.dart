import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _focused = false;
  late bool _obscured;
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
    _node = widget.focusNode ?? FocusNode();
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.labelLg),
        const SizedBox(height: AppSpacing.sm - 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: _focused
                ? [BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 0, spreadRadius: 3,
                  )]
                : null,
          ),
          child: TextFormField(
            controller:    widget.controller,
            focusNode:     _node,
            obscureText:   _obscured,
            keyboardType:  widget.keyboardType,
            validator:     widget.validator,
            maxLines:      widget.obscure ? 1 : widget.maxLines,
            enabled:       widget.enabled,
            onChanged:     widget.onChanged,
            textInputAction: widget.textInputAction,
            style: AppTypography.bodyMd,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.obscure
                  ? GestureDetector(
                      onTap: () => setState(() => _obscured = !_obscured),
                      child: Icon(
                        _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: AppColors.textLight, size: 20,
                      ),
                    )
                  : widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
