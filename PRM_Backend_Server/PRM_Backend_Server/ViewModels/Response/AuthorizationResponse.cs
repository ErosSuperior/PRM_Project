namespace PRM_Backend_Server.ViewModels.Response
{
    public class AuthorizationResponse
    {
        public class RegisterResponse
        {
            public string message { get; set; }
        }
        public class LoginResponse
        {
            public string accessToken { get; set; }
            public string refreshToken { get; set; }
            public string message { get; set; }
        }
        public class ChangePasswordResponse
        {
            public string message { get; set; }
        }
        public class ResetPasswordResponse
        {
            public string message { get; set; }
        }
        public class VerifyOTPResetPasswordResponse
        {
            public string message { get; set; }
        }
        public class SetNewPasswordResponse
        {
            public string message { get; set; }
        }
        public class RefreshTokenResponse
        {
            public string accessToken { get; set; }
            public string refreshToken { get; set; }
            public string message { get; set; }
        }
    }
}
