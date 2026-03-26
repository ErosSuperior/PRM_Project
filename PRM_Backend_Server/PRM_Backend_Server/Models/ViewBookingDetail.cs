using System;
using System.Collections.Generic;

namespace PRM_Backend_Server.Models;

public partial class ViewBookingDetail
{
    public int BookingId { get; set; }

    public string? BookingCode { get; set; }

    public DateOnly BookingDate { get; set; }

    public string? Status { get; set; }

    public string CustomerName { get; set; } = null!;

    public string? WorkerName { get; set; }

    public string PackageName { get; set; } = null!;

    public decimal Price { get; set; }
}
