-- CREATE
CREATE PROCEDURE sp_InsertLoteStock
    @producto_id INT,
    @numero_lote VARCHAR(50) = NULL,
    @fecha_vencimiento DATE = NULL,
    @precio_costo DECIMAL(10,2),
    @cantidad_recibida INT,
    @cantidad_restante INT,
    @proveedor_id INT = NULL
AS
BEGIN
    INSERT INTO LotesStock (producto_id, numero_lote, fecha_vencimiento, precio_costo, cantidad_recibida, cantidad_restante, proveedor_id)
    VALUES (@producto_id, @numero_lote, @fecha_vencimiento, @precio_costo, @cantidad_recibida, @cantidad_restante, @proveedor_id);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
go

CREATE PROCEDURE sp_GetLotesStock
AS
BEGIN
    SELECT l.id, l.producto_id, p.nombre AS producto_nombre,
           l.numero_lote, l.fecha_vencimiento, l.precio_costo,
           l.cantidad_recibida, l.cantidad_restante, l.fecha_recepcion,
           l.proveedor_id, pr.nombre AS proveedor_nombre, l.activo
    FROM LotesStock l
    INNER JOIN CatalogoProductos p ON l.producto_id = p.id
    LEFT JOIN Proveedores pr ON l.proveedor_id = pr.id
    ORDER BY l.fecha_recepcion DESC;
END;
go

CREATE PROCEDURE sp_GetLoteStockById
    @id INT
AS
BEGIN
    SELECT l.id, l.producto_id, p.nombre AS producto_nombre,
           l.numero_lote, l.fecha_vencimiento, l.precio_costo,
           l.cantidad_recibida, l.cantidad_restante, l.fecha_recepcion,
           l.proveedor_id, pr.nombre AS proveedor_nombre
    FROM LotesStock l
    INNER JOIN CatalogoProductos p ON l.producto_id = p.id
    LEFT JOIN Proveedores pr ON l.proveedor_id = pr.id
    WHERE l.id = @id;
END;
go

CREATE PROCEDURE sp_UpdateLoteStock
    @id INT,
    @producto_id INT,
    @numero_lote VARCHAR(50) = NULL,
    @fecha_vencimiento DATE = NULL,
    @precio_costo DECIMAL(10,2),
    @cantidad_recibida INT,
    @cantidad_restante INT,
    @proveedor_id INT = NULL
AS
BEGIN
    UPDATE LotesStock
    SET producto_id = @producto_id,
        numero_lote = @numero_lote,
        fecha_vencimiento = @fecha_vencimiento,
        precio_costo = @precio_costo,
        cantidad_recibida = @cantidad_recibida,
        cantidad_restante = @cantidad_restante,
        proveedor_id = @proveedor_id
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_DeleteLoteStock
    @id INT
AS
BEGIN
    DELETE FROM LotesStock
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_GetLotesDisponiblesByProducto
    @producto_id INT
AS
BEGIN
    SELECT l.id, l.producto_id, p.nombre AS producto_nombre,
           l.numero_lote, l.fecha_vencimiento, l.precio_costo,
           l.cantidad_recibida, l.cantidad_restante, l.fecha_recepcion,
           l.proveedor_id, pr.nombre AS proveedor_nombre
    FROM LotesStock l
    INNER JOIN CatalogoProductos p ON l.producto_id = p.id
    LEFT JOIN Proveedores pr ON l.proveedor_id = pr.id
    WHERE l.producto_id = @producto_id AND l.cantidad_restante > 0
    ORDER BY l.fecha_vencimiento ASC, l.fecha_recepcion ASC;
END;
go

CREATE PROCEDURE sp_GetLotesVencimientoProximo
    @dias_anticipacion INT = 30
AS
BEGIN
    SELECT l.id, l.producto_id, p.nombre AS producto_nombre,
           l.numero_lote, l.fecha_vencimiento, l.cantidad_restante,
           DATEDIFF(DAY, GETDATE(), l.fecha_vencimiento) AS dias_hasta_vencimiento
    FROM LotesStock l
    INNER JOIN CatalogoProductos p ON l.producto_id = p.id
    WHERE l.fecha_vencimiento IS NOT NULL 
      AND l.cantidad_restante > 0
      AND l.fecha_vencimiento <= DATEADD(DAY, @dias_anticipacion, GETDATE())
    ORDER BY l.fecha_vencimiento ASC;
END;
go