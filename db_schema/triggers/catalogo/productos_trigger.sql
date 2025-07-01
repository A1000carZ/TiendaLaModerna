-- =====================================================================================
-- TRIGGER: tr_InsertStockProducto
-- PROPÓSITO: Crea automáticamente un registro de stock inicial cuando se inserta 
--           un nuevo producto en el catálogo.
-- TABLA AFECTADA: CatalogoProductos (disparador)
-- TABLA DESTINO: StockProductos (donde se inserta)
-- EVENTO: AFTER INSERT - Se ejecuta después de insertar productos
-- =====================================================================================

-- VERSIÓN ORIGINAL (usando procedimiento almacenado)
-- Esta versión llama a un procedimiento almacenado para crear el stock
CREATE TRIGGER tr_InsertStockProducto
ON CatalogoProductos 
AFTER INSERT 
AS 
BEGIN
    SET NOCOUNT ON;                               -- Evita mensajes de filas afectadas
    
    DECLARE @id_prod INT;                         -- Variable para almacenar el ID del producto
    
    -- Obtiene el ID del producto recién insertado desde la tabla 'inserted'
    SELECT @id_prod = id FROM inserted;
    
    -- Llama al procedimiento almacenado para crear el registro de stock inicial
    EXEC sp_InsertStockProducto @producto_id = @id_prod;
END;