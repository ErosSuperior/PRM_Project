class RegisterResponse {
  String message;

  RegisterResponse({
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
    );
  }
}

class LoginResponse {
  String accessToken;
  String refreshToken;
  String message;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class ChangePasswordResponse {
  String message;

  ChangePasswordResponse({
    required this.message,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      message: json['message'] ?? '',
    );
  }
}

class ResetPasswordResponse {
  String message;

  ResetPasswordResponse({
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] ?? '',
    );
  }
}

class VerifyOTPResetPasswordResponse {
  String message;

  VerifyOTPResetPasswordResponse({
    required this.message,
  });

  factory VerifyOTPResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResetPasswordResponse(
      message: json['message'] ?? '',
    );
  }
}

class SetNewPasswordResponse {
  String message;

  SetNewPasswordResponse({
    required this.message,
  });

  factory SetNewPasswordResponse.fromJson(Map<String, dynamic> json) {
    return SetNewPasswordResponse(
      message: json['message'] ?? '',
    );
  }
}

class RefreshTokenResponse {
  String accessToken;
  String refreshToken;
  String message;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      message: json['message'] ?? '',
    );
  }
}