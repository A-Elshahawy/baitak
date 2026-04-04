class OTPTokenOut {
  const OTPTokenOut({
    required this.accessToken,
    required this.isNewUser,
  });

  final String accessToken;
  final bool isNewUser;

  factory OTPTokenOut.fromJson(Map<String, dynamic> json) => OTPTokenOut(
        accessToken: json['access_token'] as String,
        isNewUser: json['is_new_user'] as bool,
      );
}
