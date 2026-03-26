namespace PRM_Backend_Server.ViewModels.Response
{
    public class RatingResponse
    {
        public int RatingId { get; set; }
        public int BookingId { get; set; }
        public string? BookingCode { get; set; }
        public int CustomerId { get; set; }
        public string? CustomerName { get; set; }
        public int WorkerId { get; set; }
        public string? WorkerName { get; set; }
        public int? RatingScore { get; set; }
        public string? Comment { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
