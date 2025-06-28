using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Notificacion
{
    public class NotificacionStock
    {
        public int Id { get; set; }
        public Producto? Producto { get; set; }
        public string? Email { get; set; }
        public required string Tipo { get; set; }
        public bool Activo { get; set; } 
        public DateTime FechaCreacion { get; set; } 
    }
}