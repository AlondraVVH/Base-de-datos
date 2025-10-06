-- **************************************************
-- Script 2: Inserciones de Datos y Consultas de Prueba
-- Autor: [Tu Nombre]
-- Fecha: 2025-10-06
-- Objetivo: Poblar las tablas y ejecutar consultas
--           de verificación.
-- **************************************************

USE sistemaeducativo;

-- 1. Inserciones de Datos

-- Inserción en roles
INSERT INTO roles (id_rol, nombre_rol) VALUES
(1, 'Administrador'),
(2, 'Profesor'),
(3, 'Estudiante');

-- Inserción en instituciones
INSERT INTO instituciones (id_institucion, nombre, direccion) VALUES
(101, 'Colegio A', 'Calle Falsa 123'),
(102, 'Liceo B', 'Avenida Siempreviva 742');

-- Inserción en usuarios (Profesor y Estudiantes)
INSERT INTO usuarios (id_usuario, nombre_usuario, rut, nombre_completo, correo_electronico, hash_contrasena, id_rol) VALUES
(201, 'jperalta', '12345678-9', 'Javier Peralta', 'j.peralta@mail.com', 'hash_profesor', 2),
(301, 'sofiadiaz', '20111222-3', 'Sofia Diaz', 's.diaz@mail.com', 'hash_estudiante_1', 3),
(302, 'carlosm', '21333444-5', 'Carlos Moya', 'c.moya@mail.com', 'hash_estudiante_2', 3),
(303, 'e_eliminado', '22444555-6', 'Estudiante Eliminado', 'e.el@mail.com', 'hash_eliminado', 3);

-- Inserción de un usuario "eliminado" (Soft Delete) para la prueba
UPDATE usuarios SET deleted = 1 WHERE id_usuario = 303;

-- Inserción en profesores
INSERT INTO profesores (id_usuario, id_institucion, materia_impartida) VALUES
(201, 101, 'Bases de Datos');

-- Inserción en estudiantes
INSERT INTO estudiantes (id_usuario, id_institucion, fecha_nacimiento, fecha_registro) VALUES
(301, 101, '2000-05-15', CURDATE()),
(302, 102, '1999-11-20', CURDATE());

-- Inserción en cursos_capacitacion
INSERT INTO cursos_capacitacion (id_curso, nombre_curso, activo) VALUES
(401, 'SQL y Modelado Avanzado', 1),
(402, 'Desarrollo de Software', 1);

-- Inserción en inscripcion_cursos
INSERT INTO inscripcion_cursos (id_curso, id_estudiante_usuario, id_profesor_usuario, fecha_inscripcion, estado) VALUES
(401, 301, 201, '2025-03-01', 'En Progreso'),
(401, 302, 201, '2025-03-01', 'Finalizado');

-- Actualizar una calificación final para la prueba CHECK implícita (DECIMAL(5,2))
UPDATE inscripcion_cursos SET calificacion_final = 6.85 WHERE id_curso = 401 AND id_estudiante_usuario = 302;


-- 2. Consultas de Verificación

-- 2.1. SELECT * FROM tabla; para comprobar registros.
SELECT * FROM usuarios;
SELECT * FROM inscripcion_cursos;

-- 2.2. SELECT * FROM tabla WHERE deleted = 0; para mostrar solo los registros activos.
-- Muestra solo los usuarios activos (deleted = 0)
SELECT id_usuario, nombre_completo, rut, deleted
FROM usuarios
WHERE deleted = 0;

-- 2.3. Consultas adicionales que validen relaciones o condiciones definidas.

-- A) Validación de Relación N:M (Inscripción y Profesor)
-- Muestra el progreso de los estudiantes en un curso específico, incluyendo el profesor supervisor.
SELECT
    E.nombre_completo AS Estudiante,
    C.nombre_curso AS Curso,
    P.nombre_completo AS Profesor_Supervisor,
    IC.estado
FROM inscripcion_cursos IC
JOIN usuarios E ON IC.id_estudiante_usuario = E.id_usuario
JOIN usuarios P ON IC.id_profesor_usuario = P.id_usuario
JOIN cursos_capacitacion C ON IC.id_curso = C.id_curso
WHERE IC.deleted = 0
ORDER BY C.nombre_curso, E.nombre_completo;

-- B) Validación de la condición ENUM (estados de inscripción)
-- Muestra cuántos estudiantes están 'Finalizado' o 'En Progreso' por curso.
SELECT
    C.nombre_curso,
    IC.estado,
    COUNT(IC.id_estudiante_usuario) AS Total
FROM inscripcion_cursos IC
JOIN cursos_capacitacion C ON IC.id_curso = C.id_curso
GROUP BY C.nombre_curso, IC.estado
HAVING IC.estado IN ('Finalizado', 'En Progreso');