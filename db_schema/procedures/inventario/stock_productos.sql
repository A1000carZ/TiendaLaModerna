-- CREATE
CREATE PROCEDURE sp_InsertStockProducto
    @producto_id INT,
    @cantidad_disponible INT = 0,
    @cantidad_reservada INT = 0
AS
BEGIN
    INSERT INTO StockProductos (producto_id, cantidad_disponible, cantidad_reservada)
    VALUES (@producto_id, @cantidad_disponible, @cantidad_reservada);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
go

CREATE PROCEDURE sp_GetStockProductos
AS
BEGIN
    SELECT s.id, s.producto_id, p.nombre AS producto_nombre,
           s.cantidad_disponible, s.cantidad_reservada, s.ultima_actualizacion
    FROM StockProductos s
    INNER JOIN CatalogoProductos p ON s.producto_id = p.id
    ORDER BY p.nombre;
END;
go

CREATE PROCEDURE sp_GetStockProductoById
    @id INT
AS
BEGIN
    SELECT s.id, s.producto_id, p.nombre AS producto_nombre,
           s.cantidad_disponible, s.cantidad_reservada, s.ultima_actualizacion
    FROM StockProductos s
    INNER JOIN CatalogoProductos p ON s.producto_id = p.id
    WHERE s.id = @id;
END;
go

CREATE PROCEDURE sp_UpdateStockProducto
    @id INT,
    @producto_id INT,
    @cantidad_disponible INT = 0,
    @cantidad_reservada INT = 0
AS
BEGIN
    UPDATE StockProductos
    SET producto_id = @producto_id,
        cantidad_disponible = @cantidad_disponible,
        cantidad_reservada = @cantidad_reservada,
        ultima_actualizacion = GETDATE()
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_DeleteStockProducto
    @id INT
AS
BEGIN
    DELETE FROM StockProductos
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

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
go