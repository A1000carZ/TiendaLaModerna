-- CREATE
CREATE PROCEDURE sp_InsertVenta
    @cliente_id INT = NULL,
    @numero_orden VARCHAR(20),
    @monto_total DECIMAL(12,2) = 0,
    @metodo_pago VARCHAR(20) = 'EFECTIVO',
    @estatus_venta VARCHAR(20) = 'COMPLETADA',
    @estatus_entrega VARCHAR(30) = 'ENTREGADA',
    @fecha_entrega DATETIME = NULL,
    @notas VARCHAR(200) = NULL,
    @entregado_por VARCHAR(100) = NULL
AS
BEGIN
    IF @fecha_entrega IS NULL
        SET @fecha_entrega = GETDATE();
        
    INSERT INTO Ventas (cliente_id, numero_orden, monto_total, metodo_pago, estatus_venta, estatus_entrega, fecha_entrega, notas, entregado_por)
    VALUES (@cliente_id, @numero_orden, @monto_total, @metodo_pago, @estatus_venta, @estatus_entrega, @fecha_entrega, @notas, @entregado_por);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
go

CREATE PROCEDURE sp_GetVentas
AS
BEGIN
    SELECT v.id, v.cliente_id, CONCAT(c.nombre, ' ', c.apellido) AS cliente_nombre,
           v.numero_orden, v.fecha_venta, v.monto_total, v.metodo_pago,
           v.estatus_venta, v.estatus_entrega, v.fecha_entrega, v.notas, v.entregado_por
    FROM Ventas v
    LEFT JOIN Clientes c ON v.cliente_id = c.id
    ORDER BY v.fecha_venta DESC;
END;
go

CREATE PROCEDURE sp_GetVentaById
    @id INT
AS
BEGIN
    SELECT v.id, v.cliente_id, CONCAT(c.nombre, ' ', c.apellido) AS cliente_nombre,
           v.numero_orden, v.fecha_venta, v.monto_total, v.metodo_pago,
           v.estatus_venta, v.estatus_entrega, v.fecha_entrega, v.notas, v.entregado_por
    FROM Ventas v
    LEFT JOIN Clientes c ON v.cliente_id = c.id
    WHERE v.id = @id;
END;
go

CREATE PROCEDURE sp_UpdateVenta
    @id INT,
    @cliente_id INT = NULL,
    @numero_orden VARCHAR(20),
    @monto_total DECIMAL(12,2) = 0,
    @metodo_pago VARCHAR(20) = 'EFECTIVO',
    @estatus_venta VARCHAR(20) = 'COMPLETADA',
    @estatus_entrega VARCHAR(30) = 'ENTREGADA',
    @fecha_entrega DATETIME = NULL,
    @notas VARCHAR(200) = NULL,
    @entregado_por VARCHAR(100) = NULL
AS
BEGIN
    UPDATE Ventas
    SET cliente_id = @cliente_id,
        numero_orden = @numero_orden,
        monto_total = @monto_total,
        metodo_pago = @metodo_pago,
        estatus_venta = @estatus_venta,
        estatus_entrega = @estatus_entrega,
        fecha_entrega = @fecha_entrega,
        notas = @notas,
        entregado_por = @entregado_por
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_DeleteVenta
    @id INT
AS
BEGIN
    DELETE FROM Ventas
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go