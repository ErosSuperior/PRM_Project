using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.Models;

public partial class Payment
{
    public int PaymentId { get; set; }

    public int BookingId { get; set; }

    public string? PaymentMethod { get; set; }

    public string? PaymentStatus { get; set; }

    public string? TransactionCode { get; set; }

    public DateTime? PaidAt { get; set; }

    public virtual Booking Booking { get; set; } = null!;
}
