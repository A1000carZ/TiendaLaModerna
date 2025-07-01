using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TiendaLaModerna.Components.Models.Inventario;
using TiendaLaModerna.Components.Models.Notificacion;

namespace TiendaLaModerna.Components.Models.Catalogo
{
    [Table("CatalogoProductos")]
    public class Producto
    {
        [Key]
        [Column("id", TypeName = "int")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        [Column("nombre", TypeName = "varchar(100)")]
        public required string Name { get; set; }

        [Column("categoria_id")]
        public short? CategoriaId { get; set; }

        // Navigation property
        [ForeignKey("CategoriaId")]
        public virtual CatalogoCategorias? Categoria { get; set; }
        [Column("precio", TypeName = "decimal(10,2)")]
        public required decimal Precio { get; set; }
        [Column("costo_promedio", TypeName = "decimal(10,2)")]
        public required decimal CostoPromedio { get; set; }
        [Column("img", TypeName = "varchar(512)")]
        public string? Img { get; set; }
        [Column("promocion", TypeName = "bit")]
        public bool Promocion { get; set; }
        [Column("agotado", TypeName = "bit")]
        public bool Agotado { get; set; }
        [Column("umbral_inventario", TypeName = "int")]
        public int UmbralInventario { get; set; }
        [Column("requiere_vencimiento", TypeName = "bit")]
        public bool RequiereVencimiento { get; set; }
        [Column("activo", TypeName = "bit")]
        public bool Activo { get; set; }
        [Column("fecha_creacion", TypeName = "datetime")]
        public DateTime FechaCreacion { get; set; }

        public virtual StockProducto? Stock { get; set; }

        public virtual ICollection<LotesStock> Lotes { get; set; } = new List<LotesStock>();
        public virtual ICollection<Notificaciones> Notificaciones { get; set; } = new List<Notificaciones>();


    }
}
