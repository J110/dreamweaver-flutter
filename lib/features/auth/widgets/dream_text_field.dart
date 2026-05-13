import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class DreamTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;

  const DreamTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
  }) : super(key: key);

  @override
  State<DreamTextField> createState() => _DreamTextFieldState();
}

class _DreamTextFieldState extends State<DreamTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused
                  ? DreamTheme.primaryPurple
                  : DreamTheme.moonGlow.withOpacity(0.2),
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: DreamTheme.moonGlow.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              minLines: widget.minLines,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DreamTheme.moonGlow,
                    fontSize: 16,
                  ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DreamTheme.moonGlow.withOpacity(0.4),
                      fontSize: 16,
                    ),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: widget.prefixIcon,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: widget.suffixIcon,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.prefixIcon != null ? 8 : 16,
                  vertical: 16,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              widget.errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade300,
                    fontSize: 12,
                  ),
            ),
          ),
      ],
    );
  }
}
