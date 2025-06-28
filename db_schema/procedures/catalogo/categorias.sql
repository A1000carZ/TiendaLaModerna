CREATE PROCEDURE sp_InsertCategoria
    @nombre VARCHAR(100),
    @img VARCHAR(512) = NULL,
    @activo BIT = 1
AS
BEGIN
    INSERT INTO CatalogoCategorias (nombre, img, activo)
    VALUES (@nombre, @img, @activo);
    
    SELECT SCOPE_IDENTITY() AS id;
END;


CREATE PROCEDURE sp_GetCategorias
AS
BEGIN
    SELECT id, nombre, img, activo
    FROM CatalogoCategorias
    ORDER BY nombre;
END;


CREATE PROCEDURE sp_GetCategoriaById
    @id SMALLINT
AS
BEGIN
    SELECT id, nombre, img, activo
    FROM CatalogoCategorias
    WHERE id = @id;
END;


CREATE PROCEDURE sp_UpdateCategoria
    @id SMALLINT,
    @nombre VARCHAR(100),
    @img VARCHAR(512) = NULL,
    @activo BIT = 1
AS
BEGIN
    UPDATE CatalogoCategorias
    SET nombre = @nombre,
        img = @img,
        activo = @activo
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;


CREATE PROCEDURE sp_DeleteCategoria
    @id SMALLINT
AS
BEGIN
    DELETE FROM CatalogoCategorias
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
