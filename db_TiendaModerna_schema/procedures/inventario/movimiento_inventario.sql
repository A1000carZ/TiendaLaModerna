-- Inserta un nuevo movimiento de inventario (entrada, salida o ajuste)
-- Devuelve el ID del movimiento creado
CREATE PROCEDURE sp_InsertMovimientoInventario
    @producto_id INT,                               -- Producto afectado
    @lote_id INT = NULL,                            -- Lote involucrado (opcional)
    @tipo_movimiento VARCHAR(20),                   -- Tipo de movimiento: ENTRADA, SALIDA, AJUSTE
    @cantidad INT,                                  -- Cantidad afectada
    @tipo_referencia VARCHAR(20) = NULL,            -- Origen del movimiento: VENTA, COMPRA, AJUSTE
    @referencia_id INT = NULL,                      -- ID relacionado a la referencia (opcional)
    @notas VARCHAR(200) = NULL                      -- Observaciones (opcional)
AS
BEGIN
    INSERT INTO MovimientosInventario (producto_id, lote_id, tipo_movimiento, cantidad, tipo_referencia, referencia_id, notas)
    VALUES (@producto_id, @lote_id, @tipo_movimiento, @cantidad, @tipo_referencia, @referencia_id, @notas);

    SELECT SCOPE_IDENTITY() AS id;
END;
GO

-- Recupera todos los movimientos de inventario con detalles del producto y lote
CREATE PROCEDURE sp_GetMovimientosInventario
AS
BEGIN
    SELECT m.id, m.producto_id, p.nombre AS producto_nombre,
           m.lote_id, l.numero_lote,
           m.tipo_movimiento, m.cantidad, m.tipo_referencia, m.referencia_id,
           m.notas, m.fecha_movimiento
    FROM MovimientosInventario m
    INNER JOIN CatalogoProductos p ON m.producto_id = p.id
    LEFT JOIN LotesStock l ON m.lote_id = l.id
    ORDER BY m.fecha_movimiento DESC;
END;
GO

-- Recupera un movimiento de inventario específico por su ID
CREATE PROCEDURE sp_GetMovimientoInventarioById
    @id INT
AS
BEGIN
    SELECT m.id, m.producto_id, p.nombre AS producto_nombre,
           m.lote_id, l.numero_lote,
           m.tipo_movimiento, m.cantidad, m.tipo_referencia, m.referencia_id,
           m.notas, m.fecha_movimiento
    FROM MovimientosInventario m
    INNER JOIN CatalogoProductos p ON m.producto_id = p.id
    LEFT JOIN LotesStock l ON m.lote_id = l.id
    WHERE m.id = @id;
END;
GO

-- Actualiza los datos de un movimiento de inventario existente
-- Devuelve la cantidad de filas modificadas
CREATE PROCEDURE sp_UpdateMovimientoInventario
    @id INT,
    @producto_id INT,
    @lote_id INT = NULL,
    @tipo_movimiento VARCHAR(20),
    @cantidad INT,
    @tipo_referencia VARCHAR(20) = NULL,
    @referencia_id INT = NULL,
    @notas VARCHAR(200) = NULL
AS
BEGIN
    UPDATE MovimientosInventario
    SET producto_id = @producto_id,
        lote_id = @lote_id,
        tipo_movimiento = @tipo_movimiento,
        cantidad = @cantidad,
        tipo_referencia = @tipo_referencia,
        referencia_id = @referencia_id,
        notas = @notas
    WHERE id = @id;

    SELECT @@ROWCOUNT AS affected_rows;
END;
GO

-- Elimina un movimiento de inventario por su ID
-- Devuelve el número de registros afectados
CREATE PROCEDURE sp_DeleteMovimientoInventario
    @id INT
AS
BEGIN
    DELETE FROM MovimientosInventario
    WHERE id = @id;

    SELECT @@ROWCOUNT AS affected_rows;
END;
GO

-- Recupera los movimientos de inventario de un producto filtrados por rango de fechas
-- Si no se especifican fechas, se usa el último mes por defecto
CREATE PROCEDURE sp_GetMovimientosByProducto
    @producto_id INT,                          -- Producto a consultar
    @fecha_inicio DATETIME = NULL,             -- Fecha inicial (opcional, por defecto -1 mes)
    @fecha_fin DATETIME = NULL                 -- Fecha final (opcional, por defecto hoy)
AS
BEGIN
    IF @fecha_inicio IS NULL SET @fecha_inicio = DATEADD(MONTH, -1, GETDATE());
    IF @fecha_fin IS NULL SET @fecha_fin = GETDATE();

    SELECT m.id, m.producto_id, p.nombre AS producto_nombre,
           m.lote_id, l.numero_lote,
           m.tipo_movimiento, m.cantidad, m.tipo_referencia, m.referencia_id,
           m.notas, m.fecha_movimiento
    FROM MovimientosInventario m
    INNER JOIN CatalogoProductos p ON m.producto_id = p.id
    LEFT JOIN LotesStock l ON m.lote_id = l.id
    WHERE m.producto_id = @producto_id 
      AND m.fecha_movimiento BETWEEN @fecha_inicio AND @fecha_fin
    ORDER BY m.fecha_movimiento DESC;
END;
GO
