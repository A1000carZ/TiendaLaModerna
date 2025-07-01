-- Tabla que agrupa productos por categoría
CREATE TABLE CatalogoCategorias(
    id SMALLINT IDENTITY PRIMARY KEY, -- Identificador único
    nombre VARCHAR(100) NOT NULL,     -- Nombre de la categoría
    img VARCHAR(512) NULL,            -- Imagen asociada
    activo BIT DEFAULT 1              -- Estado de activación
);

-- Catálogo de productos disponibles para venta
CREATE TABLE CatalogoProductos(
    id INT IDENTITY PRIMARY KEY,               -- Identificador único
    nombre VARCHAR(100) NOT NULL,              -- Nombre del producto
    categoria_id SMALLINT,                     -- Relación con la categoría
    precio DECIMAL(10,2) DEFAULT 0,            -- Precio al público
    costo_promedio DECIMAL(10,2) DEFAULT 0,    -- Costo promedio calculado
    img VARCHAR(512) NULL,                     -- Imagen del producto
    promocion BIT DEFAULT 0,                   -- Indica si está en promoción
    agotado BIT DEFAULT 0,                     -- Indica si está agotado
    umbral_inventario INT DEFAULT 5,           -- Límite para activar alerta de bajo inventario
    requiere_vencimiento BIT DEFAULT 0,        -- Indica si requiere control por lote/vencimiento
    activo BIT DEFAULT 1,                      -- Estado activo/inactivo
    fecha_creacion DATETIME DEFAULT GETDATE(), -- Fecha de alta
    CONSTRAINT "FK_Categoria_Producto" FOREIGN KEY(categoria_id) REFERENCES CatalogoCategorias(id)
);

-- Registro de proveedores
CREATE TABLE Proveedores(
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,         -- Nombre del contacto
    apellido VARCHAR(100) DEFAULT '',     -- Apellido del contacto
    empresa VARCHAR(100) DEFAULT '',      -- Nombre de la empresa
    telefono VARCHAR(15) DEFAULT '',      -- Teléfono de contacto
    email VARCHAR(100) DEFAULT '',        -- Correo electrónico
    activo BIT DEFAULT 1                  -- Estado del proveedor
);

-- Relación muchos-a-muchos entre productos y proveedores
CREATE TABLE ProductoProveedores(
    id INT IDENTITY PRIMARY KEY,
    proveedor_id INT NOT NULL,                     -- Clave foránea a Proveedores
    producto_id INT NOT NULL,                      -- Clave foránea a Productos
    codigo_proveedor VARCHAR(100) DEFAULT '',      -- Código alterno que usa el proveedor
    precio_costo DECIMAL(10,2) DEFAULT 0,          -- Precio de compra
    es_proveedor_principal BIT DEFAULT 0,          -- Indica si es el proveedor principal
    CONSTRAINT "FK_ProductoProveedor_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id),
    CONSTRAINT "FK_ProductoProveedor_Proveedor" FOREIGN KEY(proveedor_id) REFERENCES Proveedores(id)
);

-- Registros por lote de productos (con vencimiento si aplica)
CREATE TABLE LotesStock(
    id INT IDENTITY PRIMARY KEY,
    producto_id INT NOT NULL,
    numero_lote VARCHAR(50),                      -- Identificador del lote
    fecha_vencimiento DATE NULL,                  -- Fecha de expiración
    precio_costo DECIMAL(10,2) NOT NULL,          -- Precio de compra
    cantidad_recibida INT NOT NULL,               -- Cantidad ingresada
    cantidad_restante INT NOT NULL,               -- Cantidad aún disponible
    fecha_recepcion DATETIME DEFAULT GETDATE(),   -- Fecha en que se recibió
    proveedor_id INT NULL,
    activo BIT DEFAULT 1,
    CONSTRAINT "FK_LoteStock_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id),
    CONSTRAINT "FK_LoteStock_Proveedor" FOREIGN KEY(proveedor_id) REFERENCES Proveedores(id)
);

-- Existencias generales por producto (sin considerar lote)
CREATE TABLE StockProductos(
    id INT IDENTITY PRIMARY KEY,
    producto_id INT NOT NULL,
    cantidad_disponible INT DEFAULT 0,        -- Cantidad actual disponible
    cantidad_reservada INT DEFAULT 0,         -- Cantidad separada para ventas
    ultima_actualizacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT "FK_Stock_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id)
);

-- Información de clientes
CREATE TABLE Clientes(
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) DEFAULT '',
    telefono VARCHAR(15) DEFAULT '',
    email VARCHAR(100) DEFAULT '',
    activo BIT DEFAULT 1
);

-- Registro diario del estado de caja
CREATE TABLE CorteCaja(
    id INT IDENTITY PRIMARY KEY,
    fecha DATE NOT NULL,                           -- Fecha del corte
    saldo_inicial DECIMAL(12,2) DEFAULT 0,
    total_ventas DECIMAL(12,2) DEFAULT 0,          -- Total vendido en el día
    efectivo_recibido DECIMAL(12,2) DEFAULT 0,     -- Efectivo recibido
    saldo_final DECIMAL(12,2) DEFAULT 0,           -- Resultado de caja
    notas VARCHAR(200),
    cerrado_por VARCHAR(100),
    fecha_cierre DATETIME,
    UNIQUE(fecha)                                  -- Un corte por día
);

-- Encabezado de la venta
CREATE TABLE Ventas(
    id INT IDENTITY PRIMARY KEY,
    cliente_id INT NULL,
    numero_orden VARCHAR(20) NOT NULL,               -- ID de referencia
    fecha_venta DATETIME DEFAULT GETDATE(),
    monto_subtotal DECIMAL(12,2) DEFAULT 0,
    monto_descuento DECIMAL(12,2) DEFAULT 0,
    monto_total DECIMAL(12,2) DEFAULT 0,
    metodo_pago VARCHAR(20) DEFAULT 'EFECTIVO',      -- Tipo de pago
    estatus_venta VARCHAR(20) NOT NULL CHECK (estatus_venta IN ('PENDIENTE','COMPLETADA','CANCELADA')),
    estatus_entrega VARCHAR(30) NOT NULL CHECK (estatus_entrega IN ('PENDIENTE','PARCIAL','COMPLETA','CANCELADA')),
    fecha_entrega DATETIME DEFAULT GETDATE(),
    notas VARCHAR(200),
    entregado_por VARCHAR(100),
    CONSTRAINT "FK_Venta_Cliente" FOREIGN KEY(cliente_id) REFERENCES Clientes(id)
);

-- Detalle por producto de cada venta
CREATE TABLE DetalleVentas(
    id INT IDENTITY PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_entregada INT DEFAULT 0,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total_linea DECIMAL(12,2) NOT NULL,
    descuento_linea DECIMAL(12,2) NOT NULL DEFAULT 0,
    estatus_entrega VARCHAR(30) NOT NULL CHECK (estatus_entrega IN ('PENDIENTE','PARCIAL','COMPLETA','CANCELADA')), 
    fecha_entrega DATETIME NULL,
    notas_entrega VARCHAR(200),
    CONSTRAINT "FK_DetalleVenta_Venta" FOREIGN KEY(venta_id) REFERENCES Ventas(id),
    CONSTRAINT "FK_DetalleVenta_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id)
);

-- Detalles de entrega de productos, por lote o directamente del stock
CREATE TABLE DetalleEntregas(
    id INT IDENTITY PRIMARY KEY,
    detalle_venta_id INT NOT NULL,
    lote_id INT NULL,
    fuente_entrega VARCHAR(20) NOT NULL CHECK (fuente_entrega IN ('LOTE', 'PRODUCTO')), -- Indica el origen del stock
    cantidad_entregada INT NOT NULL,
    fecha_entrega DATETIME DEFAULT GETDATE(),
    entregado_por VARCHAR(100),
    notas VARCHAR(200),
    CONSTRAINT "FK_DetalleEntrega_DetalleVenta" FOREIGN KEY(detalle_venta_id) REFERENCES DetalleVentas(id),
    CONSTRAINT "FK_DetalleEntrega_Lote" FOREIGN KEY(lote_id) REFERENCES LotesStock(id)
);

-- Registro de entradas, salidas o ajustes al inventario
CREATE TABLE MovimientosInventario(
    id INT IDENTITY PRIMARY KEY,
    producto_id INT NOT NULL,
    lote_id INT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('ENTRADA','SALIDA','AJUSTE')),
    cantidad INT NOT NULL,
    tipo_referencia VARCHAR(20) NOT NULL CHECK (tipo_referencia IN ('VENTA','COMPRA','AJUSTE')),
    referencia_id INT NULL,                  -- ID de venta o compra según el tipo
    notas VARCHAR(200) NULL,
    fecha_movimiento DATETIME DEFAULT GETDATE(),
    CONSTRAINT "FK_Movimiento_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id),
    CONSTRAINT "FK_Movimiento_Lote" FOREIGN KEY(lote_id) REFERENCES LotesStock(id)
);

-- Almacena correos configurados para alertas de stock
CREATE TABLE Notificacion (
    id INT IDENTITY(1,1) PRIMARY KEY,
    producto_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('LOW_STOCK', 'OUT_OF_STOCK', 'RESTOCK','NEAR_EXPIRATION','EXPIRED')), -- Tipo de alerta
    mensaje VARCHAR(255) NOT NULL,
    activo BIT DEFAULT 1,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_NotificacionStock_Producto 
        FOREIGN KEY (producto_id) REFERENCES CatalogoProductos(id),
);
