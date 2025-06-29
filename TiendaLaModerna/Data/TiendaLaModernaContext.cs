using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TiendaLaModerna.Components.Models.Catalogo;
using TiendaLaModerna.Components.Models.Inventario;
using TiendaLaModerna.Components.Models.Venta;

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
        public DbSet<TiendaLaModerna.Components.Models.Inventario.StockProducto> StockProducto { get; set; } = default!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Producto>()
                .ToTable(tb => tb.HasTrigger("tr_InsertStockProducto"));


            modelBuilder.Entity<Producto>()
                .HasOne(p => p.Categoria)
                .WithMany(c => c.Productos)
                .HasForeignKey(p => p.CategoriaId)
                .OnDelete(DeleteBehavior.SetNull); // or Cascade, depending on your needs

            modelBuilder.Entity<Producto>()
                .HasOne(p => p.Stock)
                .WithOne(s => s.Producto)
                .HasForeignKey<StockProducto>(s => s.ProductoId)
                .OnDelete(DeleteBehavior.Cascade); // Ensures stock is deleted if product is deleted
        }
        public DbSet<TiendaLaModerna.Components.Models.Inventario.Proveedor> Proveedor { get; set; } = default!;
    }
}
