using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Inventario
{
    [Table("MovimientosInventario")]
    public class MovimientoInventario
    {
        [Key]
        [Column("id", TypeName = "INT")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int? Id { get; set; }

        [ForeignKey("producto_id")]
        [Column("producto_id", TypeName = "INT")]
        public int? ProductoId { get; set; }
        

        [ForeignKey("lote_id")]
        [Column("lote_id", TypeName = "INT")]
        public int? LoteId { get; set; }
        

        [Required]
        [Column("tipo_movimiento", TypeName = "VARCHAR(20)")]
        public required string TipoMovimiento { get; set; }

        [Column("cantidad", TypeName = "INT")]
        public int Cantidad { get; set; }

        [Column("tipo_referencia", TypeName = "VARCHAR(20)")]
        public string? TipoReferencia { get; set; }

        [Column("referencia_id", TypeName = "INT")]
        public int? Referencia { get; set; }

        
        [Column("notas", TypeName = "VARCHAR(200)")]
        public string? Notas { get; set; }

        [Column("fecha_movimiento", TypeName = "DATETIME")]
        public DateTime FechaMovimiento { get; set; }

        public virtual Producto Producto { get; set; } = default!;
        public virtual LotesStock Lote { get; set; } = default!;

        public MovimientoInventario() { 
            TipoMovimiento = "ENTRADA";
        }

    }
}