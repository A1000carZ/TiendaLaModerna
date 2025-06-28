CREATE PROCEDURE sp_InsertProducto
    @nombre VARCHAR(100),
    @categoria_id SMALLINT = NULL,
    @precio DECIMAL(10,2) = 0,
    @costo_promedio DECIMAL(10,2) = 0,
    @img VARCHAR(512) = NULL,
    @promocion BIT = 0,
    @agotado BIT = 0,
    @umbral_inventario INT = 5,
    @requiere_vencimiento BIT = 0,
    @activo BIT = 1
AS
BEGIN
    INSERT INTO CatalogoProductos (nombre, categoria_id, precio, costo_promedio, img, promocion, agotado, umbral_inventario, requiere_vencimiento, activo)
    VALUES (@nombre, @categoria_id, @precio, @costo_promedio, @img, @promocion, @agotado, @umbral_inventario, @requiere_vencimiento, @activo);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
go

CREATE PROCEDURE sp_GetProductos
AS
BEGIN
    SELECT p.id, p.nombre, p.categoria_id, c.nombre AS categoria_nombre,
           p.precio, p.costo_promedio, p.img, p.promocion, p.agotado,
           p.umbral_inventario, p.requiere_vencimiento, p.activo, p.fecha_creacion
    FROM CatalogoProductos p
    LEFT JOIN CatalogoCategorias c ON p.categoria_id = c.id
    ORDER BY p.nombre;
END;
go

CREATE PROCEDURE sp_GetProductoById
    @id INT
AS
BEGIN
    SELECT p.id, p.nombre, p.categoria_id, c.nombre AS categoria_nombre,
           p.precio, p.costo_promedio, p.img, p.promocion, p.agotado,
           p.umbral_inventario, p.requiere_vencimiento, p.activo, p.fecha_creacion
    FROM CatalogoProductos p
    LEFT JOIN CatalogoCategorias c ON p.categoria_id = c.id
    WHERE p.id = @id;
END;
go

CREATE PROCEDURE sp_UpdateProducto
    @id INT,
    @nombre VARCHAR(100),
    @categoria_id SMALLINT = NULL,
    @precio DECIMAL(10,2) = 0,
    @costo_promedio DECIMAL(10,2) = 0,
    @img VARCHAR(512) = NULL,
    @promocion BIT = 0,
    @agotado BIT = 0,
    @umbral_inventario INT = 5,
    @requiere_vencimiento BIT = 0,
    @activo BIT = 1
AS
BEGIN
    UPDATE CatalogoProductos
    SET nombre = @nombre,
        categoria_id = @categoria_id,
        precio = @precio,
        costo_promedio = @costo_promedio,
        img = @img,
        promocion = @promocion,
        agotado = @agotado,
        umbral_inventario = @umbral_inventario,
        requiere_vencimiento = @requiere_vencimiento,
        activo = @activo
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_DeleteProducto
    @id INT
AS
BEGIN
    DELETE FROM CatalogoProductos
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows;
END;
go

CREATE PROCEDURE sp_GetProductosByCategoria
    @categoria_id SMALLINT
AS
BEGIN
    SELECT p.id, p.nombre, p.categoria_id, c.nombre AS categoria_nombre,
           p.precio, p.costo_promedio, p.img, p.promocion, p.agotado,
           p.umbral_inventario, p.requiere_vencimiento, p.activo, p.fecha_creacion
    FROM CatalogoProductos p
    LEFT JOIN CatalogoCategorias c ON p.categoria_id = c.id
    WHERE p.categoria_id = @categoria_id AND p.activo = 1
    ORDER BY p.nombre;
END;
go

CREATE PROCEDURE sp_GetStockByProducto
    @producto_id INT
AS
BEGIN
    SELECT s.cantidad_disponible, s.cantidad_reservada,
           (s.cantidad_disponible - s.cantidad_reservada) AS cantidad_libre,
           s.ultima_actualizacion
    FROM StockProductos s
    WHERE s.producto_id = @producto_id;
END;
go