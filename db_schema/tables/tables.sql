CREATE TABLE CatalogoCategorias(
    id SMALLINT IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    img VARCHAR(512) NULL,
    activo BIT DEFAULT 1
);

CREATE TABLE CatalogoProductos(
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria_id SMALLINT,
    precio DECIMAL(10,2) DEFAULT 0,
    costo_promedio DECIMAL(10,2) DEFAULT 0,
    img VARCHAR(512) NULL,
    promocion BIT DEFAULT 0,
    agotado BIT DEFAULT 0,
    umbral_inventario INT DEFAULT 5,
    requiere_vencimiento BIT DEFAULT 0,
    activo BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT "FK_Categoria_Producto" FOREIGN KEY(categoria_id) REFERENCES CatalogoCategorias(id)
);

CREATE TABLE Proveedores(
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) DEFAULT '',
    empresa VARCHAR(100) DEFAULT '',
    telefono VARCHAR(15) DEFAULT '',
    email VARCHAR(100) DEFAULT '',
    activo BIT DEFAULT 1
);

CREATE TABLE ProductoProveedores(
    id INT IDENTITY PRIMARY KEY,
    proveedor_id INT NOT NULL,
    producto_id INT NOT NULL,
    codigo_proveedor VARCHAR(100) DEFAULT '',
    precio_costo DECIMAL(10,2) DEFAULT 0,
    es_proveedor_principal BIT DEFAULT 0,
    CONSTRAINT "FK_ProductoProveedor_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id),
    CONSTRAINT "FK_ProductoProveedor_Proveedor" FOREIGN KEY(proveedor_id) REFERENCES Proveedores(id)
);

CREATE TABLE LotesStock(
    id INT IDENTITY PRIMARY KEY,
    producto_id INT NOT NULL,
    numero_lote VARCHAR(50),
    fecha_vencimiento DATE NULL,
    precio_costo DECIMAL(10,2) NOT NULL,
    cantidad_recibida INT NOT NULL,
    cantidad_restante INT NOT NULL,
    fecha_recepcion DATETIME DEFAULT GETDATE(),
    proveedor_id INT NULL,
    CONSTRAINT "FK_LoteStock_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id),
    CONSTRAINT "FK_LoteStock_Proveedor" FOREIGN KEY(proveedor_id) REFERENCES Proveedores(id)
);

CREATE TABLE StockProductos(
    id INT IDENTITY PRIMARY KEY,
    producto_id INT NOT NULL,
    cantidad_disponible INT DEFAULT 0,
    cantidad_reservada INT DEFAULT 0,
    ultima_actualizacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT "FK_Stock_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id)
);

CREATE TABLE Clientes(
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) DEFAULT '',
    telefono VARCHAR(15) DEFAULT '',
    email VARCHAR(100) DEFAULT '',
    activo BIT DEFAULT 1
);

CREATE TABLE CorteCaja(
    id INT IDENTITY PRIMARY KEY,
    fecha DATE NOT NULL,
    saldo_inicial DECIMAL(12,2) DEFAULT 0,
    total_ventas DECIMAL(12,2) DEFAULT 0,
    efectivo_recibido DECIMAL(12,2) DEFAULT 0,
    saldo_final DECIMAL(12,2) DEFAULT 0,
    notas VARCHAR(200),
    cerrado_por VARCHAR(100),
    fecha_cierre DATETIME,
    UNIQUE(fecha)
);

CREATE TABLE Ventas(
    id INT IDENTITY PRIMARY KEY,
    cliente_id INT NULL,
    numero_orden VARCHAR(20) NOT NULL,
    fecha_venta DATETIME DEFAULT GETDATE(),
    monto_total DECIMAL(12,2) DEFAULT 0,
    metodo_pago VARCHAR(20) DEFAULT 'EFECTIVO',
    estatus_venta VARCHAR(20) DEFAULT 'COMPLETADA', -- PENDIENTE, COMPLETADA, CANCELADA
    estatus_entrega VARCHAR(30) DEFAULT 'ENTREGADA', -- PENDIENTE, PARCIAL, COMPLETA, CANCELADA
    fecha_entrega DATETIME DEFAULT GETDATE(),
    notas VARCHAR(200),
    entregado_por VARCHAR(100),
    CONSTRAINT "FK_Venta_Cliente" FOREIGN KEY(cliente_id) REFERENCES Clientes(id)
);

CREATE TABLE DetalleVentas(
    id INT IDENTITY PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_entregada INT DEFAULT 0,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total_linea DECIMAL(12,2) NOT NULL,
    estatus_entrega VARCHAR(30) DEFAULT 'PENDIENTE', -- PENDIENTE, PARCIAL, COMPLETA, CANCELADA
    fecha_entrega DATETIME NULL,
    notas_entrega VARCHAR(200),
    CONSTRAINT "FK_DetalleVenta_Venta" FOREIGN KEY(venta_id) REFERENCES Ventas(id),
    CONSTRAINT "FK_DetalleVenta_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id)
);

CREATE TABLE DetalleEntregas(
    id INT IDENTITY PRIMARY KEY,
    detalle_venta_id INT NOT NULL,
    lote_id INT NULL,
    fuente_entrega VARCHAR(20) NOT NULL CHECK (fuente_entrega IN ('LOTE', 'PRODUCTO')),
    cantidad_entregada INT NOT NULL,
    fecha_entrega DATETIME DEFAULT GETDATE(),
    entregado_por VARCHAR(100),
    notas VARCHAR(200),
    CONSTRAINT "FK_DetalleEntrega_DetalleVenta" FOREIGN KEY(detalle_venta_id) REFERENCES DetalleVentas(id),
    CONSTRAINT "FK_DetalleEntrega_Lote" FOREIGN KEY(lote_id) REFERENCES LotesStock(id)
);

CREATE TABLE MovimientosInventario(
    id INT IDENTITY PRIMARY KEY,
    producto_id INT NOT NULL,
    lote_id INT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL, -- ENTRADA, SALIDA, AJUSTE
    cantidad INT NOT NULL,
    tipo_referencia VARCHAR(20), -- VENTA, COMPRA, AJUSTE
    referencia_id INT NULL,
    notas VARCHAR(200),
    fecha_movimiento DATETIME DEFAULT GETDATE(),
    CONSTRAINT "FK_Movimiento_Producto" FOREIGN KEY(producto_id) REFERENCES CatalogoProductos(id),
    CONSTRAINT "FK_Movimiento_Lote" FOREIGN KEY(lote_id) REFERENCES LotesStock(id)
);



CREATE TABLE NotificacionStock (
    id INT IDENTITY(1,1) PRIMARY KEY,
    producto_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('LOW_STOCK', 'OUT_OF_STOCK', 'RESTOCK')),
    activo BIT DEFAULT 1,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_NotificacionStock_Producto 
        FOREIGN KEY (producto_id) REFERENCES CatalogoProductos(id),
    CONSTRAINT UQ_NotificacionStock_Email_Producto_Tipo 
        UNIQUE (producto_id, email, tipo)
);