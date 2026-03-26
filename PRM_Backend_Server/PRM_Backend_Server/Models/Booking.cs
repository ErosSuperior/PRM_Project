using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.Models;

public partial class Booking
{
    public int BookingId { get; set; }

    public string? BookingCode { get; set; }

    public int CustomerId { get; set; }

    public int? WorkerId { get; set; }

    public int PackageId { get; set; }

    public DateOnly BookingDate { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly? EndTime { get; set; }

    public string Address { get; set; } = null!;

    public string? Note { get; set; }

    public decimal? TotalPrice { get; set; }

    public string? Status { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual User Customer { get; set; } = null!;

    public virtual ServicePackage Package { get; set; } = null!;

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    public virtual ICollection<Rating> Ratings { get; set; } = new List<Rating>();

    public virtual User? Worker { get; set; }
}
