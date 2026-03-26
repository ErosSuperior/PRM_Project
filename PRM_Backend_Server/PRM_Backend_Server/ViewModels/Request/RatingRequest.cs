namespace PRM_Backend_Server.ViewModels.Request
{
    public class RatingRequest
    {
        public class CreateRatingRequest
        {
            public int BookingId { get; set; }
            public int CustomerId { get; set; }
            public int RatingScore { get; set; }
            public string? Comment { get; set; }
        }
    }
}
