using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PRM_Backend_Server.Models;
using PRM_Backend_Server.ViewModels.Request;
using PRM_Backend_Server.ViewModels.Response;

namespace PRM_Backend_Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private static readonly HashSet<string> ValidMethods = new(StringComparer.OrdinalIgnoreCase)
        {
            "cash", "bank_transfer", "momo"
        };

        private static readonly HashSet<string> ValidStatuses = new(StringComparer.OrdinalIgnoreCase)
        {
            "pending", "paid", "failed"
        };

        private readonly HomeServiceAppContext _context;

        public PaymentController(HomeServiceAppContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<PaymentResponse>>> GetAllPayments()
        {
            var payments = await _context.Payments
                .Include(p => p.Booking)
                .OrderByDescending(p => p.PaidAt ?? DateTime.MinValue)
                .ThenByDescending(p => p.PaymentId)
                .ToListAsync();

            return Ok(payments.Select(MapPaymentResponse));
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<PaymentResponse>> GetPaymentById(int id)
        {
            var payment = await _context.Payments
                .Include(p => p.Booking)
                .FirstOrDefaultAsync(p => p.PaymentId == id);

            if (payment == null)
            {
                return NotFound(new { message = "Payment not found" });
            }

            return Ok(MapPaymentResponse(payment));
        }

        [HttpGet("booking/{bookingId:int}")]
        public async Task<ActionResult<IEnumerable<PaymentResponse>>> GetPaymentsByBooking(int bookingId)
        {
            var payments = await _context.Payments
                .Include(p => p.Booking)
                .Where(p => p.BookingId == bookingId)
                .OrderByDescending(p => p.PaymentId)
                .ToListAsync();

            return Ok(payments.Select(MapPaymentResponse));
        }

        [HttpPost]
        public async Task<ActionResult<PaymentResponse>> CreatePayment([FromBody] PaymentRequest.CreatePaymentRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.PaymentMethod) || !ValidMethods.Contains(request.PaymentMethod))
            {
                return BadRequest(new { message = "Invalid payment method" });
            }

            var booking = await _context.Bookings.FirstOrDefaultAsync(b => b.BookingId == request.BookingId);
            if (booking == null)
            {
                return BadRequest(new { message = "Booking does not exist" });
            }

            var existingPaidPayment = await _context.Payments.AnyAsync(p => p.BookingId == request.BookingId && p.PaymentStatus == "paid");
            if (existingPaidPayment)
            {
                return BadRequest(new { message = "This booking has already been paid" });
            }

            var payment = new Payment
            {
                BookingId = request.BookingId,
                PaymentMethod = request.PaymentMethod.ToLowerInvariant(),
                PaymentStatus = request.PaymentMethod.Equals("cash", StringComparison.OrdinalIgnoreCase) ? "pending" : "pending",
                TransactionCode = request.TransactionCode,
                PaidAt = null
            };

            _context.Payments.Add(payment);
            await _context.SaveChangesAsync();

            payment.Booking = booking;
            return CreatedAtAction(nameof(GetPaymentById), new { id = payment.PaymentId }, MapPaymentResponse(payment));
        }

        [HttpPut("{id:int}/status")]
        public async Task<ActionResult<PaymentResponse>> UpdatePaymentStatus(int id, [FromBody] PaymentRequest.UpdatePaymentStatusRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.PaymentStatus) || !ValidStatuses.Contains(request.PaymentStatus))
            {
                return BadRequest(new { message = "Invalid payment status" });
            }

            var payment = await _context.Payments
                .Include(p => p.Booking)
                .FirstOrDefaultAsync(p => p.PaymentId == id);

            if (payment == null)
            {
                return NotFound(new { message = "Payment not found" });
            }

            payment.PaymentStatus = request.PaymentStatus.ToLowerInvariant();
            payment.TransactionCode = string.IsNullOrWhiteSpace(request.TransactionCode)
                ? payment.TransactionCode
                : request.TransactionCode.Trim();

            if (payment.PaymentStatus == "paid")
            {
                payment.PaidAt = DateTime.Now;
            }
            else if (payment.PaymentStatus == "failed")
            {
                payment.PaidAt = null;
            }

            await _context.SaveChangesAsync();
            return Ok(MapPaymentResponse(payment));
        }

        private static PaymentResponse MapPaymentResponse(Payment payment)
        {
            return new PaymentResponse
            {
                PaymentId = payment.PaymentId,
                BookingId = payment.BookingId,
                BookingCode = payment.Booking?.BookingCode,
                BookingTotalPrice = payment.Booking?.TotalPrice,
                PaymentMethod = payment.PaymentMethod,
                PaymentStatus = payment.PaymentStatus,
                TransactionCode = payment.TransactionCode,
                PaidAt = payment.PaidAt
            };
        }
    }
}
