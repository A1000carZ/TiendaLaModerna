-- Inserta un nuevo proveedor en la tabla Proveedores.
-- Devuelve el ID generado automáticamente.
CREATE PROCEDURE sp_InsertProveedor
    @nombre VARCHAR(100),                     -- Nombre del proveedor (requerido)
    @apellido VARCHAR(100) = '',              -- Apellido (opcional)
    @empresa VARCHAR(100) = '',               -- Nombre de la empresa del proveedor (opcional)
    @telefono VARCHAR(15) = '',               -- Teléfono de contacto (opcional)
    @email VARCHAR(100) = '',                 -- Correo electrónico (opcional)
    @activo BIT = 1                           -- Estado del proveedor (activo/inactivo)
AS
BEGIN
    INSERT INTO Proveedores (nombre, apellido, empresa, telefono, email, activo)
    VALUES (@nombre, @apellido, @empresa, @telefono, @email, @activo);
    
    SELECT SCOPE_IDENTITY() AS id;            -- Devuelve el ID del nuevo proveedor
END;
GO

-- Recupera la lista completa de proveedores registrados.
CREATE PROCEDURE sp_GetProveedores
AS
BEGIN
    SELECT id, nombre, apellido, empresa, telefono, email, activo
    FROM Proveedores
    ORDER BY nombre;                          -- Ordenados alfabéticamente por nombre
END;
GO

-- Recupera los datos de un proveedor específico mediante su ID.
CREATE PROCEDURE sp_GetProveedorById
    @id INT                                   -- ID del proveedor
AS
BEGIN
    SELECT id, nombre, apellido, empresa, telefono, email, activo
    FROM Proveedores
    WHERE id = @id;
END;
GO

-- Actualiza los datos de un proveedor existente.
-- Devuelve la cantidad de filas afectadas por la actualización.
CREATE PROCEDURE sp_UpdateProveedor
    @id INT,                                  -- ID del proveedor a actualizar
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
    
    SELECT @@ROWCOUNT AS affected_rows;       -- Devuelve el número de registros modificados
END;
GO

-- Elimina un proveedor de la base de datos.
-- Devuelve la cantidad de filas eliminadas.
CREATE PROCEDURE sp_DeleteProveedor
    @id INT                                   -- ID del proveedor a eliminar
AS
BEGIN
    DELETE FROM Proveedores
    WHERE id = @id;

    SELECT @@ROWCOUNT AS affected_rows;       -- Confirma cuántas filas fueron eliminadas
END;
GO
