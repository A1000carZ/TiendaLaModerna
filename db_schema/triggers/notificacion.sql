
create trigger tr_NotificacionStock 
on DetalleEntregas after insert
as begin
    set no count on;
    declare @id_producto int;
    select @id_producto = id_producto  from inserted;
    
    declare @nombre_producto varchar, @umbral_inv int, @requiere_vencimiento bit;
    select @nombre_producto = nombre, @umbral_inv = umbral_inventario, @requiere_vencimiento = requiere_vencimiento
    from CatalogoProductos
    where id = @id_producto;

    declare @stock_anterior int;
    select @stock_anterior = cantidad_disponible
    from StockProductos
    where producto_id = @producto_id;

    if (requiere_vencimiento == 1)
    begin
        declare @id_lote int;
        select top 1 from exec sp_GetLotesDisponiblesByProducto