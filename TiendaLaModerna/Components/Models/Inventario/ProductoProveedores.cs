using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Components.Models.Inventario
{
    public class ProductoProveedores
    {
        public int Id { get; set; }
        public Producto? Producto { get; set; }
        public string? CodigoProveedor { get; set; }
        public float PrecioCosto { get; set; }
        public bool EsProveedorPrincipal { get; set; }
    
    }
}