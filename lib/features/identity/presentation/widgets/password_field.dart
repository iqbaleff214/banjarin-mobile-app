import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final TextInputAction? textInputAction;
  final bool enabled;
  final FocusNode? focusNode;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.textInputAction,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
          tooltip: _obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
        ),
      ),
    );
  }
}
