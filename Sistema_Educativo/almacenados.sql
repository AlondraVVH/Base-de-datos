-- **************************************************
-- Script 3: Creación de Procedimientos Almacenados (MEJORADO CON TRANSACCIONES Y DROP)
-- **************************************************

USE sistemaeducativo;

DELIMITER //

-- =======================================================
-- 1. PROCEDIMIENTOS PARA LA TABLA 'roles'
-- =======================================================
DROP PROCEDURE IF EXISTS SP_INSERT_ROL;
CREATE PROCEDURE SP_INSERT_ROL(IN p_nombre_rol VARCHAR(50), IN p_descripcion TEXT)
BEGIN
    START TRANSACTION;
    INSERT INTO roles (nombre_rol, descripcion)
    VALUES (p_nombre_rol, p_descripcion);
    COMMIT;
END //

DROP PROCEDURE IF EXISTS SP_DELETE_LOGIC_ROL;
CREATE PROCEDURE SP_DELETE_LOGIC_ROL(IN p_id_rol INT)
BEGIN
    UPDATE roles 
    SET deleted = 1, updated_at = CURRENT_TIMESTAMP 
    WHERE id_rol = p_id_rol;
    -- MEJORA: Informar el resultado
    SELECT ROW_COUNT() AS Filas_Afectadas;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ACTIVOS_ROLES;
CREATE PROCEDURE SP_SELECT_ACTIVOS_ROLES()
BEGIN
    SELECT id_rol, nombre_rol, descripcion, created_at FROM roles WHERE deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ALL_ROLES;
CREATE PROCEDURE SP_SELECT_ALL_ROLES()
BEGIN
    SELECT * FROM roles;
END //

-- =======================================================
-- 2. PROCEDIMIENTOS PARA LA TABLA 'usuarios'
-- =======================================================
DROP PROCEDURE IF EXISTS SP_INSERT_USUARIO;
CREATE PROCEDURE SP_INSERT_USUARIO(
    IN p_nombre_usuario VARCHAR(100), IN p_rut VARCHAR(12), IN p_nombre_completo VARCHAR(255),
    IN p_correo_electronico VARCHAR(255), IN p_hash_contrasena VARCHAR(255), IN p_id_rol INT
)
BEGIN
    -- MEJORA: Se utiliza una transacción para garantizar que todos los datos se inserten correctamente o ninguno.
    START TRANSACTION;
    INSERT INTO usuarios (nombre_usuario, rut, nombre_completo, correo_electronico, hash_contrasena, id_rol)
    VALUES (p_nombre_usuario, p_rut, p_nombre_completo, p_correo_electronico, p_hash_contrasena, p_id_rol);
    COMMIT;
END //

DROP PROCEDURE IF EXISTS SP_DELETE_LOGIC_USUARIO;
CREATE PROCEDURE SP_DELETE_LOGIC_USUARIO(IN p_id_usuario INT)
BEGIN
    UPDATE usuarios 
    SET deleted = 1, updated_at = CURRENT_TIMESTAMP 
    WHERE id_usuario = p_id_usuario;
    SELECT ROW_COUNT() AS Filas_Afectadas;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ACTIVOS_USUARIOS;
CREATE PROCEDURE SP_SELECT_ACTIVOS_USUARIOS()
BEGIN
    SELECT id_usuario, nombre_usuario, nombre_completo, correo_electronico, id_rol FROM usuarios WHERE deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ALL_USUARIOS;
CREATE PROCEDURE SP_SELECT_ALL_USUARIOS()
BEGIN
    SELECT * FROM usuarios;
END //

-- =======================================================
-- 3. PROCEDIMIENTOS PARA LA TABLA 'cursos_capacitacion'
-- =======================================================
DROP PROCEDURE IF EXISTS SP_INSERT_CURSO;
CREATE PROCEDURE SP_INSERT_CURSO(IN p_nombre_curso VARCHAR(255), IN p_descripcion TEXT)
BEGIN
    START TRANSACTION;
    INSERT INTO cursos_capacitacion (nombre_curso, descripcion) 
    VALUES (p_nombre_curso, p_descripcion);
    COMMIT;
END //

DROP PROCEDURE IF EXISTS SP_DELETE_LOGIC_CURSO;
CREATE PROCEDURE SP_DELETE_LOGIC_CURSO(IN p_id_curso INT)
BEGIN
    UPDATE cursos_capacitacion 
    SET deleted = 1, updated_at = CURRENT_TIMESTAMP 
    WHERE id_curso = p_id_curso;
    SELECT ROW_COUNT() AS Filas_Afectadas;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ACTIVOS_CURSOS;
CREATE PROCEDURE SP_SELECT_ACTIVOS_CURSOS()
BEGIN
    SELECT id_curso, nombre_curso, descripcion, activo FROM cursos_capacitacion WHERE deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ALL_CURSOS;
CREATE PROCEDURE SP_SELECT_ALL_CURSOS()
BEGIN
    SELECT * FROM cursos_capacitacion;
END //

-- =======================================================
-- 4. PROCEDIMIENTOS PARA LA TABLA 'instituciones'
-- =======================================================
DROP PROCEDURE IF EXISTS SP_INSERT_INSTITUCION;
CREATE PROCEDURE SP_INSERT_INSTITUCION(IN p_nombre VARCHAR(255), IN p_direccion VARCHAR(255), IN p_telefono VARCHAR(20))
BEGIN
    START TRANSACTION;
    INSERT INTO instituciones (nombre, direccion, telefono) 
    VALUES (p_nombre, p_direccion, p_telefono);
    COMMIT;
END //

DROP PROCEDURE IF EXISTS SP_DELETE_LOGIC_INSTITUCION;
CREATE PROCEDURE SP_DELETE_LOGIC_INSTITUCION(IN p_id_institucion INT)
BEGIN
    UPDATE instituciones 
    SET deleted = 1, updated_at = CURRENT_TIMESTAMP 
    WHERE id_institucion = p_id_institucion;
    SELECT ROW_COUNT() AS Filas_Afectadas;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ACTIVOS_INSTITUCIONES;
CREATE PROCEDURE SP_SELECT_ACTIVOS_INSTITUCIONES()
BEGIN
    SELECT id_institucion, nombre, direccion, telefono FROM instituciones WHERE deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ALL_INSTITUCIONES;
CREATE PROCEDURE SP_SELECT_ALL_INSTITUCIONES()
BEGIN
    SELECT * FROM instituciones;
END //

-- Restaurar el delimitador por defecto
DELIMITER ;