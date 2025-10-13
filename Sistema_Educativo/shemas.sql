-- **************************************************
-- Script 1: Creación de la Base de Datos y Tablas (NORMALIZADO CON CATALOGOS)
-- Autor: [Tu Nombre]
-- Fecha: 2025-10-06
-- Objetivo: Crear el esquema 'sistemaeducativo' reemplazando los tipos ENUM
--           por tablas de catálogo para mayor flexibilidad.
-- **************************************************

CREATE DATABASE IF NOT EXISTS sistemaeducativo;
USE sistemaeducativo;

-- --------------------------------------------------
-- 1. TABLAS DE CATÁLOGO (Reemplazando ENUM)
-- --------------------------------------------------

-- --- Nueva Tabla: estados_inscripcion ---
-- Catálogo de posibles estados para una matrícula en un curso.
CREATE TABLE estados_inscripcion (
    id_estado_inscripcion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE, -- Ej: 'Inscrito', 'Finalizado'
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --- Nueva Tabla: tipos_contenido ---
-- Catálogo de posibles tipos de recursos dentro de un curso.
CREATE TABLE tipos_contenido (
    id_tipo_contenido INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE, -- Ej: 'Video', 'Documento', 'Quiz'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --- Nueva Tabla: estados_progreso ---
-- Catálogo de posibles estados de avance de un estudiante en un contenido.
CREATE TABLE estados_progreso (
    id_estado_progreso INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE, -- Ej: 'No Iniciado', 'Completado'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------
-- 2. TABLAS BASE
-- --------------------------------------------------

-- Las tablas 'roles', 'usuarios', 'instituciones', 'profesores',
-- 'estudiantes' y 'relacion_profesor_estudiante' permanecen sin cambios
-- ya que no contenían campos ENUM que deban ser normalizados.

-- --- Tabla 1: roles ---
CREATE TABLE roles (
    id_rol INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT(1) DEFAULT 0
);

-- --- Tabla 2: usuarios ---
CREATE TABLE usuarios (
    id_usuario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(100) NOT NULL UNIQUE,
    rut VARCHAR(12) UNIQUE,
    nombre_completo VARCHAR(255) NOT NULL,
    correo_electronico VARCHAR(255) UNIQUE,
    hash_contrasena VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    activo TINYINT(1) DEFAULT 1,
    ultimo_acceso TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted TINYINT(1) DEFAULT 0,
    
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

-- --- Tabla 3: instituciones ---
CREATE TABLE instituciones (
    id_institucion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    direccion VARCHAR(255),
    correo_contacto VARCHAR(255),
    telefono VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted TINYINT(1) DEFAULT 0
);

-- --- Tabla 4: profesores ---
CREATE TABLE profesores (
    id_usuario INT NOT NULL PRIMARY KEY,
    id_institucion INT,
    materia_impartida VARCHAR(100),
    edad INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted TINYINT(1) DEFAULT 0,
    
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_institucion) REFERENCES instituciones(id_institucion)
);

-- --- Tabla 5: estudiantes ---
CREATE TABLE estudiantes (
    id_usuario INT NOT NULL PRIMARY KEY,
    id_institucion INT,
    fecha_nacimiento DATE,
    fecha_registro DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted TINYINT(1) DEFAULT 0,
    
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_institucion) REFERENCES instituciones(id_institucion)
);

-- --- Tabla 6: relacion_profesor_estudiante ---
CREATE TABLE relacion_profesor_estudiante (
    id_profesor_usuario INT NOT NULL,
    id_estudiante_usuario INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    
    PRIMARY KEY (id_profesor_usuario, id_estudiante_usuario),
    FOREIGN KEY (id_profesor_usuario) REFERENCES profesores(id_usuario),
    FOREIGN KEY (id_estudiante_usuario) REFERENCES estudiantes(id_usuario)
);

-- --- Tabla 7: cursos_capacitacion ---
CREATE TABLE cursos_capacitacion (
    id_curso INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_curso VARCHAR(255) NOT NULL,
    descripcion TEXT,
    activo TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted TINYINT(1) DEFAULT 0
);

-- --------------------------------------------------
-- 3. TABLAS CON REFERENCIAS A CATÁLOGOS
-- --------------------------------------------------

-- --- Tabla 8: inscripcion_cursos (MODIFICADA) ---
-- El campo 'estado' ahora es 'id_estado_inscripcion' con clave foránea.
CREATE TABLE inscripcion_cursos (
    id_curso INT NOT NULL,
    id_estudiante_usuario INT NOT NULL,
    id_profesor_usuario INT,
    fecha_inscripcion DATE NOT NULL,
    id_estado_inscripcion INT NOT NULL, -- REEMPLAZA ENUM('Inscrito', 'En Progreso', 'Finalizado', 'Anulado')
    calificacion_final DECIMAL(5, 2) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted TINYINT(1) DEFAULT 0,
    
    PRIMARY KEY (id_curso, id_estudiante_usuario),
    FOREIGN KEY (id_curso) REFERENCES cursos_capacitacion(id_curso),
    FOREIGN KEY (id_estudiante_usuario) REFERENCES estudiantes(id_usuario),
    FOREIGN KEY (id_profesor_usuario) REFERENCES profesores(id_usuario),
    FOREIGN KEY (id_estado_inscripcion) REFERENCES estados_inscripcion(id_estado_inscripcion)
);

-- --- Tabla 9: contenidos (MODIFICADA) ---
-- El campo 'tipo_contenido' ahora es 'id_tipo_contenido' con clave foránea.
CREATE TABLE contenidos (
    id_contenido INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_curso INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    id_tipo_contenido INT, -- REEMPLAZA ENUM('Video', 'Documento', 'Quiz', 'Actividad')
    url_recurso VARCHAR(2048),
    visible_para_todos TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    deleted TINYINT(1) DEFAULT 0,
    
    FOREIGN KEY (id_curso) REFERENCES cursos_capacitacion(id_curso),
    FOREIGN KEY (id_tipo_contenido) REFERENCES tipos_contenido(id_tipo_contenido)
);

-- --- Tabla 10: progreso_contenido_estudiante (MODIFICADA) ---
-- El campo 'estado_progreso' ahora es 'id_estado_progreso' con clave foránea.
CREATE TABLE progreso_contenido_estudiante (
    id_estudiante_usuario INT NOT NULL,
    id_contenido INT NOT NULL,
    fecha_ultima_acceso DATETIME,
    fecha_completado DATETIME NULL,
    calificacion DECIMAL(5, 2) NULL,
    id_estado_progreso INT NOT NULL, -- REEMPLAZA ENUM('No Iniciado', 'En Progreso', 'Completado')
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_estudiante_usuario, id_contenido),
    FOREIGN KEY (id_estudiante_usuario) REFERENCES estudiantes(id_usuario),
    FOREIGN KEY (id_contenido) REFERENCES contenidos(id_contenido),
    FOREIGN KEY (id_estado_progreso) REFERENCES estados_progreso(id_estado_progreso)
);