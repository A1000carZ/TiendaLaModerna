using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Inventario
{
    public class MovimientoInventario
    {
        public int? Id { get; set; }
        public Producto? Producto { get; set; }
        public LotesStock? Lote { get; set; }
        public required string TipoMovimiento { get; set; }
        public int Cantidad { get; set; }
        public string? TipoReferencia { get; set; }
        public int? Referencia { get; set; }

        public required string Notas { get; set; }

        public DateTime FechaMovimiento { get; set; }
    }
}