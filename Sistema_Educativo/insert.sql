-- **************************************************
-- Script 2: Inserciones de Datos y Consultas de Prueba (NORMALIZADO)
-- Autor: [Tu Nombre]
-- Fecha: 2025-10-06
-- Objetivo: Poblar las tablas de catálogo y ejecutar inserciones/consultas
--           utilizando los IDs de las nuevas tablas de catálogo.
-- **************************************************

USE sistemaeducativo;

-- 1. Inserción de Datos de Catálogo (Reemplazando ENUMs)

-- Inserción en estados_inscripcion (Reemplazo de ENUM en inscripcion_cursos)
INSERT INTO estados_inscripcion (id_estado_inscripcion, nombre_estado) VALUES
(1, 'Inscrito'),
(2, 'En Progreso'),
(3, 'Finalizado'),
(4, 'Anulado');

-- Inserción en tipos_contenido (Reemplazo de ENUM en contenidos)
INSERT INTO tipos_contenido (id_tipo_contenido, nombre_tipo) VALUES
(1, 'Video'),
(2, 'Documento'),
(3, 'Quiz'),
(4, 'Actividad');

-- Inserción en estados_progreso (Reemplazo de ENUM en progreso_contenido_estudiante)
INSERT INTO estados_progreso (id_estado_progreso, nombre_estado) VALUES
(1, 'No Iniciado'),
(2, 'En Progreso'),
(3, 'Completado');


-- 2. Inserciones en Tablas Base (Mismas inserciones que en el ejemplo anterior)

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

-- 3. Inserciones en Tablas Relacionales (Usando IDs de Catálogo)

-- Inserción en contenidos
-- Contenido 1: Tipo Video (ID 1), Contenido 2: Tipo Quiz (ID 3)
INSERT INTO contenidos (id_contenido, id_curso, titulo, id_tipo_contenido) VALUES
(501, 401, 'Introducción a la Normalización', 1),
(502, 401, 'Quiz sobre Tablas de Catálogo', 3);


-- Inserción en inscripcion_cursos
-- Sofia: En Progreso (ID 2), Carlos: Finalizado (ID 3)
INSERT INTO inscripcion_cursos (id_curso, id_estudiante_usuario, id_profesor_usuario, fecha_inscripcion, id_estado_inscripcion) VALUES
(401, 301, 201, '2025-03-01', 2), -- 'En Progreso'
(401, 302, 201, '2025-03-01', 3); -- 'Finalizado'

-- Actualizar una calificación final
UPDATE inscripcion_cursos SET calificacion_final = 6.85 WHERE id_curso = 401 AND id_estudiante_usuario = 302;

-- Inserción en progreso_contenido_estudiante
-- Sofia: Progreso en Contenido 501: Completado (ID 3)
INSERT INTO progreso_contenido_estudiante (id_estudiante_usuario, id_contenido, id_estado_progreso, fecha_completado) VALUES
(301, 501, 3, NOW()); -- 'Completado'

-- Carlos: Progreso en Contenido 501: No Iniciado (ID 1)
INSERT INTO progreso_contenido_estudiante (id_estudiante_usuario, id_contenido, id_estado_progreso) VALUES
(302, 501, 1); -- 'No Iniciado'


-- 4. Consultas de Verificación (Ajustadas para Joins)

-- 4.1. SELECT * FROM tabla; para comprobar registros.
SELECT * FROM estados_inscripcion;
SELECT * FROM inscripcion_cursos;


-- 4.2. SELECT * FROM tabla WHERE deleted = 0; para mostrar solo los registros activos.
-- Muestra solo los usuarios activos (deleted = 0)
SELECT id_usuario, nombre_completo, rut, deleted
FROM usuarios
WHERE deleted = 0;


-- 4.3. Consultas adicionales que validen relaciones o condiciones definidas.

-- A) Validación de Relación N:M y Catálogo (Estado de Inscripción)
-- Muestra los estudiantes inscritos y su estado de inscripción, utilizando el JOIN a la tabla de catálogo.
SELECT
    E.nombre_completo AS Estudiante,
    C.nombre_curso AS Curso,
    EI.nombre_estado AS Estado_Inscripcion,
    IC.calificacion_final
FROM inscripcion_cursos IC
JOIN usuarios E ON IC.id_estudiante_usuario = E.id_usuario
JOIN cursos_capacitacion C ON IC.id_curso = C.id_curso
JOIN estados_inscripcion EI ON IC.id_estado_inscripcion = EI.id_estado_inscripcion
WHERE IC.deleted = 0
ORDER BY Estado_Inscripcion DESC, Estudiante;

-- B) Validación de Relación N:M y Catálogo (Tipos de Contenido y Progreso)
-- Muestra el progreso de los estudiantes en contenidos, incluyendo el tipo de contenido y el estado de avance.
SELECT
    U.nombre_completo AS Estudiante,
    CON.titulo AS Contenido,
    TC.nombre_tipo AS Tipo_Recurso,
    EP.nombre_estado AS Estado_Avance
FROM progreso_contenido_estudiante PCE
JOIN usuarios U ON PCE.id_estudiante_usuario = U.id_usuario
JOIN contenidos CON ON PCE.id_contenido = CON.id_contenido
JOIN tipos_contenido TC ON CON.id_tipo_contenido = TC.id_tipo_contenido
JOIN estados_progreso EP ON PCE.id_estado_progreso = EP.id_estado_progreso
ORDER BY Estudiante, Tipo_Recurso;