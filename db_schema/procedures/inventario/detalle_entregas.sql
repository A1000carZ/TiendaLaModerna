
CREATE PROCEDURE sp_InsertDetalleEntrega
    @detalle_venta_id INT,
    @fuente_entrega VARCHAR(20),
    @lote_id INT = NULL,
    @cantidad_entregada INT,
    @entregado_por VARCHAR(100) = NULL,
    @notas VARCHAR(200) = NULL
AS
BEGIN
    IF @fuente_entrega NOT IN ('LOTE', 'PRODUCTO')
    BEGIN
        RAISERROR('fuente_entrega must be either LOTE or PRODUCTO', 16, 1);
        RETURN;
    END

    IF @fuente_entrega = 'LOTE' AND @lote_id IS NULL
    BEGIN
        RAISERROR('lote_id is required when fuente_entrega is LOTE', 16, 1);
        RETURN;
    END

    IF @fuente_entrega = 'PRODUCTO' AND @lote_id IS NOT NULL
    BEGIN
        RAISERROR('lote_id must be NULL when fuente_entrega is PRODUCTO', 16, 1);
        RETURN;
    END

    INSERT INTO DetalleEntregas (detalle_venta_id, lote_id, fuente_entrega, cantidad_entregada, entregado_por, notas)
    VALUES (@detalle_venta_id, @lote_id, @fuente_entrega, @cantidad_entregada, @entregado_por, @notas);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
GO


CREATE PROCEDURE sp_GetDetalleEntregas
AS
BEGIN
    SELECT 
        de.id, 
        de.detalle_venta_id, 
        dv.cantidad_solicitada,
        de.lote_id, 
        CASE 
            WHEN de.fuente_entrega = 'LOTE' THEN l.numero_lote 
            ELSE 'N/A - Producto directo'
        END AS numero_lote,
        de.fuente_entrega,
        de.cantidad_entregada, 
        de.fecha_entrega, 
        de.entregado_por, 
        de.notas,
        
        p.nombre AS producto_nombre,
    FROM DetalleEntregas de
    INNER JOIN DetalleVentas dv ON de.detalle_venta_id = dv.id
    INNER JOIN Productos p ON dv.producto_id = p.id
    LEFT JOIN LotesStock l ON de.lote_id = l.id
    ORDER BY de.fecha_entrega DESC;
END;
GO


CREATE PROCEDURE sp_GetDetalleEntregaById
    @id INT
AS
BEGIN
    SELECT 
        de.id, 
        de.detalle_venta_id, 
        dv.cantidad_solicitada,
        de.lote_id, 
        CASE 
            WHEN de.fuente_entrega = 'LOTE' THEN l.numero_lote 
            ELSE 'N/A - Producto directo'
        END AS numero_lote,
        de.fuente_entrega,
        de.cantidad_entregada, 
        de.fecha_entrega, 
        de.entregado_por, 
        de.notas,
        
        p.nombre AS producto_nombre
    FROM DetalleEntregas de
    INNER JOIN DetalleVentas dv ON de.detalle_venta_id = dv.id
    INNER JOIN Productos p ON dv.producto_id = p.id
    LEFT JOIN LotesStock l ON de.lote_id = l.id
    WHERE de.id = @id;
END;
GO


CREATE PROCEDURE sp_UpdateDetalleEntrega
    @id INT,
    @detalle_venta_id INT,
    @fuente_entrega VARCHAR(20),
    @lote_id INT = NULL,
    @cantidad_entregada INT,
    @entregado_por VARCHAR(100) = NULL,
    @notas VARCHAR(200) = NULL
AS
BEGIN
   
    IF @fuente_entrega NOT IN ('LOTE', 'PRODUCTO')
    BEGIN
        RAISERROR('fuente_entrega must be either LOTE or PRODUCTO', 16, 1);
        RETURN;
    END

    
    IF @fuente_entrega = 'LOTE' AND @lote_id IS NULL
    BEGIN
        RAISERROR('lote_id is required when fuente_entrega is LOTE', 16, 1);
        RETURN;
    END

    IF @fuente_entrega = 'PRODUCTO' AND @lote_id IS NOT NULL
    BEGIN
        RAISERROR('lote_id must be NULL when fuente_entrega is PRODUCTO', 16, 1);
        RETURN;
    END

    UPDATE DetalleEntregas
    SET detalle_venta_id = @detalle_venta_id,
        lote_id = @lote_id,
        fuente_entrega = @fuente_entrega,
        cantidad_entregada = @cantidad_entregada,
        entregado_por = @entregado_por,
        notas = @notas
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
GO


CREATE PROCEDURE sp_DeleteDetalleEntrega
    @id INT
AS
BEGIN
    DELETE FROM DetalleEntregas
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
GO


CREATE PROCEDURE sp_GetDetalleEntregasByVenta
    @detalle_venta_id INT
AS
BEGIN
    SELECT 
        de.id, 
        de.detalle_venta_id, 
        dv.cantidad_solicitada,
        de.lote_id, 
        CASE 
            WHEN de.fuente_entrega = 'LOTE' THEN l.numero_lote 
            ELSE 'N/A - Producto directo'
        END AS numero_lote,
        de.fuente_entrega,
        de.cantidad_entregada, 
        de.fecha_entrega, 
        de.entregado_por, 
        de.notas
    FROM DetalleEntregas de
    INNER JOIN DetalleVentas dv ON de.detalle_venta_id = dv.id
    LEFT JOIN LotesStock l ON de.lote_id = l.id
    WHERE de.detalle_venta_id = @detalle_venta_id
    ORDER BY de.fecha_entrega DESC;
END;
GO


CREATE PROCEDURE sp_GetResumenEntregasByVenta
    @detalle_venta_id INT
AS
BEGIN
    SELECT 
        dv.cantidad_solicitada,
        SUM(de.cantidad_entregada) AS total_entregado,
        (dv.cantidad_solicitada - ISNULL(SUM(de.cantidad_entregada), 0)) AS pendiente_entregar,
        COUNT(de.id) AS numero_entregas,
        MAX(de.fecha_entrega) AS ultima_entrega
    FROM DetalleVentas dv
    LEFT JOIN DetalleEntregas de ON dv.id = de.detalle_venta_id
    WHERE dv.id = @detalle_venta_id
    GROUP BY dv.id, dv.cantidad_solicitada;
END;
GO