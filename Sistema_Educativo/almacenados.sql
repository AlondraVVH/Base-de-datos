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

USE sistemaeducativo;

DELIMITER //

-- =======================================================
-- 5. PROCEDIMIENTOS PARA LA TABLA 'profesores'
-- =======================================================
DROP PROCEDURE IF EXISTS SP_INSERT_PROFESOR;
CREATE PROCEDURE SP_INSERT_PROFESOR(
    IN p_id_usuario INT, 
    IN p_id_institucion INT, 
    IN p_materia VARCHAR(100), 
    IN p_edad INT
)
BEGIN
    INSERT INTO profesores (id_usuario, id_institucion, materia_impartida, edad)
    VALUES (p_id_usuario, p_id_institucion, p_materia, p_edad);
END //

DROP PROCEDURE IF EXISTS SP_DELETE_LOGIC_PROFESOR;
CREATE PROCEDURE SP_DELETE_LOGIC_PROFESOR(IN p_id_usuario INT)
BEGIN
    UPDATE profesores 
    SET deleted = 1, updated_at = CURRENT_TIMESTAMP 
    WHERE id_usuario = p_id_usuario AND deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ACTIVOS_PROFESORES;
CREATE PROCEDURE SP_SELECT_ACTIVOS_PROFESORES()
BEGIN
    SELECT p.id_usuario, u.nombre_completo, i.nombre AS institucion, p.materia_impartida, p.edad
    FROM profesores p
    JOIN usuarios u ON p.id_usuario = u.id_usuario
    LEFT JOIN instituciones i ON p.id_institucion = i.id_institucion
    WHERE p.deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ALL_PROFESORES;
CREATE PROCEDURE SP_SELECT_ALL_PROFESORES()
BEGIN
    SELECT * FROM profesores;
END //

-- =======================================================
-- 6. PROCEDIMIENTOS PARA LA TABLA 'estudiantes'
-- =======================================================
DROP PROCEDURE IF EXISTS SP_INSERT_ESTUDIANTE;
CREATE PROCEDURE SP_INSERT_ESTUDIANTE(
    IN p_id_usuario INT, 
    IN p_id_institucion INT, 
    IN p_fecha_nacimiento DATE, 
    IN p_fecha_registro DATE
)
BEGIN
    INSERT INTO estudiantes (id_usuario, id_institucion, fecha_nacimiento, fecha_registro)
    VALUES (p_id_usuario, p_id_institucion, p_fecha_nacimiento, p_fecha_registro);
END //

DROP PROCEDURE IF EXISTS SP_DELETE_LOGIC_ESTUDIANTE;
CREATE PROCEDURE SP_DELETE_LOGIC_ESTUDIANTE(IN p_id_usuario INT)
BEGIN
    UPDATE estudiantes 
    SET deleted = 1, updated_at = CURRENT_TIMESTAMP 
    WHERE id_usuario = p_id_usuario AND deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ACTIVOS_ESTUDIANTES;
CREATE PROCEDURE SP_SELECT_ACTIVOS_ESTUDIANTES()
BEGIN
    SELECT e.id_usuario, u.nombre_completo, i.nombre AS institucion, e.fecha_nacimiento, e.fecha_registro
    FROM estudiantes e
    JOIN usuarios u ON e.id_usuario = u.id_usuario
    LEFT JOIN instituciones i ON e.id_institucion = i.id_institucion
    WHERE e.deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ALL_ESTUDIANTES;
CREATE PROCEDURE SP_SELECT_ALL_ESTUDIANTES()
BEGIN
    SELECT * FROM estudiantes;
END //

-- =======================================================
-- 7. PROCEDIMIENTOS PARA LA TABLA 'contenidos'
-- =======================================================
DROP PROCEDURE IF EXISTS SP_INSERT_CONTENIDO;
CREATE PROCEDURE SP_INSERT_CONTENIDO(
    IN p_id_curso INT, 
    IN p_titulo VARCHAR(255), 
    IN p_descripcion TEXT, 
    IN p_id_tipo_contenido INT
)
BEGIN
    INSERT INTO contenidos (id_curso, titulo, descripcion, id_tipo_contenido, url_recurso, visible_para_todos)
    VALUES (p_id_curso, p_titulo, p_descripcion, p_id_tipo_contenido, NULL, 0);
END //

DROP PROCEDURE IF EXISTS SP_DELETE_LOGIC_CONTENIDO;
CREATE PROCEDURE SP_DELETE_LOGIC_CONTENIDO(IN p_id_contenido INT)
BEGIN
    UPDATE contenidos 
    SET deleted = 1, updated_at = CURRENT_TIMESTAMP 
    WHERE id_contenido = p_id_contenido AND deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ACTIVOS_CONTENIDOS;
CREATE PROCEDURE SP_SELECT_ACTIVOS_CONTENIDOS()
BEGIN
    SELECT c.id_contenido, cc.nombre_curso, c.titulo, tc.nombre_tipo
    FROM contenidos c
    JOIN cursos_capacitacion cc ON c.id_curso = cc.id_curso
    LEFT JOIN tipos_contenido tc ON c.id_tipo_contenido = tc.id_tipo_contenido
    WHERE c.deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ALL_CONTENIDOS;
CREATE PROCEDURE SP_SELECT_ALL_CONTENIDOS()
BEGIN
    SELECT * FROM contenidos;
END //

-- =======================================================
-- 8. PROCEDIMIENTOS PARA LA TABLA 'inscripcion_cursos'
-- =======================================================
DROP PROCEDURE IF EXISTS SP_INSERT_INSCRIPCION;
CREATE PROCEDURE SP_INSERT_INSCRIPCION(
    IN p_id_curso INT, 
    IN p_id_estudiante_usuario INT, 
    IN p_id_profesor_usuario INT, 
    IN p_fecha_inscripcion DATE,
    IN p_id_estado_inscripcion INT
)
BEGIN
    INSERT INTO inscripcion_cursos (id_curso, id_estudiante_usuario, id_profesor_usuario, fecha_inscripcion, id_estado_inscripcion)
    VALUES (p_id_curso, p_id_estudiante_usuario, p_id_profesor_usuario, p_fecha_inscripcion, p_id_estado_inscripcion);
END //

DROP PROCEDURE IF EXISTS SP_DELETE_LOGIC_INSCRIPCION;
CREATE PROCEDURE SP_DELETE_LOGIC_INSCRIPCION(IN p_id_curso INT, IN p_id_estudiante_usuario INT)
BEGIN
    UPDATE inscripcion_cursos 
    SET deleted = 1, updated_at = CURRENT_TIMESTAMP 
    WHERE id_curso = p_id_curso 
      AND id_estudiante_usuario = p_id_estudiante_usuario 
      AND deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ACTIVOS_INSCRIPCIONES;
CREATE PROCEDURE SP_SELECT_ACTIVOS_INSCRIPCIONES()
BEGIN
    SELECT 
        c.nombre_curso, 
        u.nombre_completo AS estudiante, 
        ei.nombre_estado AS estado,
        ic.fecha_inscripcion,
        ic.calificacion_final
    FROM inscripcion_cursos ic
    JOIN cursos_capacitacion c ON ic.id_curso = c.id_curso
    JOIN usuarios u ON ic.id_estudiante_usuario = u.id_usuario
    JOIN estados_inscripcion ei ON ic.id_estado_inscripcion = ei.id_estado_inscripcion
    WHERE ic.deleted = 0;
END //

DROP PROCEDURE IF EXISTS SP_SELECT_ALL_INSCRIPCIONES;
CREATE PROCEDURE SP_SELECT_ALL_INSCRIPCIONES()
BEGIN
    SELECT * FROM inscripcion_cursos;
END //

-- Restaurar el delimitador por defecto
DELIMITER ;

-- Restaurar el delimitador por defecto
DELIMITER ;