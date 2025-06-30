using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Inventario
{
    public class LotesStock
    {
        [Key]
        [Column("id")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [ForeignKey("CatalogoProductos")]
        [Column("producto_id")]
        public int ProductoId { get; set; }

        [ForeignKey("Proveedores")]
        [Column("proveedor_id")]
        public int ProveedorId { get; set; }

        [Column("numero_lote", TypeName = "varchar(50)")]
        public string? NumeroLote { get; set; }

        [Column("fecha_vencimiento", TypeName = "date")]
        public DateOnly FechaVencimiento { get; set; }

        [Column("precio_costo", TypeName = "decimal(12,2)")]
        public float PrecioCosto { get; set; }

        [Column("cantidad_recibida", TypeName = "int")]
        public int CantidadRecibida { get; set; }

        [Column("cantidad_restante", TypeName = "int")]
        public int CantidadRestante { get; set; }

        [Column("fecha_recepcion", TypeName = "datetime")]
        public DateTime FechaRecepcion { get; set; }

        [Column("activo", TypeName = "bit")]
        public bool Activo { get; set; }


        public virtual Proveedor? Proveedor { get; set; }
        public virtual Producto Producto { get; set; } = default!;
    }
}