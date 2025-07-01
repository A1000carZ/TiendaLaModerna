-- =====================================================================================
-- TRIGGER: tr_MovimientosInventario
-- PROPÓSITO: Actualiza automáticamente las cantidades de stock cuando se registra
--           un movimiento de inventario (ENTRADA, SALIDA o AJUSTE).
-- TABLA AFECTADA: MovimientosInventario (disparador)
-- TABLAS DESTINO: StockProductos, LotesStock (actualizadas)
-- EVENTO: AFTER INSERT - Se ejecuta después de insertar un movimiento
-- =====================================================================================

CREATE TRIGGER tr_MovimientosInventario
ON MovimientosInventario 
AFTER INSERT 
AS 
BEGIN
    -- Variables para almacenar los datos del movimiento
    DECLARE @producto_id INT,                     -- ID del producto
            @lote_id INT,                        -- ID del lote (puede ser null)
            @tipo_movimiento VARCHAR(20),        -- Tipo: ENTRADA, SALIDA o AJUSTE
            @cantidad INT;                       -- Cantidad del movimiento
    
    -- Obtiene los datos del movimiento recién insertado
    SELECT @producto_id = producto_id,
           @lote_id = lote_id,
           @tipo_movimiento = tipo_movimiento,
           @cantidad = cantidad 
    FROM inserted;

    -- Procesa movimientos de ENTRADA: incrementa el stock disponible
    IF (@tipo_movimiento = 'ENTRADA')
    BEGIN
        UPDATE e
        SET e.cantidad_disponible = e.cantidad_disponible + @cantidad  -- Suma la cantidad al stock
        FROM StockProductos e
        WHERE e.producto_id = @producto_id;
    END
    
    -- Procesa movimientos de SALIDA: reduce el stock disponible y actualiza lotes
    ELSE IF (@tipo_movimiento = 'SALIDA')
    BEGIN
        -- Actualiza el stock general del producto (no permite cantidades negativas)
        UPDATE e
        SET e.cantidad_disponible = CASE
            WHEN e.cantidad_disponible - @cantidad < 0 THEN 0  -- Evita stock negativo
            ELSE e.cantidad_disponible - @cantidad             -- Resta la cantidad
        END
        FROM StockProductos e
        WHERE e.producto_id = @producto_id;
        
        -- Si existe un lote específico, actualiza su información
        IF (@lote_id IS NOT NULL)
        BEGIN
            UPDATE l
            SET l.cantidad_restante = CASE 
                    WHEN l.cantidad_restante - @cantidad <= 0 THEN 0  -- Si se agota, queda en 0
                    ELSE l.cantidad_restante - @cantidad              -- Resta la cantidad
                END,
                l.activo = CASE 
                    WHEN l.cantidad_restante - @cantidad <= 0 THEN 0  -- Desactiva lote agotado
                    ELSE 1                                            -- Mantiene lote activo
                END
            FROM LotesStock l
            WHERE l.id = @lote_id;
        END 
    END
    
    -- Procesa movimientos de AJUSTE: establece una cantidad exacta de stock
    ELSE IF (@tipo_movimiento = 'AJUSTE')
    BEGIN
        UPDATE e 
        SET e.cantidad_disponible = @cantidad      -- Establece la cantidad exacta
        FROM StockProductos e
        WHERE e.producto_id = @producto_id;
    END;
    
END;