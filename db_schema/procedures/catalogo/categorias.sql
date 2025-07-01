-- Inserta una nueva categoría en el catálogo
-- Devuelve el ID generado mediante parámetro de salida
ALTER PROCEDURE sp_InsertCategoria
    @nombre VARCHAR(100),                  -- Nombre de la categoría
    @img VARCHAR(512) = NULL,             -- Imagen opcional
    @activo BIT = 1,                      -- Estado activo por defecto
    @id INT OUTPUT                        -- Devuelve el ID insertado
AS
BEGIN
    INSERT INTO CatalogoCategorias (nombre, img, activo)
    VALUES (@nombre, @img, @activo);
    
    SET @id = SCOPE_IDENTITY(); -- Recupera el ID generado automáticamente
END;

-- Recupera todas las categorías activas o inactivas
CREATE PROCEDURE sp_GetCategorias
AS
BEGIN
    SELECT id, nombre, img, activo
    FROM CatalogoCategorias
    ORDER BY nombre; -- Orden alfabético por nombre
END;

-- Recupera una categoría específica por su ID
CREATE PROCEDURE sp_GetCategoriaById
    @id SMALLINT -- Identificador de la categoría a consultar
AS
BEGIN
    SELECT id, nombre, img, activo
    FROM CatalogoCategorias
    WHERE id = @id;
END;

-- Actualiza los datos de una categoría existente
-- Retorna el número de filas afectadas
CREATE PROCEDURE sp_UpdateCategoria
    @id SMALLINT,                         -- ID de la categoría a modificar
    @nombre VARCHAR(100),                -- Nuevo nombre
    @img VARCHAR(512) = NULL,            -- Nueva imagen (opcional)
    @activo BIT = 1                      -- Estado actualizado
AS
BEGIN
    UPDATE CatalogoCategorias
    SET nombre = @nombre,
        img = @img,
        activo = @activo
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows; -- Devuelve 1 si fue actualizada, 0 si no
END;

-- Elimina una categoría por ID
-- Retorna el número de filas eliminadas
CREATE PROCEDURE sp_DeleteCategoria
    @id SMALLINT -- ID de la categoría a eliminar
AS
BEGIN
    DELETE FROM CatalogoCategorias
    WHERE id = @id;

    SELECT @@ROWCOUNT AS affected_rows; -- Devuelve 1 si se eliminó, 0 si no existe
END;
