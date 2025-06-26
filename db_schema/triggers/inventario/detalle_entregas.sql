create trigger tr_DetalleEntregas
on DetalleEntregas after insert
as begin
    set nocount on;

    declare @detalle_venta_id int, @cantidad int, @lote_id int, @fuente_entrega varchar(50);
    select @detalle_venta_id = detalle_venta_id, @cantidad = cantidad_entregada, @lote_id = lote_id, @fuente_entrega = fuente_entrega from inserted;

    declare @producto_id int, @venta_id int;
    select @producto_id = producto_id, @venta_id = venta_id
    from DetalleVentas
    where id = @detalle_venta_id;

    update d
        set d.cantidad_entregada = d.cantidad_entregada + @cantidad,
            d.estatus_entrega = case 
            when d.cantidad_entregada + @cantidad  < d.cantidad_solicitada then 'PARCIAL'
            when d.cantidad_entregada + @cantidad >= d.cantidad_solicitada then 'COMPLETA'
            else 'PENDIENTE'
        end
    from DetalleVentas d
    where d.id = @detalle_venta_id;

    declare @total_detalle_ventas int, @detalle_ventas_completas int,@detalle_ventas_parciales int;
    select
        @total_detalle_ventas = count(*),
        @detalle_ventas_completas = sum( case when estatus_entrega = 'COMPLETA' then 1 else 0 end),
        @detalle_ventas_parciales = sum(case when estatus_entrega = 'PARCIAL' then 1 else 0 end)
    from DetalleVentas
    where venta_id = @venta_id;

    update v
        set v.estatus_entrega = case 
        when @detalle_ventas_completas = @total_detalle_ventas then 'COMPLETA'
        when @detalle_ventas_completas > 0 or @detalle_ventas_parciales > 0 then 'PARCIAL'
        else 'PENDIENTE'
        end, v.estatus_venta = case 
        when @detalle_ventas_completas = @total_detalle_ventas then 'COMPLETADA'
        when @detalle_ventas_completas > 0 or @detalle_ventas_parciales > 0 then 'PENDIENTE'
        else 'PENDIENTE'
        end
    from Ventas v
    where v.id = @venta_id;

    exec sp_InsertMovimientoInventario 
	@producto_id = @producto_id, 
	@lote_id = @lote_id, 
	@tipo_movimiento = 'SALIDA',
	@cantidad = @cantidad, 
	@tipo_referencia = 'VENTA',
	@referencia_id = @venta_id, 
	@notas = null;
end;