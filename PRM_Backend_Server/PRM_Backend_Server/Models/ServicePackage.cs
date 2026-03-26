using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.Models;

public partial class ServicePackage
{
    public int PackageId { get; set; }

    public int CategoryId { get; set; }

    public string PackageName { get; set; } = null!;

    public string? Description { get; set; }

    public decimal Price { get; set; }

    public int DurationHours { get; set; }

    public bool? IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();

    public virtual ServiceCategory Category { get; set; } = null!;
}
