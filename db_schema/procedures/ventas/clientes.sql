CREATE PROCEDURE sp_InsertCliente
    @nombre VARCHAR(100),
    @apellido VARCHAR(100) = '',
    @telefono VARCHAR(15) = '',
    @email VARCHAR(100) = '',
    @activo BIT = 1
AS
BEGIN
    INSERT INTO Clientes (nombre, apellido, telefono, email, activo)
    VALUES (@nombre, @apellido, @telefono, @email, @activo);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
go


CREATE PROCEDURE sp_GetClientes
AS
BEGIN
    SELECT id, nombre, apellido, telefono, email, activo
    FROM Clientes
    ORDER BY nombre;
END;
go

CREATE PROCEDURE sp_GetClienteById
    @id INT
AS
BEGIN
    SELECT id, nombre, apellido, telefono, email, activo
    FROM Clientes
    WHERE id = @id;
END;
go

CREATE PROCEDURE sp_UpdateCliente
    @id INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100) = '',
    @telefono VARCHAR(15) = '',
    @email VARCHAR(100) = '',
    @activo BIT = 1
AS
BEGIN
    UPDATE Clientes
    SET nombre = @nombre,
        apellido = @apellido,
        telefono = @telefono,
        email = @email,
        activo = @activo
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_DeleteCliente
    @id INT
AS
BEGIN
    DELETE FROM Clientes
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go