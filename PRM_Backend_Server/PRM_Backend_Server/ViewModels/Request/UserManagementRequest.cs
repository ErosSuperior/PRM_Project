using PRM_Backend_Server.ViewModels.Pagination;

namespace PRM_Backend_Server.ViewModels.Request
{
    public class UserManagementRequest
    {
        public class UpdateUserProfileRequest 
        {
            public string? name { get; set; }
            public string? phone { get; set; }
            public string? address { get; set; }
        }

        public class UpdateWorkerProfileRequest 
        {
            public UpdateUserProfileRequest? baseProfile { get; set; } 
            public int? experienceYears { get; set; }
            public string? bio { get; set; }
            public bool? isAvailable { get; set; }
        }

        public class AdminUpdateUserRequest //Admin can update any user's profile information and role
        {
            public int? userId { get; set; }
            public string? name { get; set; }
            public string? phone { get; set; }
            public string? address { get; set; }
            public string? role { get; set; }
            public bool? isActive { get; set; }
        }

        public class AdminUpdateUserRequestBulk //Admin can update multiple users' profile information and role in bulk
        {
            public List<AdminUpdateUserRequest> users { get; set; }
        }

        public class AdminDeleteUserRequest //Admin can delete a user by their userId
        {
            public int userId { get; set; }
        }

        public class AdminDeleteUserRequestBulk //Admin can delete multiple users by their userIds in bulk
        {
            public List<int> userIds { get; set; }
        }

        // Single user fetch by id (useful for admin endpoints)
        public class GetUserByIdRequest
        {
            public int userId { get; set; }
        }
    }
}
