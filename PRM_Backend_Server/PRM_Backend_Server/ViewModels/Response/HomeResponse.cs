using PRM_Backend_Server.ViewModels.Pagination;
using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.ViewModels.Response
{
    public class HomeResponse
    {
        public class ServiceCategoryDto
        {
            public int CategoryId { get; set; }
            public string CategoryName { get; set; }
            public string? Description { get; set; }
            public string? ImageUrl { get; set; }
        }

        public class BookingSummary
        {
            public int BookingId { get; set; }
            public string? BookingCode { get; set; }
            public DateTime BookingDate { get; set; }
            public string? StartTime { get; set; }
            public string? CustomerName { get; set; }
            public string? PackageName { get; set; }
            public string? Status { get; set; }
            public decimal? Price { get; set; }
        }

        public class CustomerHome
        {
            public string name { get; set; }
            public string? avatar { get; set; }
            public PaginationResponse<ServiceCategoryDto> categories { get; set; } = new PaginationResponse<ServiceCategoryDto>();
        }

        public class AdminHome
        {
            public string name { get; set; }
            public string? avatar { get; set; }
            public int totalUsers { get; set; }
            public int totalBookings { get; set; }
            public int pendingBookings { get; set; }
            public decimal totalRevenue { get; set; }
            public List<BookingSummary> recentBookings { get; set; } = new List<BookingSummary>();
        }

        public class WorkerHome
        {
            public string name { get; set; }
            public string? avatar { get; set; }
            public int experienceYears { get; set; }
            public bool isAvailable { get; set; }
            public decimal averageRating { get; set; }
            public int totalReviews { get; set; }
            public List<BookingSummary> upcomingBookings { get; set; } = new List<BookingSummary>();
        }
    }
}
