-- Inserta una nueva venta en la base de datos.
-- Registra la información completa de la transacción y retorna el ID generado.
CREATE PROCEDURE sp_InsertVenta
    @cliente_id INT = NULL,                       -- ID del cliente (opcional, puede ser venta sin cliente registrado)
    @numero_orden VARCHAR(20),                    -- Número único de la orden (requerido)
    @monto_total DECIMAL(12,2) = 0,              -- Monto total de la venta
    @metodo_pago VARCHAR(20) = 'EFECTIVO',       -- Forma de pago (EFECTIVO, TARJETA, TRANSFERENCIA, etc.)
    @estatus_venta VARCHAR(20) = 'COMPLETADA',   -- Estado de la venta (COMPLETADA, PENDIENTE, CANCELADA)
    @estatus_entrega VARCHAR(30) = 'ENTREGADA',  -- Estado de entrega (ENTREGADA, PENDIENTE, EN_PROCESO)
    @fecha_entrega DATETIME = NULL,               -- Fecha y hora de entrega (opcional)
    @notas VARCHAR(200) = NULL,                   -- Observaciones adicionales sobre la venta
    @entregado_por VARCHAR(100) = NULL            -- Empleado que realizó la entrega (opcional)
AS
BEGIN
    -- Si no se especifica fecha de entrega, usar la fecha/hora actual
    IF @fecha_entrega IS NULL
        SET @fecha_entrega = GETDATE();
        
    INSERT INTO Ventas (cliente_id, numero_orden, monto_total, metodo_pago, estatus_venta, estatus_entrega, fecha_entrega, notas, entregado_por)
    VALUES (@cliente_id, @numero_orden, @monto_total, @metodo_pago, @estatus_venta, @estatus_entrega, @fecha_entrega, @notas, @entregado_por);
    
    SELECT SCOPE_IDENTITY() AS id;                -- Devuelve el ID generado automáticamente
END;
GO

-- Obtiene todas las ventas registradas con información del cliente.
-- Incluye un JOIN con la tabla Clientes para mostrar el nombre completo.
-- Se ordena por fecha de venta descendente para mostrar las más recientes primero.
CREATE PROCEDURE sp_GetVentas
AS
BEGIN
    SELECT v.id, v.cliente_id, CONCAT(c.nombre, ' ', c.apellido) AS cliente_nombre,
           v.numero_orden, v.fecha_venta, v.monto_total, v.metodo_pago,
           v.estatus_venta, v.estatus_entrega, v.fecha_entrega, v.notas, v.entregado_por
    FROM Ventas v
    LEFT JOIN Clientes c ON v.cliente_id = c.id  -- LEFT JOIN para incluir ventas sin cliente
    ORDER BY v.fecha_venta DESC;                  -- Ventas más recientes primero
END;
GO

-- Recupera los datos de una venta específica a partir de su ID.
-- Incluye información del cliente asociado si existe.
CREATE PROCEDURE sp_GetVentaById
    @id INT                                       -- ID de la venta
AS
BEGIN
    SELECT v.id, v.cliente_id, CONCAT(c.nombre, ' ', c.apellido) AS cliente_nombre,
           v.numero_orden, v.fecha_venta, v.monto_total, v.metodo_pago,
           v.estatus_venta, v.estatus_entrega, v.fecha_entrega, v.notas, v.entregado_por
    FROM Ventas v
    LEFT JOIN Clientes c ON v.cliente_id = c.id  -- LEFT JOIN para incluir ventas sin cliente
    WHERE v.id = @id;
END;
GO

-- Actualiza los datos de una venta existente.
-- Permite modificar toda la información de la venta excepto la fecha de creación.
-- Retorna la cantidad de registros afectados.
CREATE PROCEDURE sp_UpdateVenta
    @id INT,                                      -- ID de la venta a actualizar
    @cliente_id INT = NULL,                       -- Nuevo ID del cliente
    @numero_orden VARCHAR(20),                    -- Nuevo número de orden
    @monto_total DECIMAL(12,2) = 0,              -- Nuevo monto total
    @metodo_pago VARCHAR(20) = 'EFECTIVO',       -- Nuevo método de pago
    @estatus_venta VARCHAR(20) = 'COMPLETADA',   -- Nuevo estatus de venta
    @estatus_entrega VARCHAR(30) = 'ENTREGADA',  -- Nuevo estatus de entrega
    @fecha_entrega DATETIME = NULL,               -- Nueva fecha de entrega
    @notas VARCHAR(200) = NULL,                   -- Nuevas notas
    @entregado_por VARCHAR(100) = NULL            -- Nuevo responsable de entrega
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
    
    SELECT @@ROWCOUNT AS affected_rows;           -- Registros modificados (0 o 1)
END;
GO

-- Elimina una venta por su ID.
-- PRECAUCIÓN: Esta acción es irreversible y puede afectar reportes de ventas.
-- Considerar cambiar el estatus a 'CANCELADA' en lugar de eliminar físicamente.
-- Retorna la cantidad de registros eliminados.
CREATE PROCEDURE sp_DeleteVenta
    @id INT                                       -- ID de la venta a eliminar
AS
BEGIN
    DELETE FROM Ventas
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;           -- Registros eliminados (0 o 1)
END;
GO


CREATE PROCEDURE sp_ReporteVentasResumen
    @modo VARCHAR(10),                          -- 'SEMANA' o 'RANGO'
    @fecha_inicio DATE = NULL,                  -- Requerido si modo = 'RANGO'
    @fecha_fin DATE = NULL                      -- Requerido si modo = 'RANGO'
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar parámetros si modo es RANGO
    IF @modo = 'RANGO' AND (@fecha_inicio IS NULL OR @fecha_fin IS NULL)
    BEGIN
        RAISERROR('Debe proporcionar fecha_inicio y fecha_fin para el modo RANGO.', 16, 1);
        RETURN;
    END

    -- Calcular rango de semana actual si modo = 'SEMANA'
    IF @modo = 'SEMANA'
    BEGIN
        -- Primer día de la semana actual (Lunes)
        SET @fecha_inicio = DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE));

        -- Ajustar si el primer día de la semana es domingo
        IF DATEPART(WEEKDAY, GETDATE()) = 1
            SET @fecha_inicio = DATEADD(DAY, -6, CAST(GETDATE() AS DATE));

        -- Último día de la semana (Domingo)
        SET @fecha_fin = DATEADD(DAY, 6, @fecha_inicio);
    END

    -- Consulta resumen diaria
    SELECT 
        CAST(v.fecha_venta AS DATE) AS Fecha,
        COUNT(*) AS TotalVentas,
        SUM(v.monto_total) AS IngresosTotales,
        SUM(CASE WHEN v.metodo_pago = 'EFECTIVO' THEN v.monto_total ELSE 0 END) AS TotalEfectivo
    FROM Ventas v
    WHERE CAST(v.fecha_venta AS DATE) BETWEEN @fecha_inicio AND @fecha_fin
    GROUP BY CAST(v.fecha_venta AS DATE)
    ORDER BY Fecha;
END;
GO
