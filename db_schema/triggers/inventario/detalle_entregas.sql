
create trigger tr_DetalleEntregas
on DetalleEntregas after insert
as begin
    set nocount on;

    declare @detalle_venta_id int, @cantidad int, @lote_id int, @fuente_entrega varchar;
    select @detalle_venta_id = detalle_venta_id, @cantidad = cantidad_entregada, @lote_id = lote_id, @fuente_entrega = fuente_entrega from insert;

    declare @producto_id int;
    select @producto_id = producto_id 
    from DetalleVentas
    where id = @detalle_venta_id;

    update d
        set d.cantidad_entregada = @cantidad
    from DetalleVentas d
    where d.id = @detalle_venta_id;
end;