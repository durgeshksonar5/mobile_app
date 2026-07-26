import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../states/auth_state.dart';
import '../../domain/models/user_model.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/errors/app_exception.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
});

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState()) {
    checkInitialSession();
  }

  Future<void> checkInitialSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authRepository.getProfile();
      if (user != null) {
        if (user.isBlocked) {
          state = state.copyWith(isLoading: false, isBlocked: true);
        } else {
          state = state.copyWith(isLoading: false, user: user);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String rawPhone, String rawPassword) async {
    final phoneErr = Validators.validatePhone(rawPhone);
    if (phoneErr != null) {
      state = state.copyWith(error: phoneErr);
      return false;
    }
    final formattedPhone = Validators.formatPhoneNumber(rawPhone);

    final passErr = Validators.validatePassword(rawPassword);
    if (passErr != null) {
      state = state.copyWith(error: passErr);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authRepository.login(
        phoneNumber: formattedPhone,
        password: rawPassword.trim(),
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on AccountBlockedException {
      state = state.copyWith(isLoading: false, isBlocked: true);
      return false;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _authRepository.register(
        phoneNumber: phoneNumber,
        password: password,
        name: name,
      );

      if (res['success'] == true) {
        final userJson = res['user'] as Map<String, dynamic>?;
        if (userJson != null) {
          final user = UserModel.fromJson(userJson);
          state = state.copyWith(isLoading: false, user: user);
        } else {
          state = state.copyWith(isLoading: false);
        }
        return true;
      } else {
        final errorMsg = res['message'] ?? 'Registration failed.';
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> firebaseLogin({
    required String idToken,
    String? name,
    String? password,
    bool isRegister = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepository.firebaseLogin(
        idToken: idToken,
        name: name,
        password: password,
        isRegister: isRegister,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedUser = await _authRepository.updateProfile(data);
      state = state.copyWith(isLoading: false, user: updatedUser);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetBlocked() {
    state = state.copyWith(isBlocked: false, clearError: true);
  }
}
