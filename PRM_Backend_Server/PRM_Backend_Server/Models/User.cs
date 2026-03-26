using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.Models;

public partial class User
{
    public int UserId { get; set; }

    public string FullName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string Phone { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public string? Role { get; set; }

    public string? Address { get; set; }

    public string? Avatar { get; set; }

    public bool? IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public string? RefreshToken { get; set; }
    public DateTime? RefreshTokenExpirationTime { get; set; }

    public virtual ICollection<Booking> BookingCustomers { get; set; } = new List<Booking>();

    public virtual ICollection<Booking> BookingWorkers { get; set; } = new List<Booking>();

    public virtual ICollection<Rating> RatingCustomers { get; set; } = new List<Rating>();

    public virtual ICollection<Rating> RatingWorkers { get; set; } = new List<Rating>();

    public virtual Worker? Worker { get; set; }
}
