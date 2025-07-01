-- Inserta un nuevo producto en el catálogo
-- Devuelve el ID generado al finalizar
CREATE PROCEDURE sp_InsertProducto
    @nombre VARCHAR(100),                         -- Nombre del producto
    @categoria_id SMALLINT = NULL,                -- Categoría asociada (puede ser NULL)
    @precio DECIMAL(10,2) = 0,                    -- Precio de venta
    @costo_promedio DECIMAL(10,2) = 0,            -- Costo promedio calculado
    @img VARCHAR(512) = NULL,                     -- Imagen del producto
    @promocion BIT = 0,                           -- Indica si está en promoción
    @agotado BIT = 0,                             -- Indica si está agotado
    @umbral_inventario INT = 5,                   -- Nivel mínimo de inventario antes de alertar
    @requiere_vencimiento BIT = 0,                -- Indica si el producto maneja fecha de vencimiento
    @activo BIT = 1                               -- Estado del producto
AS
BEGIN
    INSERT INTO CatalogoProductos (nombre, categoria_id, precio, costo_promedio, img, promocion, agotado, umbral_inventario, requiere_vencimiento, activo)
    VALUES (@nombre, @categoria_id, @precio, @costo_promedio, @img, @promocion, @agotado, @umbral_inventario, @requiere_vencimiento, @activo);
    
    SELECT SCOPE_IDENTITY() AS id; -- Devuelve el ID recién creado
END;
GO

-- Devuelve la lista completa de productos con su categoría
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
GO

-- Devuelve los detalles de un producto específico por ID
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
GO

-- Actualiza los datos de un producto existente
-- Retorna la cantidad de filas afectadas
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
    
    SELECT @@ROWCOUNT AS affected_rows; -- Indica si se actualizó correctamente
END;
GO

-- Elimina un producto por su ID
-- Retorna la cantidad de filas eliminadas
CREATE PROCEDURE sp_DeleteProducto
    @id INT
AS
BEGIN
    DELETE FROM CatalogoProductos
    WHERE id = @id;
    
    SELECT @@ROWCOUNT AS affected_rows; -- Devuelve 1 si fue eliminado, 0 si no existe
END;
GO

-- Devuelve los productos activos de una categoría específica
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
GO

-- Obtiene el estado actual del inventario de un producto específico
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
GO
