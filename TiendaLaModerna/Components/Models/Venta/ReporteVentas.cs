using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace TiendaLaModerna.Components.Models.Venta
{
    public class ReporteVentas
    {
        [Column("Fecha")]
        public DateTime Fecha { get; set; }

        [Column("TotalVentas")]
        public int TotalVentas { get; set; }

        [Column("IngresosTotales")]
        public decimal IngresosTotales { get; set; }

        [Column("TotalEfectivo")]
        public decimal TotalEfectivo { get; set; }
    }
}
