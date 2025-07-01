using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Notificacion
{
    [Table("Notificacion")]
    public class Notificaciones
    {
        [Key]
        [Column("id")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [ForeignKey("CatalogoProductos")]
        [Column("producto_id")]
        public int ProductoId { get; set; }
       

        [Column("email", TypeName = "varchar(255)")]
        public string Email { get; set; } = string.Empty;

        [Column("tipo", TypeName = "varchar(20)")]
        public string Tipo { get; set; } = string.Empty;

        [Column("mensaje", TypeName = "varchar(255)")]
        public string Mensaje { get; set; } = string.Empty;

        [Column("activo", TypeName = "bit")]
        public bool Activo { get; set; } = true;

        [Column("fecha_creacion", TypeName = "datetime2")]
        public DateTime FechaCreacion { get; set; } = DateTime.Now;

        public virtual Producto? Producto { get; set; } = default!;
    }
}