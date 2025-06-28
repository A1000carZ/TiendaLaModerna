CREATE PROCEDURE sp_InsertCorteCaja
    @fecha DATE,
    @saldo_inicial DECIMAL(12,2) = 0,
    @total_ventas DECIMAL(12,2) = 0,
    @efectivo_recibido DECIMAL(12,2) = 0,
    @saldo_final DECIMAL(12,2) = 0,
    @notas VARCHAR(200) = NULL,
    @cerrado_por VARCHAR(100) = NULL
AS
BEGIN
    INSERT INTO CorteCaja (fecha, saldo_inicial, total_ventas, efectivo_recibido, saldo_final, notas, cerrado_por, fecha_cierre)
    VALUES (@fecha, @saldo_inicial, @total_ventas, @efectivo_recibido, @saldo_final, @notas, @cerrado_por, GETDATE());
    
    SELECT SCOPE_IDENTITY() AS id;
END;
go

CREATE PROCEDURE sp_GetCortesCaja
AS
BEGIN
    SELECT id, fecha, saldo_inicial, total_ventas, efectivo_recibido,
           saldo_final, notas, cerrado_por, fecha_cierre
    FROM CorteCaja
    ORDER BY fecha DESC;
END;
go


CREATE PROCEDURE sp_GetCorteCajaById
    @id INT
AS
BEGIN
    SELECT id, fecha, saldo_inicial, total_ventas, efectivo_recibido,
           saldo_final, notas, cerrado_por, fecha_cierre
    FROM CorteCaja
    WHERE id = @id;
END;
go


CREATE PROCEDURE sp_UpdateCorteCaja
    @id INT,
    @fecha DATE,
    @saldo_inicial DECIMAL(12,2) = 0,
    @total_ventas DECIMAL(12,2) = 0,
    @efectivo_recibido DECIMAL(12,2) = 0,
    @saldo_final DECIMAL(12,2) = 0,
    @notas VARCHAR(200) = NULL,
    @cerrado_por VARCHAR(100) = NULL
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
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_DeleteCorteCaja
    @id INT
AS
BEGIN
    DELETE FROM CorteCaja
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go