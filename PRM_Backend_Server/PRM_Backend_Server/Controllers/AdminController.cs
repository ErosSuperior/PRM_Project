using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PRM_Backend_Server.Models;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

namespace PRM_Backend_Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        private readonly HomeServiceAppContext _context;
        public AdminController(HomeServiceAppContext context)
        {
            _context = context;
        }

        // GET: api/Admin/users
        [HttpGet("users")]
        public async Task<ActionResult<IEnumerable<User>>> GetUsers()
        {
            return await _context.Users.ToListAsync();
        }

        // PUT: api/Admin/user/activate/5
        [HttpPut("user/activate/{id}")]
        public async Task<IActionResult> ActivateUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound();
            user.IsActive = true;
            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // PUT: api/Admin/user/deactivate/5
        [HttpPut("user/deactivate/{id}")]
        public async Task<IActionResult> DeactivateUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound();
            user.IsActive = false;
            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // GET: api/Admin/packages
        [HttpGet("packages")]
        public async Task<ActionResult<IEnumerable<ServicePackage>>> GetPackages()
        {
            return await _context.ServicePackages.ToListAsync();
        }

        // PUT: api/Admin/package/activate/5
        [HttpPut("package/activate/{id}")]
        public async Task<IActionResult> ActivatePackage(int id)
        {
            var package = await _context.ServicePackages.FindAsync(id);
            if (package == null)
                return NotFound();
            package.IsActive = true;
            _context.Entry(package).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // PUT: api/Admin/package/deactivate/5
        [HttpPut("package/deactivate/{id}")]
        public async Task<IActionResult> DeactivatePackage(int id)
        {
            var package = await _context.ServicePackages.FindAsync(id);
            if (package == null)
                return NotFound();
            package.IsActive = false;
            _context.Entry(package).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
