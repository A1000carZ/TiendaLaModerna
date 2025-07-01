-- =====================================================================================
-- TRIGGER: tr_NotificacionStock
-- PROPÓSITO: Genera notificaciones cuando el stock de un producto está por debajo
--           del umbral mínimo o cuando hay lotes próximos a vencer después de entregas.
-- TABLA AFECTADA: DetalleEntregas (disparador)
-- TABLAS CONSULTADAS: CatalogoProductos, StockProductos, LotesStock
-- EVENTO: AFTER INSERT - Se ejecuta después de registrar una entrega
-- =====================================================================================

CREATE TRIGGER tr_NotificacionStock 
ON DetalleEntregas 
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    
    -- Manejo de errores
    BEGIN TRY
        -- Cursor para procesar múltiples inserciones
        DECLARE @id_producto INT, @detalle_venta_id INT;
        
        DECLARE cursor_entregas CURSOR FOR
        SELECT DISTINCT i.detalle_venta_id
        FROM inserted i;
        
        OPEN cursor_entregas;
        FETCH NEXT FROM cursor_entregas INTO @detalle_venta_id;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Obtener el producto_id desde DetalleVentas
            SELECT @id_producto = dv.producto_id
            FROM DetalleVentas dv
            WHERE dv.id = @detalle_venta_id;
            
            -- Verificar que se encontró el producto
            IF @id_producto IS NOT NULL
            BEGIN
                -- Variables para información del producto
                DECLARE @nombre_producto VARCHAR(255),
                        @umbral_inv INT, 
                        @requiere_vencimiento BIT;
                
                -- Obtiene información del producto desde el catálogo
                SELECT @nombre_producto = nombre, 
                       @umbral_inv = umbral_inventario, 
                       @requiere_vencimiento = requiere_vencimiento
                FROM CatalogoProductos
                WHERE id = @id_producto;
                
                -- Verificar que se encontró la información del producto
                IF @nombre_producto IS NOT NULL
                BEGIN
                    -- Variable para el stock actual
                    DECLARE @stock_actual INT;
                    SELECT @stock_actual = ISNULL(cantidad_disponible, 0)
                    FROM StockProductos
                    WHERE producto_id = @id_producto;
                    
                    -- Si no existe registro en StockProductos, asumimos stock 0
                    IF @stock_actual IS NULL
                        SET @stock_actual = 0;
                    
                    -- Email por defecto para las notificaciones
                    DECLARE @email_notificacion VARCHAR(255) = 'admin@empresa.com';
                    
                    -- Verifica si el stock está por debajo del umbral mínimo
                    IF (@stock_actual <= ISNULL(@umbral_inv, 0))
                    BEGIN
                        -- Determina el tipo de notificación según el stock
                        DECLARE @tipo_notificacion VARCHAR(20);
                        IF (@stock_actual = 0)
                            SET @tipo_notificacion = 'OUT_OF_STOCK';
                        ELSE
                            SET @tipo_notificacion = 'LOW_STOCK';
                        
                        -- Desactiva notificaciones previas del mismo tipo para evitar duplicados
                        UPDATE Notificacion 
                        SET activo = 0 
                        WHERE producto_id = @id_producto 
                          AND email = @email_notificacion
                          AND tipo = @tipo_notificacion
                          AND activo = 1;
                        
                        -- Inserta nueva notificación
                        INSERT INTO Notificacion (
                            producto_id, 
                            email,
                            tipo, 
                            mensaje, 
                            activo
                        )
                        VALUES (
                            @id_producto,
                            @email_notificacion,
                            @tipo_notificacion,
                            CASE 
                                WHEN @stock_actual = 0 THEN 
                                    'El producto ' + ISNULL(@nombre_producto, 'ID:' + CAST(@id_producto AS VARCHAR(10))) + 
                                    ' está agotado. Umbral mínimo: ' + CAST(ISNULL(@umbral_inv, 0) AS VARCHAR(10)) + ' unidades.'
                                ELSE
                                    'El producto ' + ISNULL(@nombre_producto, 'ID:' + CAST(@id_producto AS VARCHAR(10))) + 
                                    ' tiene stock bajo (' + CAST(@stock_actual AS VARCHAR(10)) + 
                                    ' unidades). Umbral mínimo: ' + CAST(ISNULL(@umbral_inv, 0) AS VARCHAR(10)) + ' unidades.'
                            END,
                            1
                        );
                    END
                    
                    -- Si el producto requiere control de vencimiento, verifica lotes próximos a vencer
                    IF (ISNULL(@requiere_vencimiento, 0) = 1)
                    BEGIN
                        DECLARE @id_lote INT, 
                                @fecha_vencimiento DATE, 
                                @cantidad_lote INT,
                                @dias_para_vencer INT;
                        
                        -- Cursor para revisar lotes activos del producto
                        DECLARE cursor_lotes CURSOR FOR
                        SELECT id, fecha_vencimiento, cantidad_restante,
                               DATEDIFF(DAY, GETDATE(), fecha_vencimiento) AS dias_para_vencer
                        FROM LotesStock
                        WHERE producto_id = @id_producto 
                          AND ISNULL(activo, 0) = 1 
                          AND ISNULL(cantidad_restante, 0) > 0
                          AND fecha_vencimiento IS NOT NULL;
                        
                        OPEN cursor_lotes;
                        
                        FETCH NEXT FROM cursor_lotes 
                        INTO @id_lote, @fecha_vencimiento, @cantidad_lote, @dias_para_vencer;
                        
                        WHILE @@FETCH_STATUS = 0
                        BEGIN
                            -- Notifica si el lote vence en los próximos 7 días
                            IF (@dias_para_vencer <= 7 AND @dias_para_vencer >= 0)
                            BEGIN
                                -- Desactiva notificaciones previas de proximidad de vencimiento para este lote
                                UPDATE Notificacion 
                                SET activo = 0 
                                WHERE producto_id = @id_producto 
                                  AND email = @email_notificacion
                                  AND tipo = 'NEAR_EXPIRATION'
                                  AND activo = 1
                                  AND mensaje LIKE '%lote ' + CAST(@id_lote AS VARCHAR(10)) + '%';
                                
                                INSERT INTO Notificacion (
                                    producto_id, 
                                    email,
                                    tipo, 
                                    mensaje, 
                                    activo
                                )
                                VALUES (
                                    @id_producto,
                                    @email_notificacion,
                                    'NEAR_EXPIRATION',
                                    'El lote ' + CAST(@id_lote AS VARCHAR(10)) + ' del producto ' + 
                                    ISNULL(@nombre_producto, 'ID:' + CAST(@id_producto AS VARCHAR(10))) + 
                                    ' vence en ' + CAST(@dias_para_vencer AS VARCHAR(10)) + 
                                    ' días (fecha: ' + CONVERT(VARCHAR(10), @fecha_vencimiento, 103) + 
                                    '). Cantidad restante: ' + CAST(@cantidad_lote AS VARCHAR(10)) + ' unidades.',
                                    1
                                );
                            END
                            
                            -- Notifica si el lote ya está vencido
                            ELSE IF (@dias_para_vencer < 0)
                            BEGIN
                                -- Desactiva notificaciones previas de producto vencido para este lote
                                UPDATE Notificacion 
                                SET activo = 0 
                                WHERE producto_id = @id_producto 
                                  AND email = @email_notificacion
                                  AND tipo = 'EXPIRED'
                                  AND activo = 1
                                  AND mensaje LIKE '%lote ' + CAST(@id_lote AS VARCHAR(10)) + '%';
                                
                                INSERT INTO Notificacion (
                                    producto_id, 
                                    email,
                                    tipo, 
                                    mensaje, 
                                    activo
                                )
                                VALUES (
                                    @id_producto,
                                    @email_notificacion,
                                    'EXPIRED',
                                    'URGENTE: El lote ' + CAST(@id_lote AS VARCHAR(10)) + ' del producto ' + 
                                    ISNULL(@nombre_producto, 'ID:' + CAST(@id_producto AS VARCHAR(10))) + 
                                    ' está vencido desde el ' + CONVERT(VARCHAR(10), @fecha_vencimiento, 103) + 
                                    '. Cantidad: ' + CAST(@cantidad_lote AS VARCHAR(10)) + ' unidades.',
                                    1
                                );
                            END
                            
                            FETCH NEXT FROM cursor_lotes 
                            INTO @id_lote, @fecha_vencimiento, @cantidad_lote, @dias_para_vencer;
                        END
                        
                        CLOSE cursor_lotes;
                        DEALLOCATE cursor_lotes;
                    END
                END
            END
            
            FETCH NEXT FROM cursor_entregas INTO @detalle_venta_id;
        END
        
        CLOSE cursor_entregas;
        DEALLOCATE cursor_entregas;
        
    END TRY
    BEGIN CATCH
        -- En caso de error, cerrar cursores si están abiertos
        IF CURSOR_STATUS('local', 'cursor_entregas') >= 0
        BEGIN
            CLOSE cursor_entregas;
            DEALLOCATE cursor_entregas;
        END
        
        IF CURSOR_STATUS('local', 'cursor_lotes') >= 0
        BEGIN
            CLOSE cursor_lotes;
            DEALLOCATE cursor_lotes;
        END
        
        -- Re-lanzar el error para debugging
        THROW;
    END CATCH
END;