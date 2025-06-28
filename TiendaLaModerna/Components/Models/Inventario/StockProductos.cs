using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Inventario
{
    public class StockProducto
    {
        public int Id { get; set; }
        public required Producto Producto { get; set; }
        public int CantidadDisponible { get; set; }
        public int CantidadReservada { get; set; }
        public DateTime UltimaActualizacion { get; set; }

        public Proveedor? Proveedor { get; set; }
    }
}