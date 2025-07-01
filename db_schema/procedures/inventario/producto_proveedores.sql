-- Inserta un nuevo registro de relación entre un producto y un proveedor
-- Devuelve el ID generado para el registro
CREATE PROCEDURE sp_InsertProductoProveedor
    @proveedor_id INT,                              -- ID del proveedor
    @producto_id INT,                               -- ID del producto
    @codigo_proveedor VARCHAR(100) = '',            -- Código del producto según el proveedor (opcional)
    @precio_costo DECIMAL(10,2) = 0,                -- Precio de costo desde este proveedor
    @es_proveedor_principal BIT = 0                 -- Indica si es el proveedor principal (1) o no (0)
AS
BEGIN
    INSERT INTO ProductoProveedores (proveedor_id, producto_id, codigo_proveedor, precio_costo, es_proveedor_principal)
    VALUES (@proveedor_id, @producto_id, @codigo_proveedor, @precio_costo, @es_proveedor_principal);
    
    SELECT SCOPE_IDENTITY() AS id;
END;
GO

-- Recupera todos los productos con sus respectivos proveedores
CREATE PROCEDURE sp_GetProductoProveedores
AS
BEGIN
    SELECT pp.id, pp.proveedor_id, pr.nombre AS proveedor_nombre,
           pp.producto_id, p.nombre AS producto_nombre,
           pp.codigo_proveedor, pp.precio_costo, pp.es_proveedor_principal
    FROM ProductoProveedores pp
    INNER JOIN Proveedores pr ON pp.proveedor_id = pr.id
    INNER JOIN CatalogoProductos p ON pp.producto_id = p.id
    ORDER BY pr.nombre, p.nombre;
END;
GO

-- Recupera un registro específico de producto-proveedor por su ID
CREATE PROCEDURE sp_GetProductoProveedorById
    @id INT                                          -- ID del registro en ProductoProveedores
AS
BEGIN
    SELECT pp.id, pp.proveedor_id, pr.nombre AS proveedor_nombre,
           pp.producto_id, p.nombre AS producto_nombre,
           pp.codigo_proveedor, pp.precio_costo, pp.es_proveedor_principal
    FROM ProductoProveedores pp
    INNER JOIN Proveedores pr ON pp.proveedor_id = pr.id
    INNER JOIN CatalogoProductos p ON pp.producto_id = p.id
    WHERE pp.id = @id;
END;
GO

-- Actualiza un registro de relación producto-proveedor
-- Devuelve el número de filas afectadas
CREATE PROCEDURE sp_UpdateProductoProveedor
    @id INT,                                         -- ID del registro a actualizar
    @proveedor_id INT,
    @producto_id INT,
    @codigo_proveedor VARCHAR(100) = '',
    @precio_costo DECIMAL(10,2) = 0,
    @es_proveedor_principal BIT = 0
AS
BEGIN
    UPDATE ProductoProveedores
    SET proveedor_id = @proveedor_id,
        producto_id = @producto_id,
        codigo_proveedor = @codigo_proveedor,
        precio_costo = @precio_costo,
        es_proveedor_principal = @es_proveedor_principal
    WHERE id = @id;

    SELECT @@ROWCOUNT AS affected_rows;
END;
GO

-- Elimina un registro de relación producto-proveedor
-- Devuelve el número de filas eliminadas
CREATE PROCEDURE sp_DeleteProductoProveedor
    @id INT                                          -- ID del registro a eliminar
AS
BEGIN
    DELETE FROM ProductoProveedores
    WHERE id = @id;

    SELECT @@ROWCOUNT AS affected_rows;
END;
GO
