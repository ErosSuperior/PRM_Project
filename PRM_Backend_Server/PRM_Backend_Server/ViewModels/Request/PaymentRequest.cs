namespace PRM_Backend_Server.ViewModels.Request
{
    public class PaymentRequest
    {
        public class CreatePaymentRequest
        {
            public int BookingId { get; set; }
            public string PaymentMethod { get; set; } = string.Empty;
            public string? TransactionCode { get; set; }
        }

        public class UpdatePaymentStatusRequest
        {
            public string PaymentStatus { get; set; } = string.Empty;
            public string? TransactionCode { get; set; }
        }
    }
}
