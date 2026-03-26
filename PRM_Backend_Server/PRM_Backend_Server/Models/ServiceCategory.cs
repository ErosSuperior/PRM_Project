using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.Models;

public partial class ServiceCategory
{
    public int CategoryId { get; set; }

    public string CategoryName { get; set; } = null!;

    public string? Description { get; set; }

    public string? ImageUrl { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual ICollection<ServicePackage> ServicePackages { get; set; } = new List<ServicePackage>();
}
