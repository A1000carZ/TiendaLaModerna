using TiendaLaModerna.Components.Models.Catalogo;
using TiendaLaModerna.Components.Models.Inventario;

namespace TiendaLaModerna.Components.Models.Venta
{
    public class Venta
    {
        public int? Id { get; set; }
        public Cliente? cliente { get; set; }
        public required string NumeroOrden { get; set; }
        public DateTime FechaVenta { get; set; }
        public required float MontoTotal { get; set; }
        public required string MetodoPago { get; set; }
        public required string EstatusVenta { get; set; }
        public required string EstatusEntrega { get; set; }
        public required string Notas { get; set; }

        public required string EntregadoPor { get; set; }

        public required DetalleVenta[] Items { get; set; }
    }

    public class DetalleVenta
    {
        public int? Id { get; set; }
        public Producto? Producto { get; set; }
        public int CantidadSolicitada { get; set; }
        public int CantidadEntregada { get; set; }

        public float PrecioUnitario { get; set; }
        public float TotalLinea { get; set; }
        public required string EstatusEntrega { get; set; }

        public DateTime FechaEntrega { get; set; }
        public string? Notas { get; set; }

        public DetalleEntrega[]? Entregas { get; set; }
    }
    
    public class DetalleEntrega
    {
        public int? Id { get; set; }
        public LotesStock? Lote { get; set; }
        public string? FuenteEntrega { get; set; }
        public int CantidadEntregada { get; set; }
        public DateTime FechaEntrega { get; set; }
        public required string EntregadoPor { get; set; }
        public string? Notas { get; set; }
    }
}