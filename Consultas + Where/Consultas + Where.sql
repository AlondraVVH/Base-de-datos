-- Crear la base de datos
CREATE DATABASE sistema_ventas_4c;

-- Seleccionar la base de datos para trabajar
USE sistema_ventas_4c;

-- Crear la tabla tipo_usuarios
CREATE TABLE tipo_usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted BOOLEAN DEFAULT FALSE
);

-- Crear la tabla usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE,
    password VARCHAR(100),
    tipo_usuario_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted BOOLEAN DEFAULT FALSE
);

-- Crear la tabla productos
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_productos VARCHAR(100) NOT NULL,
    descripcion VARCHAR(300),
    precio_productos DECIMAL(10,2) NOT NULL,
    stock_productos INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted BOOLEAN DEFAULT FALSE
);

-- Crear la tabla ventas
CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted BOOLEAN DEFAULT FALSE
);

-- Crear la tabla detalle_ventas
CREATE TABLE detalle_ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted BOOLEAN DEFAULT FALSE
);

-- Agregar claves foráneas
ALTER TABLE usuarios
ADD CONSTRAINT fk_usuario_tipo_usuario
FOREIGN KEY (tipo_usuario_id) REFERENCES tipo_usuarios(id);

ALTER TABLE ventas
ADD CONSTRAINT fk_venta_usuario
FOREIGN KEY (usuario_id) REFERENCES usuarios(id);

ALTER TABLE detalle_ventas
ADD CONSTRAINT fk_detalle_venta
FOREIGN KEY (venta_id) REFERENCES ventas(id);

ALTER TABLE detalle_ventas
ADD CONSTRAINT fk_detalle_producto
FOREIGN KEY (producto_id) REFERENCES productos(id);

-- Inserciones
INSERT INTO usuarios (nombre, correo, password, tipo_usuario_id, created_by, updated_by)
VALUES (
    'sistema',
    'sistema@empresa.cl',
    '$2y$10$2pEjT0G2k9YzHs1oZ.abcde3Y8GkmHfvhO1/abcxyz', 
    NULL,
    NULL,
    NULL
);

-- Tipos de usuario
INSERT INTO tipo_usuarios (nombre_tipo, created_by, updated_by)
VALUES 
('Administrador', 1, 1),
('Vendedor', 1, 1);

-- Usuarios reales
INSERT INTO usuarios (nombre, correo, password, tipo_usuario_id, created_by, updated_by)
VALUES 
('Claudia Rivas', 'claudia.rivas@empresa.cl', '$2y$10$kCm1S6uRfMcc6wFQ7SmG7OYOf0e1G9YaUB9JJkSBdn3Jvym2cGEpW', 1, 1, 1),
('Luis Paredes', 'luis.paredes@empresa.cl', '$2y$10$pt8U6u62AQaeHu1tcfq0Qevs5sLkINyozZ4EM9ZJ0xzEyb5EJhVSu', 2, 1, 1),
('Marta Soto', 'marta.soto@empresa.cl', '$2y$10$yC0jE5Q.DkBTq9hCjU1jIeyAen19D7ZLjZ6vT2BwMiVfbd5FFbiwS', 2, 1, 1);

-- Productos
INSERT INTO productos (nombre_productos, descripcion, precio_productos, stock_productos, created_by, updated_by)
VALUES
('Laptop HP 14"', 'Laptop con procesador AMD Ryzen 5, 8GB RAM, 256GB SSD.', 459990, 15, 1, 1),
('Mouse Logitech M185', 'Mouse inalámbrico con receptor USB, color gris.', 12990, 50, 1, 1),
('Monitor LG 24"', 'Monitor IPS Full HD de 24 pulgadas con HDMI y VGA.', 119990, 20, 1, 1);

-- Ventas
INSERT INTO ventas (usuario_id, created_by, updated_by)
VALUES
(2, 1, 1),
(3, 1, 1);

-- Insertar detalles de ventas
INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, created_by, updated_by)
VALUES
(1, 1, 1, 459990, 1, 1), -- 1 Laptop HP
(1, 2, 2, 12990, 1, 1),  -- 2 Mouse Logitech
(2, 3, 1, 119990, 1, 1); -- 1 Monitor LG


-- Consultas

-- a. Usuarios activos
SELECT * FROM usuarios WHERE deleted = FALSE;

-- b. Usuarios con tipo "Administrador"
SELECT u.*
FROM usuarios u
JOIN tipo_usuarios t ON u.tipo_usuario_id = t.id
WHERE t.nombre_tipo = 'Administrador';

-- c. Usuarios cuyo nombre empieza con "M"
SELECT nombre FROM usuarios WHERE nombre LIKE 'M%';

-- d. Usuarios creados entre el 19 de mayo y el 3 de junio de 2025
SELECT * FROM usuarios
WHERE DATE(created_at) BETWEEN '2025-05-19' AND '2025-06-05';

-- 1. Usuarios tipo "Cliente" (si se agrega) o con "Marta" en su nombre
SELECT nombre, tipo_usuario_id
FROM usuarios
WHERE tipo_usuario_id = 3 OR nombre LIKE '%Marta%';



-- 2. Productos con stock bajo o eliminados
SELECT nombre_productos, stock_productos
FROM productos
WHERE stock_productos < 20 OR deleted = TRUE;

-- 3. Ventas del usuario con ID 1 no eliminadas
SELECT * FROM ventas WHERE usuario_id = 2 AND deleted = FALSE;

-- 4. Productos cuyo nombre comienza con "M"
SELECT nombre_productos, precio_productos
FROM productos
WHERE nombre_productos LIKE 'M%';

-- 5. Detalles de ventas con precio mayor a 5000
SELECT * FROM detalle_ventas WHERE precio_unitario > 5000;
