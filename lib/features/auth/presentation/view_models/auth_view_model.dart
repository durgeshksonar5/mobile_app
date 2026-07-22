import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../states/auth_state.dart';
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
    final passErr = Validators.validatePassword(rawPassword);

    if (phoneErr != null || passErr != null) {
      state = state.copyWith(error: phoneErr ?? passErr);
      return false;
    }

    final formattedPhone = Validators.formatPhoneNumber(rawPhone);
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user =
          await _authRepository.login(formattedPhone, rawPassword.trim());
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
