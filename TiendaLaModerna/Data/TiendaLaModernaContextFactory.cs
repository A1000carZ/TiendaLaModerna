using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace TiendaLaModerna.Data
{
    public class TiendaLaModernaContextFactory : IDesignTimeDbContextFactory<TiendaLaModernaContext>
    {
        public TiendaLaModernaContext CreateDbContext(string[] args)
        {
            // Build configuration
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile("appsettings.Development.json", optional: true, reloadOnChange: true)
                .Build();

            // Create DbContextOptionsBuilder
            var optionsBuilder = new DbContextOptionsBuilder<TiendaLaModernaContext>();

            // Get connection string from configuration
            var connectionString = configuration.GetConnectionString("TiendaLaModernaContext");

            if (string.IsNullOrEmpty(connectionString))
            {
                throw new InvalidOperationException("Connection string 'TiendaLaModernaContext' not found in configuration.");
            }

            // Configure SQL Server
            optionsBuilder.UseSqlServer(connectionString);

            return new TiendaLaModernaContext(optionsBuilder.Options);
        }


    }
}