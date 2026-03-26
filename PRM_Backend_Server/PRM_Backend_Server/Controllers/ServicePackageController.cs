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
    public class ServicePackageController : ControllerBase
    {
        private readonly HomeServiceAppContext _context;
        public ServicePackageController(HomeServiceAppContext context)
        {
            _context = context;
        }

        // GET: api/ServicePackage
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ServicePackage>>> GetPackages()
        {
            return await _context.ServicePackages.ToListAsync();
        }

        // GET: api/ServicePackage/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ServicePackage>> GetPackage(int id)
        {
            var package = await _context.ServicePackages.FindAsync(id);
            if (package == null)
                return NotFound();
            return package;
        }

        // GET: api/ServicePackage/category/5
        [HttpGet("category/{categoryId}")]
        public async Task<ActionResult<IEnumerable<ServicePackage>>> GetPackagesByCategory(int categoryId)
        {
            return await _context.ServicePackages.Where(p => p.CategoryId == categoryId).ToListAsync();
        }

        // POST: api/ServicePackage
        [HttpPost]
        public async Task<ActionResult<ServicePackage>> CreatePackage(ServicePackage package)
        {
            _context.ServicePackages.Add(package);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetPackage), new { id = package.PackageId }, package);
        }

        // PUT: api/ServicePackage/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePackage(int id, ServicePackage package)
        {
            if (id != package.PackageId)
                return BadRequest();
            _context.Entry(package).State = EntityState.Modified;
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.ServicePackages.Any(e => e.PackageId == id))
                    return NotFound();
                else
                    throw;
            }
            return NoContent();
        }

        // DELETE: api/ServicePackage/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePackage(int id)
        {
            var package = await _context.ServicePackages.FindAsync(id);
            if (package == null)
                return NotFound();
            _context.ServicePackages.Remove(package);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
