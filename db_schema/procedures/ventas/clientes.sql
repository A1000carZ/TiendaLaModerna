-- Inserta un nuevo cliente en la base de datos.
-- Retorna el ID generado automáticamente.
CREATE PROCEDURE sp_InsertCliente
    @nombre VARCHAR(100),                         -- Nombre del cliente (requerido)
    @apellido VARCHAR(100) = '',                  -- Apellido del cliente (opcional)
    @telefono VARCHAR(15) = '',                   -- Teléfono de contacto (opcional)
    @email VARCHAR(100) = '',                     -- Correo electrónico (opcional)
    @activo BIT = 1                               -- Estado activo del cliente (1 = activo, 0 = inactivo)
AS
BEGIN
    INSERT INTO Clientes (nombre, apellido, telefono, email, activo)
    VALUES (@nombre, @apellido, @telefono, @email, @activo);
    
    SELECT SCOPE_IDENTITY() AS id;                -- Devuelve el ID generado
END;
GO

-- Obtiene todos los clientes registrados.
-- Se ordena el resultado por nombre para facilitar la lectura.
CREATE PROCEDURE sp_GetClientes
AS
BEGIN
    SELECT id, nombre, apellido, telefono, email, activo
    FROM Clientes
    ORDER BY nombre;
END;
GO

-- Recupera los datos de un cliente específico a partir de su ID.
CREATE PROCEDURE sp_GetClienteById
    @id INT                                        -- ID del cliente
AS
BEGIN
    SELECT id, nombre, apellido, telefono, email, activo
    FROM Clientes
    WHERE id = @id;
END;
GO

-- Actualiza los datos de un cliente existente.
-- Retorna la cantidad de registros afectados.
CREATE PROCEDURE sp_UpdateCliente
    @id INT,                                       -- ID del cliente a actualizar
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
    
    SELECT @@ROWCOUNT AS affected_rows;            -- Registros modificados (0 o 1)
END;
GO

-- Elimina un cliente por su ID.
-- Retorna la cantidad de registros eliminados.
CREATE PROCEDURE sp_DeleteCliente
    @id INT                                        -- ID del cliente a eliminar
AS
BEGIN
    DELETE FROM Clientes
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
GO
