using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PRM_Backend_Server.Models;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace PRM_Backend_Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ServiceCategoryController : ControllerBase
    {
        private readonly HomeServiceAppContext _context;
        public ServiceCategoryController(HomeServiceAppContext context)
        {
            _context = context;
        }

        // GET: api/ServiceCategory
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ServiceCategory>>> GetCategories()
        {
            return await _context.ServiceCategories.ToListAsync();
        }

        // GET: api/ServiceCategory/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ServiceCategory>> GetCategory(int id)
        {
            var category = await _context.ServiceCategories.FindAsync(id);
            if (category == null)
                return NotFound();
            return category;
        }

        // POST: api/ServiceCategory
        [HttpPost]
        public async Task<ActionResult<ServiceCategory>> CreateCategory(ServiceCategory category)
        {
            _context.ServiceCategories.Add(category);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetCategory), new { id = category.CategoryId }, category);
        }

        // PUT: api/ServiceCategory/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCategory(int id, ServiceCategory category)
        {
            if (id != category.CategoryId)
                return BadRequest();
            _context.Entry(category).State = EntityState.Modified;
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.ServiceCategories.Any(e => e.CategoryId == id))
                    return NotFound();
                else
                    throw;
            }
            return NoContent();
        }

        // DELETE: api/ServiceCategory/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            var category = await _context.ServiceCategories.FindAsync(id);
            if (category == null)
                return NotFound();
            _context.ServiceCategories.Remove(category);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
