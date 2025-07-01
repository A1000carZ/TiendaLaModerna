-- Inserta un nuevo corte de caja en la base de datos.
-- Registra la información del cierre diario de caja y retorna el ID generado.
CREATE PROCEDURE sp_InsertCorteCaja
    @fecha DATE,                                  -- Fecha del corte de caja (requerido)
    @saldo_inicial DECIMAL(12,2) = 0,            -- Efectivo inicial en caja al inicio del día
    @total_ventas DECIMAL(12,2) = 0,             -- Total de ventas realizadas durante el día
    @efectivo_recibido DECIMAL(12,2) = 0,        -- Efectivo total recibido por ventas
    @saldo_final DECIMAL(12,2) = 0,              -- Efectivo final contado en caja
    @notas VARCHAR(200) = NULL,                   -- Observaciones adicionales (opcional)
    @cerrado_por VARCHAR(100) = NULL              -- Usuario que realizó el corte (opcional)
AS
BEGIN
    INSERT INTO CorteCaja (fecha, saldo_inicial, total_ventas, efectivo_recibido, saldo_final, notas, cerrado_por, fecha_cierre)
    VALUES (@fecha, @saldo_inicial, @total_ventas, @efectivo_recibido, @saldo_final, @notas, @cerrado_por, GETDATE());
    
    SELECT SCOPE_IDENTITY() AS id;                -- Devuelve el ID generado automáticamente
END;
GO

-- Obtiene todos los cortes de caja registrados.
-- Se ordena por fecha descendente para mostrar los más recientes primero.
CREATE PROCEDURE sp_GetCortesCaja
AS
BEGIN
    SELECT id, fecha, saldo_inicial, total_ventas, efectivo_recibido,
           saldo_final, notas, cerrado_por, fecha_cierre
    FROM CorteCaja
    ORDER BY fecha DESC;                          -- Cortes más recientes primero
END;
GO

-- Recupera los datos de un corte de caja específico a partir de su ID.
CREATE PROCEDURE sp_GetCorteCajaById
    @id INT                                       -- ID del corte de caja
AS
BEGIN
    SELECT id, fecha, saldo_inicial, total_ventas, efectivo_recibido,
           saldo_final, notas, cerrado_por, fecha_cierre
    FROM CorteCaja
    WHERE id = @id;
END;
GO

-- Actualiza los datos de un corte de caja existente.
-- Permite modificar toda la información excepto la fecha de cierre.
-- Retorna la cantidad de registros afectados.
CREATE PROCEDURE sp_UpdateCorteCaja
    @id INT,                                      -- ID del corte de caja a actualizar
    @fecha DATE,                                  -- Nueva fecha del corte
    @saldo_inicial DECIMAL(12,2) = 0,            -- Nuevo saldo inicial
    @total_ventas DECIMAL(12,2) = 0,             -- Nuevo total de ventas
    @efectivo_recibido DECIMAL(12,2) = 0,        -- Nuevo efectivo recibido
    @saldo_final DECIMAL(12,2) = 0,              -- Nuevo saldo final
    @notas VARCHAR(200) = NULL,                   -- Nuevas notas
    @cerrado_por VARCHAR(100) = NULL              -- Usuario que modificó el registro
AS
BEGIN
    UPDATE CorteCaja
    SET fecha = @fecha,
        saldo_inicial = @saldo_inicial,
        total_ventas = @total_ventas,
        efectivo_recibido = @efectivo_recibido,
        saldo_final = @saldo_final,
        notas = @notas,
        cerrado_por = @cerrado_por
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;           -- Registros modificados (0 o 1)
END;
GO

-- Elimina un corte de caja por su ID.
-- PRECAUCIÓN: Esta acción es irreversible y afectará el historial de cortes.
-- Retorna la cantidad de registros eliminados.
CREATE PROCEDURE sp_DeleteCorteCaja
    @id INT                                       -- ID del corte de caja a eliminar
AS
BEGIN
    DELETE FROM CorteCaja
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;           -- Registros eliminados (0 o 1)
END;
GO

CREATE PROCEDURE sp_CrearCorteCaja
    @fecha DATE = NULL,                  -- Fecha del corte (default: hoy)
    @saldo_inicial DECIMAL(12,2) = 0,    -- Saldo inicial del día
    @cerrado_por VARCHAR(100)           -- Usuario que cierra la caja
AS
BEGIN
    SET NOCOUNT ON;

    -- Si no se pasa fecha, se usa la actual
    IF @fecha IS NULL
        SET @fecha = CAST(GETDATE() AS DATE);

    -- Verifica si ya existe un corte para esta fecha
    IF EXISTS (SELECT 1 FROM CorteCaja WHERE fecha = @fecha)
    BEGIN
        RAISERROR('Ya existe un corte de caja para esta fecha.', 16, 1);
        RETURN;
    END

    -- Calcular total de ventas del día (COMPLETADAS)
    DECLARE @total_ventas DECIMAL(12,2) = (
        SELECT ISNULL(SUM(monto_total), 0)
        FROM Ventas
        WHERE CAST(fecha_venta AS DATE) = @fecha
          AND estatus_venta = 'COMPLETADA'
    );

    -- Calcular efectivo recibido (puedes adaptar esto a otros métodos de pago)
    DECLARE @efectivo_recibido DECIMAL(12,2) = (
        SELECT ISNULL(SUM(monto_total), 0)
        FROM Ventas
        WHERE CAST(fecha_venta AS DATE) = @fecha
          AND estatus_venta = 'COMPLETADA'
          AND metodo_pago = 'EFECTIVO'
    );

    -- Saldo final = saldo inicial + efectivo recibido
    DECLARE @saldo_final DECIMAL(12,2) = @saldo_inicial + @efectivo_recibido;

    -- Insertar el corte del día
    INSERT INTO CorteCaja (
        fecha,
        saldo_inicial,
        total_ventas,
        efectivo_recibido,
        saldo_final,
        cerrado_por,
        fecha_cierre
    )
    VALUES (
        @fecha,
        @saldo_inicial,
        @total_ventas,
        @efectivo_recibido,
        @saldo_final,
        @cerrado_por,
        GETDATE()
    );
END;
GO
