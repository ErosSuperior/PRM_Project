namespace PRM_Backend_Server.ViewModels.Response
{
    public class BookingResponse
    {
        public int BookingId { get; set; }
        public string? BookingCode { get; set; }
        public int CustomerId { get; set; }
        public string? CustomerName { get; set; }
        public int? WorkerId { get; set; }
        public string? WorkerName { get; set; }
        public int PackageId { get; set; }
        public string? PackageName { get; set; }
        public DateOnly BookingDate { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly? EndTime { get; set; }
        public string Address { get; set; } = string.Empty;
        public string? Note { get; set; }
        public decimal? TotalPrice { get; set; }
        public string? Status { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
    
}
