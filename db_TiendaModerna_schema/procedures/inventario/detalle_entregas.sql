-- Inserta un registro de entrega asociado a un detalle de venta
-- Valida el tipo de fuente de entrega y coherencia del parámetro lote_id
CREATE PROCEDURE sp_InsertDetalleEntrega
    @detalle_venta_id INT,                   -- ID del detalle de venta
    @fuente_entrega VARCHAR(20),            -- 'LOTE' o 'PRODUCTO'
    @lote_id INT = NULL,                    -- ID del lote si aplica
    @cantidad_entregada INT,                -- Cantidad entregada
    @entregado_por VARCHAR(100) = NULL,     -- Nombre del responsable de la entrega
    @notas VARCHAR(200) = NULL              -- Observaciones adicionales
AS
BEGIN
    -- Validaciones de integridad
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

    -- Inserción
    INSERT INTO DetalleEntregas (detalle_venta_id, lote_id, fuente_entrega, cantidad_entregada, entregado_por, notas)
    VALUES (@detalle_venta_id, @lote_id, @fuente_entrega, @cantidad_entregada, @entregado_por, @notas);
    
    SELECT SCOPE_IDENTITY() AS id; -- Devuelve el ID de la entrega insertada
END;
GO

-- Recupera todas las entregas realizadas, con datos del producto, lote y cantidad
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
        p.nombre AS producto_nombre
    FROM DetalleEntregas de
    INNER JOIN DetalleVentas dv ON de.detalle_venta_id = dv.id
    INNER JOIN CatalogoProductos p ON dv.producto_id = p.id
    LEFT JOIN LotesStock l ON de.lote_id = l.id
    ORDER BY de.fecha_entrega DESC;
END;
GO

-- Obtiene una entrega específica por ID
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
    INNER JOIN CatalogoProductos p ON dv.producto_id = p.id
    LEFT JOIN LotesStock l ON de.lote_id = l.id
    WHERE de.id = @id;
END;
GO

-- Actualiza los datos de una entrega, validando la coherencia del tipo de fuente y lote
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
    -- Validaciones de integridad de datos
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

    -- Actualización
    UPDATE DetalleEntregas
    SET detalle_venta_id = @detalle_venta_id,
        lote_id = @lote_id,
        fuente_entrega = @fuente_entrega,
        cantidad_entregada = @cantidad_entregada,
        entregado_por = @entregado_por,
        notas = @notas
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows; -- Devuelve 1 si se actualizó correctamente
END;
GO

-- Elimina una entrega registrada por su ID
CREATE PROCEDURE sp_DeleteDetalleEntrega
    @id INT
AS
BEGIN
    DELETE FROM DetalleEntregas
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows; -- Indica si la eliminación fue exitosa
END;
GO

-- Obtiene todas las entregas asociadas a un mismo detalle de venta
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

-- Proporciona un resumen consolidado de las entregas de un detalle de venta
CREATE PROCEDURE sp_GetResumenEntregasByVenta
    @detalle_venta_id INT
AS
BEGIN
    SELECT 
        dv.cantidad_solicitada,
        SUM(de.cantidad_entregada) AS total_entregado,               -- Total entregado hasta el momento
        (dv.cantidad_solicitada - ISNULL(SUM(de.cantidad_entregada), 0)) AS pendiente_entregar,
        COUNT(de.id) AS numero_entregas,                              -- Cuántas entregas parciales o totales se han hecho
        MAX(de.fecha_entrega) AS ultima_entrega
    FROM DetalleVentas dv
    LEFT JOIN DetalleEntregas de ON dv.id = de.detalle_venta_id
    WHERE dv.id = @detalle_venta_id
    GROUP BY dv.id, dv.cantidad_solicitada;
END;
GO
