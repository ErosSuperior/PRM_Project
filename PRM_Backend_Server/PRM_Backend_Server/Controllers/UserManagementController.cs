using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PRM_Backend_Server.Models;
using PRM_Backend_Server.ViewModels.Pagination;
using PRM_Backend_Server.ViewModels.Response;
using PRM_Backend_Server.ViewModels.Request;
using System.Security.Claims;

namespace PRM_Backend_Server.Controllers
{
    [Route("user/[controller]")]
    [ApiController]
    public class UserManagementController : ControllerBase
    {
        private readonly HomeServiceAppContext _db;
        private readonly ILogger<UserManagementController> _logger;

        public UserManagementController(HomeServiceAppContext db, ILogger<UserManagementController> logger)
        {
            _db = db;
            _logger = logger;
        }

        //[Authorize(Roles = "admin,customer")]
        [HttpGet("list")]
        public async Task<IActionResult> GetWorkerUsers([FromQuery] PaginationRequest request)
        {
            // Base query: include user navigation so we can access user fields
            var baseQuery = _db.Workers.Include(w => w.WorkerNavigation).AsQueryable();

            // Only consider workers that have a linked user and are available
            baseQuery = baseQuery.Where(w => w.WorkerNavigation != null && (w.IsAvailable ?? false));

            // Apply search term (server-side, translatable)
            if (!string.IsNullOrWhiteSpace(request.SearchTerm))
            {
                var st = request.SearchTerm.Trim();
                baseQuery = baseQuery.Where(w =>
                    (w.WorkerNavigation.FullName != null && EF.Functions.Like(w.WorkerNavigation.FullName, $"%{st}%")) ||
                    (w.WorkerNavigation.Email != null && EF.Functions.Like(w.WorkerNavigation.Email, $"%{st}%")) ||
                    (w.WorkerNavigation.Phone != null && EF.Functions.Like(w.WorkerNavigation.Phone, $"%{st}%")) ||
                    (w.Bio != null && EF.Functions.Like(w.Bio, $"%{st}%"))
                );
            }

            // If FilterBy tokens are provided, we need substring matching against Bio.
            // EF Core cannot translate certain string methods with comparison overloads inside Any().
            // We therefore materialize the pre-filtered query to memory and perform token matching there.
            List<Worker> filteredWorkers;
            if (!string.IsNullOrWhiteSpace(request.FilterBy) && request.FilterBy != "default")
            {
                var tokens = request.FilterBy
                    .Split(' ', StringSplitOptions.RemoveEmptyEntries)
                    .Select(t => t.Trim())
                    .Where(t => t.Length > 0)
                    .ToArray();

                // Materialize the current query to reduce the dataset before expensive client-side filtering
                var preFiltered = await baseQuery.ToListAsync();

                filteredWorkers = preFiltered
                    .Where(w => (w.IsAvailable ?? false) && !string.IsNullOrWhiteSpace(w.Bio) &&
                                tokens.Any(t => w.Bio.IndexOf(t, StringComparison.OrdinalIgnoreCase) >= 0))
                    .ToList();
            }
            else
            {
                // No token filter — keep everything server-side for now
                filteredWorkers = await baseQuery.ToListAsync();
            }

            // Sorting (in-memory if we materialized; still works if filteredWorkers is from DB)
            var ascending = request.SortOrder >= 0;
            IEnumerable<Worker> sorted = filteredWorkers;
            switch (request.SortBy?.ToLowerInvariant())
            {
                case "experienceyears":
                case "experience":
                    sorted = ascending
                        ? filteredWorkers.OrderBy(w => w.ExperienceYears)
                        : filteredWorkers.OrderByDescending(w => w.ExperienceYears);
                    break;
                case "averagerating":
                case "rating":
                    sorted = ascending
                        ? filteredWorkers.OrderBy(w => w.AverageRating)
                        : filteredWorkers.OrderByDescending(w => w.AverageRating);
                    break;
                case "totalreviews":
                case "reviews":
                    sorted = ascending
                        ? filteredWorkers.OrderBy(w => w.TotalReviews)
                        : filteredWorkers.OrderByDescending(w => w.TotalReviews);
                    break;
                case "name":
                    sorted = ascending
                        ? filteredWorkers.OrderBy(w => w.WorkerNavigation.FullName)
                        : filteredWorkers.OrderByDescending(w => w.WorkerNavigation.FullName);
                    break;
                default:
                    sorted = filteredWorkers.OrderBy(w => w.WorkerId);
                    break;
            }

            // Pagination (in-memory)
            var totalItems = sorted.Count();
            var pageSize = Math.Max(1, request.PageSize);
            var totalPages = (int)Math.Ceiling(totalItems / (double)pageSize);
            var currentPage = Math.Max(1, request.PageNumber);
            var skip = (currentPage - 1) * pageSize;

            var pageItems = sorted.Skip(skip).Take(pageSize).ToList();

            var resultItems = pageItems.Select(w => new UserManagementResponse.WorkerProfileResponse
            {
                id = w.WorkerNavigation.UserId,
                name = w.WorkerNavigation.FullName,
                email = w.WorkerNavigation.Email,
                phone = w.WorkerNavigation.Phone,
                address = w.WorkerNavigation.Address,
                experienceYears = w.ExperienceYears ?? 0,
                avatar = w.WorkerNavigation.Avatar,
                bio = w.Bio ?? string.Empty,
                isAvailable = w.IsAvailable ?? false,
                TotalReviews = w.TotalReviews ?? 0,
                AverageRating = w.AverageRating ?? 0m
            }).ToList();

            var response = new PaginationResponse<UserManagementResponse.WorkerProfileResponse>
            {
                TotalItems = totalItems,
                TotalPages = totalPages,
                CurrentPage = currentPage,
                PageSize = pageSize,
                Items = resultItems
            };

            return Ok(response);
        }

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile([FromQuery] int? userId)
        {

            // Get caller information from token
            var callerRole = User.FindFirst(ClaimTypes.Role)?.Value?.ToLowerInvariant();

            // Try multiple possible claim types for subject (some libraries use different types)
            string? callerSub =
                User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub)?.Value
                ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? User.FindFirst("sub")?.Value
                ?? User.FindFirst("id")?.Value;

            if (string.IsNullOrEmpty(callerSub))
            {
                // Provide additional debug output in response during dev — remove in production
                var claimsDump = User.Claims.Select(c => new { c.Type, c.Value }).ToList();
                return Unauthorized(new { message = "Invalid token: missing subject", claims = claimsDump });
            }

            if (!int.TryParse(callerSub, out var callerId))
            {
                return Unauthorized(new { message = "Invalid token: subject is not an integer", subject = callerSub });
            }

            int targetUserId;

            if (callerRole == "admin")
            {
                // Admin can view any user; if no userId provided, show admin's own profile
                targetUserId = userId ?? callerId;
            }
            else
            {
                // Non-admins can only view their own profile
                if (userId.HasValue && userId.Value != callerId)
                {
                    return Forbid();
                }

                targetUserId = callerId;
            }

            // Include Worker navigation so we can return worker-specific fields if present
            var user = await _db.Users
                .Include(u => u.Worker)
                .FirstOrDefaultAsync(u => u.UserId == targetUserId);

            if (user == null)
            {
                return NotFound(new { message = "User not found" });
            }

            // If target is a worker and worker record exists, return WorkerProfileResponse
            if ((user.Role?.ToLowerInvariant() == "worker") && user.Worker != null)
            {
                var w = user.Worker;
                var workerResp = new UserManagementResponse.WorkerProfileResponse
                {
                    name = user.FullName,
                    email = user.Email,
                    phone = user.Phone,
                    address = user.Address,
                    experienceYears = w.ExperienceYears ?? 0,
                    avatar = user.Avatar,
                    bio = w.Bio ?? string.Empty,
                    isAvailable = w.IsAvailable ?? false,
                    TotalReviews = w.TotalReviews ?? 0,
                    AverageRating = w.AverageRating ?? 0m
                };

                return Ok(workerResp);
            }

            // Otherwise return the standard user profile
            var response = new UserManagementResponse.UserProfileResponse
            {
                name = user.FullName,
                email = user.Email,
                phone = user.Phone,
                address = user.Address,
                avatar = user.Avatar
            };

            return Ok(response);
        }


        // ------------------ New endpoints: update basic profile and worker profile ------------------

        // Updates basic profile fields for the authenticated user (customer/admin/worker)
        [Authorize]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UserManagementRequest.UpdateUserProfileRequest request)
        {
            if (request == null)
                return BadRequest(new UserManagementResponse.UpdateUserProfileResponse { message = "Invalid request" });

            // get caller id from token
            string? callerSub =
                User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub)?.Value
                ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? User.FindFirst("sub")?.Value
                ?? User.FindFirst("id")?.Value;

            if (string.IsNullOrEmpty(callerSub) || !int.TryParse(callerSub, out var callerId))
                return Unauthorized(new UserManagementResponse.UpdateUserProfileResponse { message = "Invalid token" });

            var user = await _db.Users.FirstOrDefaultAsync(u => u.UserId == callerId);
            if (user == null)
                return NotFound(new UserManagementResponse.UpdateUserProfileResponse { message = "User not found" });

            // Update only non-null fields
            var updated = false;
            if (request.name != null)
            {
                user.FullName = request.name.Trim();
                updated = true;
            }
            if (request.phone != null)
            {
                user.Phone = request.phone.Trim();
                updated = true;
            }
            if (request.address != null)
            {
                user.Address = request.address.Trim();
                updated = true;
            }

            if (!updated)
                return BadRequest(new UserManagementResponse.UpdateUserProfileResponse { message = "No changes provided" });

            user.UpdatedAt = DateTime.UtcNow;
            _db.Users.Update(user);
            await _db.SaveChangesAsync();

            return Ok(new UserManagementResponse.UpdateUserProfileResponse { message = "Profile updated successfully" });
        }

        // Worker updates: update base profile plus worker-specific fields
        [Authorize(Roles = "worker")]
        [HttpPut("profile/worker")]
        public async Task<IActionResult> UpdateWorkerProfile([FromBody] UserManagementRequest.UpdateWorkerProfileRequest request)
        {
            if (request == null)
                return BadRequest(new UserManagementResponse.UpdateUserProfileResponse { message = "Invalid request" });

            // get caller id from token
            string? callerSub =
                User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub)?.Value
                ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? User.FindFirst("sub")?.Value
                ?? User.FindFirst("id")?.Value;

            if (string.IsNullOrEmpty(callerSub) || !int.TryParse(callerSub, out var callerId))
                return Unauthorized(new UserManagementResponse.UpdateUserProfileResponse { message = "Invalid token" });

            var user = await _db.Users.Include(u => u.Worker).FirstOrDefaultAsync(u => u.UserId == callerId);
            if (user == null)
                return NotFound(new UserManagementResponse.UpdateUserProfileResponse { message = "User not found" });

            if (user.Worker == null)
                return BadRequest(new UserManagementResponse.UpdateUserProfileResponse { message = "Worker profile not found" });

            var updated = false;

            // update base profile if provided
            if (request.baseProfile != null)
            {
                if (request.baseProfile.name != null)
                {
                    user.FullName = request.baseProfile.name.Trim();
                    updated = true;
                }
                if (request.baseProfile.phone != null)
                {
                    user.Phone = request.baseProfile.phone.Trim();
                    updated = true;
                }
                if (request.baseProfile.address != null)
                {
                    user.Address = request.baseProfile.address.Trim();
                    updated = true;
                }
            }

            // worker-specific updates
            if (request.experienceYears.HasValue)
            {
                user.Worker.ExperienceYears = request.experienceYears.Value;
                updated = true;
            }
            if (request.bio != null)
            {
                user.Worker.Bio = request.bio.Trim();
                updated = true;
            }
            if (request.isAvailable.HasValue)
            {
                user.Worker.IsAvailable = request.isAvailable.Value;
                updated = true;
            }

            if (!updated)
                return BadRequest(new UserManagementResponse.UpdateUserProfileResponse { message = "No changes provided" });

            user.UpdatedAt = DateTime.UtcNow;
            _db.Users.Update(user);
            _db.Workers.Update(user.Worker);
            await _db.SaveChangesAsync();

            return Ok(new UserManagementResponse.UpdateUserProfileResponse { message = "Worker profile updated successfully" });
        }
    }
}
