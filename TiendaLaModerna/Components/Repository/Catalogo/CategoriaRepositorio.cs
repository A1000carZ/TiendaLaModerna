using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using TiendaLaModerna.Components.Models.Catalogo;
using TiendaLaModerna.Data;

namespace TiendaLaModerna.Components.Repository.Catalogo
{
    public class CategoriaRepositorio : Repository<CatalogoCategorias, int>
    {
        private readonly TiendaLaModernaContext _context;
        

        public CategoriaRepositorio(TiendaLaModernaContext context)
        {
            _context = context;
            
        }

        public async Task<CatalogoCategorias> CreateAsync(CatalogoCategorias entity)
        {
            var parameters = new[]
            {
                new SqlParameter("@nombre", entity.nombre ?? (object)DBNull.Value),
                new SqlParameter("@img", entity.img ?? (object)DBNull.Value),
                new SqlParameter("@activo", entity.activo),
                new SqlParameter("@id", SqlDbType.Int) { Direction = ParameterDirection.Output }
            };

            // Ejecutar procedimiento y recuperar el ID insertado
            var idResult = await _context.Database.ExecuteSqlRawAsync("EXEC sp_InsertCategoria @nombre, @img, @activo, @id OUTPUT", parameters);

            entity.id =(int) parameters[3].Value;
            return entity;
        }

        public async Task DeleteAsync(int id)
        {
            var parameter = new SqlParameter("@id", id);
            await _context.Database.ExecuteSqlRawAsync("EXEC sp_DeleteCategoria @id", parameter);
        }

        public async Task<bool> Exists(int id)
        {
            var parameter = new SqlParameter("@id", id);
            var result = await _context.CatalogoCategorias
        .FromSqlRaw("EXEC sp_GetCategoriaById @id", parameter)
        .FirstOrDefaultAsync();
            return result != null;
        }

        public async Task<IEnumerable<CatalogoCategorias>> GetAllAsync()
        {
            return await _context.CatalogoCategorias
                .FromSqlRaw("EXEC sp_GetCategorias")
                .ToListAsync();
        }

        public async Task<CatalogoCategorias> ReadAsync(int id)
        {
            var parameter = new SqlParameter("@id", id);
            var results = await _context.CatalogoCategorias
                .FromSqlRaw("EXEC sp_GetCategoriaById @id", parameter)
                .ToListAsync();

            return results.FirstOrDefault();
        }

        public async Task<CatalogoCategorias> UpdateAsync(CatalogoCategorias entity)
        {
            try
            {
                var parameters = new[]
                {
            new SqlParameter("@id", entity.id),
            new SqlParameter("@nombre", entity.nombre ?? (object)DBNull.Value),
            new SqlParameter("@img", entity.img ?? (object)DBNull.Value),
            new SqlParameter("@activo", entity.activo)
        };

                Console.WriteLine($"Executing sp_UpdateCategoria with: ID={entity.id}, Name={entity.nombre}, Active={entity.activo}");

                var rowsAffected = await _context.Database.ExecuteSqlRawAsync(
                    "EXEC sp_UpdateCategoria @id, @nombre, @img, @activo",
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
    }
}
