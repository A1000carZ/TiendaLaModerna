using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TiendaLaModerna.Components.Models.Venta;
using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Data
{
    public class TiendaLaModernaContext : DbContext
    {
        public TiendaLaModernaContext(DbContextOptions<TiendaLaModernaContext> options)
            : base(options)
        {
        }

        public DbSet<TiendaLaModerna.Components.Models.Catalogo.CatalogoCategorias> CatalogoCategorias { get; set; } = default!;
        public DbSet<TiendaLaModerna.Components.Models.Venta.Cliente> Cliente { get; set; } = default!;
        public DbSet<TiendaLaModerna.Components.Models.Catalogo.Producto> Producto { get; set; } = default!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Producto>()
                .HasOne(p => p.Categoria)
                .WithMany(c => c.Productos)
                .HasForeignKey(p => p.CategoriaId)
                .OnDelete(DeleteBehavior.SetNull); // or Cascade, depending on your needs
        }
    }
}
