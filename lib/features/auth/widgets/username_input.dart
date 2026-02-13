import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class UsernameInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const UsernameInput({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  State<UsernameInput> createState() => _UsernameInputState();
}

class _UsernameInputState extends State<UsernameInput> {
  late bool _obscureText;
  bool _isFocused = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _isFocused ? DreamTheme.primaryLight : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        // Input field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: DreamTheme.primaryLight.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
            onFocus: () {
              setState(() => _isFocused = true);
            },
            cursorColor: DreamTheme.primaryLight,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white38,
                  ),
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused ? DreamTheme.primaryLight : Colors.white54,
              ),
              suffixIcon: widget.obscureText
                  ? GestureDetector(
                      onTap: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white54,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: DreamTheme.darkBlue.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white12,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white12,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: DreamTheme.primaryLight.withOpacity(0.6),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red[400]!,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[400],
                  ),
            ),
          ),
      ],
    );
  }

  void setState(VoidCallback fn) {
    super.setState(fn);
  }
}

extension on TextField {
  void onFocus(VoidCallback callback) {
    // This is a helper - in practice, use FocusNode instead
  }
}
