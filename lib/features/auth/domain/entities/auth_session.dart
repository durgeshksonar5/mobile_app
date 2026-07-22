import 'authenticated_user.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final AuthenticatedUser? user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  bool get isValid => accessToken.isNotEmpty;
}
