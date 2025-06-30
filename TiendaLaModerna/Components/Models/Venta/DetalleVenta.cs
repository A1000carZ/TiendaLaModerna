using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Venta
{
    [Table("DetalleVentas")]
    public class DetalleVenta
    {
        [Key]
        [Column("id")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [ForeignKey("Venta")]
        [Column("venta_id")]
        public int VentaId { get; set; }

        public Venta? Venta { get; set; }

        [ForeignKey("Producto")]
        [Column("producto_id")]
        public int ProductoId { get; set; }

        public Producto? Producto { get; set; }

        [Required]
        [Column("cantidad_solicitada")]
        public int CantidadSolicitada { get; set; }

        [Column("cantidad_entregada")]
        public int CantidadEntregada { get; set; } = 0;

        [Required]
        [Column("precio_unitario", TypeName = "decimal(10,2)")]
        public decimal PrecioUnitario { get; set; }

        [Required]
        [Column("total_linea", TypeName = "decimal(12,2)")]
        public decimal TotalLinea { get; set; }

        [Required]
        [Column("descuento_linea", TypeName = "decimal(12,2)")]
        public decimal DescuentoLinea { get; set; }

        [Required]
        [Column("estatus_entrega", TypeName = "varchar(30)")]
        public string EstatusEntrega { get; set; } = "PENDIENTE";

        [Column("fecha_entrega", TypeName = "datetime")]
        public DateTime? FechaEntrega { get; set; }

        [Column("notas_entrega", TypeName = "varchar(200)")]
        public string? Notas { get; set; }

        public virtual ICollection<DetalleEntrega>? Entregas { get; set; }
    }
}