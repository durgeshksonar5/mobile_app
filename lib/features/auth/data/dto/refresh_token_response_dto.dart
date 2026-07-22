class RefreshTokenResponseDto {
  final String access;
  final String? refresh;

  const RefreshTokenResponseDto({
    required this.access,
    this.refresh,
  });

  factory RefreshTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseDto(
      access:
          json['access'] as String? ?? json['access_token'] as String? ?? '',
      refresh: json['refresh'] as String? ?? json['refresh_token'] as String?,
    );
  }
}
