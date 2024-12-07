class AccessTokenData {
  final String accessToken;
  final String accessTokenExpiration;

  AccessTokenData(
      {required this.accessToken, required this.accessTokenExpiration});

  factory AccessTokenData.fromJson(Map<String, dynamic> json) {
    return AccessTokenData(
      accessToken: json['accessToken'],
      accessTokenExpiration: json['accessTokenExpiration'],
    );
  }
}
