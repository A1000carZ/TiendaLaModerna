using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TiendaLaModerna.Components.Models.Inventario
{
    [Table("Proveedores")]
    public class Proveedor
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Required]
        [Column("nombre", TypeName = "varchar(100)")]
        public string Nombre { get; set; } = string.Empty;

        [Column("apellido", TypeName = "varchar(100)")]
        public string Apellido { get; set; } = string.Empty;

        [Column("empresa", TypeName = "varchar(100)")]
        public string Empresa { get; set; } = string.Empty;

        [Column("telefono", TypeName = "varchar(15)")]
        public string Telefono { get; set; } = string.Empty;

        [Column("email", TypeName = "varchar(100)")]
        public string Email { get; set; } = string.Empty;

        [Column("activo", TypeName = "bit")]
        public bool Activo { get; set; } = true;
    }
}
