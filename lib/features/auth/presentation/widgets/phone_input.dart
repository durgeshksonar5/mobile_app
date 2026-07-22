import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const PhoneInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter 10-digit mobile number',
        prefixIcon: const Icon(Icons.phone_android,
            color: AppColors.primaryGold, size: 20),
        errorText: errorText,
      ),
    );
  }
}
