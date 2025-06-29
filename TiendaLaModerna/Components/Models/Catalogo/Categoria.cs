using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TiendaLaModerna.Components.Models.Catalogo
{
    public class CatalogoCategorias
    {
        [Key]
        [Column("id", TypeName = "smallint")]
        public int id { get; set; }

        [Required]
        public string nombre { get; set; } = string.Empty;
        public string? img { get; set; }

        public bool activo { get; set; }

        public CatalogoCategorias() { }

        public virtual ICollection<Producto>? Productos { get; set; }

    }


}