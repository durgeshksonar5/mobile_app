class RefreshTokenRequestDto {
  final String refresh;

  const RefreshTokenRequestDto({required this.refresh});

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
    };
  }
}
