using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Inventario
{
    public class LotesStock
    {
        public int Id { get; set; }
        public required Producto Producto { get; set; }
        public string? NumeroLote { get; set; }
        public DateOnly FechaVencimiento { get; set; }
        public float PrecioCosto { get; set; }
        public int CantidadRecibida { get; set; }
        public int CantidadRestante { get; set; }
        public DateTime FechaRecepcion { get; set; }

        public Proveedor? Proveedor { get; set; }

        public bool Activo { get; set; }
    }
}