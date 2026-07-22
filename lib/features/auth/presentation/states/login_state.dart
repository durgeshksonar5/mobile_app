import '../../domain/entities/authenticated_user.dart';

class LoginState {
  final bool isLoading;
  final String phoneNumber;
  final String password;
  final String? phoneError;
  final String? passwordError;
  final String? errorMessage;
  final AuthenticatedUser? user;
  final bool isSuccess;

  const LoginState({
    this.isLoading = false,
    this.phoneNumber = '',
    this.password = '',
    this.phoneError,
    this.passwordError,
    this.errorMessage,
    this.user,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? phoneNumber,
    String? password,
    String? phoneError,
    String? passwordError,
    String? errorMessage,
    AuthenticatedUser? user,
    bool? isSuccess,
    bool clearErrors = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      phoneError: clearErrors ? null : (phoneError ?? this.phoneError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
