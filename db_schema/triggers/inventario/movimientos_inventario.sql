
create trigger tr_MovimientosInventario
on MovimientosInventario after insert 
as begin
    declare @producto_id int, @lote_id int,@tipo_movimiento varchar(20), @cantidad int;
    select @producto_id = producto_id,@lote_id = lote_id,@tipo_movimiento = tipo_movimiento,@cantidad=cantidad from inserted;

    if (@tipo_movimiento = 'ENTRADA')
	begin
        update e
        set e.cantidad_disponible = e.cantidad_disponible + @cantidad
        from StockProductos e
        where e.producto_id = @producto_id;
    end
    else if (@tipo_movimiento = 'SALIDA')
    begin
        update e
        set e.cantidad_disponible = case
            when e.cantidad_disponible - @cantidad < 0 then 0
            else e.cantidad_disponible - @cantidad
		end
        from StockProductos e
        where e.producto_id = @producto_id;
        
        if (@lote_id is not null)
        begin
            update l
            set l.cantidad_restante = case when l.cantidad_restante - @cantidad <= 0 then 0
            else l.cantidad_restante - @cantidad end, l.activo = case when l.cantidad_restante - @cantidad <= 0 then 0 else 1 end
            from LotesStock l
            where l.id = @lote_id;
        end 
    end;
    else if (@tipo_movimiento = 'AJUSTE')
    begin
        update e 
        set e.cantidad_disponible = @cantidad
        from StockProductos e
        where e.producto_id = @producto_id;
    end;
end;