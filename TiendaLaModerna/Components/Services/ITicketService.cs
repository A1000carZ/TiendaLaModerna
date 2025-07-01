using TiendaLaModerna.Components.Models.Venta;

namespace TiendaLaModerna.Services
{
    public interface ITicketService
    {
        string GenerateReceiptHtml(Venta venta);
        Task<byte[]> GenerateReceiptPdfAsync(Venta venta);
    }
}