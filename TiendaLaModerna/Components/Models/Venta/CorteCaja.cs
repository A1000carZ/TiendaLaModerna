using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TiendaLaModerna.Components.Models.Venta
{
    [Table("CorteCaja")]
    public class CorteCaja
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Required]
        [Column("fecha", TypeName = "date")]
        public DateTime Fecha { get; set; }

        [Column("saldo_inicial", TypeName = "decimal(12,2)")]
        public decimal SaldoInicial { get; set; } = 0;

        [Column("total_ventas", TypeName = "decimal(12,2)")]
        public decimal TotalVentas { get; set; } = 0;

        [Column("efectivo_recibido", TypeName = "decimal(12,2)")]
        public decimal EfectivoRecibido { get; set; } = 0;

        [Column("saldo_final", TypeName = "decimal(12,2)")]
        public decimal SaldoFinal { get; set; } = 0;

        [Column("notas")]
        [MaxLength(200)]
        public string? Notas { get; set; }

        [Column("cerrado_por")]
        [MaxLength(100)]
        public string? CerradoPor { get; set; }

        [Column("fecha_cierre")]
        public DateTime? FechaCierre { get; set; }
    }
}