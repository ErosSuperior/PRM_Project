using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.Models;

public partial class Worker
{
    public int WorkerId { get; set; }

    public int? ExperienceYears { get; set; }

    public string? Bio { get; set; }

    public bool? IsAvailable { get; set; }

    public decimal? AverageRating { get; set; }

    public int? TotalReviews { get; set; }

    public virtual User WorkerNavigation { get; set; } = null!;
}
