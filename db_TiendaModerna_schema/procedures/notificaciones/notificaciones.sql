-- CREATE PROCEDURE sp_CheckStockAndNotify
--     @producto_id INT,
--     @new_qty INT
-- AS
-- BEGIN
--     SET NOCOUNT ON;
    
--     DECLARE @old_stock INT, @threshold INT, @product_name VARCHAR(100);
--     SELECT @old_stock = stock_quantity, @threshold = stock_threshold, @product_name = name
--     FROM CatalogoProductos 
--     WHERE id = @producto_id;
    
--     -- Update stock
--     UPDATE CatalogoProductos 
--     SET stock_quantity = @new_stock_quantity 
--     WHERE id = @producto_id;
    
--     -- Create notifications based on stock changes
--     IF @old_stock > @threshold AND @new_stock_quantity <= @threshold
--     BEGIN
--         -- Low stock notification
--         INSERT INTO Notificaciones (titulo, mensaje, entidad_tipo, entidad_id, prioridad)
--         VALUES ('Stock Bajo: ' + @product_name,
--                 'Alerta: Stock bajo para ' + @product_name + '. Quedan ' + CAST(@new_stock_quantity AS VARCHAR) + ' unidades.',
--                 'PRODUCTO', 
--                 @producto_id, 
--                 'ALTA');
                
--     END
    
--     IF @old_stock > 0 AND @new_stock_quantity = 0
--     BEGIN
--         -- Out of stock notification
--         INSERT INTO Notificaciones (titulo, mensaje, entidad_tipo, entidad_id, prioridad)
--         VALUES ('Sin Stock: ' + @product_name,
--                 'Producto agotado: ' + @product_name + ' ya no está disponible.',
--                 'PRODUCTO', 
--                 @producto_id, 
--                 'CRITICA');
                
--     END
    
--     IF @old_stock = 0 AND @new_stock_quantity > 0
--     BEGIN
--         -- Restock notification
--         INSERT INTO Notificaciones (titulo, mensaje, entidad_tipo, entidad_id, prioridad)
--         VALUES ('Restock: ' + @product_name,
--                 'Producto disponible: ' + @product_name + ' está nuevamente en stock con ' + CAST(@new_stock_quantity AS VARCHAR) + ' unidades.',
--                 'PRODUCTO', 
--                 @producto_id, 
--                 'NORMAL');
                
--     END
-- END;


-- CREATE PROCEDURE sp_MarcarNotificacionLeida
--     @notificacion_id INT
-- AS
-- BEGIN
--     UPDATE Notificaciones 
--     SET leida = 1, fecha_leida = GETDATE()
--     WHERE id = @notificacion_id AND leida = 0;
-- END;

-- -- Procedure to get unread notifications
-- CREATE PROCEDURE sp_ObtenerNotificacionesNoLeidas
--     @entidad_tipo VARCHAR(50) = NULL,
--     @prioridad VARCHAR(20) = NULL,
--     @top_count INT = 50
-- AS
-- BEGIN
--     SELECT TOP (@top_count)
--         n.id,
--         n.titulo,
--         n.mensaje,
--         n.entidad_tipo,
--         n.entidad_id,
--         n.prioridad,
--         n.fecha_creacion,
--         CASE n.prioridad
--             WHEN 'CRITICA' THEN 1
--             WHEN 'ALTA' THEN 2  
--             WHEN 'NORMAL' THEN 3
--             WHEN 'BAJA' THEN 4
--         END as orden_prioridad
--     FROM Notificaciones n
--     WHERE n.leida = 0
--         AND (@entidad_tipo IS NULL OR n.entidad_tipo = @entidad_tipo)
--         AND (@prioridad IS NULL OR n.prioridad = @prioridad)
--     ORDER BY orden_prioridad ASC, n.fecha_creacion DESC;
-- END;

-- -- Cleanup procedure for old notifications
-- CREATE PROCEDURE sp_CleanupOldNotifications
-- AS
-- BEGIN
--     DELETE FROM ColaNotificaciones 
--     WHERE enviado = 1 AND fecha_envio < DATEADD(DAY, -30, GETDATE());
-- END;