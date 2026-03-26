namespace PRM_Backend_Server.ViewModels.Request
{
    public class BookingRequest
    {
        public class CreateBookingRequest
        {
            public int CustomerId { get; set; }
            public int? WorkerId { get; set; }
            public string PackageId { get; set; }
            public DateOnly BookingDate { get; set; }
            public TimeOnly StartTime { get; set; }
            public string Address { get; set; } = string.Empty;
            public string? Note { get; set; }
        }

        public class AssignWorkerRequest
        {
            public int WorkerId { get; set; }
        }

        public class UpdateBookingStatusRequest
        {
            public string Status { get; set; } = string.Empty;
        }
    }
}
