-- =====================================================================================
-- TRIGGER: tr_DetalleEntregas
-- PROPÓSITO: Actualiza automáticamente el estado de entregas cuando se registra
--           una nueva entrega de productos, actualizando tanto el detalle de venta
--           como el estado general de la venta y registrando el movimiento de inventario.
-- TABLA AFECTADA: DetalleEntregas (disparador)
-- TABLAS DESTINO: DetalleVentas, Ventas (actualizadas)
-- EVENTO: AFTER INSERT - Se ejecuta después de insertar una entrega
-- =====================================================================================

CREATE TRIGGER tr_DetalleEntregas 
ON DetalleEntregas 
AFTER INSERT 
AS 
BEGIN
    SET NOCOUNT ON;                               -- Evita mensajes de filas afectadas
    
    -- =====================================================================================
    -- SECCIÓN 1: DECLARACIÓN DE VARIABLES Y OBTENCIÓN DE DATOS DE LA ENTREGA
    -- =====================================================================================
    
    -- Variables para almacenar los datos de la entrega recién insertada
    DECLARE @detalle_venta_id INT,                -- ID del detalle de venta asociado
            @cantidad INT,                        -- Cantidad entregada
            @lote_id INT,                        -- ID del lote del producto
            @fuente_entrega VARCHAR(50);         -- Fuente de la entrega (almacén, etc.)
    
    -- Obtiene los datos de la entrega desde la tabla 'inserted'
    SELECT @detalle_venta_id = detalle_venta_id, 
           @cantidad = cantidad_entregada, 
           @lote_id = lote_id, 
           @fuente_entrega = fuente_entrega 
    FROM inserted;
    
    -- Variables adicionales para datos relacionados
    DECLARE @producto_id INT,                     -- ID del producto
            @venta_id INT;                       -- ID de la venta
    
    -- Obtiene el producto_id y venta_id desde el detalle de venta
    SELECT @producto_id = producto_id, 
           @venta_id = venta_id
    FROM DetalleVentas
    WHERE id = @detalle_venta_id;
    
    -- =====================================================================================
    -- SECCIÓN 2: ACTUALIZACIÓN DEL DETALLE DE VENTA
    -- =====================================================================================
    
    -- Actualiza la cantidad entregada y el estatus de entrega del detalle específico
    UPDATE d 
    SET d.cantidad_entregada = d.cantidad_entregada + @cantidad,  -- Suma la nueva cantidad entregada
        d.estatus_entrega = CASE 
            -- Si aún falta por entregar, marca como PARCIAL
            WHEN d.cantidad_entregada + @cantidad < d.cantidad_solicitada THEN 'PARCIAL'
            -- Si ya se entregó todo o más, marca como COMPLETA
            WHEN d.cantidad_entregada + @cantidad >= d.cantidad_solicitada THEN 'COMPLETA'
            -- Caso por defecto (no debería ocurrir)
            ELSE 'PENDIENTE'
        END
    FROM DetalleVentas d
    WHERE d.id = @detalle_venta_id;
    
    -- =====================================================================================
    -- SECCIÓN 3: CÁLCULO DE ESTADÍSTICAS DE LA VENTA COMPLETA
    -- =====================================================================================
    
    -- Variables para contar el estado de todos los detalles de la venta
    DECLARE @total_detalle_ventas INT,            -- Total de líneas de detalle en la venta
            @detalle_ventas_completas INT,        -- Líneas completamente entregadas
            @detalle_ventas_parciales INT;        -- Líneas parcialmente entregadas
    
    -- Calcula las estadísticas de entrega para toda la venta
    SELECT 
        @total_detalle_ventas = COUNT(*),         -- Cuenta total de líneas
        @detalle_ventas_completas = SUM(CASE WHEN estatus_entrega = 'COMPLETA' THEN 1 ELSE 0 END),
        @detalle_ventas_parciales = SUM(CASE WHEN estatus_entrega = 'PARCIAL' THEN 1 ELSE 0 END)
    FROM DetalleVentas
    WHERE venta_id = @venta_id;
    
    -- =====================================================================================
    -- SECCIÓN 4: ACTUALIZACIÓN DEL ESTADO GENERAL DE LA VENTA
    -- =====================================================================================
    
    -- Actualiza el estado de entrega y venta basado en las estadísticas calculadas
    UPDATE v 
    SET v.estatus_entrega = CASE 
            -- Si todas las líneas están completas, la entrega está completa
            WHEN @detalle_ventas_completas = @total_detalle_ventas THEN 'COMPLETA'
            -- Si hay líneas completas o parciales, la entrega es parcial
            WHEN @detalle_ventas_completas > 0 OR @detalle_ventas_parciales > 0 THEN 'PARCIAL'
            -- Si no hay entregas, permanece pendiente
            ELSE 'PENDIENTE'
        END,
        v.estatus_venta = CASE 
            -- Si todas las líneas están completas, la venta está completada
            WHEN @detalle_ventas_completas = @total_detalle_ventas THEN 'COMPLETADA'
            -- En cualquier otro caso, la venta sigue pendiente
            WHEN @detalle_ventas_completas > 0 OR @detalle_ventas_parciales > 0 THEN 'PENDIENTE'
            ELSE 'PENDIENTE'
        END
    FROM Ventas v
    WHERE v.id = @venta_id;
    
    -- =====================================================================================
    -- SECCIÓN 5: REGISTRO DEL MOVIMIENTO DE INVENTARIO
    -- =====================================================================================
    
    -- Registra la salida del producto del inventario mediante procedimiento almacenado
    EXEC sp_InsertMovimientoInventario  
        @producto_id = @producto_id,              -- Producto que sale del inventario
        @lote_id = @lote_id,                     -- Lote específico del producto
        @tipo_movimiento = 'SALIDA',             -- Tipo de movimiento (salida por venta)
        @cantidad = @cantidad,                   -- Cantidad que sale
        @tipo_referencia = 'VENTA',              -- Referencia del movimiento
        @referencia_id = @venta_id,              -- ID de la venta que origina el movimiento
        @notas = NULL;                           -- Sin notas adicionales
        
END;