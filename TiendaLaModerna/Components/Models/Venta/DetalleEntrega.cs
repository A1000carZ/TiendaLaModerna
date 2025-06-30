using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TiendaLaModerna.Components.Models.Inventario;

namespace TiendaLaModerna.Components.Models.Venta
{
    [Table("DetalleEntregas")]
    public class DetalleEntrega
    {
        [Key]
        [Column("id")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [ForeignKey("DetalleVenta")]
        [Column("detalle_venta_id")]
        public int DetalleVentaId { get; set; }

        public DetalleVenta? DetalleVenta { get; set; }

        [ForeignKey("Lote")]
        [Column("lote_id")]
        public int? LoteId { get; set; }

        public LotesStock? Lote { get; set; }

        [Required]
        [Column("fuente_entrega", TypeName = "varchar(20)")]
        public string FuenteEntrega { get; set; } = "PRODUCTO";

        [Required]
        [Column("cantidad_entregada")]
        public int CantidadEntregada { get; set; }

        [Column("fecha_entrega", TypeName = "datetime")]
        public DateTime FechaEntrega { get; set; } = DateTime.Now;

        [Column("entregado_por", TypeName = "varchar(100)")]
        public string? EntregadoPor { get; set; }

        [Column("notas", TypeName = "varchar(200)")]
        public string? Notas { get; set; }
    }
}