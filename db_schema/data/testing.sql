use TiendaModerna;


EXEC sp_InsertCategoria 
    @nombre = 'Bebidas', 
    @img = 'https://example.com/images/bebidas.jpg', 
    @activo = 1;

EXEC sp_InsertCategoria 
    @nombre = 'Perfiles', 
    @img = 'https://example.com/images/bebidas.jpg', 
    @activo = 1;

exec sp_GetCategorias;

EXEC sp_InsertProducto 
    @nombre = 'Coca Cola 600ml', 
    @categoria_id = 3, 
    @precio = 25.00, 
    @costo_promedio = 18.50, 
    @img = 'https://example.com/images/coca-cola-600ml.jpg',
    @promocion = 0,
    @agotado = 0,
    @umbral_inventario = 20,
    @requiere_vencimiento = 1,
    @activo = 1;

EXEC sp_InsertProducto 
    @nombre = 'Chambrana', 
    @categoria_id = 7, 
    @precio = 25.00, 
    @costo_promedio = 18.50, 
    @img = 'https://example.com/images/coca-cola-600ml.jpg',
    @promocion = 0,
    @agotado = 0,
    @requiere_vencimiento = 0;

exec sp_GetProductos


exec sp_DeleteProducto @id=2;

declare @customer_id int;
exec sp_InsertCliente @nombre = "Jesus",@apellido ="Jimenez";


DECLARE @venta_id INT;
EXEC sp_InsertVenta 
    @cliente_id = 1,
    @numero_orden = 'ORD-2025-003',
    @monto_total = 2340.00,
    @metodo_pago = 'EFECTIVO',
    @estatus_venta = 'PENDIENTE',
    @estatus_entrega = 'PENDIENTE',
    @notas = 'Cliente pagará contra entrega',
    @entregado_por = 'María González';

EXEC sp_InsertDetalleVenta
    @venta_id = 2,
    @producto_id = 6,
    @cantidad_solicitada = 2,
    @cantidad_entregada = 0,
    @precio_unitario = 25.00,
    @total_linea = 50.00,
    @estatus_entrega = 'PENDIENTE',
    @notas_entrega = 'Esperando confirmación de pago';

exec sp_GetDetalleVentas

exec sp_InsertDetalleEntrega
	@detalle_venta_id = 1, 
	@fuente_entrega = 'PRODUCTO',
	@lote_id = null,
	@cantidad_entregada =1;

exec sp_InsertMovimientoInventario 
	@producto_id = 6, 
	@lote_id = null, 
	@tipo_movimiento = 'ENTRADA',
	@cantidad = 5, 
	@tipo_referencia = null,
	@referencia_id = null, 
	@notas = null;

exec sp_InsertMovimientoInventario 
	@producto_id = 6, 
	@lote_id = null, 
	@tipo_movimiento = 'SALIDA',
	@cantidad = 2, 
	@tipo_referencia = null,
	@referencia_id = null, 
	@notas = null;

exec sp_InsertMovimientoInventario 
	@producto_id = 6, 
	@lote_id = null, 
	@tipo_movimiento = 'AJUSTE',
	@cantidad = 10, 
	@tipo_referencia = null,
	@referencia_id = null, 
	@notas = null;

DECLARE @venta_id INT;
EXEC sp_InsertVenta 
    @cliente_id = 1,
    @numero_orden = 'ORD-2025-003',
    @monto_total = 50.00,
    @metodo_pago = 'EFECTIVO',
    @estatus_venta = 'PENDIENTE',
    @estatus_entrega = 'PENDIENTE',
    @notas = 'Cliente pagará contra entrega',
    @entregado_por = 'María González';

EXEC sp_InsertDetalleVenta
    @venta_id = 1,
    @producto_id = 6,
    @cantidad_solicitada = 2,
    @cantidad_entregada = 0,
    @precio_unitario = 25.00,
    @total_linea = 50.00,
    @estatus_entrega = 'PENDIENTE',
    @notas_entrega = 'Esperando confirmación de pago';

exec sp_InsertDetalleEntrega
	@detalle_venta_id = 1, 
	@fuente_entrega = 'PRODUCTO',
	@lote_id = null,
	@cantidad_entregada =1;

exec sp_InsertProveedor @nombre = 'PEHIMACONS', @apellido = '',@empresa = 'PEHIMACONS';  
exec sp_GetProveedores

exec sp_InsertLoteStock 
	@producto_id = 7,
	@numero_lote="0001",
	@fecha_vencimiento="6/30/2025",
	@precio_costo=18.50,
	@cantidad_recibida=10,
	@cantidad_restante=10,
	@proveedor_id=1;

exec sp_InsertMovimientoInventario @producto_id = 7,@lote_id=1,@tipo_movimiento='ENTRADA',@cantidad =10,@tipo_referencia='COMPRA';

DECLARE @venta_id INT;
EXEC sp_InsertVenta 
    @cliente_id = 1,
    @numero_orden = 'ORD-2025-004',
    @monto_total = 50.00,
    @metodo_pago = 'EFECTIVO',
    @estatus_venta = 'PENDIENTE',
    @estatus_entrega = 'PENDIENTE',
    @notas = 'Cliente pagará contra entrega',
    @entregado_por = 'María González';

EXEC sp_InsertDetalleVenta
    @venta_id = 2,
    @producto_id = 7,
    @cantidad_solicitada = 2,
    @cantidad_entregada = 0,
    @precio_unitario = 25.00,
    @total_linea = 50.00,
    @estatus_entrega = 'PENDIENTE',
    @notas_entrega = 'Esperando confirmación de pago';

exec sp_GetDetalleVentas

exec sp_InsertDetalleEntrega
	@detalle_venta_id = 2, 
	@fuente_entrega = 'LOTE',
	@lote_id = 2,
	@cantidad_entregada =1;