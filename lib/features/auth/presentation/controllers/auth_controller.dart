import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firebase_auth_service.dart';
import '../view_models/auth_view_model.dart';

class AuthControllerState {
  final bool isLoading;
  final String? error;
  final String? verificationId;
  final String phoneNumber;
  final int countdownSeconds;
  final bool isCodeSent;

  const AuthControllerState({
    this.isLoading = false,
    this.error,
    this.verificationId,
    this.phoneNumber = '',
    this.countdownSeconds = 0,
    this.isCodeSent = false,
  });

  AuthControllerState copyWith({
    bool? isLoading,
    String? error,
    String? verificationId,
    String? phoneNumber,
    int? countdownSeconds,
    bool? isCodeSent,
    bool clearError = false,
  }) {
    return AuthControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isCodeSent: isCodeSent ?? this.isCodeSent,
    );
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthControllerState>((ref) {
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  final authViewModel = ref.watch(authViewModelProvider.notifier);
  return AuthController(firebaseAuthService, authViewModel);
});

class AuthController extends StateNotifier<AuthControllerState> {
  final FirebaseAuthService _firebaseAuthService;
  final AuthViewModel _authViewModel;
  Timer? _timer;

  AuthController(this._firebaseAuthService, this._authViewModel)
      : super(const AuthControllerState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    _timer?.cancel();
    state = state.copyWith(countdownSeconds: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (state.countdownSeconds <= 1) {
        _timer?.cancel();
        state = state.copyWith(countdownSeconds: 0);
      } else {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      }
    });
  }

  Future<void> sendOtp(String formattedPhone) async {
    state = state.copyWith(isLoading: true, clearError: true, phoneNumber: formattedPhone);
    try {
      await _firebaseAuthService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId, resendToken) {
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
            isCodeSent: true,
          );
          startCountdown();
        },
        onVerificationFailed: (exception) {
          String userFriendlyMsg = exception.message ?? 'Verification failed.';
          if (exception.code == 'invalid-phone-number') {
            userFriendlyMsg = 'The provided phone number is not valid.';
          } else if (exception.code == 'too-many-requests') {
            userFriendlyMsg = 'Too many requests. Please try again later.';
          }
          state = state.copyWith(isLoading: false, error: userFriendlyMsg);
        },
        onVerificationCompleted: (credential) async {
          await _signInAndAuthenticateWithDjango(credential);
        },
        onAutoRetrievalTimeout: (verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> verifyOtpAndLogin(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(error: 'Session expired. Please request a new OTP.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );

      return await _signInAndAuthenticateWithDjango(credential);
    } on FirebaseAuthException catch (e) {
      String userFriendlyMsg = e.message ?? 'OTP verification failed.';
      if (e.code == 'invalid-verification-code') {
        userFriendlyMsg = 'Invalid verification code. Please check and try again.';
      } else if (e.code == 'session-expired') {
        userFriendlyMsg = 'OTP session has expired. Please request a new OTP.';
      }
      state = state.copyWith(isLoading: false, error: userFriendlyMsg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtpAndRegister(String smsCode, String name, String password) async {
    if (state.verificationId == null) {
      state = state.copyWith(error: 'Session expired. Please request a new OTP.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuthService.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        state = state.copyWith(isLoading: false, error: 'Failed to retrieve ID token.');
        return false;
      }

      final success = await _authViewModel.firebaseLogin(
        idToken: idToken,
        name: name,
        password: password,
        isRegister: true,
      );

      if (success) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        final errorMsg = _authViewModel.state.error ?? 'Django registration failed.';
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String userFriendlyMsg = e.message ?? 'OTP verification failed.';
      if (e.code == 'invalid-verification-code') {
        userFriendlyMsg = 'Invalid verification code. Please check and try again.';
      } else if (e.code == 'session-expired') {
        userFriendlyMsg = 'OTP session has expired. Please request a new OTP.';
      }
      state = state.copyWith(isLoading: false, error: userFriendlyMsg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> _signInAndAuthenticateWithDjango(PhoneAuthCredential credential) async {
    final userCredential = await _firebaseAuthService.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();

    if (idToken == null) {
      state = state.copyWith(isLoading: false, error: 'Failed to retrieve ID token from Firebase.');
      return false;
    }

    final success = await _authViewModel.firebaseLogin(
      idToken: idToken,
      isRegister: false,
    );

    if (success) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      final errorMsg = _authViewModel.state.error ?? 'Django login failed.';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
