using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Inventario
{
    [Table("StockProductos")]
    public class StockProducto
    {
        [Key]
        [Column("id", TypeName = "int")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Column("producto_id", TypeName = "int")]
        public int ProductoId { get; set; }

        [Column("cantidad_disponible", TypeName = "int")]
        public int CantidadDisponible { get; set; } = 0;

        [Column("cantidad_reservada", TypeName = "int")]
        public int CantidadReservada { get; set; } = 0;

        [Column("ultima_actualizacion", TypeName = "datetime")]
        public DateTime UltimaActualizacion { get; set; } = DateTime.Now;

      
        [ForeignKey("ProductoId")]
        public virtual Producto? Producto { get; set; }
    }
}