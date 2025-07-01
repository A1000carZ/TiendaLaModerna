CREATE PROCEDURE sp_InsertDetalleVenta
    @venta_id INT,
    @producto_id INT,
    @cantidad_solicitada INT,
    @cantidad_entregada INT = 0,
    @precio_unitario DECIMAL(10,2),
    @total_linea DECIMAL(12,2),
    @estatus_entrega VARCHAR(30) = 'PENDIENTE',
    @fecha_entrega DATETIME = NULL,
    @notas_entrega VARCHAR(200) = NULL
AS
BEGIN
    INSERT INTO DetalleVentas (venta_id, producto_id, cantidad_solicitada, cantidad_entregada, precio_unitario, total_linea, estatus_entrega, fecha_entrega, notas_entrega)
    VALUES (@venta_id, @producto_id, @cantidad_solicitada, @cantidad_entregada, @precio_unitario, @total_linea, @estatus_entrega, @fecha_entrega, @notas_entrega);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
go


CREATE PROCEDURE sp_GetDetalleVentas
AS
BEGIN
    SELECT dv.id, dv.venta_id, v.numero_orden,
           dv.producto_id, p.nombre AS producto_nombre,
           dv.cantidad_solicitada, dv.cantidad_entregada, dv.precio_unitario, dv.total_linea,
           dv.estatus_entrega, dv.fecha_entrega, dv.notas_entrega
    FROM DetalleVentas dv
    INNER JOIN Ventas v ON dv.venta_id = v.id
    INNER JOIN CatalogoProductos p ON dv.producto_id = p.id
    ORDER BY dv.venta_id, p.nombre;
END;
go

CREATE PROCEDURE sp_GetDetalleVentaById
    @id INT
AS
BEGIN
    SELECT dv.id, dv.venta_id, v.numero_orden,
           dv.producto_id, p.nombre AS producto_nombre,
           dv.cantidad_solicitada, dv.cantidad_entregada, dv.precio_unitario, dv.total_linea,
           dv.estatus_entrega, dv.fecha_entrega, dv.notas_entrega
    FROM DetalleVentas dv
    INNER JOIN Ventas v ON dv.venta_id = v.id
    INNER JOIN CatalogoProductos p ON dv.producto_id = p.id
    WHERE dv.id = @id;
END;
go

CREATE PROCEDURE sp_UpdateDetalleVenta
    @id INT,
    @venta_id INT,
    @producto_id INT,
    @cantidad_solicitada INT,
    @cantidad_entregada INT = 0,
    @precio_unitario DECIMAL(10,2),
    @total_linea DECIMAL(12,2),
    @estatus_entrega VARCHAR(30) = 'PENDIENTE',
    @fecha_entrega DATETIME = NULL,
    @notas_entrega VARCHAR(200) = NULL
AS
BEGIN
    UPDATE DetalleVentas
    SET venta_id = @venta_id,
        producto_id = @producto_id,
        cantidad_solicitada = @cantidad_solicitada,
        cantidad_entregada = @cantidad_entregada,
        precio_unitario = @precio_unitario,
        total_linea = @total_linea,
        estatus_entrega = @estatus_entrega,
        fecha_entrega = @fecha_entrega,
        notas_entrega = @notas_entrega
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_DeleteDetalleVenta
    @id INT
AS
BEGIN
    DELETE FROM DetalleVentas
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_GetDetalleVentaByVentaId
    @venta_id INT
AS
BEGIN
    SELECT dv.id, dv.venta_id, v.numero_orden,
           dv.producto_id, p.nombre AS producto_nombre,
           dv.cantidad_solicitada, dv.cantidad_entregada, dv.precio_unitario, dv.total_linea,
           dv.estatus_entrega, dv.fecha_entrega, dv.notas_entrega
    FROM DetalleVentas dv
    INNER JOIN Ventas v ON dv.venta_id = v.id
    INNER JOIN CatalogoProductos p ON dv.producto_id = p.id
    WHERE dv.venta_id = @venta_id
    ORDER BY p.nombre;
END;
go