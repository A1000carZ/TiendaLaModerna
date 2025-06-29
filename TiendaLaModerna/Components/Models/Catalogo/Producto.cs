using System.ComponentModel.DataAnnotations;

namespace TiendaLaModerna.Components.Models.Catalogo
{
    public class Producto
    {
        [Key]
        public int Id { get; set; }
        public required string Name { get; set; }
        public CatalogoCategorias? categoria { get; set; }
        public required float Precio { get; set; }
        public required float CostoPromedio { get; set; }
        public string? Img { get; set; }

        public bool Promocion { get; set; }

        public bool Agotado { get; set; }

        public int UmbralInventario { get; set; }

        public bool RequiereVencimiento { get; set; }
        public bool Activo { get; set; }

        public DateTime FechaCreacion { get; set; }
        
    }
}
