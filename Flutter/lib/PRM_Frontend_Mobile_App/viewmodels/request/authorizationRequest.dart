class RegisterRequest {
  String name;
  String email;
  String password;
  String confirmPassword;
  String phone;
  String address;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    'phone': phone,
    'address': address,
  };
}

class LoginRequest {
  String email;
  String password;

  LoginRequest({
    required this.email,
    required this.password
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class ChangePasswordRequest {
  String email;
  String oldPassword;
  String newPassword;
  String confirmNewPassword;

  ChangePasswordRequest({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'oldPassword': oldPassword,
    'newPassword': newPassword,
    'confirmNewPassword': confirmNewPassword,
  };
}

class ResetPasswordRequest {
  String email;

  ResetPasswordRequest({
    required this.email
  });

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class VerifyOTPResetPasswordRequest {
  String email;
  String otp;

  VerifyOTPResetPasswordRequest({
    required this.email,
    required this.otp
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
  };
}

class SetNewPasswordRequest {
  String email;
  String newPassword;
  String confirmNewPassword;

  SetNewPasswordRequest({
    required this.email,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'newPassword': newPassword,
    'confirmNewPassword': confirmNewPassword,
  };
}

class RefreshTokenRequest {
  String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken
  });

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}