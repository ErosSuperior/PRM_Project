using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PRM_Backend_Server.Models;
using PRM_Backend_Server.ViewModels.Request;
using PRM_Backend_Server.ViewModels.Response;

namespace PRM_Backend_Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RatingController : ControllerBase
    {
        private readonly HomeServiceAppContext _context;

        public RatingController(HomeServiceAppContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<RatingResponse>>> GetAllRatings()
        {
            var ratings = await _context.Ratings
                .Include(r => r.Booking)
                .Include(r => r.Customer)
                .Include(r => r.Worker)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(ratings.Select(MapRatingResponse));
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<RatingResponse>> GetRatingById(int id)
        {
            var rating = await _context.Ratings
                .Include(r => r.Booking)
                .Include(r => r.Customer)
                .Include(r => r.Worker)
                .FirstOrDefaultAsync(r => r.RatingId == id);

            if (rating == null)
            {
                return NotFound(new { message = "Rating not found" });
            }

            return Ok(MapRatingResponse(rating));
        }

        [HttpGet("worker/{workerId:int}")]
        public async Task<ActionResult<IEnumerable<RatingResponse>>> GetRatingsByWorker(int workerId)
        {
            var ratings = await _context.Ratings
                .Include(r => r.Booking)
                .Include(r => r.Customer)
                .Include(r => r.Worker)
                .Where(r => r.WorkerId == workerId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(ratings.Select(MapRatingResponse));
        }

        [HttpGet("booking/{bookingId:int}")]
        public async Task<ActionResult<IEnumerable<RatingResponse>>> GetRatingsByBooking(int bookingId)
        {
            var ratings = await _context.Ratings
                .Include(r => r.Booking)
                .Include(r => r.Customer)
                .Include(r => r.Worker)
                .Where(r => r.BookingId == bookingId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(ratings.Select(MapRatingResponse));
        }

        [HttpPost]
        public async Task<ActionResult<RatingResponse>> CreateRating([FromBody] RatingRequest.CreateRatingRequest request)
        {
            if (request == null)
            {
                return BadRequest(new { message = "Invalid request" });
            }

            if (request.RatingScore < 1 || request.RatingScore > 5)
            {
                return BadRequest(new { message = "Rating score must be between 1 and 5" });
            }

            var booking = await _context.Bookings
                .Include(b => b.Customer)
                .Include(b => b.Worker)
                .FirstOrDefaultAsync(b => b.BookingId == request.BookingId);

            if (booking == null)
            {
                return BadRequest(new { message = "Booking does not exist" });
            }

            if (!string.Equals(booking.Status, "completed", StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest(new { message = "Only completed bookings can be rated" });
            }

            if (booking.WorkerId == null)
            {
                return BadRequest(new { message = "This booking has no assigned worker" });
            }

            if (booking.CustomerId != request.CustomerId)
            {
                return BadRequest(new { message = "This customer is not allowed to rate the booking" });
            }

            var existed = await _context.Ratings.AnyAsync(r => r.BookingId == request.BookingId && r.CustomerId == request.CustomerId);
            if (existed)
            {
                return BadRequest(new { message = "This booking has already been rated" });
            }

            var rating = new Rating
            {
                BookingId = booking.BookingId,
                CustomerId = request.CustomerId,
                WorkerId = booking.WorkerId.Value,
                RatingScore = request.RatingScore,
                Comment = request.Comment,
                CreatedAt = DateTime.Now
            };

            _context.Ratings.Add(rating);
            await _context.SaveChangesAsync();

            rating.Booking = booking;
            rating.Customer = booking.Customer;
            rating.Worker = booking.Worker!;

            return CreatedAtAction(nameof(GetRatingById), new { id = rating.RatingId }, MapRatingResponse(rating));
        }

        private static RatingResponse MapRatingResponse(Rating rating)
        {
            return new RatingResponse
            {
                RatingId = rating.RatingId,
                BookingId = rating.BookingId,
                BookingCode = rating.Booking?.BookingCode,
                CustomerId = rating.CustomerId,
                CustomerName = rating.Customer?.FullName,
                WorkerId = rating.WorkerId,
                WorkerName = rating.Worker?.FullName,
                RatingScore = rating.RatingScore,
                Comment = rating.Comment,
                CreatedAt = rating.CreatedAt
            };
        }
    }
}
