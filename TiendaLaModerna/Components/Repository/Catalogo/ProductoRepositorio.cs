using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using TiendaLaModerna.Components.Models.Catalogo;
using TiendaLaModerna.Data;

namespace TiendaLaModerna.Components.Repository.Catalogo
{
    public class ProductoRepositorio : Repository<Producto, int>
    {
        private readonly TiendaLaModernaContext _context;

        public ProductoRepositorio(TiendaLaModernaContext context)
        {
            _context = context;
        }

        public async Task<Producto> CreateAsync(Producto entity)
        {
            var parameters = new[]
            {
                new SqlParameter("@nombre", entity.Name ?? (object)DBNull.Value),
                new SqlParameter("@categoria_id", entity.CategoriaId ?? (object)DBNull.Value),
                new SqlParameter("@precio", entity.Precio),
                new SqlParameter("@costo_promedio", entity.CostoPromedio),
                new SqlParameter("@img", entity.Img ?? (object)DBNull.Value),
                new SqlParameter("@promocion", entity.Promocion),
                new SqlParameter("@agotado", entity.Agotado),
                new SqlParameter("@umbral_inventario", entity.UmbralInventario),
                new SqlParameter("@requiere_vencimiento", entity.RequiereVencimiento),
                new SqlParameter("@activo", entity.Activo)
            };

            // Ejecutar procedimiento y recuperar el ID insertado
            var result = await _context.Database.SqlQueryRaw<int>(
                "EXEC sp_InsertProducto @nombre, @categoria_id, @precio, @costo_promedio, @img, @promocion, @agotado, @umbral_inventario, @requiere_vencimiento, @activo",
                parameters).FirstAsync();

            entity.Id = result;
            return entity;
        }

        public async Task DeleteAsync(int id)
        {
            var parameter = new SqlParameter("@id", id);
            await _context.Database.ExecuteSqlRawAsync("EXEC sp_DeleteProducto @id", parameter);
        }

        public async Task<bool> Exists(int id)
        {
            var parameter = new SqlParameter("@id", id);
            var result = await _context.Set<Producto>()
                .FromSqlRaw("EXEC sp_GetProductoById @id", parameter)
                .FirstOrDefaultAsync();
            return result != null;
        }

        public async Task<IEnumerable<Producto>> GetAllAsync()
        {
            return await _context.Set<Producto>()
                .FromSqlRaw("EXEC sp_GetProductos")
                .ToListAsync();
        }

        public async Task<Producto> ReadAsync(int id)
        {
            var parameter = new SqlParameter("@id", id);
            var results = await _context.Set<Producto>()
                .FromSqlRaw("EXEC sp_GetProductoById @id", parameter)
                .ToListAsync();

            return results.FirstOrDefault();
        }

        public async Task<Producto> UpdateAsync(Producto entity)
        {
            try
            {
                var parameters = new[]
                {
                    new SqlParameter("@id", entity.Id),
                    new SqlParameter("@nombre", entity.Name ?? (object)DBNull.Value),
                    new SqlParameter("@categoria_id", entity.CategoriaId ?? (object)DBNull.Value),
                    new SqlParameter("@precio", entity.Precio),
                    new SqlParameter("@costo_promedio", entity.CostoPromedio),
                    new SqlParameter("@img", entity.Img ?? (object)DBNull.Value),
                    new SqlParameter("@promocion", entity.Promocion),
                    new SqlParameter("@agotado", entity.Agotado),
                    new SqlParameter("@umbral_inventario", entity.UmbralInventario),
                    new SqlParameter("@requiere_vencimiento", entity.RequiereVencimiento),
                    new SqlParameter("@activo", entity.Activo)
                };

                Console.WriteLine($"Executing sp_UpdateProducto with: ID={entity.Id}, Name={entity.Name}, Price={entity.Precio}, Active={entity.Activo}");

                var rowsAffected = await _context.Database.ExecuteSqlRawAsync(
                    "EXEC sp_UpdateProducto @id, @nombre, @categoria_id, @precio, @costo_promedio, @img, @promocion, @agotado, @umbral_inventario, @requiere_vencimiento, @activo",
                    parameters);

                Console.WriteLine($"Rows affected: {rowsAffected}");

                return entity;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in UpdateAsync: {ex.Message}");
                throw;
            }
        }

        // Método adicional específico para productos por categoría
        public async Task<IEnumerable<Producto>> GetProductosByCategoriaAsync(int categoriaId)
        {
            var parameter = new SqlParameter("@categoria_id", categoriaId);
            return await _context.Set<Producto>()
                .FromSqlRaw("EXEC sp_GetProductosByCategoria @categoria_id", parameter)
                .ToListAsync();
        }
    }
}
