using System.ComponentModel.DataAnnotations.Schema;

namespace TiendaLaModerna.Components.Models.Venta
{
   [Table("Clientes")]
    public class Cliente
    {
        public int? Id { get; set; }
        public required string Nombre { get; set; }
        public required string Apellido { get; set; }
        public required string Telefono { get; set; }
        public required string Email { get; set; }
        public bool Activo { get; set; }

        public Cliente() {
            
        }
    }
}