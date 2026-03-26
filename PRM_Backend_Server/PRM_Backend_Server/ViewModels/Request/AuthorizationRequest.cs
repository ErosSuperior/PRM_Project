namespace PRM_Backend_Server.ViewModels.Request
{
    public class AuthorizationRequest
    {

        public class RegisterRequest
        {
            public string name { get; set; }
            public string email { get; set; }
            public string password { get; set; }
            public string confirmPassword { get; set; }
            public string phone { get; set; }
            public string address { get; set; }
        }
        public class LoginRequest
        {
            public string email { get; set; }
            public string password { get; set; }
        }
        public class ChangePasswordRequest
        {
            public string email { get; set; }
            public string oldPassword { get; set; }
            public string newPassword { get; set; }
            public string confirmNewPassword { get; set; }
        }

        public class ResetPasswordRequest
        {
            public string email { get; set; }
        }
        public class VerifyOTPResetPasswordRequest
        {
            public string email { get; set; }
            public string otp { get; set; }
        }
        public class SetNewPasswordRequest
        {
            public string email { get; set; }
            public string newPassword { get; set; }
            public string confirmNewPassword { get; set; }
        }
        public class RefreshTokenRequest
        {
            public string refreshToken { get; set; }
        }

    }

    

}
