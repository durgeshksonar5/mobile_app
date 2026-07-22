import '../../domain/entities/authenticated_user.dart';

class LoginResponseDto {
  final String access;
  final String refresh;
  final Map<String, dynamic>? userJson;

  const LoginResponseDto({
    required this.access,
    required this.refresh,
    this.userJson,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      access:
          json['access'] as String? ?? json['access_token'] as String? ?? '',
      refresh:
          json['refresh'] as String? ?? json['refresh_token'] as String? ?? '',
      userJson: json['user'] as Map<String, dynamic>?,
    );
  }

  AuthenticatedUser? toEntity() {
    if (userJson == null) return null;
    return AuthenticatedUser.fromJson(userJson!);
  }
}
