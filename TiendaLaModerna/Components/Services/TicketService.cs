
using System.Text;
using TiendaLaModerna.Components.Models.Venta;
using TiendaLaModerna.Services;

namespace TiendaLaModerna.Services
{
    public class TicketService : ITicketService
    {
        public string GenerateReceiptHtml(Venta venta)
        {
            var html = new StringBuilder();

            html.Append(@"<!DOCTYPE html>
<html lang='es'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Ticket - Tienda La Moderna</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Courier New', monospace; background-color: white; padding: 8px; }
        .ticket { width: 80mm; background: white; }
        .header { text-align: center; margin-bottom: 10px; border-bottom: 1px dashed #333; padding-bottom: 8px; }
        .store-name { font-size: 16px; font-weight: bold; margin-bottom: 3px; }
        .store-info { font-size: 10px; line-height: 1.2; }
        .order-info { margin: 8px 0; font-size: 11px; }
        .order-row { display: flex; justify-content: space-between; margin-bottom: 2px; }
        .items-section { border-top: 1px dashed #333; border-bottom: 1px dashed #333; padding: 6px 0; margin: 8px 0; }
        .item-header { font-size: 10px; font-weight: bold; display: flex; justify-content: space-between; margin-bottom: 4px; }
        .item { font-size: 10px; margin-bottom: 4px; }
        .item-name { font-weight: bold; margin-bottom: 1px; }
        .item-details { display: flex; justify-content: space-between; color: #555; }
        .totals { font-size: 11px; margin: 6px 0; }
        .total-row { display: flex; justify-content: space-between; margin-bottom: 2px; }
        .total-final { font-weight: bold; font-size: 13px; border-top: 1px solid #333; padding-top: 3px; margin-top: 4px; }
        .payment-info { margin: 8px 0; font-size: 11px; text-align: center; }
        .footer { text-align: center; font-size: 9px; margin-top: 10px; border-top: 1px dashed #333; padding-top: 6px; }
        .status { background: #e8f5e8; color: #2d5d2d; padding: 2px 4px; border-radius: 3px; font-size: 9px; display: inline-block; }
        .status.pending { background: #fff3cd; color: #856404; }
        .notes { font-size: 9px; font-style: italic; margin-top: 4px; color: #666; }
        @media print { body { padding: 0; } .ticket { width: 80mm; } }
    </style>
</head>
<body>
    <div class='ticket'>");

            // Header
            html.Append(@"
        <div class='header'>
            <div class='store-name'>TIENDA LA MODERNA</div>
            <div class='store-info'>
                Av. Principal #123<br>
                Col. Centro, Ciudad<br>
                Tel: (555) 123-4567
            </div>
        </div>");

            // Order Information
            html.Append($@"
        <div class='order-info'>
            <div class='order-row'>
                <span>Orden:</span>
                <span><strong>{venta.NumeroOrden}</strong></span>
            </div>
            <div class='order-row'>
                <span>Fecha:</span>
                <span>{venta.FechaVenta:dd/MM/yyyy HH:mm}</span>
            </div>
            <div class='order-row'>
                <span>Cliente:</span>
                <span>{venta.Cliente?.Nombre ?? "Cliente General"}</span>
            </div>
            <div class='order-row'>
                <span>Estado:</span>
                <span class='status{(venta.EstatusVenta == "PENDIENTE" ? " pending" : "")}'>{venta.EstatusVenta}</span>
            </div>
        </div>");

            // Items
            html.Append(@"
        <div class='items-section'>
            <div class='item-header'>
                <span>DESCRIPCIÓN</span>
                <span>TOTAL</span>
            </div>");

            foreach (var detalle in venta.Items)
            {
                html.Append($@"
            <div class='item'>
                <div class='item-name'>{detalle.Producto?.Name}</div>
                <div class='item-details'>
                    <span>{detalle.CantidadSolicitada} x ${detalle.PrecioUnitario:F2}</span>
                    <span>${detalle.TotalLinea:F2}</span>
                </div>
            </div>");
            }

            html.Append("</div>");

            // Totals
            html.Append($@"
        <div class='totals'>
            <div class='total-row'>
                <span>Subtotal:</span>
                <span>${venta.MontoSubtotal:F2}</span>
            </div>
            <div class='total-row'>
                <span>Descuento:</span>
                <span>-${venta.MontoDescuento:F2}</span>
            </div>
            <div class='total-row total-final'>
                <span>TOTAL:</span>
                <span>${venta.MontoTotal:F2}</span>
            </div>
        </div>");

            
            html.Append($@"
        <div class='payment-info'>
            <strong>MÉTODO DE PAGO: {venta.MetodoPago}</strong>
        </div>
        
        <div class='order-info'>
            <div class='order-row'>
                <span>Entrega:</span>
                <span class='status{(venta.EstatusEntrega == "PENDIENTE" ? " pending" : "")}'>{venta.EstatusEntrega}</span>
            </div>");

            if (venta.FechaEntrega != null)
            {
                html.Append($@"
            <div class='order-row'>
                <span>Fecha entrega:</span>
                <span>{venta.FechaEntrega:dd/MM/yyyy HH:mm}</span>
            </div>");
            }

            if (!string.IsNullOrEmpty(venta.EntregadoPor))
            {
                html.Append($@"
            <div class='order-row'>
                <span>Entregado por:</span>
                <span>{venta.EntregadoPor}</span>
            </div>");
            }

            html.Append("</div>");

          
            if (!string.IsNullOrEmpty(venta.Notas))
            {
                html.Append($@"
        <div class='notes'>
            {venta.Notas}
        </div>");
            }

            
            html.Append(@"
        <div class='footer'>
            ¡Gracias por su compra!<br>
            Conserve este ticket<br>
            www.tiendalamoderna.com
        </div>
    </div>
</body>
</html>");

            return html.ToString();
        }

        public async Task<byte[]> GenerateReceiptPdfAsync(Venta venta)
        {
           
            var html = GenerateReceiptHtml(venta);
            return Encoding.UTF8.GetBytes(html);
        }
    }
}