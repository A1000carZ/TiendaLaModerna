-- Inserta un nuevo registro de stock para un producto.
-- Este procedimiento se usa generalmente después de registrar un nuevo producto.
-- Devuelve el ID generado para el registro de stock.
CREATE PROCEDURE sp_InsertStockProducto
    @producto_id INT,                         -- ID del producto
    @cantidad_disponible INT = 0,             -- Cantidad actual disponible en inventario
    @cantidad_reservada INT = 0               -- Cantidad reservada (por pedidos u otros)
AS
BEGIN
    INSERT INTO StockProductos (producto_id, cantidad_disponible, cantidad_reservada)
    VALUES (@producto_id, @cantidad_disponible, @cantidad_reservada);
    
    SELECT SCOPE_IDENTITY() AS id;            -- Devuelve el ID del nuevo registro
END;
GO

-- Recupera el listado completo de stock para todos los productos.
-- Incluye nombre del producto y última fecha de actualización.
CREATE PROCEDURE sp_GetStockProductos
AS
BEGIN
    SELECT s.id, s.producto_id, p.nombre AS producto_nombre,
           s.cantidad_disponible, s.cantidad_reservada, s.ultima_actualizacion
    FROM StockProductos s
    INNER JOIN CatalogoProductos p ON s.producto_id = p.id
    ORDER BY p.nombre;
END;
GO

-- Obtiene el registro de stock de un producto por su ID en la tabla StockProductos.
CREATE PROCEDURE sp_GetStockProductoById
    @id INT                                   -- ID del registro en StockProductos
AS
BEGIN
    SELECT s.id, s.producto_id, p.nombre AS producto_nombre,
           s.cantidad_disponible, s.cantidad_reservada, s.ultima_actualizacion
    FROM StockProductos s
    INNER JOIN CatalogoProductos p ON s.producto_id = p.id
    WHERE s.id = @id;
END;
GO

-- Actualiza las cantidades de un producto en stock.
-- Se actualiza también la fecha de última modificación.
-- Devuelve el número de filas afectadas.
CREATE PROCEDURE sp_UpdateStockProducto
    @id INT,                                  -- ID del registro de stock a modificar
    @producto_id INT,
    @cantidad_disponible INT = 0,
    @cantidad_reservada INT = 0
AS
BEGIN
    UPDATE StockProductos
    SET producto_id = @producto_id,
        cantidad_disponible = @cantidad_disponible,
        cantidad_reservada = @cantidad_reservada,
        ultima_actualizacion = GETDATE()      -- Se actualiza automáticamente la fecha
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
GO

-- Elimina un registro de stock por su ID.
-- Devuelve la cantidad de filas eliminadas.
CREATE PROCEDURE sp_DeleteStockProducto
    @id INT
AS
BEGIN
    DELETE FROM StockProductos
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
GO

-- Consulta los productos cuyo stock disponible está por debajo del umbral definido.
-- El cálculo considera la cantidad disponible menos la reservada.
CREATE PROCEDURE sp_GetProductosBajoStock
AS
BEGIN
    SELECT p.id, p.nombre, p.umbral_inventario,
           ISNULL(s.cantidad_disponible, 0) AS cantidad_disponible,
           ISNULL(s.cantidad_reservada, 0) AS cantidad_reservada,
           (ISNULL(s.cantidad_disponible, 0) - ISNULL(s.cantidad_reservada, 0)) AS cantidad_libre
    FROM CatalogoProductos p
    LEFT JOIN StockProductos s ON p.id = s.producto_id
    WHERE p.activo = 1 
      AND (ISNULL(s.cantidad_disponible, 0) - ISNULL(s.cantidad_reservada, 0)) <= p.umbral_inventario
    ORDER BY cantidad_libre ASC, p.nombre;
END;
GO
