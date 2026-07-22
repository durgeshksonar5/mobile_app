import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const PasswordInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter account password',
        prefixIcon: const Icon(Icons.lock_outline,
            color: AppColors.primaryGold, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textMuted,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        errorText: widget.errorText,
      ),
    );
  }
}
