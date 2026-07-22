import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/contact_disclosure.dart';

class ContactPermissionScreen extends ConsumerWidget {
  final VoidCallback onContinue;
  final VoidCallback onNotNow;
  final VoidCallback onPrivacyPolicy;

  const ContactPermissionScreen({
    super.key,
    required this.onContinue,
    required this.onNotNow,
    required this.onPrivacyPolicy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: ContactDisclosure(
          onContinue: onContinue,
          onNotNow: onNotNow,
          onPrivacyPolicy: onPrivacyPolicy,
        ),
      ),
    );
  }
}
