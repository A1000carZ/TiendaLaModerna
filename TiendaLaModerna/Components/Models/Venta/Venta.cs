using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TiendaLaModerna.Components.Models.Catalogo;
using TiendaLaModerna.Components.Models.Inventario;

namespace TiendaLaModerna.Components.Models.Venta
{
    [Table("Ventas")]
    public class Venta
    {
        [Key]
        [Column("id")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [ForeignKey("Cliente")]
        [Column("cliente_id")]
        public int? ClienteId { get; set; }

        public Cliente? Cliente { get; set; }

        [Required]
        [Column("numero_orden", TypeName = "varchar(20)")]
        public string NumeroOrden { get; set; } = string.Empty;

        [Column("fecha_venta", TypeName = "datetime")]
        public DateTime FechaVenta { get; set; } = DateTime.Now;

        [Column("monto_subtotal", TypeName = "decimal(12,2)")]
        public decimal MontoSubtotal { get; set; } = 0;
        [Column("monto_descuento", TypeName = "decimal(12,2)")]
        public decimal MontoDescuento { get; set; } = 0;
        [Column("monto_total", TypeName = "decimal(12,2)")]
        public decimal MontoTotal { get; set; } = 0;

        [Required]
        [Column("metodo_pago", TypeName = "varchar(20)")]
        public string MetodoPago { get; set; } = "EFECTIVO";

        [Required]
        [Column("estatus_venta", TypeName = "varchar(20)")]
        public string EstatusVenta { get; set; } = "PENDIENTE";

        [Required]
        [Column("estatus_entrega", TypeName = "varchar(30)")]
        public string EstatusEntrega { get; set; } = "PENDIENTE";

        [Column("fecha_entrega", TypeName = "datetime")]
        public DateTime FechaEntrega { get; set; } = DateTime.Now;

        [Column("notas", TypeName = "varchar(200)")]
        public string? Notas { get; set; }

        [Required]
        [Column("entregado_por", TypeName = "varchar(100)")]
        public string EntregadoPor { get; set; } = string.Empty;

        public virtual ICollection<DetalleVenta> Items { get; set; } = new List<DetalleVenta>();
    }
}