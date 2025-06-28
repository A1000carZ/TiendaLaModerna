namespace TiendaLaModerna.Components.Models.Inventario
{
    public class Proveedor
    {
        public int? Id { get; set; }
        public required string Nombre { get; set; }
        public required string Apellido { get; set; }
        public required string Empresa { get; set; }
        public required string Telefono { get; set; }
        public required string Email { get; set; }
        public bool Activo { get; set; }

    }
}