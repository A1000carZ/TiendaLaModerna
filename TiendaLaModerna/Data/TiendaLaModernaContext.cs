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
        public DbSet<TiendaLaModerna.Components.Models.Inventario.LotesStock> LotesStock { get; set; } = default!;
        public DbSet<TiendaLaModerna.Components.Models.Inventario.Proveedor> Proveedor { get; set; } = default!;
        public DbSet<TiendaLaModerna.Components.Models.Venta.Venta> Venta { get; set; } = default!;
        public DbSet<TiendaLaModerna.Components.Models.Venta.DetalleVenta> DetalleVenta { get; set; } = default!;
        public DbSet<TiendaLaModerna.Components.Models.Venta.DetalleEntrega> DetalleEntrega { get; set; } = default!;
        public DbSet<TiendaLaModerna.Components.Models.Inventario.MovimientoInventario> MovimientoInventario { get; set; } = default!;
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Producto>()
                .ToTable(tb => tb.HasTrigger("tr_InsertStockProducto"));

            modelBuilder.Entity<DetalleEntrega>()
                          .ToTable(tb => tb.HasTrigger("tr_DetalleEntregas"));
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

            modelBuilder.Entity<Producto>()
                .HasMany(p => p.Lotes)
                .WithOne(l => l.Producto)
                .HasForeignKey(l => l.ProductoId)
                .OnDelete(DeleteBehavior.Cascade); // Ensures lots are deleted if product is deleted
            
            modelBuilder.Entity<Venta>()
                .HasMany(v => v.Items)
                .WithOne(dv => dv.Venta)
                .HasForeignKey(dv => dv.VentaId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<DetalleVenta>()
                .HasMany(dv => dv.Entregas)
                .WithOne(e => e.DetalleVenta)
                .HasForeignKey(e => e.DetalleVentaId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovimientoInventario>()
                .ToTable(tb => tb.HasTrigger("tr_MovimientosInventario"));
        }
      
    }
}
