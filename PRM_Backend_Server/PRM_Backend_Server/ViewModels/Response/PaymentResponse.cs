namespace PRM_Backend_Server.ViewModels.Response
{
    public class PaymentResponse
    {
        public int PaymentId { get; set; }
        public int BookingId { get; set; }
        public string? BookingCode { get; set; }
        public decimal? BookingTotalPrice { get; set; }
        public string? PaymentMethod { get; set; }
        public string? PaymentStatus { get; set; }
        public string? TransactionCode { get; set; }
        public DateTime? PaidAt { get; set; }
    }
}
