-- **************************************************
-- Script 1: Creación de la Base de Datos y Tablas (NORMALIZADO CON CHECK MEJORADO)
-- **************************************************

CREATE DATABASE IF NOT EXISTS sistemaeducativo;
USE sistemaeducativo;

-- --------------------------------------------------
-- 1. TABLAS DE CATÁLOGO
-- --------------------------------------------------

CREATE TABLE estados_inscripcion (
    id_estado_inscripcion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tipos_contenido (
    id_tipo_contenido INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE estados_progreso (
    id_estado_progreso INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------
-- 2. TABLAS BASE
-- --------------------------------------------------

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
    
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    -- MEJORA: Restricción CHECK explícita para el formato mínimo del RUT.
    CONSTRAINT chk_rut_formato CHECK (LENGTH(rut) >= 7)
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
    FOREIGN KEY (id_institucion) REFERENCES instituciones(id_institucion),
    -- MEJORA: Restricción CHECK para asegurar una edad realista.
    CONSTRAINT chk_edad_profesor CHECK (edad > 20 AND edad < 100)
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

-- --- Tabla 8: inscripcion_cursos ---
CREATE TABLE inscripcion_cursos (
    id_curso INT NOT NULL,
    id_estudiante_usuario INT NOT NULL,
    id_profesor_usuario INT,
    fecha_inscripcion DATE NOT NULL,
    id_estado_inscripcion INT NOT NULL,
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
    FOREIGN KEY (id_estado_inscripcion) REFERENCES estados_inscripcion(id_estado_inscripcion),
    -- Restricción CHECK explícita para rango de calificación.
    CONSTRAINT chk_calificacion_rango CHECK (calificacion_final IS NULL OR (calificacion_final >= 1.0 AND calificacion_final <= 7.0))
);

-- --- Tabla 9: contenidos ---
CREATE TABLE contenidos (
    id_contenido INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_curso INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    id_tipo_contenido INT,
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

-- --- Tabla 10: progreso_contenido_estudiante ---
CREATE TABLE progreso_contenido_estudiante (
    id_estudiante_usuario INT NOT NULL,
    id_contenido INT NOT NULL,
    fecha_ultima_acceso DATETIME,
    fecha_completado DATETIME NULL,
    calificacion DECIMAL(5, 2) NULL,
    id_estado_progreso INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_estudiante_usuario, id_contenido),
    FOREIGN KEY (id_estudiante_usuario) REFERENCES estudiantes(id_usuario),
    FOREIGN KEY (id_contenido) REFERENCES contenidos(id_contenido),
    FOREIGN KEY (id_estado_progreso) REFERENCES estados_progreso(id_estado_progreso)
);