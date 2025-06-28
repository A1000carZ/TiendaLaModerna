
create trigger tr_InsertStockProducto
on CatalogoProductos after insert 
as begin
    set nocount on;
    declare @id_prod int;
    select @id_prod = id from inserted;

    exec sp_InsertStockProducto @producto_id = @id_prod;
end;