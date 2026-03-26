using PRM_Backend_Server.ViewModels.Pagination;

namespace PRM_Backend_Server.ViewModels.Response
{
    public class UserManagementResponse
    {
        // Profile DTOs
        public class UserProfileResponse
        {
            public string name { get; set; }
            public string email { get; set; }
            public string? phone { get; set; }
            public string? address { get; set; }
            public string? avatar { get; set; }
        }

        public class WorkerProfileResponse
        {
            public int id { get; set; }
            public string name { get; set; }
            public string email { get; set; }
            public string phone { get; set; }
            public string address { get; set; }
            public int experienceYears { get; set; }
            public string? avatar { get; set; }
            public string bio { get; set; }
            public bool isAvailable { get; set; }
            public int TotalReviews { get; set; }
            public decimal AverageRating { get; set; }
        }

        public class UpdateUserProfileResponse
        {
            public string message { get; set; }
        }

        // Admin Management DTOs
        public class DeleteUserResponse
        {
            public string message { get; set; }
        }

        public class UpdateUserResponse
        {
            public string message { get; set; }
        }

        public class BulkUpdateUserResponse
        {
            public string message { get; set; }
        }

        public class BulkDeleteUserResponse
        {
            public string message { get; set; }
        }

        // Lightweight list item returned in paged lists
        public class UserListItemResponse
        {
            public int userId { get; set; }
            public string name { get; set; }
            public string email { get; set; }
            public string phone { get; set; }
            public string role { get; set; }
            public bool isActive { get; set; }
            public string address { get; set; }
            public string avatar { get; set; }
            public string bio { get; set; }
            public string experienceYears { get; set; }
            public string totalReviews { get; set; }
            public string averageRating { get; set; }
            public DateTime? createdAt { get; set; }
        }
    }
}
