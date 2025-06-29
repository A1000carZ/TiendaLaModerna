using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TiendaLaModerna.Components.Models.Catalogo;

namespace TiendaLaModerna.Data
{
    public class TiendaLaModernaContext : DbContext
    {
        public TiendaLaModernaContext (DbContextOptions<TiendaLaModernaContext> options)
            : base(options)
        {
        }

        public DbSet<CatalogoCategorias> CatalogoCategorias { get; set; } = default!;
    }
}
