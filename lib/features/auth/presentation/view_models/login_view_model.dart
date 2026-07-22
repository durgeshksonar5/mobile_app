import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../states/login_state.dart';
import '../../../../core/validation/validators.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository) : super(const LoginState());

  void setPhoneNumber(String phone) {
    state = state.copyWith(
      phoneNumber: phone,
      phoneError: Validators.validatePhone(phone),
      clearErrors: false,
    );
  }

  void setPassword(String pwd) {
    state = state.copyWith(
      password: pwd,
      passwordError: Validators.validatePassword(pwd, minLength: 1),
      clearErrors: false,
    );
  }

  Future<bool> submitLogin() async {
    final pError = Validators.validatePhone(state.phoneNumber);
    final pwdError = Validators.validatePassword(state.password, minLength: 1);

    if (pError != null || pwdError != null) {
      state = state.copyWith(
        phoneError: pError,
        passwordError: pwdError,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearErrors: true);

    try {
      final formattedPhone = Validators.formatPhoneNumber(state.phoneNumber);
      final session = await _authRepository.login(
        phoneNumber: formattedPhone,
        password: state.password,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        user: session.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('AppException: ', ''),
      );
      return false;
    }
  }
}
