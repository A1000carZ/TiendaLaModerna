using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TiendaLaModerna.Components.Models.Catalogo;
using TiendaLaModerna.Components.Repository.Catalogo;

namespace TiendaLaModerna.Components.Controllers.Catalogo
{
    [Route("api/catalogo/categorias")]
    [ApiController]
    public class CatalogoCategoriasController : ControllerBase
    {
        private readonly CategoriaRepositorio _categoriaRepositorio;

        public CatalogoCategoriasController(CategoriaRepositorio categoriaRepositorio)
        {
            _categoriaRepositorio = categoriaRepositorio;
        }


        [HttpGet]
        public async Task<ActionResult<IEnumerable<CatalogoCategorias>>> GetCategorias()
        {
            try
            {
                var categorias = await _categoriaRepositorio.GetAllAsync();
                if (categorias == null || !categorias.Any())
                {
                    return NotFound("No hay categorias");
                }
                return Ok(categorias);
            }
            catch (Exception e)
            {
                return StatusCode(500, new { message = "Error en el servidor", error = e.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<CatalogoCategorias>> GetCategoria(int id)
        {
            try
            {
                var categoria = await _categoriaRepositorio.ReadAsync(id);
                if (categoria == null)
                {
                    return NotFound($"Categoria con ID {id} no encontrada");
                }
                return Ok(categoria);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error en el servidor", error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<CatalogoCategorias>> CreateCategoria([FromForm] CatalogoCategorias categoria)
        {
            if (categoria == null)
            {
                return BadRequest("Categoria no puede ser nula");
            }
            if (string.IsNullOrWhiteSpace(categoria.nombre))
            {
                return BadRequest("El nombre de la categoria es requerido");
            }
            try
            {
                var createdCategoria = await _categoriaRepositorio.CreateAsync(categoria);
                return CreatedAtAction(nameof(GetCategoria), new { id = createdCategoria.id }, createdCategoria);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error al crear la categoria", error = ex.Message });
            }
        }
    }
}
