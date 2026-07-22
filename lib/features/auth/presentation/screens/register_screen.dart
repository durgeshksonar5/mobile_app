import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/auth_view_model.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/validation/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _step = 1;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showPassword = false;
  String? _infoMessage;
  String? _localError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    setState(() {
      _localError = null;
      _infoMessage = null;
    });

    final nameErr = _nameController.text.trim().isEmpty
        ? 'Please fill in all fields.'
        : null;
    final phoneErr = Validators.validatePhone(_phoneController.text);
    final passErr =
        Validators.validatePassword(_passwordController.text, minLength: 6);

    if (nameErr != null || phoneErr != null || passErr != null) {
      setState(() {
        _localError = nameErr ?? phoneErr ?? passErr;
      });
      return;
    }

    setState(() {
      _step = 2;
      _infoMessage = 'Verification code sent to your phone number via SMS.';
    });
  }

  void _handleVerifyOtp() async {
    setState(() {
      _localError = null;
    });

    final otpErr = Validators.validateOtp(_otpController.text);
    if (otpErr != null) {
      setState(() {
        _localError = otpErr;
      });
      return;
    }

    final viewModel = ref.read(authViewModelProvider.notifier);
    // Submit registration call
    final success = await viewModel.firebaseLogin(
      idToken: 'mock_firebase_id_token_${_otpController.text.trim()}',
      name: _nameController.text.trim(),
      password: _passwordController.text.trim(),
      isRegister: true,
    );

    if (mounted && success) {
      setState(() {
        _infoMessage = 'Registration complete! Redirecting...';
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) context.go(RoutePaths.home);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final errorToDisplay = _localError ?? authState.error;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Gold Banner Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF8D044),
                            Color(0xFFE4AA25),
                            Color(0xFFC58514),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (_step == 2)
                            Positioned(
                              left: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: AppColors.textPrimary),
                                onPressed: () {
                                  setState(() {
                                    _step = 1;
                                    _localError = null;
                                  });
                                },
                              ),
                            ),
                          Center(
                            child: Column(
                              children: const [
                                Text(
                                  'KING WIN',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Trusted Satta Matka Experience',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Content Body
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.p24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _step == 1 ? 'Create Account' : 'Verify Phone',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (errorToDisplay != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.statusRedBg,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusMd),
                                border: Border.all(
                                    color: AppColors.statusRed
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.statusRed, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      errorToDisplay,
                                      style: const TextStyle(
                                        color: AppColors.statusRed,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_infoMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.statusGreenBg,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusMd),
                                border: Border.all(
                                    color: AppColors.statusGreen
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      color: AppColors.statusGreen, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _infoMessage!,
                                      style: const TextStyle(
                                        color: AppColors.statusGreen,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_step == 1) ...[
                            // Full Name Input
                            const Text(
                              'Full Name',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _nameController,
                              enabled: !authState.isLoading,
                              decoration: const InputDecoration(
                                hintText: 'Enter your name',
                                prefixIcon: Icon(Icons.person,
                                    size: 20, color: AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Phone Input
                            const Text(
                              'Phone Number',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              enabled: !authState.isLoading,
                              decoration: const InputDecoration(
                                hintText: 'Enter 10-digit number',
                                prefixIcon: Icon(Icons.phone_android,
                                    size: 20, color: AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Password Input
                            const Text(
                              'Password',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              enabled: !authState.isLoading,
                              decoration: InputDecoration(
                                hintText: 'Create a password (min 6 chars)',
                                prefixIcon: const Icon(Icons.lock_outline,
                                    size: 20, color: AppColors.textMuted),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Send OTP Button
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryGold,
                                    AppColors.primaryGoldLight
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusXl),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: _handleSendOtp,
                                child: const Text(
                                  'Send OTP',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textWhite),
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              "We've sent a code to ${_phoneController.text}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Enter OTP Code',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                              decoration: const InputDecoration(
                                hintText: '123456',
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Verify Button
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryGold,
                                    AppColors.primaryGoldLight
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusXl),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: authState.isLoading
                                    ? null
                                    : _handleVerifyOtp,
                                child: authState.isLoading
                                    ? const CircularProgressIndicator(
                                        color: AppColors.textWhite)
                                    : const Text(
                                        'Verify & Register',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textWhite),
                                      ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: () => context.go(RoutePaths.login),
                                child: const Text(
                                  'Login Here',
                                  style: TextStyle(
                                    color: AppColors.primaryGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
