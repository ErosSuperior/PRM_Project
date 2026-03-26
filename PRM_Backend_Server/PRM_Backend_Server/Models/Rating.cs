using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.Models;

public partial class Rating
{
    public int RatingId { get; set; }

    public int BookingId { get; set; }

    public int CustomerId { get; set; }

    public int WorkerId { get; set; }

    public int? RatingScore { get; set; }

    public string? Comment { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Booking Booking { get; set; } = null!;

    public virtual User Customer { get; set; } = null!;

    public virtual User Worker { get; set; } = null!;
}
