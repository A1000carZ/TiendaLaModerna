
using Microsoft.AspNetCore.Mvc;
using TiendaLaModerna.Components.Models.Catalogo;
using Microsoft.Data.SqlClient;
namespace TiendaLaModerna.Components.Controllers.Catalogo
{
    [ApiController]
    public class ProductoController : ControllerBase
    {
        string ConnectionString = "Data Source=192.168.1.73,1433;Initial Catalog=TiendaModerna;User ID=SA;Password=********;Connect Timeout=30;Encrypt=True;Trust Server Certificate=True;Application Intent=ReadWrite;Multi Subnet Failover=False";
        
        public static List<Producto>? Productos { get; set; }

        
    }

}
