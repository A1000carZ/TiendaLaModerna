-- CREATE
CREATE PROCEDURE sp_InsertProveedor
    @nombre VARCHAR(100),
    @apellido VARCHAR(100) = '',
    @empresa VARCHAR(100) = '',
    @telefono VARCHAR(15) = '',
    @email VARCHAR(100) = '',
    @activo BIT = 1
AS
BEGIN
    INSERT INTO Proveedores (nombre, apellido, empresa, telefono, email, activo)
    VALUES (@nombre, @apellido, @empresa, @telefono, @email, @activo);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
go

CREATE PROCEDURE sp_GetProveedores
AS
BEGIN
    SELECT id, nombre, apellido, empresa, telefono, email, activo
    FROM Proveedores
    ORDER BY nombre;
END;
go

CREATE PROCEDURE sp_GetProveedorById
    @id INT
AS
BEGIN
    SELECT id, nombre, apellido, empresa, telefono, email, activo
    FROM Proveedores
    WHERE id = @id;
END;
go

CREATE PROCEDURE sp_UpdateProveedor
    @id INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100) = '',
    @empresa VARCHAR(100) = '',
    @telefono VARCHAR(15) = '',
    @email VARCHAR(100) = '',
    @activo BIT = 1
AS
BEGIN
    UPDATE Proveedores
    SET nombre = @nombre,
        apellido = @apellido,
        empresa = @empresa,
        telefono = @telefono,
        email = @email,
        activo = @activo
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_DeleteProveedor
    @id INT
AS
BEGIN
    DELETE FROM Proveedores
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go