import '../../domain/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isBlocked;
  final bool isUpdateRequired;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isBlocked = false,
    this.isUpdateRequired = false,
  });

  bool get isAuthenticated => user != null && !isBlocked;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isBlocked,
    bool? isUpdateRequired,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      isBlocked: isBlocked ?? this.isBlocked,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
    );
  }
}
