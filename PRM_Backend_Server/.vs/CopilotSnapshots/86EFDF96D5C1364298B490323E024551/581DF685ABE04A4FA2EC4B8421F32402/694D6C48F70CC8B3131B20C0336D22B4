using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PRM_Backend_Server.ViewModels.Request;
using PRM_Backend_Server.ViewModels.Response;
using PRM_Backend_Server.Models;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;

namespace PRM_Backend_Server.Controllers
{
    [Route("auth/[controller]")]
    [ApiController]
    public class AuthorizationController : ControllerBase
    {
        private readonly HomeServiceAppContext _db;
        private readonly ILogger<AuthorizationController> _logger;

        public AuthorizationController(HomeServiceAppContext db, ILogger<AuthorizationController> logger)
        {
            _db = db;
            _logger = logger;
        }

        [HttpPost("register")]
        public async Task<ActionResult<AuthorizationResponse.RegisterResponse>> Register([FromBody] AuthorizationRequest.RegisterRequest request)
        {
            if (request == null)
                return BadRequest(new AuthorizationResponse.RegisterResponse { message = "Invalid request" });

            if (request.password != request.confirmPassword)
                return BadRequest(new AuthorizationResponse.RegisterResponse { message = "Password and confirm password do not match" });

            var exists = await _db.Users.AnyAsync(u => u.Email == request.email);
            if (exists)
                return Conflict(new AuthorizationResponse.RegisterResponse { message = "Email already registered" });

            // create user
            var passwordHash = HashPassword(request.password);
            var user = new User
            {
                FullName = request.email,
                Email = request.email,
                Phone = request.phone ?? string.Empty,
                Address = request.address,
                PasswordHash = passwordHash,
                Role = "customer",
                IsActive = true
            };

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            return Ok(new AuthorizationResponse.RegisterResponse { message = "Register successful" });
        }

        [HttpPost("login")]
        public async Task<ActionResult<AuthorizationResponse.LoginResponse>> Login([FromBody] AuthorizationRequest.LoginRequest request)
        {
            if (request == null)
                return BadRequest(new AuthorizationResponse.LoginResponse { message = "Invalid request" });

            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == request.email);
            if (user == null)
                return Unauthorized(new AuthorizationResponse.LoginResponse { message = "Invalid credentials" });

            if (!VerifyPassword(request.password, user.PasswordHash))
                return Unauthorized(new AuthorizationResponse.LoginResponse { message = "Invalid credentials" });

            // generate tokens (simple GUID-based tokens for demo)
            var accessToken = Guid.NewGuid().ToString();
            var refreshToken = Guid.NewGuid().ToString();

            return Ok(new AuthorizationResponse.LoginResponse
            {
                accessToken = accessToken,
                refreshToken = refreshToken,
                message = "Login successful"
            });
        }

        [HttpPost("change-password")]
        public async Task<ActionResult<AuthorizationResponse.ChangePasswordResponse>> ChangePassword([FromBody] AuthorizationRequest.ChangePasswordRequest request)
        {
            if (request == null)
                return BadRequest(new AuthorizationResponse.ChangePasswordResponse { message = "Invalid request" });

            if (request.newPassword != request.confirmNewPassword)
                return BadRequest(new AuthorizationResponse.ChangePasswordResponse { message = "New password and confirmation do not match" });

            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == request.email);
            if (user == null)
                return NotFound(new AuthorizationResponse.ChangePasswordResponse { message = "User not found" });

            if (!VerifyPassword(request.oldPassword, user.PasswordHash))
                return Unauthorized(new AuthorizationResponse.ChangePasswordResponse { message = "Old password is incorrect" });

            user.PasswordHash = HashPassword(request.newPassword);
            _db.Users.Update(user);
            await _db.SaveChangesAsync();

            return Ok(new AuthorizationResponse.ChangePasswordResponse { message = "Password changed successfully" });
        }

        [HttpPost("reset-password")]
        public ActionResult<AuthorizationResponse.ResetPasswordResponse> ResetPassword([FromBody] AuthorizationRequest.ResetPasswordRequest request)
        {
            if (request == null)
                return BadRequest(new AuthorizationResponse.ResetPasswordResponse { message = "Invalid request" });

            // In a real implementation you'd generate and store an OTP and send it via email/SMS.
            // Here we'll just return a success message to indicate the flow.
            return Ok(new AuthorizationResponse.ResetPasswordResponse { message = "OTP sent to registered email (demo)" });
        }

        [HttpPost("verify-otp-reset-password")]
        public ActionResult<AuthorizationResponse.VerifyOTPResetPasswordResponse> VerifyOTP([FromBody] AuthorizationRequest.VerifyOTPResetPasswordRequest request)
        {
            if (request == null)
                return BadRequest(new AuthorizationResponse.VerifyOTPResetPasswordResponse { message = "Invalid request" });

            // In a real implementation verify the OTP stored for this user.
            // For demo accept any non-empty OTP.
            if (string.IsNullOrWhiteSpace(request.otp))
                return BadRequest(new AuthorizationResponse.VerifyOTPResetPasswordResponse { message = "Invalid OTP" });

            return Ok(new AuthorizationResponse.VerifyOTPResetPasswordResponse { message = "OTP verified (demo)" });
        }

        [HttpPost("set-new-password")]
        public async Task<ActionResult<AuthorizationResponse.SetNewPasswordResponse>> SetNewPassword([FromBody] AuthorizationRequest.SetNewPasswordRequest request)
        {
            if (request == null)
                return BadRequest(new AuthorizationResponse.SetNewPasswordResponse { message = "Invalid request" });

            if (request.newPassword != request.confirmNewPassword)
                return BadRequest(new AuthorizationResponse.SetNewPasswordResponse { message = "New password and confirmation do not match" });

            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == request.email);
            if (user == null)
                return NotFound(new AuthorizationResponse.SetNewPasswordResponse { message = "User not found" });

            // In a real flow you'd verify OTP before allowing this.
            user.PasswordHash = HashPassword(request.newPassword);
            _db.Users.Update(user);
            await _db.SaveChangesAsync();

            return Ok(new AuthorizationResponse.SetNewPasswordResponse { message = "Password reset successfully" });
        }

        [HttpPost("refresh-token")]
        public ActionResult<AuthorizationResponse.RefreshTokenResponse> RefreshToken([FromBody] AuthorizationRequest.RefreshTokenRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.refreshToken))
                return BadRequest(new AuthorizationResponse.RefreshTokenResponse { message = "Invalid refresh token" });

            // In a real implementation you'd validate the refresh token.
            var newAccessToken = Guid.NewGuid().ToString();
            var newRefreshToken = Guid.NewGuid().ToString();

            return Ok(new AuthorizationResponse.RefreshTokenResponse
            {
                accessToken = newAccessToken,
                refreshToken = newRefreshToken,
                message = "Token refreshed (demo)"
            });
        }

        // Simple salted SHA256 password hashing for demo purposes.
        private static string HashPassword(string password)
        {
            var salt = Guid.NewGuid().ToString("N");
            using var sha = SHA256.Create();
            var combined = salt + password;
            var hash = sha.ComputeHash(Encoding.UTF8.GetBytes(combined));
            return salt + ":" + Convert.ToHexString(hash);
        }

        private static bool VerifyPassword(string password, string stored)
        {
            if (string.IsNullOrEmpty(stored)) return false;
            var parts = stored.Split(':');
            if (parts.Length != 2) return false;
            var salt = parts[0];
            var hashHex = parts[1];
            using var sha = SHA256.Create();
            var computed = sha.ComputeHash(Encoding.UTF8.GetBytes(salt + password));
            var computedHex = Convert.ToHexString(computed);
            return StringComparer.OrdinalIgnoreCase.Compare(computedHex, hashHex) == 0;
        }
    }
}
